from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_active_or_first_shop, get_current_shop, get_current_user
from app.db.session import get_db
from app.models.expense import Expense
from app.models.shop import Shop
from app.models.user import User
from app.schemas.expense import ExpenseCreateRequest, ExpenseResponse

# Router mounted at /shops/{shop_id}/expenses
shop_expenses_router = APIRouter(prefix="/shops/{shop_id}/expenses", tags=["Expenses"])

# Router for root-level expenses
general_expenses_router = APIRouter(tags=["Expenses"])


@shop_expenses_router.get("", response_model=List[ExpenseResponse])
def get_expenses(
    shop_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    expenses = db.scalars(
        select(Expense).where(Expense.shop_id == shop.id).order_by(Expense.created_at.desc())
    ).all()
    return [ExpenseResponse.model_validate(e) for e in expenses]


@shop_expenses_router.post("", response_model=ExpenseResponse, status_code=status.HTTP_201_CREATED)
def create_expense(
    shop_id: str,
    payload: ExpenseCreateRequest,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    expense = Expense(
        shop_id=shop.id,
        title=payload.title.strip(),
        category=payload.category.strip(),
        amount=payload.amount,
        note=payload.note.strip() if payload.note else None,
    )
    db.add(expense)
    db.commit()
    db.refresh(expense)
    return ExpenseResponse.model_validate(expense)


@shop_expenses_router.delete("/{expense_id}")
def delete_expense(
    shop_id: str,
    expense_id: str,
    shop: Shop = Depends(get_current_shop),
    db: Session = Depends(get_db),
):
    expense = db.get(Expense, expense_id)
    if not expense or expense.shop_id != shop.id:
        raise HTTPException(status_code=404, detail="Expense not found")
    db.delete(expense)
    db.commit()
    return {"message": "Expense deleted successfully"}


# --- Root-level convenience endpoints from ApiEndpoints.dart ---

@general_expenses_router.get("/expenses", response_model=List[ExpenseResponse])
def get_expenses_root(
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

    expenses = db.scalars(
        select(Expense).where(Expense.shop_id == shop.id).order_by(Expense.created_at.desc())
    ).all()
    return [ExpenseResponse.model_validate(e) for e in expenses]


@general_expenses_router.post("/expenses", response_model=ExpenseResponse, status_code=status.HTTP_201_CREATED)
def create_expense_root(
    payload: ExpenseCreateRequest,
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

    expense = Expense(
        shop_id=shop.id,
        title=payload.title.strip(),
        category=payload.category.strip(),
        amount=payload.amount,
        note=payload.note.strip() if payload.note else None,
    )
    db.add(expense)
    db.commit()
    db.refresh(expense)
    return ExpenseResponse.model_validate(expense)
