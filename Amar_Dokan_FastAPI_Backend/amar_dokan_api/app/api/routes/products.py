from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_active_or_first_shop, get_current_shop, get_current_user
from app.db.session import get_db
from app.models.category import ProductCategory
from app.models.product import Product
from app.models.shop import Shop
from app.models.user import User
from app.schemas.product import (
    CategoryCreateRequest,
    CategoryResponse,
    ProductCreateRequest,
    ProductResponse,
    ProductUpdateRequest,
)

# Router mounted at /shops/{shop_id}/products
shop_products_router = APIRouter(prefix="/shops/{shop_id}/products", tags=["Products"])

# Router for root-level products, categories, inventory
general_products_router = APIRouter(tags=["Products & Inventory"])


# --- Shop-nested Products Endpoints ---

@shop_products_router.get("", response_model=List[ProductResponse])
def get_products(
    shop_id: str,
    search: Optional[str] = Query(default=None),
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    stmt = select(Product).where(Product.shop_id == shop.id)
    if search and search.strip():
        term = f"%{search.strip()}%"
        stmt = stmt.where(or_(Product.name.ilike(term), Product.barcode.ilike(term)))
    stmt = stmt.order_by(Product.name.asc())
    products = db.scalars(stmt).all()
    return [ProductResponse.model_validate(p) for p in products]


@shop_products_router.post("", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def create_product(
    shop_id: str,
    payload: ProductCreateRequest,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    product = Product(
        shop_id=shop.id,
        name=payload.name.strip(),
        barcode=payload.barcode.strip() if payload.barcode else None,
        purchase_price=payload.purchase_price,
        selling_price=payload.selling_price,
        current_stock=payload.current_stock,
        min_stock=payload.min_stock,
        unit=payload.unit.strip(),
        category_id=payload.category_id,
        image_url=payload.image_url,
    )
    db.add(product)
    db.commit()
    db.refresh(product)
    return ProductResponse.model_validate(product)


@shop_products_router.get("/{product_id}", response_model=ProductResponse)
def get_product(
    shop_id: str,
    product_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    product = db.get(Product, product_id)
    if not product or product.shop_id != shop.id:
        raise HTTPException(status_code=404, detail="Product not found")
    return ProductResponse.model_validate(product)


@shop_products_router.put("/{product_id}", response_model=ProductResponse)
def update_product(
    shop_id: str,
    product_id: str,
    payload: ProductUpdateRequest,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    product = db.get(Product, product_id)
    if not product or product.shop_id != shop.id:
        raise HTTPException(status_code=404, detail="Product not found")

    if payload.name is not None:
        product.name = payload.name.strip()
    if payload.barcode is not None:
        product.barcode = payload.barcode.strip() if payload.barcode.strip() else None
    if payload.purchase_price is not None:
        product.purchase_price = payload.purchase_price
    if payload.selling_price is not None:
        product.selling_price = payload.selling_price
    if payload.current_stock is not None:
        product.current_stock = payload.current_stock
    if payload.min_stock is not None:
        product.min_stock = payload.min_stock
    if payload.unit is not None:
        product.unit = payload.unit.strip()
    if payload.category_id is not None:
        product.category_id = payload.category_id
    if payload.image_url is not None:
        product.image_url = payload.image_url

    db.commit()
    db.refresh(product)
    return ProductResponse.model_validate(product)


@shop_products_router.delete("/{product_id}")
def delete_product(
    shop_id: str,
    product_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    product = db.get(Product, product_id)
    if not product or product.shop_id != shop.id:
        raise HTTPException(status_code=404, detail="Product not found")

    db.delete(product)
    db.commit()
    return {"message": "Product deleted successfully"}


# --- Low Stock and Inventory ---

@general_products_router.get("/shops/{shop_id}/inventory/low-stock", response_model=List[ProductResponse])
def get_shop_low_stock(
    shop_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    stmt = (
        select(Product)
        .where(Product.shop_id == shop.id, Product.current_stock <= Product.min_stock)
        .order_by(Product.current_stock.asc())
    )
    products = db.scalars(stmt).all()
    return [ProductResponse.model_validate(p) for p in products]


# --- Root-level convenience endpoints from ApiEndpoints.dart ---

@general_products_router.get("/products", response_model=List[ProductResponse])
def get_products_root(
    shop_id: Optional[str] = Query(default=None),
    search: Optional[str] = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if shop_id:
        shop = db.get(Shop, shop_id)
        if not shop or shop.owner_id != current_user.id:
            raise HTTPException(status_code=404, detail="Shop not found")
    else:
        shop = get_active_or_first_shop(current_user=current_user, db=db)

    stmt = select(Product).where(Product.shop_id == shop.id)
    if search and search.strip():
        term = f"%{search.strip()}%"
        stmt = stmt.where(or_(Product.name.ilike(term), Product.barcode.ilike(term)))
    stmt = stmt.order_by(Product.name.asc())
    products = db.scalars(stmt).all()
    return [ProductResponse.model_validate(p) for p in products]


@general_products_router.get("/inventory/low-stock", response_model=List[ProductResponse])
def get_inventory_low_stock_root(
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

    stmt = (
        select(Product)
        .where(Product.shop_id == shop.id, Product.current_stock <= Product.min_stock)
        .order_by(Product.current_stock.asc())
    )
    products = db.scalars(stmt).all()
    return [ProductResponse.model_validate(p) for p in products]


@general_products_router.get("/inventory")
def get_inventory_summary_root(
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

    products = db.scalars(select(Product).where(Product.shop_id == shop.id)).all()
    total_items = len(products)
    total_valuation = sum(p.current_stock * p.purchase_price for p in products)
    low_stock = sum(1 for p in products if p.current_stock <= p.min_stock)

    return {
        "shop_id": shop.id,
        "total_items": total_items,
        "total_valuation": total_valuation,
        "low_stock_count": low_stock,
    }


@general_products_router.get("/categories", response_model=List[CategoryResponse])
def get_categories_root(
    shop_id: Optional[str] = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if shop_id:
        target_shop_id = shop_id
    elif current_user.active_shop_id:
        target_shop_id = current_user.active_shop_id
    else:
        target_shop_id = None

    stmt = select(ProductCategory)
    if target_shop_id:
        stmt = stmt.where(or_(ProductCategory.shop_id == target_shop_id, ProductCategory.shop_id.is_(None)))
    categories = db.scalars(stmt).all()
    return [CategoryResponse.model_validate(c) for c in categories]


@general_products_router.post("/categories", response_model=CategoryResponse, status_code=status.HTTP_201_CREATED)
def create_category_root(
    payload: CategoryCreateRequest,
    shop_id: Optional[str] = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    target_shop_id = shop_id or current_user.active_shop_id
    cat = ProductCategory(shop_id=target_shop_id, name=payload.name.strip())
    db.add(cat)
    db.commit()
    db.refresh(cat)
    return CategoryResponse.model_validate(cat)
