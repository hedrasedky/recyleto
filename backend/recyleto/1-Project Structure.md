# Recyleto Backend

A comprehensive backend system for managing medicine inventory, transactions, and pharmacy operations with support functionality.

## 📂 Project Structure

```
recyleto/
├── config/
│   └── db.js                           # MongoDB database connection configuration
├── controllers/
│   ├── authController.js               # User authentication, registration, login, logout, and 2FA operations
│   ├── dashboardController.js          # Analytics dashboard data aggregation and business insights
│   ├── medicineController.js           # Medicine CRUD operations, inventory management, and stock control
│   ├── transactionController.js        # Shopping cart operations and transaction queries
│   ├── checkoutController.js           # Payment processing, order completion, and draft transaction handling
│   ├── refundController.js             # Refund request processing and refund history management
│   ├── requestController.js            # Medicine request functionality for unavailable items
│   ├── profileController.js            # User profile management and pharmacy information updates
│   ├── supportController.js            # Customer support ticket creation and management
│   └── businessSettingsController.js  # Business configuration and operational settings management
├── middleware/
│   ├── auth.js                         # JWT authentication middleware with 2FA verification and role authorization
│   ├── upload.js                       # Multer file upload configuration for images and documents
│   └── validateResult.js               # Express-validator error handling and response formatting
├── models/
│   ├── User.js                         # User schema with authentication, roles, 2FA settings, and notification preferences
│   ├── Medicine.js                     # Medicine inventory schema with pricing, stock, and low stock thresholds
│   ├── Transaction.js                  # Transaction records with items, payments, refunds, and draft status
│   ├── Cart.js                         # Shopping cart schema with items and calculation helper methods
│   ├── Inventory.js                    # Stock tracking schema with expiry dates and stock movements
│   ├── Receipt.js                      # Receipt generation schema for completed transactions
│   ├── Refund.js                       # Refund request schema with approval workflow and processing status
│   ├── Request.js                      # Medicine request schema for items not in current inventory
│   ├── Counter.js                      # Atomic counter schema for generating unique transaction numbers
│   ├── Support.js                      # Support ticket schema with priority, status, and attachment handling
│   └── BusinessSettings.js             # Business configuration schema for operational parameters and preferences
├── routes/
│   ├── auth.js                         # Authentication endpoints including registration, login, and 2FA setup
│   ├── dashboard.js                    # Dashboard analytics endpoints with filtered data and reports
│   ├── medicine.js                     # Medicine management endpoints for CRUD operations and inventory
│   ├── transaction.js                  # Transaction endpoints for cart management and order history
│   ├── checkout.js                     # Checkout endpoints for payment processing and order completion
│   ├── refund.js                       # Refund management endpoints for requests and processing
│   ├── request.js                      # Medicine request endpoints for customer requests
│   ├── profile.js                      # User profile management endpoints and pharmacy settings
│   ├── support.js                      # Customer support endpoints for ticket management
│   └── businessSettings.js             # Business settings endpoints for configuration management
├── templates/
│   ├── receipt.ejs                     # EJS template for generating formatted receipts
│   └── emails/                         # Email template directory for automated notifications
│       ├── supportTicketConfirmation.ejs    # Support ticket creation confirmation email
│       ├── supportStatusUpdate.ejs          # Support ticket status change notification email
│       └── supportResponse.ejs              # Support team response email template
├── validators/
│   ├── authValidator.js                # Input validation for authentication forms and 2FA
│   ├── pharmacyValidator.js            # Validation rules for pharmacy registration and verification
│   ├── medicineValidator.js            # Medicine data validation including pricing and stock
│   ├── transactionValidator.js         # Cart and transaction data validation rules
│   ├── checkoutValidator.js            # Checkout process validation including payment details
│   ├── refundValidator.js              # Refund request validation with reason and item checks
│   ├── requestValidator.js             # Medicine request validation for customer requests
│   ├── profileValidator.js             # User profile update validation rules
│   ├── supportValidator.js             # Support ticket validation including attachments
│   └── businessSettingsValidator.js   # Business settings validation for configuration changes
├── utils/
│   ├── mailer.js                       # Email and SMS service integration with template rendering
│   ├── helpers.js                      # Utility functions for transaction numbers, currency formatting, and dates
│   ├── receiptGenerator.js             # PDF and EJS receipt generation with transaction details
│   └── alerts.js                       # Cron job scheduler for inventory alerts and automated notifications
├── uploads/                            # File upload storage directories
│   ├── licenses/                       # Pharmacy license document uploads
│   ├── requests/                       # Medicine request supporting document uploads
│   └── support/                        # Support ticket attachment uploads
├── .env                                # Environment variables including JWT secrets and Twilio credentials
├── package.json                        # Project dependencies and npm scripts configuration
└── server.js                           # Express application setup with routes, middleware, and cron job initialization
```

## 🚀 Features

### Core Functionality
- **Authentication System**: User registration, login, and role-based authorization
- **Medicine Management**: CRUD operations for medicine inventory with stock tracking
- **Transaction Processing**: Cart operations with secure checkout and unique transaction numbers
- **Dashboard Analytics**: Comprehensive analytics for business insights
- **Refund Management**: Handle refund requests and maintain refund history

### New Features
- **Support System**: Complete support ticket management with file attachments
- **Medicine Requests**: Allow users to request medicines not in inventory
- **Profile Management**: User profile updates and pharmacy information management
- **Receipt Generation**: Automated receipt generation with PDF support
- **Email Templates**: Professional email templates for various notifications
- **Two-Factor Authentication (2FA)**: Enhanced security with SMS and authenticator app support
- **Business Settings**: Configurable business parameters and preferences
- **Draft Transactions**: Save incomplete transactions for later completion
- **Inventory Alerts**: Automated low stock notifications and alerts

## 📋 Key Components

### Models
- **User Model**: Handles user authentication, pharmacy information, and 2FA settings
- **Medicine Model**: Manages medicine inventory, stock levels, and low stock thresholds
- **Transaction Model**: Processes transactions with refund capabilities and draft support
- **Cart Model**: Shopping cart functionality with helper methods
- **Support Model**: Support ticket management
- **Counter Model**: Atomic transaction number generation
- **BusinessSettings Model**: NEW - Configurable business parameters

### Controllers
- **Authentication**: Secure login/logout functionality with 2FA support
- **Medicine Management**: Complete CRUD operations with inventory tracking
- **Transaction Processing**: Cart and checkout operations with draft support
- **Support System**: Handle support tickets and communications
- **Dashboard**: Analytics and reporting functionality
- **Business Settings**: NEW - Configure business parameters and preferences

### Middleware
- **Authentication**: JWT-based authentication middleware with 2FA verification
- **File Upload**: Multer configuration for various file types including support attachments
- **Validation**: Request validation and error handling

### Utilities
- **Mailer**: Email and SMS service with support for various templates
- **Helpers**: Common utility functions for transactions and formatting
- **Receipt Generator**: PDF receipt generation capabilities
- **Alerts**: NEW - Automated cron jobs for inventory alerts and notifications

## 🔧 Setup & Installation

1. Clone the repository
2. Install dependencies: `npm install`
3. Configure environment variables in `.env`
4. Start the server: `npm start`

## 📝 Environment Variables

Required environment variables:
- `JWT_SECRET`: Secret key for JWT token generation
- `DB_URI`: MongoDB connection string
- `EMAIL_SERVICE`: Email service configuration
- `TWILIO_ACCOUNT_SID`: Twilio account SID for SMS
- `TWILIO_AUTH_TOKEN`: Twilio authentication token
- `TWILIO_PHONE_NUMBER`: Twilio phone number for SMS
- `PORT`: Server port (default: 3000)

## 🎯 Recent Updates

- **NEW**: Two-Factor Authentication (2FA) with SMS and authenticator app support
- **NEW**: Business settings management for configurable parameters
- **NEW**: Draft transaction support for incomplete checkouts
- **NEW**: Automated inventory alerts with cron job scheduling
- **UPDATED**: Authentication middleware with 2FA verification
- **UPDATED**: Medicine model with low stock threshold configuration
- **UPDATED**: Transaction model with draft status support
- **UPDATED**: Mailer utility with SMS and notification functions
- **UPDATED**: Enhanced user model with 2FA fields and notification preferences

## 📚 API Documentation

The API provides endpoints for:
- User authentication and authorization with 2FA support
- Medicine inventory management with low stock alerts
- Transaction processing and cart operations with draft support
- Support ticket creation and management
- Profile management and updates
- Dashboard analytics and reporting
- Refund request handling
- Business settings configuration and management
- Automated inventory monitoring and notifications