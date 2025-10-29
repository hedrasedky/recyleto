# Backend Transaction Data Requirements

## Overview
This document outlines the data structure requirements for transaction APIs to support the Flutter frontend screens. When a transaction is processed from the Add Transaction screen, it should be saved in the backend and displayed in three different formats across three screens.

---

## 1. Sales Screen Requirements

### API Endpoint
```
GET /api/transactions
```

### Data Structure Required
```json
{
  "success": true,
  "data": [
    {
      "_id": "transaction_id",
      "transactionId": "TXN-20241215-1234ABC",
      "transactionReference": "REF-ABC123DE",
      "createdAt": "2024-12-15T10:30:00.000Z",
      "status": "completed",
      "customerInfo": {
        "name": "John Doe",
        "phone": "+1234567890"
      },
      "customerName": "John Doe",
      "items": [
        {
          "medicineId": "med_123",
          "name": "Paracetamol",
          "quantity": 2,
          "unitPrice": 25.50
        }
      ],
      "totalAmount": 51.00,
      "total": 51.00,
      "amount": 51.00,
      "pharmacyId": "pharmacy_123"
    }
  ]
}
```

### Display Format in Sales Screen
- **Card Layout**: Each transaction displayed as a card
- **Transaction ID**: Shows `transactionId` or `transactionReference` or `id`
- **Date & Time**: Shows formatted date and time from `createdAt`
- **Customer**: Shows `customerInfo.name` or `customerName`
- **Items Count**: Shows number of items in `items` array
- **Total Amount**: Shows `totalAmount` or `total` or `amount`
- **Status**: Shows `status` with color coding (completed=green, pending=orange, refunded=red)

---

## 2. Transaction Details Screen Requirements

### API Endpoint
```
GET /api/transactions/:id
```

### Data Structure Required
```json
{
  "success": true,
  "data": {
    "_id": "transaction_id",
    "transactionId": "TXN-20241215-1234ABC",
    "transactionReference": "REF-ABC123DE",
    "createdAt": "2024-12-15T10:30:00.000Z",
    "status": "completed",
    "customerInfo": {
      "name": "John Doe",
      "phone": "+1234567890",
      "email": "john@example.com"
    },
    "items": [
      {
        "medicineId": "med_123",
        "name": "Paracetamol 500mg",
        "genericName": "Acetaminophen",
        "form": "Tablet",
        "quantity": 2,
        "unitPrice": 25.50,
        "totalPrice": 51.00,
        "manufacturer": "ABC Pharma"
      }
    ],
    "totalAmount": 51.00,
    "subtotal": 50.00,
    "tax": 1.00,
    "discount": 0.00,
    "paymentMethod": "cash",
    "notes": "Customer requested receipt",
    "description": "Walk-in customer purchase"
  }
}
```

### Display Format in Transaction Details Screen
- **Status Card**: Shows transaction status with icon and color
- **Customer Information**: Shows customer details from `customerInfo`
- **Order Items**: Shows detailed list of items with medicine details
- **Payment Summary**: Shows subtotal, tax, discount, total
- **Transaction Notes**: Shows `notes` and `description` if available
- **Action Buttons**: Print receipt, share, etc.

---

## 3. Market Screen Requirements

### API Endpoint
```
GET /api/market/search
```

### Data Structure Required
```json
{
  "success": true,
  "data": [
    {
      "_id": "transaction_id",
      "invoiceNumber": "INV-20241215-001",
      "pharmacyName": "ABC Pharmacy",
      "pharmacyId": "pharmacy_123",
      "date": "2024-12-15",
      "invoiceType": "complete",
      "totalAmount": 51.00,
      "discount": 5.0,
      "finalAmount": 48.45,
      "medicines": [
        {
          "id": "med_123",
          "name": "Paracetamol 500mg",
          "genericName": "Acetaminophen",
          "activeIngredient": "Acetaminophen",
          "category": "Pain Relief",
          "manufacturer": "ABC Pharma",
          "price": 25.50,
          "quantity": 2,
          "form": "Tablet"
        }
      ],
      "status": "completed",
      "createdAt": "2024-12-15T10:30:00.000Z"
    }
  ]
}
```

### Display Format in Market Screen
- **Invoice Card Layout**: Each transaction displayed as an invoice card
- **Invoice Header**: Shows `invoiceNumber` and `pharmacyName`
- **Amount**: Shows `finalAmount` with currency
- **Date**: Shows `date`
- **Type**: Shows `invoiceType` (complete/partial)
- **Items Count**: Shows number of items in `medicines` array
- **Discount**: Shows `discount` percentage if > 0
- **Medicines Preview**: Shows first 3 medicines with details
- **Expandable**: Can expand to show all medicines
- **Action Button**: Different actions based on `invoiceType`

---

## 4. Data Flow Summary

### When Process Transaction is called:
1. **Save Transaction**: Store transaction in backend with all required fields
2. **Sales Screen**: Display transaction in list format with summary info
3. **Transaction Details**: Display full transaction details when tapped
4. **Market Screen**: Display transaction as invoice card with medicine details

### Key Points:
- **Same Transaction**: All three screens display the same transaction data
- **Different Formats**: Each screen has its own display format
- **Consistent Data**: All screens use the same transaction ID and core data
- **Flexible Fields**: Some fields are optional (notes, description, customer info)

---

## 5. Field Mapping

| Field | Sales Screen | Transaction Details | Market Screen |
|-------|-------------|-------------------|---------------|
| transactionId | ✅ Title | ✅ Header | ❌ |
| transactionReference | ✅ Title | ✅ Header | ❌ |
| createdAt | ✅ Date/Time | ✅ Date/Time | ✅ Date |
| status | ✅ Status Badge | ✅ Status Card | ✅ Status |
| customerInfo | ✅ Customer Name | ✅ Full Details | ❌ |
| items | ✅ Count Only | ✅ Full Details | ✅ As medicines |
| totalAmount | ✅ Amount | ✅ Payment Summary | ✅ Amount |
| invoiceNumber | ❌ | ❌ | ✅ Title |
| pharmacyName | ❌ | ❌ | ✅ Subtitle |
| invoiceType | ❌ | ❌ | ✅ Type Badge |
| discount | ❌ | ✅ Payment Summary | ✅ Discount % |
| notes | ❌ | ✅ Notes Section | ❌ |
| description | ❌ | ✅ Notes Section | ❌ |

---

## 6. Implementation Notes

### Backend Requirements:
1. **Transaction Storage**: Save complete transaction data with all fields
2. **API Endpoints**: Provide endpoints for all three screens
3. **Data Consistency**: Ensure same transaction ID across all endpoints
4. **Field Validation**: Validate all required fields before saving

### Frontend Requirements:
1. **Data Parsing**: Handle different field names (totalAmount vs total vs amount)
2. **Null Safety**: Handle missing optional fields gracefully
3. **Date Formatting**: Format dates consistently across screens
4. **Status Colors**: Map status values to appropriate colors

---

## 7. Example API Responses

### Sales Screen Response:
```json
{
  "success": true,
  "data": [
    {
      "_id": "675e123456789abc12345678",
      "transactionId": "TXN-20241215-1234ABC",
      "createdAt": "2024-12-15T10:30:00.000Z",
      "status": "completed",
      "customerInfo": {"name": "John Doe"},
      "items": [{"medicineId": "med_123", "name": "Paracetamol", "quantity": 2}],
      "totalAmount": 51.00
    }
  ]
}
```

### Transaction Details Response:
```json
{
  "success": true,
  "data": {
    "_id": "675e123456789abc12345678",
    "transactionId": "TXN-20241215-1234ABC",
    "createdAt": "2024-12-15T10:30:00.000Z",
    "status": "completed",
    "customerInfo": {"name": "John Doe", "phone": "+1234567890"},
    "items": [{"medicineId": "med_123", "name": "Paracetamol", "quantity": 2, "unitPrice": 25.50}],
    "totalAmount": 51.00,
    "notes": "Customer requested receipt"
  }
}
```

### Market Screen Response:
```json
{
  "success": true,
  "data": [
    {
      "_id": "675e123456789abc12345678",
      "invoiceNumber": "INV-20241215-001",
      "pharmacyName": "ABC Pharmacy",
      "date": "2024-12-15",
      "invoiceType": "complete",
      "totalAmount": 51.00,
      "discount": 5.0,
      "finalAmount": 48.45,
      "medicines": [{"id": "med_123", "name": "Paracetamol", "price": 25.50}]
    }
  ]
}
```

---

## 8. Testing Checklist

### Backend Testing:
- [ ] Transaction creation saves all required fields
- [ ] Sales API returns transactions in correct format
- [ ] Transaction details API returns full transaction data
- [ ] Market API returns transactions as invoice cards
- [ ] All APIs handle missing optional fields gracefully

### Frontend Testing:
- [ ] Sales screen displays transactions correctly
- [ ] Transaction details screen shows full details
- [ ] Market screen displays invoice cards
- [ ] All screens handle null/missing data gracefully
- [ ] Date formatting works consistently
- [ ] Status colors display correctly

---

## 9. Conclusion

This document provides a comprehensive guide for implementing transaction data requirements across all three screens. The key is to maintain data consistency while providing the appropriate level of detail for each screen's specific use case.

**Remember**: The same transaction should be accessible from all three screens, but each screen displays it in its own format optimized for its specific functionality.
