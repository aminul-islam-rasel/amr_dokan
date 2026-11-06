import uuid
from datetime import datetime, timezone
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import DateTime, Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base

if TYPE_CHECKING:
    from app.models.due_payment import DuePayment
    from app.models.sale import Sale
    from app.models.shop import Shop


class Customer(Base):
    __tablename__ = "customers"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    shop_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("shops.id", ondelete="CASCADE"), index=True, nullable=False
    )
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    phone: Mapped[str] = mapped_column(String(30), nullable=False, index=True)
    address: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    total_due: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    total_purchase: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    shop: Mapped["Shop"] = relationship("Shop", back_populates="customers")
    due_payments: Mapped[List["DuePayment"]] = relationship(
        "DuePayment", back_populates="customer", cascade="all, delete-orphan"
    )
    sales: Mapped[List["Sale"]] = relationship("Sale", back_populates="customer")
