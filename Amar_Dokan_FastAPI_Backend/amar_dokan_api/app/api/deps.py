from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.orm import Session
import jwt

from app.core.security import decode_access_token
from app.db.session import get_db
from app.models.shop import Shop
from app.models.user import User

bearer_scheme = HTTPBearer(auto_error=False)


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> User:
    unauthorized = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired access token",
        headers={"WWW-Authenticate": "Bearer"},
    )
    if credentials is None:
        raise unauthorized
    try:
        payload = decode_access_token(credentials.credentials)
    except (jwt.PyJWTError, ValueError):
        raise unauthorized
    user = db.get(User, payload["sub"])
    if user is None or not user.is_active:
        raise unauthorized
    return user


def get_current_admin(
    current_user: User = Depends(get_current_user),
) -> User:
    if current_user.role not in ("admin", "superadmin", "owner"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Administrative privileges required to access this resource",
        )
    return current_user


def get_current_shop(
    shop_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Shop:
    shop = db.get(Shop, shop_id)
    if shop is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Shop not found")
    if current_user.role not in ("admin", "superadmin") and shop.owner_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied for this shop")
    return shop


def get_active_or_first_shop(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Shop:
    if current_user.active_shop_id:
        shop = db.get(Shop, current_user.active_shop_id)
        if shop and (current_user.role in ("admin", "superadmin") or shop.owner_id == current_user.id):
            return shop
    if current_user.role in ("admin", "superadmin"):
        shop = db.scalar(select(Shop).order_by(Shop.created_at.desc()))
        if shop:
            return shop
    shop = db.scalar(select(Shop).where(Shop.owner_id == current_user.id).order_by(Shop.created_at.asc()))
    if shop is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No active shop found. Please create or set up a shop first.",
        )
    return shop
