from collections import defaultdict
from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_active_or_first_shop, get_current_shop, get_current_user
from app.db.session import get_db
from app.models.expense import Expense
from app.models.sale import Sale
from app.models.shop import Shop
from app.models.user import User
from app.schemas.report import (
    DailyReportItem,
    DailyReportResponse,
    MonthlyReportItem,
    MonthlyReportResponse,
    ProfitLossReportResponse,
)

# Router mounted at /shops/{shop_id}/reports
shop_reports_router = APIRouter(prefix="/shops/{shop_id}/reports", tags=["Reports"])

# Router for root-level reports
general_reports_router = APIRouter(tags=["Reports"])


def compute_daily_report(shop: Shop, db: Session) -> DailyReportResponse:
    sales = db.scalars(select(Sale).where(Sale.shop_id == shop.id)).all()
    expenses = db.scalars(select(Expense).where(Expense.shop_id == shop.id)).all()

    daily_sales = defaultdict(float)
    daily_orders = defaultdict(int)
    daily_profit = defaultdict(float)
    daily_expenses = defaultdict(float)

    for s in sales:
        date_str = s.created_at.strftime("%Y-%m-%d")
        daily_sales[date_str] += s.total
        daily_orders[date_str] += 1
        gross_profit = 0.0
        for item in s.items:
            gross_profit += (item.unit_price - item.purchase_price) * item.quantity - item.discount
        gross_profit -= s.discount
        daily_profit[date_str] += max(0.0, gross_profit)

    for e in expenses:
        date_str = e.created_at.strftime("%Y-%m-%d")
        daily_expenses[date_str] += e.amount

    all_dates = sorted(set(list(daily_sales.keys()) + list(daily_expenses.keys())), reverse=True)
    items = []
    for d in all_dates:
        p = max(0.0, daily_profit[d] - daily_expenses[d])
        items.append(
            DailyReportItem(
                date=d,
                total_sales=round(daily_sales[d], 2),
                total_profit=round(p, 2),
                total_expenses=round(daily_expenses[d], 2),
                total_orders=daily_orders[d],
            )
        )

    return DailyReportResponse(
        items=items,
        total_sales=round(sum(daily_sales.values()), 2),
        total_profit=round(sum(i.total_profit for i in items), 2),
        total_expenses=round(sum(daily_expenses.values()), 2),
    )


def compute_monthly_report(shop: Shop, db: Session) -> MonthlyReportResponse:
    sales = db.scalars(select(Sale).where(Sale.shop_id == shop.id)).all()
    expenses = db.scalars(select(Expense).where(Expense.shop_id == shop.id)).all()

    monthly_sales = defaultdict(float)
    monthly_orders = defaultdict(int)
    monthly_profit = defaultdict(float)
    monthly_expenses = defaultdict(float)

    for s in sales:
        month_str = s.created_at.strftime("%Y-%m")
        monthly_sales[month_str] += s.total
        monthly_orders[month_str] += 1
        gross_profit = 0.0
        for item in s.items:
            gross_profit += (item.unit_price - item.purchase_price) * item.quantity - item.discount
        gross_profit -= s.discount
        monthly_profit[month_str] += max(0.0, gross_profit)

    for e in expenses:
        month_str = e.created_at.strftime("%Y-%m")
        monthly_expenses[month_str] += e.amount

    all_months = sorted(set(list(monthly_sales.keys()) + list(monthly_expenses.keys())), reverse=True)
    items = []
    for m in all_months:
        p = max(0.0, monthly_profit[m] - monthly_expenses[m])
        items.append(
            MonthlyReportItem(
                month=m,
                total_sales=round(monthly_sales[m], 2),
                total_profit=round(p, 2),
                total_expenses=round(monthly_expenses[m], 2),
                total_orders=monthly_orders[m],
            )
        )

    return MonthlyReportResponse(
        items=items,
        total_sales=round(sum(monthly_sales.values()), 2),
        total_profit=round(sum(i.total_profit for i in items), 2),
        total_expenses=round(sum(monthly_expenses.values()), 2),
    )


def compute_profit_loss(shop: Shop, db: Session) -> ProfitLossReportResponse:
    sales = db.scalars(select(Sale).where(Sale.shop_id == shop.id)).all()
    expenses = db.scalars(select(Expense).where(Expense.shop_id == shop.id)).all()

    gross_sales = sum(s.subtotal for s in sales)
    discounts = sum(s.discount for s in sales)
    net_sales = max(0.0, gross_sales - discounts)

    cogs = 0.0
    for s in sales:
        for item in s.items:
            cogs += item.purchase_price * item.quantity

    gross_profit = max(0.0, net_sales - cogs)
    operating_expenses = sum(e.amount for e in expenses)
    net_profit = gross_profit - operating_expenses

    return ProfitLossReportResponse(
        period=datetime.now(timezone.utc).strftime("%Y-%m"),
        gross_sales=round(gross_sales, 2),
        discounts=round(discounts, 2),
        net_sales=round(net_sales, 2),
        cost_of_goods_sold=round(cogs, 2),
        gross_profit=round(gross_profit, 2),
        operating_expenses=round(operating_expenses, 2),
        net_profit=round(net_profit, 2),
    )


@shop_reports_router.get("/daily", response_model=DailyReportResponse)
def get_daily_report(
    shop_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    return compute_daily_report(shop, db)


@shop_reports_router.get("/monthly", response_model=MonthlyReportResponse)
def get_monthly_report(
    shop_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    return compute_monthly_report(shop, db)


@shop_reports_router.get("/profit-loss", response_model=ProfitLossReportResponse)
def get_profit_loss_report(
    shop_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    return compute_profit_loss(shop, db)


# --- Root-level convenience endpoints from ApiEndpoints.dart ---

@general_reports_router.get("/reports/daily", response_model=DailyReportResponse)
def get_daily_report_root(
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
    return compute_daily_report(shop, db)


@general_reports_router.get("/reports/monthly", response_model=MonthlyReportResponse)
def get_monthly_report_root(
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
    return compute_monthly_report(shop, db)


@general_reports_router.get("/reports/profit-loss", response_model=ProfitLossReportResponse)
def get_profit_loss_report_root(
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
    return compute_profit_loss(shop, db)
