from app.api.routes.admin import router as admin_router
from app.api.routes.auth import router as auth_router
from app.api.routes.customers import (
    general_customers_router,
    shop_customers_router,
)
from app.api.routes.dashboard import router as dashboard_router
from app.api.routes.expenses import (
    general_expenses_router,
    shop_expenses_router,
)
from app.api.routes.products import (
    general_products_router,
    shop_products_router,
)
from app.api.routes.reports import (
    general_reports_router,
    shop_reports_router,
)
from app.api.routes.sales import general_sales_router, shop_sales_router
from app.api.routes.shops import router as shops_router
from app.api.routes.uploads import router as uploads_router

__all__ = [
    "admin_router",
    "auth_router",
    "shops_router",
    "shop_products_router",
    "general_products_router",
    "shop_customers_router",
    "general_customers_router",
    "shop_sales_router",
    "general_sales_router",
    "dashboard_router",
    "shop_expenses_router",
    "general_expenses_router",
    "shop_reports_router",
    "general_reports_router",
    "uploads_router",
]
