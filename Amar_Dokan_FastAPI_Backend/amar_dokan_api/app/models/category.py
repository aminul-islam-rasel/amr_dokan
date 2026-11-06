import uuid
from datetime import datetime, timezone
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base

if TYPE_CHECKING:
    from app.models.product import Product
    from app.models.shop import Shop


class ProductCategory(Base):
    __tablename__ = "product_categories"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    shop_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("shops.id", ondelete="CASCADE"), index=True, nullable=True
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False
    )

    shop: Mapped[Optional["Shop"]] = relationship("Shop", back_populates="categories")
    products: Mapped[List["Product"]] = relationship("Product", back_populates="category")
