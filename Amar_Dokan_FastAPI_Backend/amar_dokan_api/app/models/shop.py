import uuid
from datetime import datetime, timezone
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base

if TYPE_CHECKING:
    from app.models.category import ProductCategory
    from app.models.customer import Customer
    from app.models.expense import Expense
    from app.models.product import Product
    from app.models.sale import Sale
    from app.models.user import User


class Shop(Base):
    __tablename__ = "shops"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    owner_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    owner_name: Mapped[str] = mapped_column(String(120), nullable=False)
    category: Mapped[str] = mapped_column(String(60), default="grocery", nullable=False)
    phone: Mapped[str] = mapped_column(String(30), nullable=False)
    address: Mapped[str] = mapped_column(String(255), default="", nullable=False)
    currency: Mapped[str] = mapped_column(String(10), default="BDT", nullable=False)
    logo_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    owner: Mapped["User"] = relationship("User", back_populates="shops")
    products: Mapped[List["Product"]] = relationship(
        "Product", back_populates="shop", cascade="all, delete-orphan"
    )
    customers: Mapped[List["Customer"]] = relationship(
        "Customer", back_populates="shop", cascade="all, delete-orphan"
    )
    sales: Mapped[List["Sale"]] = relationship(
        "Sale", back_populates="shop", cascade="all, delete-orphan"
    )
    expenses: Mapped[List["Expense"]] = relationship(
        "Expense", back_populates="shop", cascade="all, delete-orphan"
    )
    categories: Mapped[List["ProductCategory"]] = relationship(
        "ProductCategory", back_populates="shop", cascade="all, delete-orphan"
    )
