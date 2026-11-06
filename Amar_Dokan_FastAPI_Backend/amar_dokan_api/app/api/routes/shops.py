import os
import uuid
from typing import List

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_shop, get_current_user
from app.db.session import get_db
from app.models.shop import Shop
from app.models.user import User
from app.schemas.shop import ShopCreateRequest, ShopResponse, ShopUpdateRequest

router = APIRouter(prefix="/shops", tags=["Shops"])

SHOP_CATEGORIES = [
    {"key": "grocery", "name": "Grocery / মুদি দোকান"},
    {"key": "clothing", "name": "Clothing / কাপড়ের দোকান"},
    {"key": "electronics", "name": "Electronics / ইলেকট্রনিক্স"},
    {"key": "pharmacy", "name": "Pharmacy / ফার্মেসি"},
    {"key": "restaurant", "name": "Restaurant / রেস্তোরাঁ"},
    {"key": "cosmetics", "name": "Cosmetics / কসমেটিক্স"},
    {"key": "stationery", "name": "Stationery / স্টেশনারি"},
    {"key": "other", "name": "Other / অন্যান্য"},
]


@router.get("/categories")
def get_shop_categories():
    return SHOP_CATEGORIES


@router.post("", response_model=ShopResponse, status_code=status.HTTP_201_CREATED)
def create_shop(
    payload: ShopCreateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    shop = Shop(
        owner_id=current_user.id,
        name=payload.name.strip(),
        owner_name=payload.owner_name.strip(),
        category=payload.category.strip(),
        phone=payload.phone.strip(),
        address=payload.address.strip(),
        currency=payload.currency.strip().upper(),
    )
    db.add(shop)
    db.commit()
    db.refresh(shop)

    # Set as user's active shop
    current_user.active_shop_id = shop.id
    db.commit()

    return ShopResponse.model_validate(shop)


@router.get("", response_model=List[ShopResponse])
def get_user_shops(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    shops = db.scalars(
        select(Shop).where(Shop.owner_id == current_user.id).order_by(Shop.created_at.desc())
    ).all()
    return [ShopResponse.model_validate(s) for s in shops]


@router.get("/{shop_id}", response_model=ShopResponse)
def get_shop(
    shop_id: str,
    shop: Shop = Depends(get_current_shop),
):
    return ShopResponse.model_validate(shop)


@router.put("/{shop_id}", response_model=ShopResponse)
def update_shop(
    shop_id: str,
    payload: ShopUpdateRequest,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    if payload.name is not None:
        shop.name = payload.name.strip()
    if payload.owner_name is not None:
        shop.owner_name = payload.owner_name.strip()
    if payload.category is not None:
        shop.category = payload.category.strip()
    if payload.phone is not None:
        shop.phone = payload.phone.strip()
    if payload.address is not None:
        shop.address = payload.address.strip()
    if payload.currency is not None:
        shop.currency = payload.currency.strip().upper()
    if payload.logo_url is not None:
        shop.logo_url = payload.logo_url.strip()

    db.commit()
    db.refresh(shop)
    return ShopResponse.model_validate(shop)


@router.post("/{shop_id}/logo", response_model=ShopResponse)
async def upload_shop_logo(
    shop_id: str,
    file: UploadFile = File(...),
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    upload_dir = os.path.join(os.getcwd(), "uploads")
    os.makedirs(upload_dir, exist_ok=True)

    ext = os.path.splitext(file.filename or "")[1] or ".jpg"
    filename = f"shop_{shop.id}_{uuid.uuid4().hex[:8]}{ext}"
    filepath = os.path.join(upload_dir, filename)

    contents = await file.read()
    with open(filepath, "wb") as f:
        f.write(contents)

    logo_url = f"/uploads/{filename}"
    shop.logo_url = logo_url
    db.commit()
    db.refresh(shop)
    return ShopResponse.model_validate(shop)
