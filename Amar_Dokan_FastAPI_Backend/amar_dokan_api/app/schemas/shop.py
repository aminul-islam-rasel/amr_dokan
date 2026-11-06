from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class ShopCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=150)
    owner_name: str = Field(min_length=1, max_length=120)
    category: str = Field(default="grocery", max_length=60)
    phone: str = Field(min_length=5, max_length=30)
    address: str = Field(default="", max_length=255)
    currency: str = Field(default="BDT", max_length=10)


class ShopUpdateRequest(BaseModel):
    name: Optional[str] = Field(default=None, max_length=150)
    owner_name: Optional[str] = Field(default=None, max_length=120)
    category: Optional[str] = Field(default=None, max_length=60)
    phone: Optional[str] = Field(default=None, max_length=30)
    address: Optional[str] = Field(default=None, max_length=255)
    currency: Optional[str] = Field(default=None, max_length=10)
    logo_url: Optional[str] = Field(default=None, max_length=500)


class ShopResponse(BaseModel):
    id: str
    name: str
    owner_name: str
    category: str
    phone: str
    address: str
    currency: str
    logo_url: Optional[str] = None
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
