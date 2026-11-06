from datetime import datetime, time, timezone
from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import get_current_shop
from app.db.session import get_db
from app.models.customer import Customer
from app.models.due_payment import DuePayment
from app.models.expense import Expense
from app.models.product import Product
from app.models.sale import Sale
from app.models.shop import Shop
from app.schemas.dashboard import DashboardSummaryResponse, TransactionResponse

router = APIRouter(prefix="/shops/{shop_id}/dashboard", tags=["Dashboard"])


@router.get("/summary", response_model=DashboardSummaryResponse)
def get_dashboard_summary(
    shop_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    now = datetime.now(timezone.utc)
    today_start = datetime.combine(now.date(), time.min, tzinfo=timezone.utc)

    # Today's Sales
    todays_sales_list = db.scalars(
        select(Sale).where(Sale.shop_id == shop.id, Sale.created_at >= today_start)
    ).all()
    todays_sales = sum(s.total for s in todays_sales_list)

    # Today's Expenses
    todays_expenses_val = db.scalar(
        select(func.coalesce(func.sum(Expense.amount), 0.0)).where(
            Expense.shop_id == shop.id, Expense.created_at >= today_start
        )
    ) or 0.0

    # Today's Profit calculation:
    # Gross Profit = Sum over all items today of (unit_price - purchase_price) * quantity - item discount - sale discount
    gross_profit = 0.0
    for s in todays_sales_list:
        for item in s.items:
            item_profit = (item.unit_price - item.purchase_price) * item.quantity - item.discount
            gross_profit += max(0.0, item_profit)
        gross_profit -= s.discount

    todays_profit = max(0.0, gross_profit - todays_expenses_val)

    # Total Due from Customers
    total_due = db.scalar(
        select(func.coalesce(func.sum(Customer.total_due), 0.0)).where(Customer.shop_id == shop.id)
    ) or 0.0

    # Products Count
    total_products = db.scalar(
        select(func.count(Product.id)).where(Product.shop_id == shop.id)
    ) or 0

    # Customers Count
    total_customers = db.scalar(
        select(func.count(Customer.id)).where(Customer.shop_id == shop.id)
    ) or 0

    # Low Stock Count
    low_stock_count = db.scalar(
        select(func.count(Product.id)).where(
            Product.shop_id == shop.id, Product.current_stock <= Product.min_stock
        )
    ) or 0

    return DashboardSummaryResponse(
        todays_sales=round(todays_sales, 2),
        todays_profit=round(todays_profit, 2),
        todays_expenses=round(todays_expenses_val, 2),
        total_due=round(total_due, 2),
        total_products=total_products,
        total_customers=total_customers,
        low_stock_count=low_stock_count,
    )


@router.get("/transactions", response_model=List[TransactionResponse])
def get_recent_transactions(
    shop_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    # Fetch recent sales
    recent_sales = db.scalars(
        select(Sale).where(Sale.shop_id == shop.id).order_by(Sale.created_at.desc()).limit(15)
    ).all()

    # Fetch recent expenses
    recent_expenses = db.scalars(
        select(Expense).where(Expense.shop_id == shop.id).order_by(Expense.created_at.desc()).limit(15)
    ).all()

    # Fetch recent due collections
    recent_due_payments = db.scalars(
        select(DuePayment).where(DuePayment.shop_id == shop.id).order_by(DuePayment.created_at.desc()).limit(15)
    ).all()

    combined: List[TransactionResponse] = []

    for s in recent_sales:
        combined.append(
            TransactionResponse(
                id=s.id,
                title=s.customer_name or "সাধারণ বিক্রি (Cash Sale)",
                subtitle=f"ইনভয়েস #{s.invoice_no}",
                amount=s.total,
                type="sale",
                timestamp=s.created_at,
            )
        )

    for e in recent_expenses:
        combined.append(
            TransactionResponse(
                id=e.id,
                title=e.title,
                subtitle=e.category or "খরচ",
                amount=e.amount,
                type="expense",
                timestamp=e.created_at,
            )
        )

    for dp in recent_due_payments:
        cust = db.get(Customer, dp.customer_id)
        cust_name = cust.name if cust else "গ্রাহক"
        combined.append(
            TransactionResponse(
                id=dp.id,
                title=f"{cust_name} (বাকি আদায়)",
                subtitle="বাকি পরিশোধ",
                amount=dp.amount,
                type="due_collection",
                timestamp=dp.created_at,
            )
        )

    # Sort all by timestamp descending and take top 20
    combined.sort(key=lambda t: t.timestamp, reverse=True)
    return combined[:20]
