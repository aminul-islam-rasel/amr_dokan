from collections import defaultdict
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, ConfigDict, EmailStr, Field
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_current_admin
from app.core.security import hash_password
from app.db.session import get_db
from app.models.category import ProductCategory
from app.models.customer import Customer
from app.models.due_payment import DuePayment
from app.models.expense import Expense
from app.models.product import Product
from app.models.sale import Sale
from app.models.shop import Shop
from app.models.user import User
from app.schemas.auth import UserResponse
from app.schemas.sale import SaleResponse
from app.api.routes.sales import format_sale_response

router = APIRouter(prefix="/admin", tags=["Admin Management"])


# --- Schemas for Admin Operations ---

class AdminUserCreateRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)
    full_name: str = Field(min_length=2, max_length=120)
    phone: Optional[str] = Field(default=None, max_length=30)
    role: str = Field(default="owner")  # admin, owner, manager, staff
    is_active: bool = True
    is_email_verified: bool = True


class AdminUserUpdateRequest(BaseModel):
    full_name: Optional[str] = Field(default=None, max_length=120)
    phone: Optional[str] = Field(default=None, max_length=30)
    role: Optional[str] = None
    is_active: Optional[bool] = None
    is_email_verified: Optional[bool] = None
    password: Optional[str] = Field(default=None, min_length=6, max_length=128)


class AdminOrderStatusUpdateRequest(BaseModel):
    status: str = Field(pattern="^(completed|pending|processing|delivered|cancelled)$")
    payment_method: Optional[str] = None
    notes: Optional[str] = None


class AdminSettingsPayload(BaseModel):
    company_name: str = "Amar Dokan"
    contact_email: str = "support@amardokan.com"
    contact_phone: str = "+880 1700-000000"
    currency: str = "BDT"
    tax_rate: float = 0.0
    invoice_footer: str = "Thank you for shopping with Amar Dokan!"


# In-memory settings store for dev/production simplicity
SYSTEM_SETTINGS = {
    "company_name": "Amar Dokan",
    "contact_email": "support@amardokan.com",
    "contact_phone": "+880 1700-000000",
    "currency": "BDT",
    "tax_rate": 0.0,
    "invoice_footer": "Thank you for shopping with Amar Dokan!",
}


# --- 1. Admin Dashboard Stats & Analytics ---

@router.get("/stats")
def get_admin_dashboard_stats(
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    total_users = db.scalar(select(func.count(User.id))) or 0
    total_shops = db.scalar(select(func.count(Shop.id))) or 0
    total_products = db.scalar(select(func.count(Product.id))) or 0
    total_orders = db.scalar(select(func.count(Sale.id))) or 0
    total_revenue = db.scalar(select(func.coalesce(func.sum(Sale.total), 0.0))) or 0.0
    total_due = db.scalar(select(func.coalesce(func.sum(Customer.total_due), 0.0))) or 0.0
    total_expenses = db.scalar(select(func.coalesce(func.sum(Expense.amount), 0.0))) or 0.0

    # Calculate net profit
    sales_all = db.scalars(select(Sale)).all()
    gross_profit = 0.0
    for s in sales_all:
        for item in s.items:
            item_profit = (item.unit_price - item.purchase_price) * item.quantity - item.discount
            gross_profit += max(0.0, item_profit)
        gross_profit -= s.discount
    net_profit = round(max(0.0, gross_profit - total_expenses), 2)

    # Order statistics
    completed_orders = db.scalar(select(func.count(Sale.id)).where(Sale.status == "completed")) or 0
    pending_orders = db.scalar(select(func.count(Sale.id)).where(Sale.status == "pending")) or 0
    cancelled_orders = db.scalar(select(func.count(Sale.id)).where(Sale.status == "cancelled")) or 0

    # Recent Orders (last 8)
    recent_sales_models = db.scalars(select(Sale).order_by(Sale.created_at.desc()).limit(8)).all()
    recent_orders = [
        {
            "id": s.id,
            "invoice_no": s.invoice_no,
            "shop_id": s.shop_id,
            "customer_name": s.customer_name or "Cash Customer",
            "customer_phone": s.customer_phone or "N/A",
            "total": s.total,
            "paid": s.paid,
            "due": s.due,
            "status": s.status,
            "payment_method": s.payment_method,
            "items_count": len(s.items),
            "created_at": s.created_at.isoformat(),
        }
        for s in recent_sales_models
    ]

    # Recent Activities (combining users, shops, sales, dues)
    activities = []
    for s in recent_sales_models[:5]:
        activities.append({
            "id": f"sale_{s.id}",
            "type": "order",
            "title": f"Order #{s.invoice_no}",
            "description": f"New order of ৳{s.total:,.2f} by {s.customer_name or 'Cash Customer'}",
            "timestamp": s.created_at.isoformat(),
        })

    recent_users = db.scalars(select(User).order_by(User.created_at.desc()).limit(3)).all()
    for u in recent_users:
        activities.append({
            "id": f"user_{u.id}",
            "type": "user",
            "title": f"User Registered: {u.full_name}",
            "description": f"New account registered with role '{u.role}'",
            "timestamp": u.created_at.isoformat(),
        })

    recent_dues = db.scalars(select(DuePayment).order_by(DuePayment.created_at.desc()).limit(3)).all()
    for dp in recent_dues:
        activities.append({
            "id": f"due_{dp.id}",
            "type": "payment",
            "title": f"Due Payment: ৳{dp.amount:,.2f}",
            "description": dp.note or "Due payment received",
            "timestamp": dp.created_at.isoformat(),
        })

    activities.sort(key=lambda x: x["timestamp"], reverse=True)

    # Sales Analytics for Chart (last 14 days)
    now = datetime.now(timezone.utc)
    fourteen_days_ago = now - timedelta(days=14)
    sales_trend = db.scalars(select(Sale).where(Sale.created_at >= fourteen_days_ago)).all()

    daily_map = defaultdict(lambda: {"revenue": 0.0, "orders": 0, "profit": 0.0})
    for day_offset in range(14, -1, -1):
        d_str = (now - timedelta(days=day_offset)).strftime("%Y-%m-%d")
        daily_map[d_str] = {"revenue": 0.0, "orders": 0, "profit": 0.0}

    for s in sales_trend:
        d_str = s.created_at.strftime("%Y-%m-%d")
        daily_map[d_str]["revenue"] += s.total
        daily_map[d_str]["orders"] += 1
        s_profit = 0.0
        for it in s.items:
            s_profit += (it.unit_price - it.purchase_price) * it.quantity - it.discount
        s_profit -= s.discount
        daily_map[d_str]["profit"] += max(0.0, s_profit)

    analytics = [
        {
            "date": date_key,
            "revenue": round(data["revenue"], 2),
            "orders": data["orders"],
            "profit": round(data["profit"], 2),
        }
        for date_key, data in sorted(daily_map.items())
    ]

    # Top selling products
    products_all = db.scalars(select(Product)).all()
    product_sales_map = defaultdict(lambda: {"qty": 0.0, "revenue": 0.0})
    for s in sales_all:
        for it in s.items:
            if it.product_id:
                product_sales_map[it.product_id]["qty"] += it.quantity
                product_sales_map[it.product_id]["revenue"] += it.subtotal

    top_products = []
    for p in products_all:
        stats = product_sales_map[p.id]
        if stats["qty"] > 0:
            top_products.append({
                "id": p.id,
                "name": p.name,
                "sold_quantity": stats["qty"],
                "total_revenue": round(stats["revenue"], 2),
                "current_stock": p.current_stock,
            })
    top_products.sort(key=lambda x: x["total_revenue"], reverse=True)
    top_products = top_products[:5]

    # Category distribution
    categories_all = db.scalars(select(ProductCategory)).all()
    cat_distribution = []
    for c in categories_all:
        cnt = db.scalar(select(func.count(Product.id)).where(Product.category_id == c.id)) or 0
        cat_distribution.append({"category": c.name, "count": cnt})

    return {
        "total_users": total_users,
        "total_shops": total_shops,
        "total_products": total_products,
        "total_orders": total_orders,
        "total_revenue": round(total_revenue, 2),
        "total_due": round(total_due, 2),
        "total_expenses": round(total_expenses, 2),
        "net_profit": net_profit,
        "order_statistics": {
            "completed": completed_orders,
            "pending": pending_orders,
            "cancelled": cancelled_orders,
        },
        "recent_orders": recent_orders,
        "recent_activities": activities[:10],
        "sales_analytics": analytics,
        "top_products": top_products,
        "category_distribution": cat_distribution,
    }


# --- 2. Admin User Management ---

@router.get("/users")
def get_admin_users(
    search: Optional[str] = None,
    role: Optional[str] = None,
    is_active: Optional[bool] = None,
    page: int = 1,
    limit: int = 20,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    stmt = select(User)
    if search and search.strip():
        term = f"%{search.strip()}%"
        stmt = stmt.where(or_(User.email.ilike(term), User.full_name.ilike(term), User.phone.ilike(term)))
    if role and role.strip():
        stmt = stmt.where(User.role == role.strip())
    if is_active is not None:
        stmt = stmt.where(User.is_active == is_active)

    total_count = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0
    offset = (page - 1) * limit
    users = db.scalars(stmt.order_by(User.created_at.desc()).offset(offset).limit(limit)).all()

    items = []
    for u in users:
        items.append({
            "id": u.id,
            "email": u.email,
            "full_name": u.full_name,
            "name": u.full_name,
            "phone": u.phone,
            "role": u.role,
            "is_active": u.is_active,
            "is_email_verified": u.is_email_verified,
            "active_shop_id": u.active_shop_id,
            "created_at": u.created_at.isoformat() if u.created_at else None,
            "shops_count": len(u.shops),
        })

    return {
        "items": items,
        "total": total_count,
        "page": page,
        "limit": limit,
        "pages": (total_count + limit - 1) // limit if total_count > 0 else 1,
    }


@router.post("/users", status_code=status.HTTP_201_CREATED)
def create_admin_user(
    payload: AdminUserCreateRequest,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    email = payload.email.lower().strip()
    if db.scalar(select(User).where(User.email == email)):
        raise HTTPException(status_code=409, detail="User with this email already exists")

    new_user = User(
        email=email,
        full_name=payload.full_name.strip(),
        phone=payload.phone.strip() if payload.phone else None,
        password_hash=hash_password(payload.password),
        role=payload.role,
        is_active=payload.is_active,
        is_email_verified=payload.is_email_verified,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return UserResponse.model_validate(new_user)


@router.get("/users/{user_id}")
def get_admin_user_detail(
    user_id: str,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    target = db.get(User, user_id)
    if not target:
        raise HTTPException(status_code=404, detail="User not found")

    shops = [
        {"id": s.id, "name": s.name, "category": s.category, "phone": s.phone, "currency": s.currency}
        for s in target.shops
    ]
    return {
        "id": target.id,
        "email": target.email,
        "full_name": target.full_name,
        "phone": target.phone,
        "role": target.role,
        "is_active": target.is_active,
        "is_email_verified": target.is_email_verified,
        "active_shop_id": target.active_shop_id,
        "created_at": target.created_at.isoformat() if target.created_at else None,
        "shops": shops,
    }


@router.put("/users/{user_id}")
def update_admin_user(
    user_id: str,
    payload: AdminUserUpdateRequest,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    target = db.get(User, user_id)
    if not target:
        raise HTTPException(status_code=404, detail="User not found")

    if payload.full_name is not None:
        target.full_name = payload.full_name.strip()
    if payload.phone is not None:
        target.phone = payload.phone.strip() if payload.phone.strip() else None
    if payload.role is not None:
        target.role = payload.role
    if payload.is_active is not None:
        target.is_active = payload.is_active
    if payload.is_email_verified is not None:
        target.is_email_verified = payload.is_email_verified
    if payload.password is not None and payload.password.strip():
        target.password_hash = hash_password(payload.password.strip())

    db.commit()
    db.refresh(target)
    return UserResponse.model_validate(target)


@router.delete("/users/{user_id}")
def delete_admin_user(
    user_id: str,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    if user_id == admin.id:
        raise HTTPException(status_code=400, detail="Cannot delete your own administrator account")

    target = db.get(User, user_id)
    if not target:
        raise HTTPException(status_code=404, detail="User not found")

    db.delete(target)
    db.commit()
    return {"message": "User deleted successfully"}


# --- 3. Admin Orders / Sales Management ---

@router.get("/orders")
def get_admin_orders(
    search: Optional[str] = None,
    shop_id: Optional[str] = None,
    status_filter: Optional[str] = Query(default=None, alias="status"),
    payment_method: Optional[str] = None,
    page: int = 1,
    limit: int = 20,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    stmt = select(Sale)
    if shop_id:
        stmt = stmt.where(Sale.shop_id == shop_id)
    if status_filter:
        stmt = stmt.where(Sale.status == status_filter)
    if payment_method:
        stmt = stmt.where(Sale.payment_method == payment_method)
    if search and search.strip():
        term = f"%{search.strip()}%"
        stmt = stmt.where(
            or_(
                Sale.invoice_no.ilike(term),
                Sale.customer_name.ilike(term),
                Sale.customer_phone.ilike(term),
            )
        )

    total_count = db.scalar(select(func.count()).select_from(stmt.subquery())) or 0
    offset = (page - 1) * limit
    sales = db.scalars(stmt.order_by(Sale.created_at.desc()).offset(offset).limit(limit)).all()

    items = [format_sale_response(s, db) for s in sales]

    return {
        "items": items,
        "total": total_count,
        "page": page,
        "limit": limit,
        "pages": (total_count + limit - 1) // limit if total_count > 0 else 1,
    }


@router.get("/orders/{order_id}")
def get_admin_order_detail(
    order_id: str,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    sale = db.get(Sale, order_id)
    if not sale:
        raise HTTPException(status_code=404, detail="Order not found")
    return format_sale_response(sale, db)


@router.put("/orders/{order_id}")
def update_admin_order_status(
    order_id: str,
    payload: AdminOrderStatusUpdateRequest,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    sale = db.get(Sale, order_id)
    if not sale:
        raise HTTPException(status_code=404, detail="Order not found")

    sale.status = payload.status
    if payload.payment_method:
        sale.payment_method = payload.payment_method
    if payload.notes is not None:
        sale.notes = payload.notes

    db.commit()
    db.refresh(sale)
    return format_sale_response(sale, db)


@router.delete("/orders/{order_id}")
def cancel_admin_order(
    order_id: str,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    sale = db.get(Sale, order_id)
    if not sale:
        raise HTTPException(status_code=404, detail="Order not found")

    # Restore stock for each item
    for item in sale.items:
        if item.product_id:
            product = db.get(Product, item.product_id)
            if product:
                product.current_stock += item.quantity

    # Adjust customer totals if customer was linked
    if sale.customer_id:
        customer = db.get(Customer, sale.customer_id)
        if customer:
            customer.total_purchase = max(0.0, customer.total_purchase - sale.total)
            customer.total_due = max(0.0, customer.total_due - sale.due)

    db.delete(sale)
    db.commit()
    return {"message": "Order cancelled and stock restored successfully"}


# --- 4. Admin Shops Management ---

@router.get("/shops")
def get_admin_shops(
    search: Optional[str] = None,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    stmt = select(Shop)
    if search and search.strip():
        term = f"%{search.strip()}%"
        stmt = stmt.where(or_(Shop.name.ilike(term), Shop.owner_name.ilike(term), Shop.phone.ilike(term)))
    shops = db.scalars(stmt.order_by(Shop.created_at.desc())).all()

    results = []
    for s in shops:
        prod_count = len(s.products)
        sales_count = len(s.sales)
        total_rev = sum(sl.total for sl in s.sales)
        results.append({
            "id": s.id,
            "owner_id": s.owner_id,
            "name": s.name,
            "owner_name": s.owner_name,
            "category": s.category,
            "phone": s.phone,
            "address": s.address,
            "currency": s.currency,
            "logo_url": s.logo_url,
            "created_at": s.created_at.isoformat(),
            "products_count": prod_count,
            "sales_count": sales_count,
            "total_revenue": round(total_rev, 2),
        })
    return results


# --- 5. Admin System Notifications ---

@router.get("/notifications")
def get_admin_notifications(
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    notifications = []

    # 1. Low stock alerts
    low_stock_products = db.scalars(
        select(Product).where(Product.current_stock <= Product.min_stock).limit(10)
    ).all()
    for p in low_stock_products:
        notifications.append({
            "id": f"low_stock_{p.id}",
            "type": "warning",
            "title": "Low Stock Alert",
            "message": f"Product '{p.name}' is running low (Current: {p.current_stock} {p.unit}, Min: {p.min_stock})",
            "timestamp": p.updated_at.isoformat() if p.updated_at else datetime.now(timezone.utc).isoformat(),
            "read": False,
        })

    # 2. Customers with high due
    high_due_customers = db.scalars(
        select(Customer).where(Customer.total_due > 1000).order_by(Customer.total_due.desc()).limit(5)
    ).all()
    for c in high_due_customers:
        notifications.append({
            "id": f"due_{c.id}",
            "type": "info",
            "title": "High Customer Due",
            "message": f"Customer '{c.name}' has an outstanding due balance of ৳{c.total_due:,.2f}",
            "timestamp": c.updated_at.isoformat() if c.updated_at else datetime.now(timezone.utc).isoformat(),
            "read": False,
        })

    # 3. Recent High Value Orders
    high_sales = db.scalars(select(Sale).where(Sale.total > 5000).order_by(Sale.created_at.desc()).limit(5)).all()
    for s in high_sales:
        notifications.append({
            "id": f"sale_high_{s.id}",
            "type": "success",
            "title": "High Value Sale Completed",
            "message": f"Invoice #{s.invoice_no} was completed for ৳{s.total:,.2f}",
            "timestamp": s.created_at.isoformat(),
            "read": False,
        })

    notifications.sort(key=lambda n: n["timestamp"], reverse=True)
    return notifications


# --- 6. Admin Settings & Profile ---

@router.get("/settings")
def get_admin_settings(admin: User = Depends(get_current_admin)):
    return SYSTEM_SETTINGS


@router.put("/settings")
def update_admin_settings(
    payload: AdminSettingsPayload,
    admin: User = Depends(get_current_admin),
):
    SYSTEM_SETTINGS["company_name"] = payload.company_name
    SYSTEM_SETTINGS["contact_email"] = payload.contact_email
    SYSTEM_SETTINGS["contact_phone"] = payload.contact_phone
    SYSTEM_SETTINGS["currency"] = payload.currency
    SYSTEM_SETTINGS["tax_rate"] = payload.tax_rate
    SYSTEM_SETTINGS["invoice_footer"] = payload.invoice_footer
    return {"message": "Settings updated successfully", "settings": SYSTEM_SETTINGS}


@router.get("/profile")
def get_admin_profile(admin: User = Depends(get_current_admin)):
    return {
        "id": admin.id,
        "email": admin.email,
        "full_name": admin.full_name,
        "name": admin.full_name,
        "phone": admin.phone,
        "role": admin.role,
        "is_active": admin.is_active,
        "is_email_verified": admin.is_email_verified,
        "active_shop_id": admin.active_shop_id,
        "created_at": admin.created_at.isoformat() if admin.created_at else None,
    }


class AdminProfileUpdate(BaseModel):
    full_name: Optional[str] = Field(default=None, min_length=2, max_length=120)
    phone: Optional[str] = Field(default=None, max_length=30)
    current_password: Optional[str] = None
    new_password: Optional[str] = Field(default=None, min_length=6)


@router.put("/profile")
def update_admin_profile(
    payload: AdminProfileUpdate,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    if payload.full_name:
        admin.full_name = payload.full_name.strip()
    if payload.phone:
        admin.phone = payload.phone.strip()
    if payload.new_password:
        admin.password_hash = hash_password(payload.new_password.strip())

    db.commit()
    db.refresh(admin)
    return {"message": "Profile updated successfully", "user": UserResponse.model_validate(admin)}
