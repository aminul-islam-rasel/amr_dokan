# Amar Dokan API (FastAPI Backend)

Complete REST API backend for the **Amar Dokan** Flutter application.

## Features & Endpoints Implemented

### 1. Authentication (`/api/v1/auth`)
- `POST /api/v1/auth/register`: Register user with name, email, phone, and password.
- `POST /api/v1/auth/login`: Login with email and password, returns JWT access token and refresh token.
- `POST /api/v1/auth/refresh`: Rotate refresh token and obtain a new access token.
- `POST /api/v1/auth/logout`: Revoke active refresh token.
- `POST /api/v1/auth/forgot-password`: Request 6-digit OTP code for password reset.
- `POST /api/v1/auth/reset-password`: Reset password using OTP code and new password.
- `POST /api/v1/auth/verify-email`: Verify email using 6-digit OTP code.
- `GET /api/v1/auth/me`: Get current authenticated user profile.

### 2. Shop Management (`/api/v1/shops`)
- `GET /api/v1/shops/categories`: Get business categories list (grocery, clothing, electronics, etc.).
- `POST /api/v1/shops`: Create a new shop and set it as the user's active shop.
- `GET /api/v1/shops`: List all shops owned by the user.
- `GET /api/v1/shops/{shop_id}`: Get specific shop details.
- `PUT /api/v1/shops/{shop_id}`: Update shop information.
- `POST /api/v1/shops/{shop_id}/logo`: Upload shop logo image.

### 3. Products & Inventory (`/api/v1/shops/{shop_id}/products` & `/api/v1/products`)
- `GET /api/v1/shops/{shop_id}/products`: List products with search filter (`?search=...`).
- `POST /api/v1/shops/{shop_id}/products`: Add new product (name, barcode, purchase price, selling price, current stock, min stock, unit).
- `GET /api/v1/shops/{shop_id}/products/{product_id}`: Get single product details.
- `PUT /api/v1/shops/{shop_id}/products/{product_id}`: Update product details and inventory.
- `DELETE /api/v1/shops/{shop_id}/products/{product_id}`: Remove product.
- `GET /api/v1/shops/{shop_id}/inventory/low-stock`: Retrieve products whose stock is at or below minimum threshold.
- `GET /api/v1/products`: Convenience root endpoint for products list.
- `GET /api/v1/inventory/low-stock`: Convenience root endpoint for low-stock items.
- `GET /api/v1/categories`: List product categories.

### 4. Customers & Dues (`/api/v1/shops/{shop_id}/customers` & `/api/v1/customers`)
- `GET /api/v1/shops/{shop_id}/customers`: List customers with search filter (`?search=...`).
- `POST /api/v1/shops/{shop_id}/customers`: Create customer record.
- `GET /api/v1/shops/{shop_id}/customers/{customer_id}`: View customer profile with due balance and purchase history.
- `PUT /api/v1/shops/{shop_id}/customers/{customer_id}`: Update customer profile.
- `DELETE /api/v1/shops/{shop_id}/customers/{customer_id}`: Delete customer record.
- `POST /api/v1/shops/{shop_id}/customers/{customer_id}/collect-due`: Record due payment and deduct customer's outstanding balance.
- `GET /api/v1/dues`: List all customers with outstanding due balances.
- `POST /api/v1/dues/collect`: Convenience root endpoint for due collection.

### 5. Sales & POS Checkout (`/api/v1/shops/{shop_id}/sales` & `/api/v1/sales`)
- `POST /api/v1/shops/{shop_id}/sales` & `POST /api/v1/sales/checkout`: POS checkout:
  - Generates unique invoice number (e.g. `INV-XXXXXX`).
  - Deducts item quantities from inventory stock.
  - Automatically manages customer due balance if partial payment is made.
  - Records full itemized invoice.
- `GET /api/v1/shops/{shop_id}/sales`: List sale invoice history.
- `GET /api/v1/shops/{shop_id}/sales/{sale_id}`: View itemized sale invoice details.

### 6. Dashboard Analytics (`/api/v1/shops/{shop_id}/dashboard`)
- `GET /api/v1/shops/{shop_id}/dashboard/summary`:
  - `todays_sales`: Sum of today's total sales.
  - `todays_profit`: Net calculated profit for today (sales gross profit minus expenses).
  - `todays_expenses`: Sum of expenses recorded today.
  - `total_due`: Total due amount outstanding from all customers.
  - `total_products`: Total products catalog count.
  - `total_customers`: Total customer count.
  - `low_stock_count`: Count of products requiring restocking.
- `GET /api/v1/shops/{shop_id}/dashboard/transactions`: List recent activities combining sales, expenses, and due collections.

### 7. Expenses (`/api/v1/shops/{shop_id}/expenses` & `/api/v1/expenses`)
- `GET /api/v1/shops/{shop_id}/expenses`: List expenses for shop.
- `POST /api/v1/shops/{shop_id}/expenses`: Record new operating expense (utilities, rent, salaries, etc.).
- `DELETE /api/v1/shops/{shop_id}/expenses/{expense_id}`: Delete an expense record.

### 8. Reports (`/api/v1/shops/{shop_id}/reports` & `/api/v1/reports`)
- `GET /api/v1/shops/{shop_id}/reports/daily`: Daily sales, profit, and order breakdown.
- `GET /api/v1/shops/{shop_id}/reports/monthly`: Monthly financial report.
- `GET /api/v1/shops/{shop_id}/reports/profit-loss`: Complete profit & loss statement (Gross Sales, COGS, Gross Profit, Operating Expenses, Net Profit).

### 9. File & Image Uploads (`/api/v1/upload`)
- `POST /api/v1/upload`: Upload product images or attachments.
- `POST /api/v1/shops/{shop_id}/upload`: Upload shop documents or photos.
- Uploaded files are served directly under `/uploads/{filename}` via static mounting.

---

## Quickstart

### 1. Run the API
Open terminal in `Amar_Dokan_FastAPI_Backend/amar_dokan_api`:

```powershell
..\.venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 2. Run Tests
```powershell
..\.venv\Scripts\python.exe -m pytest -v
```

### 3. Open Documentation
- Interactive Swagger UI: `http://127.0.0.1:8000/docs`
- Health check: `http://127.0.0.1:8000/health`
