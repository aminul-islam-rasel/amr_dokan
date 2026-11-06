import uuid
from datetime import datetime, timezone
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import DateTime, Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base

if TYPE_CHECKING:
    from app.models.customer import Customer
    from app.models.sale_item import SaleItem
    from app.models.shop import Shop


class Sale(Base):
    __tablename__ = "sales"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    invoice_no: Mapped[str] = mapped_column(String(50), unique=True, index=True, nullable=False)
    shop_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("shops.id", ondelete="CASCADE"), index=True, nullable=False
    )
    customer_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("customers.id", ondelete="SET NULL"), nullable=True
    )
    customer_name: Mapped[Optional[str]] = mapped_column(String(150), nullable=True)
    customer_phone: Mapped[Optional[str]] = mapped_column(String(30), nullable=True)
    subtotal: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    discount: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    total: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    paid: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    due: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    status: Mapped[str] = mapped_column(String(30), default="completed", nullable=False)  # completed, pending, cancelled
    payment_method: Mapped[str] = mapped_column(String(50), default="cash", nullable=False)  # cash, bkash, nagad, card, due
    notes: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False
    )

    shop: Mapped["Shop"] = relationship("Shop", back_populates="sales")
    customer: Mapped[Optional["Customer"]] = relationship("Customer", back_populates="sales")
    items: Mapped[List["SaleItem"]] = relationship(
        "SaleItem", back_populates="sale", cascade="all, delete-orphan"
    )
