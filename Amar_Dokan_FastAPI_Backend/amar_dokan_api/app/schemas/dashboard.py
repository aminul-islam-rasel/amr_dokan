from datetime import datetime
from pydantic import BaseModel, ConfigDict


class DashboardSummaryResponse(BaseModel):
    todays_sales: float = 0.0
    todays_profit: float = 0.0
    todays_expenses: float = 0.0
    total_due: float = 0.0
    total_products: int = 0
    total_customers: int = 0
    low_stock_count: int = 0

    model_config = ConfigDict(from_attributes=True)


class TransactionResponse(BaseModel):
    id: str
    title: str
    subtitle: str
    amount: float
    type: str  # "sale", "expense", "due_collection"
    timestamp: datetime

    model_config = ConfigDict(from_attributes=True)
