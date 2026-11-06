import io
import pytest
from fastapi.testclient import TestClient

from app.db.session import Base, engine
from app.main import app

# Ensure tables are created
Base.metadata.create_all(bind=engine)
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

client = TestClient(app)


@pytest.fixture(scope="module")
def auth_context():
    # 1. Register User
    reg_res = client.post(
        "/api/v1/auth/register",
        json={
            "email": "test_owner@example.com",
            "password": "Password123!",
            "name": "Rasel Ahmed",
            "phone": "01712345678",
        },
    )
    if reg_res.status_code == 409:
        # Already exists, login
        login_res = client.post(
            "/api/v1/auth/login",
            json={"email": "test_owner@example.com", "password": "Password123!"},
        )
        data = login_res.json()
    else:
        assert reg_res.status_code == 201
        data = reg_res.json()

    access_token = data["access_token"]
    refresh_token = data["refresh_token"]
    headers = {"Authorization": f"Bearer {access_token}"}
    return {"headers": headers, "refresh_token": refresh_token}


def test_auth_me(auth_context):
    res = client.get("/api/v1/auth/me", headers=auth_context["headers"])
    assert res.status_code == 200
    data = res.json()
    assert data["email"] == "test_owner@example.com"
    assert data["name"] == "Rasel Ahmed"


def test_auth_forgot_and_reset_password():
    # Forgot password
    res = client.post("/api/v1/auth/forgot-password", json={"email": "test_owner@example.com"})
    assert res.status_code == 200
    code = res.json().get("code")

    # Reset password with received code
    res = client.post(
        "/api/v1/auth/reset-password",
        json={"email": "test_owner@example.com", "code": code, "new_password": "NewPassword123!"},
    )
    assert res.status_code == 200

    # Reset back to original password for other tests
    res = client.post(
        "/api/v1/auth/reset-password",
        json={"email": "test_owner@example.com", "code": "123456", "new_password": "Password123!"},
    )
    assert res.status_code == 200


def test_auth_verify_email():
    res = client.post(
        "/api/v1/auth/verify-email",
        json={"email": "test_owner@example.com", "code": "123456"},
    )
    assert res.status_code == 200


def test_shop_categories():
    res = client.get("/api/v1/shops/categories")
    assert res.status_code == 200
    categories = res.json()
    assert isinstance(categories, list)
    assert any(c["key"] == "grocery" for c in categories)


def test_full_business_workflow(auth_context):
    headers = auth_context["headers"]

    # 1. Create Shop
    shop_res = client.post(
        "/api/v1/shops",
        headers=headers,
        json={
            "name": "Amar Dokan Dhanmondi",
            "owner_name": "Rasel Ahmed",
            "category": "grocery",
            "phone": "01712345678",
            "address": "Road 27, Dhanmondi, Dhaka",
            "currency": "BDT",
        },
    )
    assert shop_res.status_code == 201
    shop = shop_res.json()
    shop_id = shop["id"]
    assert shop["name"] == "Amar Dokan Dhanmondi"

    # 2. Get User Shops
    shops_res = client.get("/api/v1/shops", headers=headers)
    assert shops_res.status_code == 200
    assert any(s["id"] == shop_id for s in shops_res.json())

    # 3. Create Products
    prod1_res = client.post(
        f"/api/v1/shops/{shop_id}/products",
        headers=headers,
        json={
            "name": "Soyabean Oil 1L",
            "barcode": "8941234567890",
            "purchase_price": 150.0,
            "selling_price": 165.0,
            "current_stock": 50.0,
            "min_stock": 10.0,
            "unit": "ltr",
        },
    )
    assert prod1_res.status_code == 201
    prod1 = prod1_res.json()
    prod1_id = prod1["id"]

    prod2_res = client.post(
        f"/api/v1/shops/{shop_id}/products",
        headers=headers,
        json={
            "name": "Miniket Rice 1kg",
            "barcode": "8941234567891",
            "purchase_price": 65.0,
            "selling_price": 75.0,
            "current_stock": 8.0,  # Below min_stock to trigger low stock
            "min_stock": 15.0,
            "unit": "kg",
        },
    )
    assert prod2_res.status_code == 201
    prod2 = prod2_res.json()
    prod2_id = prod2["id"]

    # 4. List and Search Products
    prod_list = client.get(f"/api/v1/shops/{shop_id}/products", headers=headers).json()
    assert len(prod_list) >= 2

    search_res = client.get(
        f"/api/v1/shops/{shop_id}/products", headers=headers, params={"search": "Soyabean"}
    ).json()
    assert len(search_res) == 1
    assert search_res[0]["id"] == prod1_id

    # 5. Check Low Stock Endpoint
    low_stock = client.get(f"/api/v1/shops/{shop_id}/inventory/low-stock", headers=headers).json()
    assert any(p["id"] == prod2_id for p in low_stock)

    # 6. Create Customer
    cust_res = client.post(
        f"/api/v1/shops/{shop_id}/customers",
        headers=headers,
        json={
            "name": "Karim Mia",
            "phone": "01811223344",
            "address": "Dhanmondi, Dhaka",
        },
    )
    assert cust_res.status_code == 201
    cust = cust_res.json()
    cust_id = cust["id"]
    assert cust["total_due"] == 0.0

    # 7. POS Sale Checkout (1 bottle oil + 2 kg rice, partial payment to test due)
    # Total calculation:
    # 1 * 165 = 165
    # 2 * 75 = 150
    # Subtotal = 315
    # Discount = 15
    # Total = 300
    # Paid = 200
    # Due = 100
    sale_res = client.post(
        f"/api/v1/shops/{shop_id}/sales",
        headers=headers,
        json={
            "items": [
                {"product_id": prod1_id, "quantity": 1.0, "discount": 0.0},
                {"product_id": prod2_id, "quantity": 2.0, "discount": 0.0},
            ],
            "discount": 15.0,
            "paid": 200.0,
            "customer_name": "Karim Mia",
            "customer_phone": "01811223344",
        },
    )
    assert sale_res.status_code == 201
    sale = sale_res.json()
    assert sale["subtotal"] == 315.0
    assert sale["total"] == 300.0
    assert sale["paid"] == 200.0
    assert sale["due"] == 100.0
    assert len(sale["items"]) == 2

    # Verify inventory was decremented
    updated_prod1 = client.get(f"/api/v1/shops/{shop_id}/products/{prod1_id}", headers=headers).json()
    assert updated_prod1["current_stock"] == 49.0  # was 50

    # Verify customer's due and purchase was updated
    updated_cust = client.get(f"/api/v1/shops/{shop_id}/customers/{cust_id}", headers=headers).json()
    assert updated_cust["total_due"] == 100.0
    assert updated_cust["total_purchase"] == 300.0

    # 8. Collect Due from Customer
    collect_res = client.post(
        f"/api/v1/shops/{shop_id}/customers/{cust_id}/collect-due",
        headers=headers,
        json={"amount": 60.0, "note": "Partial due payment"},
    )
    assert collect_res.status_code == 200
    assert collect_res.json()["remaining_due"] == 40.0

    # 9. Create Expense
    expense_res = client.post(
        f"/api/v1/shops/{shop_id}/expenses",
        headers=headers,
        json={
            "title": "Shop Electricity Bill",
            "category": "utilities",
            "amount": 50.0,
            "note": "Electricity for current month",
        },
    )
    assert expense_res.status_code == 201
    expense = expense_res.json()
    assert expense["amount"] == 50.0

    # 10. Verify Dashboard Summary
    dash_summary = client.get(f"/api/v1/shops/{shop_id}/dashboard/summary", headers=headers).json()
    assert dash_summary["todays_sales"] >= 300.0
    assert dash_summary["todays_expenses"] >= 50.0
    assert dash_summary["total_due"] >= 40.0
    assert dash_summary["total_products"] >= 2
    assert dash_summary["total_customers"] >= 1

    # 11. Verify Dashboard Recent Transactions
    transactions = client.get(f"/api/v1/shops/{shop_id}/dashboard/transactions", headers=headers).json()
    assert isinstance(transactions, list)
    assert len(transactions) >= 3  # Sale, Expense, Due Collection
    types = [t["type"] for t in transactions]
    assert "sale" in types
    assert "expense" in types
    assert "due_collection" in types

    # 12. Verify Reports
    daily_report = client.get(f"/api/v1/shops/{shop_id}/reports/daily", headers=headers).json()
    assert daily_report["total_sales"] >= 300.0

    pl_report = client.get(f"/api/v1/shops/{shop_id}/reports/profit-loss", headers=headers).json()
    assert pl_report["gross_sales"] >= 315.0

    # 13. Test Image/File Upload
    fake_image = io.BytesIO(b"fake image bytes content")
    fake_image.name = "test_product.jpg"
    upload_res = client.post(
        "/api/v1/upload",
        headers=headers,
        files={"file": ("test_product.jpg", fake_image, "image/jpeg")},
    )
    assert upload_res.status_code == 200
    upload_data = upload_res.json()
    assert upload_data["url"].startswith("/uploads/")


def test_auth_refresh_and_logout(auth_context):
    headers = auth_context["headers"]
    refresh_token = auth_context["refresh_token"]

    # Refresh
    ref_res = client.post("/api/v1/auth/refresh", json={"refresh_token": refresh_token})
    assert ref_res.status_code == 200
    new_refresh = ref_res.json()["refresh_token"]

    # Logout
    logout_res = client.post("/api/v1/auth/logout", json={"refresh_token": new_refresh})
    assert logout_res.status_code in (200, 204)


def test_admin_api_endpoints(auth_context):
    headers = auth_context["headers"]

    # 1. Admin Stats
    stats_res = client.get("/api/v1/admin/stats", headers=headers)
    assert stats_res.status_code == 200
    stats = stats_res.json()
    assert stats["total_users"] >= 1
    assert "sales_analytics" in stats
    assert "order_statistics" in stats

    # 2. Admin Users
    users_res = client.get("/api/v1/admin/users", headers=headers)
    assert users_res.status_code == 200
    users_data = users_res.json()
    assert users_data["total"] >= 1
    assert len(users_data["items"]) >= 1

    # 3. Admin Orders
    orders_res = client.get("/api/v1/admin/orders", headers=headers)
    assert orders_res.status_code == 200
    orders_data = orders_res.json()
    assert "items" in orders_data

    # 4. Admin Notifications
    notif_res = client.get("/api/v1/admin/notifications", headers=headers)
    assert notif_res.status_code == 200
    assert isinstance(notif_res.json(), list)

    # 5. Admin Settings
    settings_res = client.get("/api/v1/admin/settings", headers=headers)
    assert settings_res.status_code == 200
    assert settings_res.json()["company_name"] == "Amar Dokan"

