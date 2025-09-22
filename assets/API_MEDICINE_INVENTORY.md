# 🆕 Recyleto API: Added/Modified Endpoints (Inventory)

## 💊 Add New Medicine

- **POST** `/api/medicines`
- **Description**: Add new medicine to inventory
- **Body Example**:
  ```json
  {
    "name": "Paracetamol 500mg",
    "genericName": "Acetaminophen",
    "form": "Tablet",
    "packSize": "10 tablets",
    "quantity": 100,
    "price": 25.99,
    "expiryDate": "2025-12-31T00:00:00.000Z",
    "manufacturer": "PharmaCorp Ltd.",
    "batchNumber": "PCT2024001",
    "description": "Used for pain relief and fever.",
    "isOTC": true
  }
  ```
- **Notes**:
  - `form` must be one of: Tablet, Capsule, Syrup, Injection, Cream, Ointment, Drops, Inhaler, Patch, Powder, Gel, Lotion
  - `expiryDate` is ISO8601 string
  - `isOTC`: true (OTC) or false (Prescription)

---

## 🗂️ Get All Medicines (with Search/Filter)

- **GET** `/api/medicines`
- **Query Parameters**:
  - `search`: (optional) search by name or genericName
  - `form`: (optional) filter by form
  - `category`: (optional) filter by category

---

## 🔍 Get Medicine By ID

- **GET** `/api/medicines/:id`
- **Description**: Get details for a specific medicine

---

## ✏️ Update Medicine

- **PATCH** `/api/medicines/:id`
- **Description**: Update medicine info (same body as add)

---

## 🗑️ Delete Medicine

- **DELETE** `/api/medicines/:id`
- **Description**: Remove medicine from inventory

---

## 📉 Get Low Stock Medicines

- **GET** `/api/medicines/low-stock`
- **Description**: List medicines with low stock

---

## ⏰ Get Expiring Medicines

- **GET** `/api/medicines/expiring`
- **Description**: List medicines expiring soon

---

## 🏷️ Update Medicine Stock Only

- **PATCH** `/api/medicines/:id/stock`
- **Body**:
  ```json
  { "quantity": 50 }
  ```

---

## ⚠️ Error Response Example

```json
{
  "success": false,
  "message": "Error description"
}
```

---

## ℹ️ All endpoints require authentication header:

```
Authorization: Bearer <token>
```

---

# 🚀 Recyleto API: Main Endpoints (All App)

## 🔐 Authentication

### 1. Login
- **POST** `/api/auth/login`
- **Body**:
  ```json
  { "email": "demo@pharmacy.com", "password": "demo123456" }
  ```
- **Response**:
  ```json
  { "success": true, "token": "...", "user": { "id": "...", "email": "..." } }
  ```

### 2. Forgot Password
- **POST** `/api/auth/forgot-password`
- **Body**:
  ```json
  { "email": "demo@pharmacy.com" }
  ```

### 3. Reset Password
- **POST** `/api/auth/reset-password`
- **Body**:
  ```json
  { "email": "demo@pharmacy.com", "code": "123456", "newPassword": "newpassword123" }
  ```

### 4. Register Pharmacy
- **POST** `/api/auth/register-pharmacy`
- **Body**: (multipart/form-data)
  - pharmacyName, businessEmail, businessPhone, mobileNumber, password, businessAddress[...], licenseImage

---

## 📊 Dashboard

### 1. Get Dashboard Data
- **GET** `/api/dashboard`
- **Query**: `startDate`, `endDate`, `status`

### 2. Get Statistics
- **GET** `/api/dashboard/statistics`

### 3. Get Alerts
- **GET** `/api/dashboard/alerts`

### 4. Get Recent Activities
- **GET** `/api/dashboard/recent-activities`
- **Query**: `limit`, `type`

### 5. Get Notifications
- **GET** `/api/dashboard/notifications`

### 6. Create Request
- **POST** `/api/dashboard/requests`
- **Body**:
  ```json
  { "type": "request_type", "description": "Request description", "priority": "high|medium|low" }
  ```

---

## 💊 Medicines (see above for details)

---

## 💰 Transactions

### 1. Add to Cart
- **POST** `/api/transactions/cart`
- **Body**:
  ```json
  { "medicineId": "...", "quantity": 5, "price": 25.99 }
  ```

### 2. Get Cart
- **GET** `/api/transactions/cart`

### 3. Update Cart Item
- **PUT** `/api/transactions/cart/:itemId`
- **Body**:
  ```json
  { "quantity": 10 }
  ```

### 4. Remove from Cart
- **DELETE** `/api/transactions/cart/:itemId`

### 5. Clear Cart
- **DELETE** `/api/transactions/cart`

### 6. Create Transaction
- **POST** `/api/transactions`
- **Body**:
  ```json
  { "items": [ { "medicineId": "...", "quantity": 5, "price": 25.99 } ], "totalAmount": 129.95, "paymentMethod": "cash|card|transfer" }
  ```

---

## 📈 Reports

### 1. Sales Report
- **GET** `/api/reports/sales`
- **Query**: `startDate`, `endDate`, `category`, `paymentMethod`

### 2. Inventory Report
- **GET** `/api/reports/inventory`
- **Query**: `category`, `stockStatus`, `expiryStatus`

### 3. Performance Report
- **GET** `/api/reports/performance`
- **Query**: `startDate`, `endDate`, `metric`

---

## 🆘 Support

### 1. Send Support Message
- **POST** `/api/support/messages`
- **Body**:
  ```json
  { "message": "I need help..." }
  ```

### 2. Get Support Messages
- **GET** `/api/support/messages`

### 3. Create Support Ticket
- **POST** `/api/support/tickets`
- **Body**:
  ```json
  { "subject": "Issue", "description": "Details..." }
  ```

### 4. Get Support Tickets
- **GET** `/api/support/tickets`

---

## 🚚 Delivery

### 1. Create Delivery
- **POST** `/api/delivery`
- **Body**: deliveryData

### 2. Get Delivery Status
- **GET** `/api/delivery/:id`

### 3. Update Delivery Status
- **PATCH** `/api/delivery/:id/status`
- **Body**:
  ```json
  { "status": "delivered" }
  ```

---

## 💳 Payments

### 1. Process Payment
- **POST** `/api/payments/process`
- **Body**: paymentData

### 2. Get Payment Methods
- **GET** `/api/payments/methods`

### 3. Get Payment History
- **GET** `/api/payments/history`
- **Query**: `startDate`, `endDate`, `status`

### 4. Refund Payment
- **POST** `/api/payments/:id/refund`
- **Body**: refundData

---

## 👤 User Management

### 1. Get Users
- **GET** `/api/users`

### 2. Create User
- **POST** `/api/users`
- **Body**: userData

### 3. Update User
- **PUT** `/api/users/:id`
- **Body**: userData

### 4. Delete User
- **DELETE** `/api/users/:id`

### 5. Update User Role
- **PATCH** `/api/users/:id/role`
- **Body**:
  ```json
  { "role": "manager" }
  ```

---

## ⚙️ Settings

### 1. Get System Settings
- **GET** `/api/settings`

### 2. Update System Settings
- **PUT** `/api/settings`
- **Body**: settings

---

## 📦 Export & Analytics

### 1. Export Data
- **POST** `/api/export/:type`
- **Body**: exportParams

### 2. Get Analytics
- **GET** `/api/analytics`
- **Query**: `period`, `metric`

---

## 📝 Error Response Example

```json
{ "success": false, "message": "Error description" }
```

---

## ℹ️ All endpoints require authentication header:

```
Authorization: Bearer <token>
```
