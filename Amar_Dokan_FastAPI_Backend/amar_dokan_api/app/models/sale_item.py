import uuid
from typing import TYPE_CHECKING, Optional

from sqlalchemy import Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base

if TYPE_CHECKING:
    from app.models.product import Product
    from app.models.sale import Sale


class SaleItem(Base):
    __tablename__ = "sale_items"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    sale_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("sales.id", ondelete="CASCADE"), index=True, nullable=False
    )
    product_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("products.id", ondelete="SET NULL"), nullable=True
    )
    product_name: Mapped[str] = mapped_column(String(200), nullable=False)
    unit_price: Mapped[float] = mapped_column(Float, nullable=False)
    purchase_price: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    quantity: Mapped[float] = mapped_column(Float, nullable=False)
    discount: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    subtotal: Mapped[float] = mapped_column(Float, nullable=False)

    sale: Mapped["Sale"] = relationship("Sale", back_populates="items")
    product: Mapped[Optional["Product"]] = relationship("Product", back_populates="sale_items")
