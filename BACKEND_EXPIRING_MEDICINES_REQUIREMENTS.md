# Backend Requirements – Medicines + Expiring Logic (Matches Flutter UI)

Purpose: This document tells the backend exactly what to implement and what to return so Flutter shows correct data in:
- Add Medicine screen (POST)
- Inventory list/search (GET)
- Expiring Medicines screen (GET with 0–10 days window) and Home KPI (expiring count)

All endpoints require Authorization: `Bearer <JWT>`

---

## 1) Add Medicine (Create)

Endpoint:
- Method: POST
- Path: `/api/medicines`
- Content-Type: `application/json`

Request body (Flutter already sends these fields):
```json
{
  "name": "Paracetamol 500mg",
  "genericName": "Acetaminophen",
  "form": "Tablet",           
  "packSize": "20 tablets",
  "quantity": 100,
  "price": 25.5,
  "expiryDate": "2026-09-29T22:00:00.000Z",
  "manufacturer": "ABC Pharma",
  "batchNumber": "BATCH123456",
  "category": "Over-the-Counter",
  "requiresPrescription": false
}
```

Validation notes:
- `form` must accept at least: `Tablet | Capsule | Syrup | Injection | Ointment | Cream | Drops | Inhaler | Other`
- `expiryDate` must be a valid ISO date string.

Response (on success – keep it simple and consistent):
```json
{
  "success": true,
  "message": "Medicine added successfully",
  "data": {
    "_id": "68da6bd36a8e18e0a0a80f3d",
    "name": "Paracetamol 500mg",
    "genericName": "Acetaminophen",
    "form": "Tablet",
    "packSize": "20 tablets",
    "quantity": 100,
    "price": 25.5,
    "expiryDate": "2026-09-29T22:00:00.000Z",
    "manufacturer": "ABC Pharma",
    "batchNumber": "BATCH123456",
    "category": "Over-the-Counter",
    "requiresPrescription": false,
    "createdAt": "2025-09-25T10:30:00.000Z",
    "updatedAt": "2025-09-25T10:30:00.000Z"
  }
}
```

Important: Persist ALL fields above in DB so they can be returned later; Flutter shows them directly and avoids showing "Unknown".

---

## 2) Get Medicines (Inventory/Search)

Endpoint:
- Method: GET
- Path: `/api/medicines/search`
- Query params supported: `q, category, page, limit`

Response (Flutter expects this shape):
```json
{
  "success": true,
  "data": {
    "medicines": [
      {
        "_id": "68da6bd36a8e18e0a0a80f3d",
        "name": "Paracetamol 500mg",
        "genericName": "Acetaminophen",
        "form": "Tablet",
        "packSize": "20 tablets",
        "quantity": 100,
        "price": 25.5,
        "expiryDate": "2026-09-29T22:00:00.000Z",
        "manufacturer": "ABC Pharma",
        "batchNumber": "BATCH123456",
        "category": "Over-the-Counter",
        "requiresPrescription": false
      }
    ],
    "totalPages": 1,
    "currentPage": 1,
    "total": 1
  }
}
```

Notes:
- Return FULL medicine objects (include manufacturer, category, batchNumber, requiresPrescription). Flutter uses these fields in Inventory and Expiring screens.

---

## 3) Expiring Medicines Logic (used by Flutter)

Flutter logic (already implemented):
- Fetches all medicines and filters locally to show only those expiring within the next 0..10 days (inclusive) and NOT already expired.
- Home KPI "Expiring Soon" shows the count using the same 0..10 window.

Backend options (either is fine):
1) Keep as-is: just make sure `expiryDate` is saved and returned correctly. Flutter will filter.
2) Optional bonus: Provide an endpoint that returns expiring medicines directly (recommended for performance on big data):
   - Method: GET
   - Path: `/api/medicines/expiring?days=10`
   - Returns the same medicine objects array as above, already filtered by `0..days`.

If you implement (2), response example:
```json
{
  "success": true,
  "data": [
    {
      "_id": "68da6bd36a8e18e0a0a80f3d",
      "name": "Paracetamol 500mg",
      "genericName": "Acetaminophen",
      "form": "Tablet",
      "packSize": "20 tablets",
      "quantity": 100,
      "price": 25.5,
      "expiryDate": "2025-10-02T22:00:00.000Z",
      "manufacturer": "ABC Pharma",
      "batchNumber": "BATCH123456",
      "category": "Over-the-Counter",
      "requiresPrescription": false
    }
  ]
}
```

---

## 4) Data Consistency Rules

- Field names must match exactly what Flutter uses: `name, genericName, form, packSize, quantity, price, expiryDate, manufacturer, batchNumber, category, requiresPrescription`.
- ID field is `_id` (Mongo style) – Flutter already supports `_id`.
- `expiryDate` must be ISO string (UTC preferred).
- `form` must accept: `Tablet | Capsule | Syrup | Injection | Ointment | Cream | Drops | Inhaler | Other`.

---

## 5) Testing Checklist for Backend

- [ ] POST /api/medicines saves all fields above
- [ ] GET /api/medicines/search returns all fields for each medicine
- [ ] Add a medicine with expiry = tomorrow → check it appears in GET and contains the exact values entered
- [ ] (Optional) GET /api/medicines/expiring?days=10 correctly returns only items in next 10 days
- [ ] All endpoints require valid JWT and return `{ success, data }` consistently

---

## 6) What Flutter Will Do Automatically

- Show all returned fields directly in Inventory and Expiring screens (no UI change required)
- Show "Unknown" only if a field is missing/null in the API response
- Count expiring items using `0..10` days window to display KPI in Home


