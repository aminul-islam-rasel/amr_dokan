from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field

from app.schemas.product import ProductResponse


class SaleItemRequest(BaseModel):
    product_id: str
    quantity: float = Field(gt=0.0)
    discount: float = Field(default=0.0, ge=0.0)


class SaleCreateRequest(BaseModel):
    items: List[SaleItemRequest]
    discount: float = Field(default=0.0, ge=0.0)
    paid: float = Field(default=0.0, ge=0.0)
    customer_name: Optional[str] = Field(default=None, max_length=150)
    customer_phone: Optional[str] = Field(default=None, max_length=30)
    payment_method: Optional[str] = Field(default="cash", max_length=50)
    notes: Optional[str] = Field(default=None, max_length=255)
    status: Optional[str] = Field(default="completed", max_length=30)


class SaleItemResponse(BaseModel):
    product: ProductResponse
    quantity: float
    discount: float = 0.0

    model_config = ConfigDict(from_attributes=True)


class SaleResponse(BaseModel):
    id: str
    invoice_no: str
    shop_id: str
    customer_name: Optional[str] = None
    customer_phone: Optional[str] = None
    items: List[SaleItemResponse]
    subtotal: float
    discount: float
    total: float
    paid: float
    due: float
    status: str = "completed"
    payment_method: str = "cash"
    notes: Optional[str] = None
    timestamp: datetime
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
