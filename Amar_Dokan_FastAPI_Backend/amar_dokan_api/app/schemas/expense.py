from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class ExpenseCreateRequest(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    category: str = Field(default="other", max_length=100)
    amount: float = Field(gt=0.0)
    note: Optional[str] = Field(default=None, max_length=255)


class ExpenseResponse(BaseModel):
    id: str
    shop_id: str
    title: str
    category: str
    amount: float
    note: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
