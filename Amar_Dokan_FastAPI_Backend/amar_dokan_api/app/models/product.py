import uuid
from datetime import datetime, timezone
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import DateTime, Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base

if TYPE_CHECKING:
    from app.models.category import ProductCategory
    from app.models.sale_item import SaleItem
    from app.models.shop import Shop


class Product(Base):
    __tablename__ = "products"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    shop_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("shops.id", ondelete="CASCADE"), index=True, nullable=False
    )
    category_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("product_categories.id", ondelete="SET NULL"), nullable=True
    )
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    barcode: Mapped[Optional[str]] = mapped_column(String(100), nullable=True, index=True)
    purchase_price: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    selling_price: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    current_stock: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    min_stock: Mapped[float] = mapped_column(Float, default=5.0, nullable=False)
    unit: Mapped[str] = mapped_column(String(30), default="pcs", nullable=False)
    image_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    shop: Mapped["Shop"] = relationship("Shop", back_populates="products")
    category: Mapped[Optional["ProductCategory"]] = relationship("ProductCategory", back_populates="products")
    sale_items: Mapped[List["SaleItem"]] = relationship("SaleItem", back_populates="product")
