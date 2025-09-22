# Missing Backend APIs Documentation

This document contains all the missing API endpoints that need to be implemented in the backend to complete the Flutter app integration.

## Overview

The Flutter app is 100% ready and integrated with the existing backend APIs. However, there are some missing endpoints that need to be implemented to provide full functionality for:

1. **User Settings Management**
2. **Delivery Address Management** 
3. **Payment Methods Management**

---

## 1. User Settings APIs

### Base URL: `/api/settings/user`

### 1.1 Get User Settings
**GET** `/api/settings/user`

Retrieves user-specific settings including notification preferences, currency, and other personal preferences.

#### Response
```json
{
  "success": true,
  "data": {
    "notificationsEnabled": true,
    "emailNotifications": true,
    "pushNotifications": true,
    "orderUpdates": true,
    "promotionalOffers": false,
    "currency": "USD",
    "language": "en",
    "theme": "light",
    "updatedAt": "2024-12-15T10:30:00.000Z"
  }
}
```

#### Implementation Notes
- Create a new `UserSettings` model in MongoDB
- Link settings to user via `userId` field
- Return default settings if none exist
- Settings should be user-specific (each user has their own settings)

---

### 1.2 Update User Settings
**PUT** `/api/settings/user`

Updates user-specific settings.

#### Request Body
```json
{
  "notificationsEnabled": true,
  "emailNotifications": true,
  "pushNotifications": true,
  "orderUpdates": true,
  "promotionalOffers": false,
  "currency": "USD",
  "language": "en",
  "theme": "light"
}
```

#### Response
```json
{
  "success": true,
  "message": "User settings updated successfully",
  "data": {
    "notificationsEnabled": true,
    "emailNotifications": true,
    "pushNotifications": true,
    "orderUpdates": true,
    "promotionalOffers": false,
    "currency": "USD",
    "language": "en",
    "theme": "light",
    "updatedAt": "2024-12-15T10:30:00.000Z"
  }
}
```

#### Implementation Notes
- Update existing settings or create new if none exist
- Validate currency codes (USD, EUR, GBP, SAR, EGP)
- Validate language codes (en, ar)
- Validate theme values (light, dark, system)

---

## 2. Delivery Address APIs

### Base URL: `/api/delivery`

### 2.1 Get Delivery Addresses
**GET** `/api/delivery/addresses`

Retrieves all delivery addresses for the authenticated user.

#### Response
```json
{
  "success": true,
  "data": [
    {
      "id": "addr_123456789",
      "name": "Home",
      "address": "123 Main Street, Apt 4B",
      "city": "New York",
      "state": "NY",
      "zipCode": "10001",
      "phone": "+1 (555) 123-4567",
      "landmark": "Near Central Park",
      "isDefault": true,
      "createdAt": "2024-12-15T10:30:00.000Z",
      "updatedAt": "2024-12-15T10:30:00.000Z"
    },
    {
      "id": "addr_987654321",
      "name": "Office",
      "address": "456 Business Ave, Suite 200",
      "city": "New York",
      "state": "NY",
      "zipCode": "10002",
      "phone": "+1 (555) 987-6543",
      "landmark": "Near Times Square",
      "isDefault": false,
      "createdAt": "2024-12-15T10:30:00.000Z",
      "updatedAt": "2024-12-15T10:30:00.000Z"
    }
  ]
}
```

#### Implementation Notes
- Create a new `DeliveryAddress` model in MongoDB
- Link addresses to user via `userId` field
- Return empty array if no addresses exist
- Sort by `isDefault` first, then by `createdAt`

---

### 2.2 Add Delivery Address
**POST** `/api/delivery/addresses`

Creates a new delivery address for the authenticated user.

#### Request Body
```json
{
  "name": "Home",
  "address": "123 Main Street, Apt 4B",
  "city": "New York",
  "state": "NY",
  "zipCode": "10001",
  "phone": "+1 (555) 123-4567",
  "landmark": "Near Central Park",
  "isDefault": true
}
```

#### Response
```json
{
  "success": true,
  "message": "Delivery address added successfully",
  "data": {
    "id": "addr_123456789",
    "name": "Home",
    "address": "123 Main Street, Apt 4B",
    "city": "New York",
    "state": "NY",
    "zipCode": "10001",
    "phone": "+1 (555) 123-4567",
    "landmark": "Near Central Park",
    "isDefault": true,
    "createdAt": "2024-12-15T10:30:00.000Z"
  }
}
```

#### Implementation Notes
- If `isDefault` is true, set all other addresses to `isDefault: false`
- Validate required fields: name, address, city, state, zipCode, phone
- Validate phone number format
- Validate zipCode format based on country/state
- Generate unique ID for each address

---

### 2.3 Set Default Delivery Address
**PUT** `/api/delivery/addresses/:id/default`

Sets a specific delivery address as the default for the authenticated user.

#### URL Parameters
- `id`: Delivery address identifier

#### Response
```json
{
  "success": true,
  "message": "Default delivery address updated successfully",
  "data": {
    "id": "addr_123456789",
    "isDefault": true,
    "updatedAt": "2024-12-15T10:30:00.000Z"
  }
}
```

#### Implementation Notes
- Set the specified address to `isDefault: true`
- Set all other addresses for the user to `isDefault: false`
- Verify the address belongs to the authenticated user
- Return 404 if address not found

---

### 2.4 Delete Delivery Address
**DELETE** `/api/delivery/addresses/:id`

Deletes a specific delivery address for the authenticated user.

#### URL Parameters
- `id`: Delivery address identifier

#### Response
```json
{
  "success": true,
  "message": "Delivery address deleted successfully"
}
```

#### Implementation Notes
- Verify the address belongs to the authenticated user
- Return 404 if address not found
- If deleting the default address, set another address as default (if any exist)
- Return 400 if trying to delete the last remaining address

---

## 3. Payment Methods APIs

### Base URL: `/api/payment`

### 3.1 Get Payment Methods
**GET** `/api/payment/methods`

Retrieves all payment methods for the authenticated user.

#### Response
```json
{
  "success": true,
  "data": [
    {
      "id": "pm_123456789",
      "type": "card",
      "cardNumber": "**** **** **** 1234",
      "cardholderName": "John Doe",
      "expiryDate": "12/25",
      "bankName": "Visa",
      "isDefault": true,
      "createdAt": "2024-12-15T10:30:00.000Z",
      "updatedAt": "2024-12-15T10:30:00.000Z"
    },
    {
      "id": "pm_987654321",
      "type": "bank",
      "bankName": "Chase Bank",
      "accountNumber": "****1234",
      "routingNumber": "****5678",
      "isDefault": false,
      "createdAt": "2024-12-15T10:30:00.000Z",
      "updatedAt": "2024-12-15T10:30:00.000Z"
    }
  ]
}
```

#### Implementation Notes
- Create a new `PaymentMethod` model in MongoDB
- Link payment methods to user via `userId` field
- Mask sensitive information (card numbers, account numbers)
- Return empty array if no payment methods exist
- Sort by `isDefault` first, then by `createdAt`

---

### 3.2 Add Payment Method
**POST** `/api/payment/methods`

Creates a new payment method for the authenticated user.

#### Request Body
```json
{
  "type": "card",
  "cardNumber": "4111111111111111",
  "cardholderName": "John Doe",
  "expiryDate": "12/25",
  "bankName": "Visa",
  "isDefault": true
}
```

#### Response
```json
{
  "success": true,
  "message": "Payment method added successfully",
  "data": {
    "id": "pm_123456789",
    "type": "card",
    "cardNumber": "**** **** **** 1111",
    "cardholderName": "John Doe",
    "expiryDate": "12/25",
    "bankName": "Visa",
    "isDefault": true,
    "createdAt": "2024-12-15T10:30:00.000Z"
  }
}
```

#### Implementation Notes
- If `isDefault` is true, set all other payment methods to `isDefault: false`
- Validate required fields based on type (card vs bank)
- Mask sensitive information in response
- Validate card number format (Luhn algorithm)
- Validate expiry date format (MM/YY)
- Encrypt sensitive data before storing in database

---

### 3.3 Set Default Payment Method
**PUT** `/api/payment/methods/:id/default`

Sets a specific payment method as the default for the authenticated user.

#### URL Parameters
- `id`: Payment method identifier

#### Response
```json
{
  "success": true,
  "message": "Default payment method updated successfully",
  "data": {
    "id": "pm_123456789",
    "isDefault": true,
    "updatedAt": "2024-12-15T10:30:00.000Z"
  }
}
```

#### Implementation Notes
- Set the specified payment method to `isDefault: true`
- Set all other payment methods for the user to `isDefault: false`
- Verify the payment method belongs to the authenticated user
- Return 404 if payment method not found

---

### 3.4 Delete Payment Method
**DELETE** `/api/payment/methods/:id`

Deletes a specific payment method for the authenticated user.

#### URL Parameters
- `id`: Payment method identifier

#### Response
```json
{
  "success": true,
  "message": "Payment method deleted successfully"
}
```

#### Implementation Notes
- Verify the payment method belongs to the authenticated user
- Return 404 if payment method not found
- If deleting the default payment method, set another payment method as default (if any exist)
- Return 400 if trying to delete the last remaining payment method
- Permanently delete sensitive data from database

---

## 4. Database Models

### 4.1 UserSettings Model
```javascript
const userSettingsSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  notificationsEnabled: {
    type: Boolean,
    default: true
  },
  emailNotifications: {
    type: Boolean,
    default: true
  },
  pushNotifications: {
    type: Boolean,
    default: true
  },
  orderUpdates: {
    type: Boolean,
    default: true
  },
  promotionalOffers: {
    type: Boolean,
    default: false
  },
  currency: {
    type: String,
    default: 'USD',
    enum: ['USD', 'EUR', 'GBP', 'SAR', 'EGP']
  },
  language: {
    type: String,
    default: 'en',
    enum: ['en', 'ar']
  },
  theme: {
    type: String,
    default: 'light',
    enum: ['light', 'dark', 'system']
  }
}, {
  timestamps: true
});
```

### 4.2 DeliveryAddress Model
```javascript
const deliveryAddressSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: true,
    maxlength: 100
  },
  address: {
    type: String,
    required: true,
    maxlength: 255
  },
  city: {
    type: String,
    required: true,
    maxlength: 100
  },
  state: {
    type: String,
    required: true,
    maxlength: 100
  },
  zipCode: {
    type: String,
    required: true,
    maxlength: 20
  },
  phone: {
    type: String,
    required: true,
    maxlength: 20
  },
  landmark: {
    type: String,
    maxlength: 255
  },
  isDefault: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});
```

### 4.3 PaymentMethod Model
```javascript
const paymentMethodSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    required: true,
    enum: ['card', 'bank']
  },
  // Card fields
  cardNumber: {
    type: String,
    required: function() { return this.type === 'card'; }
  },
  cardholderName: {
    type: String,
    required: function() { return this.type === 'card'; }
  },
  expiryDate: {
    type: String,
    required: function() { return this.type === 'card'; }
  },
  bankName: {
    type: String,
    required: true
  },
  // Bank fields
  accountNumber: {
    type: String,
    required: function() { return this.type === 'bank'; }
  },
  routingNumber: {
    type: String,
    required: function() { return this.type === 'bank'; }
  },
  isDefault: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});
```

---

## 5. Route Configuration

Add the following routes to your `server.js`:

```javascript
// Import new route files
const userSettingsRoutes = require('./routes/userSettings');
const deliveryRoutes = require('./routes/delivery');
const paymentRoutes = require('./routes/payment');

// Add route middleware
app.use('/api/settings/user', userSettingsRoutes);
app.use('/api/delivery', deliveryRoutes);
app.use('/api/payment', paymentRoutes);
```

---

## 6. Authentication & Authorization

All endpoints require:
- **Authentication**: Valid JWT token in Authorization header
- **Authorization**: User can only access their own data
- **Validation**: Proper input validation and sanitization

---

## 7. Error Handling

All endpoints should return consistent error responses:

```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error information"
}
```

Common HTTP status codes:
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `404`: Not Found
- `500`: Internal Server Error

---

## 8. Testing

After implementation, test all endpoints with:
- Valid authentication tokens
- Invalid/missing authentication
- Valid request data
- Invalid request data
- Edge cases (empty arrays, missing required fields)
- Authorization (users can only access their own data)

---

## 9. Priority

**High Priority:**
1. User Settings APIs (needed for app preferences)
2. Delivery Address APIs (needed for checkout flow)
3. Payment Methods APIs (needed for payment processing)

---

## 10. Notes

- All sensitive data should be encrypted before storing
- Implement proper validation for all input fields
- Use consistent response formats across all endpoints
- Add proper error logging for debugging
- Consider rate limiting for sensitive operations
- Implement proper data sanitization to prevent injection attacks

---

**This documentation provides everything needed to implement the missing backend APIs. The Flutter app is ready and will work seamlessly once these endpoints are implemented.**
