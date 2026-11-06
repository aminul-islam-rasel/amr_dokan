import random
import time
from datetime import datetime, timezone
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_active_or_first_shop, get_current_shop, get_current_user
from app.db.session import get_db
from app.models.customer import Customer
from app.models.product import Product
from app.models.sale import Sale
from app.models.sale_item import SaleItem
from app.models.shop import Shop
from app.models.user import User
from app.schemas.product import ProductResponse
from app.schemas.sale import (
    SaleCreateRequest,
    SaleItemResponse,
    SaleResponse,
)

# Router mounted at /shops/{shop_id}/sales
shop_sales_router = APIRouter(prefix="/shops/{shop_id}/sales", tags=["Sales & POS"])

# Router for root-level sales & posCheckout
general_sales_router = APIRouter(tags=["Sales & POS"])


def generate_invoice_no() -> str:
    timestamp = int(time.time() * 1000) % 10000000
    rand = random.randint(100, 999)
    return f"INV-{timestamp}{rand}"


def process_sale_transaction(
    shop: Shop,
    payload: SaleCreateRequest,
    db: Session,
) -> SaleResponse:
    if not payload.items:
        raise HTTPException(status_code=400, detail="Cannot create a sale without items")

    subtotal = 0.0
    sale_item_models = []
    response_items: List[SaleItemResponse] = []

    for item_req in payload.items:
        product = db.get(Product, item_req.product_id)
        if not product or product.shop_id != shop.id:
            raise HTTPException(
                status_code=404,
                detail=f"Product with ID '{item_req.product_id}' not found in this shop",
            )

        # Deduct stock
        product.current_stock = max(0.0, product.current_stock - item_req.quantity)

        # Calculate pricing
        line_subtotal = (product.selling_price * item_req.quantity) - item_req.discount
        line_subtotal = max(0.0, line_subtotal)
        subtotal += line_subtotal

        # Prepare DB SaleItem
        sale_item = SaleItem(
            product_id=product.id,
            product_name=product.name,
            unit_price=product.selling_price,
            purchase_price=product.purchase_price,
            quantity=item_req.quantity,
            discount=item_req.discount,
            subtotal=line_subtotal,
        )
        sale_item_models.append(sale_item)

        # Prepare Response item
        response_items.append(
            SaleItemResponse(
                product=ProductResponse.model_validate(product),
                quantity=item_req.quantity,
                discount=item_req.discount,
            )
        )

    total = max(0.0, subtotal - payload.discount)
    paid = payload.paid
    due = max(0.0, total - paid)

    # Handle customer if name or phone provided
    customer_id = None
    if payload.customer_phone and payload.customer_phone.strip():
        phone = payload.customer_phone.strip()
        customer = db.scalar(
            select(Customer).where(Customer.shop_id == shop.id, Customer.phone == phone)
        )
        if customer:
            customer.total_purchase += total
            customer.total_due += due
            if payload.customer_name and payload.customer_name.strip():
                customer.name = payload.customer_name.strip()
            customer_id = customer.id
        else:
            cust_name = payload.customer_name.strip() if payload.customer_name else phone
            customer = Customer(
                shop_id=shop.id,
                name=cust_name,
                phone=phone,
                total_purchase=total,
                total_due=due,
            )
            db.add(customer)
            db.flush()
            customer_id = customer.id
    elif payload.customer_name and payload.customer_name.strip():
        # Name only
        cust_name = payload.customer_name.strip()
        customer = Customer(
            shop_id=shop.id,
            name=cust_name,
            phone="N/A",
            total_purchase=total,
            total_due=due,
        )
        db.add(customer)
        db.flush()
        customer_id = customer.id

    now = datetime.now(timezone.utc)
    invoice_no = generate_invoice_no()

    sale = Sale(
        invoice_no=invoice_no,
        shop_id=shop.id,
        customer_id=customer_id,
        customer_name=payload.customer_name.strip() if payload.customer_name else None,
        customer_phone=payload.customer_phone.strip() if payload.customer_phone else None,
        subtotal=subtotal,
        discount=payload.discount,
        total=total,
        paid=paid,
        due=due,
        status=payload.status or "completed",
        payment_method=payload.payment_method or "cash",
        notes=payload.notes,
        created_at=now,
    )
    db.add(sale)
    db.flush()

    for item in sale_item_models:
        item.sale_id = sale.id
        db.add(item)

    db.commit()
    db.refresh(sale)

    return SaleResponse(
        id=sale.id,
        invoice_no=sale.invoice_no,
        shop_id=sale.shop_id,
        customer_name=sale.customer_name,
        customer_phone=sale.customer_phone,
        items=response_items,
        subtotal=sale.subtotal,
        discount=sale.discount,
        total=sale.total,
        paid=sale.paid,
        due=sale.due,
        status=sale.status,
        payment_method=sale.payment_method,
        notes=sale.notes,
        timestamp=sale.created_at,
        created_at=sale.created_at,
    )


def format_sale_response(sale: Sale, db: Session) -> SaleResponse:
    items = []
    for item in sale.items:
        product = db.get(Product, item.product_id) if item.product_id else None
        if product:
            prod_resp = ProductResponse.model_validate(product)
        else:
            prod_resp = ProductResponse(
                id=item.product_id or "",
                name=item.product_name,
                purchase_price=item.purchase_price,
                selling_price=item.unit_price,
                current_stock=0.0,
                min_stock=0.0,
                unit="pcs",
            )
        items.append(
            SaleItemResponse(
                product=prod_resp,
                quantity=item.quantity,
                discount=item.discount,
            )
        )
    return SaleResponse(
        id=sale.id,
        invoice_no=sale.invoice_no,
        shop_id=sale.shop_id,
        customer_name=sale.customer_name,
        customer_phone=sale.customer_phone,
        items=items,
        subtotal=sale.subtotal,
        discount=sale.discount,
        total=sale.total,
        paid=sale.paid,
        due=sale.due,
        status=sale.status,
        payment_method=sale.payment_method,
        notes=sale.notes,
        timestamp=sale.created_at,
        created_at=sale.created_at,
    )


@shop_sales_router.post("", response_model=SaleResponse, status_code=status.HTTP_201_CREATED)
def checkout_shop(
    shop_id: str,
    payload: SaleCreateRequest,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    return process_sale_transaction(shop=shop, payload=payload, db=db)


@shop_sales_router.get("", response_model=List[SaleResponse])
def get_sales_history(
    shop_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    sales = db.scalars(
        select(Sale).where(Sale.shop_id == shop.id).order_by(Sale.created_at.desc())
    ).all()
    return [format_sale_response(s, db) for s in sales]


@shop_sales_router.get("/{sale_id}", response_model=SaleResponse)
def get_sale_details(
    shop_id: str,
    sale_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    sale = db.get(Sale, sale_id)
    if not sale or sale.shop_id != shop.id:
        raise HTTPException(status_code=404, detail="Sale not found")
    return format_sale_response(sale, db)


# --- Root-level convenience endpoints from ApiEndpoints.dart ---

@general_sales_router.post("/sales/checkout", response_model=SaleResponse, status_code=status.HTTP_201_CREATED)
def checkout_root(
    payload: SaleCreateRequest,
    shop_id: Optional[str] = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if shop_id:
        shop = db.get(Shop, shop_id)
        if not shop or shop.owner_id != current_user.id:
            raise HTTPException(status_code=404, detail="Shop not found")
    else:
        shop = get_active_or_first_shop(current_user=current_user, db=db)
    return process_sale_transaction(shop=shop, payload=payload, db=db)


@general_sales_router.get("/sales", response_model=List[SaleResponse])
def get_sales_root(
    shop_id: Optional[str] = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if shop_id:
        shop = db.get(Shop, shop_id)
        if not shop or shop.owner_id != current_user.id:
            raise HTTPException(status_code=404, detail="Shop not found")
    else:
        shop = get_active_or_first_shop(current_user=current_user, db=db)

    sales = db.scalars(
        select(Sale).where(Sale.shop_id == shop.id).order_by(Sale.created_at.desc())
    ).all()
    return [format_sale_response(s, db) for s in sales]
