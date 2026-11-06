import os
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models  # noqa: F401 - register SQLAlchemy models
from app.api.routes import (
    admin_router,
    auth_router,
    dashboard_router,
    general_customers_router,
    general_expenses_router,
    general_products_router,
    general_reports_router,
    general_sales_router,
    shop_customers_router,
    shop_expenses_router,
    shop_products_router,
    shop_reports_router,
    shop_sales_router,
    shops_router,
    uploads_router,
)
from app.core.config import settings
from app.core.security import hash_password
from app.db.session import Base, SessionLocal, engine
from app.models.user import User


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Convenient for local development. Use Alembic migrations in production.
    Base.metadata.create_all(bind=engine)

    # Automatically upgrade SQLite schema if new columns are added
    try:
        with engine.connect() as conn:
            res = conn.exec_driver_sql("PRAGMA table_info(sales)").fetchall()
            cols = [r[1] for r in res]
            if cols:
                if "status" not in cols:
                    conn.exec_driver_sql("ALTER TABLE sales ADD COLUMN status VARCHAR(30) DEFAULT 'completed'")
                if "payment_method" not in cols:
                    conn.exec_driver_sql("ALTER TABLE sales ADD COLUMN payment_method VARCHAR(50) DEFAULT 'cash'")
                if "notes" not in cols:
                    conn.exec_driver_sql("ALTER TABLE sales ADD COLUMN notes VARCHAR(255)")
                conn.commit()
    except Exception:
        pass

    # Seed default administrator if not present
    with SessionLocal() as db:
        admin_user = db.scalar(select(User).where(User.email == "admin@amardokan.com"))
        if not admin_user:
            admin_user = User(
                email="admin@amardokan.com",
                full_name="System Administrator",
                phone="01700000000",
                password_hash=hash_password("Admin1234!"),
                role="admin",
                is_email_verified=True,
                is_active=True,
            )
            db.add(admin_user)
            db.commit()

    yield


app = FastAPI(
    title=settings.app_name,
    version="1.0.0",
    lifespan=lifespan,
    description="Backend REST API for Amar Dokan Retail Management System",
)

# Configure CORS
cors_kwargs = {}
if settings.cors_origins.strip() == "*":
    cors_kwargs["allow_origin_regex"] = ".*"
else:
    cors_kwargs["allow_origins"] = settings.cors_origin_list

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    **cors_kwargs,
)

# Mount static files directory for file and image uploads
uploads_dir = os.path.join(os.getcwd(), "uploads")
os.makedirs(uploads_dir, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=uploads_dir), name="uploads")


@app.get("/health", tags=["Health"])
def health():
    return {"status": "ok", "app": settings.app_name}


# Include all routers under API prefix (e.g. /api/v1)
prefix = settings.api_v1_prefix

app.include_router(auth_router, prefix=prefix)
app.include_router(admin_router, prefix=prefix)
app.include_router(shops_router, prefix=prefix)
app.include_router(shop_products_router, prefix=prefix)
app.include_router(general_products_router, prefix=prefix)
app.include_router(shop_customers_router, prefix=prefix)
app.include_router(general_customers_router, prefix=prefix)
app.include_router(shop_sales_router, prefix=prefix)
app.include_router(general_sales_router, prefix=prefix)
app.include_router(dashboard_router, prefix=prefix)
app.include_router(shop_expenses_router, prefix=prefix)
app.include_router(general_expenses_router, prefix=prefix)
app.include_router(shop_reports_router, prefix=prefix)
app.include_router(general_reports_router, prefix=prefix)
app.include_router(uploads_router, prefix=prefix)
