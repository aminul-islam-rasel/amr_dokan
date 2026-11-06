from typing import List, Optional
from pydantic import BaseModel


class DailyReportItem(BaseModel):
    date: str
    total_sales: float
    total_profit: float
    total_expenses: float
    total_orders: int


class DailyReportResponse(BaseModel):
    items: List[DailyReportItem]
    total_sales: float
    total_profit: float
    total_expenses: float


class MonthlyReportItem(BaseModel):
    month: str
    total_sales: float
    total_profit: float
    total_expenses: float
    total_orders: int


class MonthlyReportResponse(BaseModel):
    items: List[MonthlyReportItem]
    total_sales: float
    total_profit: float
    total_expenses: float


class ProfitLossReportResponse(BaseModel):
    period: str
    gross_sales: float
    discounts: float
    net_sales: float
    cost_of_goods_sold: float
    gross_profit: float
    operating_expenses: float
    net_profit: float
