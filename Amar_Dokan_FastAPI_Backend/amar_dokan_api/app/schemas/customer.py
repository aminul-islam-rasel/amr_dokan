from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class CustomerCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=150)
    phone: str = Field(min_length=5, max_length=30)
    address: Optional[str] = Field(default=None, max_length=255)


class CustomerUpdateRequest(BaseModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=150)
    phone: Optional[str] = Field(default=None, min_length=5, max_length=30)
    address: Optional[str] = Field(default=None, max_length=255)


class CustomerResponse(BaseModel):
    id: str
    name: str
    phone: str
    address: Optional[str] = None
    total_due: float = 0.0
    total_purchase: float = 0.0

    model_config = ConfigDict(from_attributes=True)


class DueCollectionRequest(BaseModel):
    amount: float = Field(gt=0.0)
    note: Optional[str] = Field(default=None, max_length=255)


class DuePaymentResponse(BaseModel):
    id: str
    customer_id: str
    amount: float
    note: Optional[str] = None
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
