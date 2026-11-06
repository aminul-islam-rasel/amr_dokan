from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_active_or_first_shop, get_current_shop, get_current_user
from app.db.session import get_db
from app.models.customer import Customer
from app.models.due_payment import DuePayment
from app.models.shop import Shop
from app.models.user import User
from app.schemas.customer import (
    CustomerCreateRequest,
    CustomerResponse,
    CustomerUpdateRequest,
    DueCollectionRequest,
)

# Router mounted at /shops/{shop_id}/customers
shop_customers_router = APIRouter(prefix="/shops/{shop_id}/customers", tags=["Customers"])

# Router for root-level customers & dues
general_customers_router = APIRouter(tags=["Customers & Dues"])


# --- Shop-nested Customers Endpoints ---

@shop_customers_router.get("", response_model=List[CustomerResponse])
def get_customers(
    shop_id: str,
    search: Optional[str] = Query(default=None),
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    stmt = select(Customer).where(Customer.shop_id == shop.id)
    if search and search.strip():
        term = f"%{search.strip()}%"
        stmt = stmt.where(or_(Customer.name.ilike(term), Customer.phone.ilike(term)))
    stmt = stmt.order_by(Customer.name.asc())
    customers = db.scalars(stmt).all()
    return [CustomerResponse.model_validate(c) for c in customers]


@shop_customers_router.post("", response_model=CustomerResponse, status_code=status.HTTP_201_CREATED)
def create_customer(
    shop_id: str,
    payload: CustomerCreateRequest,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    customer = Customer(
        shop_id=shop.id,
        name=payload.name.strip(),
        phone=payload.phone.strip(),
        address=payload.address.strip() if payload.address else None,
        total_due=0.0,
        total_purchase=0.0,
    )
    db.add(customer)
    db.commit()
    db.refresh(customer)
    return CustomerResponse.model_validate(customer)


@shop_customers_router.get("/{customer_id}", response_model=CustomerResponse)
def get_customer(
    shop_id: str,
    customer_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    customer = db.get(Customer, customer_id)
    if not customer or customer.shop_id != shop.id:
        raise HTTPException(status_code=404, detail="Customer not found")
    return CustomerResponse.model_validate(customer)


@shop_customers_router.put("/{customer_id}", response_model=CustomerResponse)
def update_customer(
    shop_id: str,
    customer_id: str,
    payload: CustomerUpdateRequest,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    customer = db.get(Customer, customer_id)
    if not customer or customer.shop_id != shop.id:
        raise HTTPException(status_code=404, detail="Customer not found")

    if payload.name is not None:
        customer.name = payload.name.strip()
    if payload.phone is not None:
        customer.phone = payload.phone.strip()
    if payload.address is not None:
        customer.address = payload.address.strip() if payload.address.strip() else None

    db.commit()
    db.refresh(customer)
    return CustomerResponse.model_validate(customer)


@shop_customers_router.delete("/{customer_id}")
def delete_customer(
    shop_id: str,
    customer_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    customer = db.get(Customer, customer_id)
    if not customer or customer.shop_id != shop.id:
        raise HTTPException(status_code=404, detail="Customer not found")

    db.delete(customer)
    db.commit()
    return {"message": "Customer deleted successfully"}


@shop_customers_router.post("/{customer_id}/collect-due")
def collect_due(
    shop_id: str,
    customer_id: str,
    payload: DueCollectionRequest,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    customer = db.get(Customer, customer_id)
    if not customer or customer.shop_id != shop.id:
        raise HTTPException(status_code=404, detail="Customer not found")

    # Record the payment
    payment = DuePayment(
        shop_id=shop.id,
        customer_id=customer.id,
        amount=payload.amount,
        note=payload.note,
    )
    db.add(payment)

    # Adjust customer due
    customer.total_due = max(0.0, customer.total_due - payload.amount)
    db.commit()
    db.refresh(customer)

    return {
        "message": "Due collected successfully",
        "collected_amount": payload.amount,
        "remaining_due": customer.total_due,
        "customer": CustomerResponse.model_validate(customer),
    }


# --- Root-level convenience endpoints from ApiEndpoints.dart ---

@general_customers_router.get("/customers", response_model=List[CustomerResponse])
def get_customers_root(
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

    stmt = select(Customer).where(Customer.shop_id == shop.id)
    if search and search.strip():
        term = f"%{search.strip()}%"
        stmt = stmt.where(or_(Customer.name.ilike(term), Customer.phone.ilike(term)))
    stmt = stmt.order_by(Customer.name.asc())
    customers = db.scalars(stmt).all()
    return [CustomerResponse.model_validate(c) for c in customers]


@general_customers_router.get("/dues", response_model=List[CustomerResponse])
def get_dues_root(
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
        select(Customer)
        .where(Customer.shop_id == shop.id, Customer.total_due > 0)
        .order_by(Customer.total_due.desc())
    )
    customers = db.scalars(stmt).all()
    return [CustomerResponse.model_validate(c) for c in customers]


class RootDueCollectRequest(BaseModel):
    customer_id: str
    amount: float = Field(gt=0.0)
    note: Optional[str] = None
    shop_id: Optional[str] = None


@general_customers_router.post("/dues/collect")
def collect_due_root(
    payload: RootDueCollectRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    customer = db.get(Customer, payload.customer_id)
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    shop = db.get(Shop, customer.shop_id)
    if not shop or shop.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Access denied")

    payment = DuePayment(
        shop_id=shop.id,
        customer_id=customer.id,
        amount=payload.amount,
        note=payload.note,
    )
    db.add(payment)

    customer.total_due = max(0.0, customer.total_due - payload.amount)
    db.commit()
    db.refresh(customer)

    return {
        "message": "Due collected successfully",
        "collected_amount": payload.amount,
        "remaining_due": customer.total_due,
        "customer": CustomerResponse.model_validate(customer),
    }
