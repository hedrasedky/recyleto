# 🚀 Recyleto API Documentation

## Base URL

```
http://localhost:5000/api
```

## 🔐 Authentication

All protected routes require a valid JWT token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

---

## 📍 Authentication Routes (`/api/auth`)

### 1. User Login

- **POST** `/api/auth/login`
- **Description**: Authenticate user and get JWT token
- **Body**:
  ```json
  {
    "email": "admin@recyleto.com",
    "password": "demo123456"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "68a9bd6e9fa43e99dedb5b83",
      "email": "demo@pharmacy.com",
      "username": "demopharmacy",
      "pharmacyName": "Demo Pharmacy"
    }
  }
  ```

### 2. Forgot Password

- **POST** `/api/auth/forgot-password`
- **Description**: Send password reset code to email
- **Body**:
  ```json
  {
    "email": "demo@pharmacy.com"
  }
  ```

### 3. Reset Password

- **POST** `/api/auth/reset-password`
- **Description**: Reset password using reset code
- **Body**:
  ```json
  {
    "email": "demo@pharmacy.com",
    "code": "123456",
    "newPassword": "newpassword123"
  }
  ```

### 4. Register Pharmacy

- **POST** `/api/auth/register-pharmacy`
- **Description**: Register new pharmacy account
- **Body** (multipart/form-data):
  ```
  pharmacyName: "New Pharmacy"
  businessEmail: "pharmacy@example.com"
  businessPhone: "+1234567890"
  mobileNumber: "+1234567890"
  password: "password123"
  businessAddress[street]: "123 Main St"
  businessAddress[city]: "City"
  businessAddress[state]: "State"
  businessAddress[zipCode]: "12345"
  licenseImage: [file upload]
  ```

---

## 📊 Dashboard Routes (`/api/dashboard`)

_All routes require authentication_

### 1. Get Dashboard Data

- **GET** `/api/dashboard`
- **Query Parameters**:
  - `startDate`: Start date filter (YYYY-MM-DD)
  - `endDate`: End date filter (YYYY-MM-DD)
  - `status`: Filter by status

### 2. Get Dashboard Statistics (NEW - Real-time KPIs)

- **GET** `/api/dashboard/statistics`
- **Description**: Get real-time dashboard statistics and KPIs
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "sales": {
        "today": 2450.0,
        "week": 12500.0,
        "month": 52000.0,
        "change": "+12.5%"
      },
      "inventory": {
        "lowStock": 8,
        "expiringSoon": 15,
        "totalItems": 1250,
        "categories": 45
      },
      "transactions": {
        "today": 23,
        "week": 156,
        "month": 678,
        "refundRequests": 3
      },
      "performance": {
        "customerSatisfaction": 4.8,
        "orderAccuracy": 98.5,
        "responseTime": "2.3 min"
      }
    }
  }
  ```

### 3. Get Real-time Alerts (NEW - Automated Alerts)

- **GET** `/api/dashboard/alerts`
- **Description**: Get real-time system alerts and notifications
- **Response**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "alert_001",
        "type": "low_stock",
        "priority": "high",
        "title": "Low Stock Alert",
        "message": "Paracetamol 500mg tablets are running low (5 units remaining)",
        "medicineId": "med_123",
        "medicineName": "Paracetamol 500mg",
        "currentStock": 5,
        "minStock": 20,
        "createdAt": "2024-01-15T10:30:00Z",
        "isRead": false
      },
      {
        "id": "alert_002",
        "type": "expiry",
        "priority": "critical",
        "title": "Expiry Alert",
        "message": "Amoxicillin 250mg capsules expire in 7 days",
        "medicineId": "med_456",
        "medicineName": "Amoxicillin 250mg",
        "expiryDate": "2024-01-22",
        "daysUntilExpiry": 7,
        "currentStock": 150,
        "createdAt": "2024-01-15T09:15:00Z",
        "isRead": false
      }
    ]
  }
  ```

### 4. Get Recent Activities (NEW - Real-time Feed)

- **GET** `/api/dashboard/recent-activities`
- **Description**: Get recent system activities and user actions
- **Query Parameters**:
  - `limit`: Number of activities to return (default: 10)
  - `type`: Filter by activity type (sale, inventory, refund, etc.)
- **Response**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "activity_001",
        "type": "sale",
        "title": "Sale Completed",
        "subtitle": "Transaction #TX-2024-001",
        "amount": 45.0,
        "currency": "USD",
        "time": "2024-01-15T12:30:00Z",
        "timeAgo": "2 hours ago",
        "details": {
          "transactionId": "TX-2024-001",
          "customerName": "John Doe",
          "itemsCount": 3,
          "paymentMethod": "card"
        }
      },
      {
        "id": "activity_002",
        "type": "inventory",
        "title": "Medicine Added",
        "subtitle": "Ibuprofen 400mg tablets",
        "amount": "50 units",
        "time": "2024-01-15T10:45:00Z",
        "timeAgo": "4 hours ago",
        "details": {
          "medicineId": "med_789",
          "medicineName": "Ibuprofen 400mg",
          "quantity": 50,
          "addedBy": "admin@pharmacy.com"
        }
      }
    ]
  }
  ```

### 5. Get Notifications

- **GET** `/api/dashboard/notifications`
- **Description**: Get user notifications
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "unreadCount": 5,
      "notifications": [
        {
          "id": "notif_001",
          "type": "system",
          "title": "System Update",
          "message": "New features available in your dashboard",
          "isRead": false,
          "createdAt": "2024-01-15T08:00:00Z"
        }
      ]
    }
  }
  ```

### 6. Create Request

- **POST** `/api/dashboard/requests`
- **Description**: Create new request
- **Body**:
  ```json
  {
    "type": "request_type",
    "description": "Request description",
    "priority": "high|medium|low"
  }
  ```

---

## 💊 Medicine Routes (`/api/medicines`)

_All routes require authentication_

### 1. Add Medicine

- **POST** `/api/medicines`
- **Description**: Add new medicine to inventory
- **Body**:
  ```json
  {
    "name": "Medicine Name",
    "genericName": "Generic Name",
    "category": "Category",
    "strength": "10mg",
    "form": "tablet",
    "quantity": 100,
    "expiryDate": "2025-12-31",
    "price": 25.99,
    "manufacturer": "Manufacturer Name"
  }
  ```

### 2. Search Medicines

- **GET** `/api/medicines/search`
- **Query Parameters**:
  - `q`: Search query
  - `category`: Filter by category
  - `form`: Filter by form

### 3. Get Medicine by ID

- **GET** `/api/medicines/:id`
- **Description**: Get specific medicine details

### 4. Update Medicine

- **PUT** `/api/medicines/:id`
- **Description**: Update medicine information
- **Body**: Same as Add Medicine

---

## 💰 Transaction Routes (`/api/transactions`)

_All routes require authentication_

### 1. Add to Cart

- **POST** `/api/transactions/cart`
- **Description**: Add item to shopping cart
- **Body**:
  ```json
  {
    "medicineId": "medicine_id_here",
    "quantity": 5,
    "price": 25.99
  }
  ```

### 2. Get Cart

- **GET** `/api/transactions/cart`
- **Description**: Get current cart items

### 3. Update Cart Item

- **PUT** `/api/transactions/cart/:itemId`
- **Description**: Update cart item quantity
- **Body**:
  ```json
  {
    "quantity": 10
  }
  ```

### 4. Remove from Cart

- **DELETE** `/api/transactions/cart/:itemId`
- **Description**: Remove item from cart

### 5. Clear Cart

- **DELETE** `/api/transactions/cart`
- **Description**: Clear entire cart

### 6. Create Transaction

- **POST** `/api/transactions`
- **Description**: Complete purchase transaction
- **Body**:
  ```json
  {
    "items": [
      {
        "medicineId": "medicine_id",
        "quantity": 5,
        "price": 25.99
      }
    ],
    "totalAmount": 129.95,
    "paymentMethod": "cash|card|transfer"
  }
  ```

---

## 🔧 Demo User Credentials

For testing purposes, use these credentials:

```json
{
  "email": "demo@pharmacy.com",
  "password": "demo123456"
}
```

---

## 📝 Error Responses

All endpoints return consistent error responses:

```json
{
  "success": false,
  "message": "Error description"
}
```

### Common HTTP Status Codes:

- **200**: Success
- **201**: Created
- **400**: Bad Request (validation errors)
- **401**: Unauthorized (invalid/missing token)
- **404**: Not Found
- **500**: Internal Server Error

---

## 🚀 Getting Started

1. **Start the server**:

   ```bash
   npm start
   ```

2. **Login to get token**:

   ```bash
   curl -X POST http://localhost:5000/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email": "demo@pharmacy.com", "password": "demo123456"}'
   ```

3. **Use token for protected routes**:
   ```bash
   curl -X GET http://localhost:5000/api/dashboard \
     -H "Authorization: Bearer YOUR_TOKEN_HERE"
   ```

---

## 📁 File Uploads

- **License Images**: Uploaded to `/uploads/licenses/`
- **Supported Formats**: Images (jpg, png, gif)
- **Max Size**: Configured in upload middleware

---

## 🔒 Security Features

- JWT-based authentication
- Password hashing with bcrypt
- Protected routes with middleware
- Input validation and sanitization
- CORS enabled for cross-origin requests
