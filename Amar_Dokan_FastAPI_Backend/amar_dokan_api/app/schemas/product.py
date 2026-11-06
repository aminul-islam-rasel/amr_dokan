from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class ProductCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    barcode: Optional[str] = Field(default=None, max_length=100)
    purchase_price: float = Field(default=0.0, ge=0.0)
    selling_price: float = Field(default=0.0, ge=0.0)
    current_stock: float = Field(default=0.0)
    min_stock: float = Field(default=5.0, ge=0.0)
    unit: str = Field(default="pcs", max_length=30)
    category_id: Optional[str] = None
    image_url: Optional[str] = None


class ProductUpdateRequest(BaseModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=200)
    barcode: Optional[str] = Field(default=None, max_length=100)
    purchase_price: Optional[float] = Field(default=None, ge=0.0)
    selling_price: Optional[float] = Field(default=None, ge=0.0)
    current_stock: Optional[float] = None
    min_stock: Optional[float] = Field(default=None, ge=0.0)
    unit: Optional[str] = Field(default=None, max_length=30)
    category_id: Optional[str] = None
    image_url: Optional[str] = None


class ProductResponse(BaseModel):
    id: str
    name: str
    barcode: Optional[str] = None
    purchase_price: float
    selling_price: float
    current_stock: float
    min_stock: float
    unit: str
    category_id: Optional[str] = None
    image_url: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


class CategoryCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=100)


class CategoryResponse(BaseModel):
    id: str
    name: str

    model_config = ConfigDict(from_attributes=True)
