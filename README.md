# Recyleto - Pharmacy Management Mobile Application

A comprehensive Flutter-based pharmacy management mobile application designed to digitize and streamline pharmacy operations while enhancing customer service and inventory management.

## 🏥 Overview

Recyleto transforms traditional pharmacy operations by providing a unified digital platform that:
- **Streamlines Medicine Sales**: Enables efficient transaction processing from product selection to payment completion
- **Enhances Inventory Management**: Provides real-time stock tracking, expiry monitoring, and automated alerts
- **Improves Customer Experience**: Offers intuitive interfaces for medicine requests, transaction history, and support services
- **Supports Business Operations**: Includes comprehensive reporting, user management, and compliance features
- **Facilitates Communication**: Integrates support chat, notifications, and request management systems

## 🎨 Design System

The application features a modern, attractive UI/UX design with colors derived from the Recyleto logo:

### Color Palette
- **Primary Teal**: `#20B2AA` - Main brand color from logo gradient
- **Primary Green**: `#4CAF50` - Bright lime green from bottle icon
- **Dark Teal**: `#008B8B` - Darker blue-green from gradient
- **Light Teal**: `#48D1CC` - Lighter teal from gradient
- **Success Green**: `#81C784` - For positive actions
- **Warning Orange**: `#FFB74D` - For alerts and warnings
- **Error Red**: `#E57373` - For errors and negative actions

### Design Features
- **Modern Material Design 3** with custom theming
- **Dark/Light Mode Support** with automatic theme switching
- **Responsive Layout** optimized for various screen sizes
- **Custom Components** with consistent styling and animations
- **Gradient Backgrounds** and subtle shadows for depth
- **Rounded Corners** and smooth transitions throughout

## 📱 Screens & Features

### Authentication Screens
1. **Login Screen** - Email/password authentication with remember me option
2. **Forgot Password** - Email-based password reset
3. **Register Pharmacy** - Complete pharmacy registration with license upload
4. **OTP Verification** - Two-factor authentication support

### Main Dashboard
5. **Home Dashboard** - Centralized overview with:
   - KPI cards showing sales, low stock, expiring medicines, refunds
   - Quick action buttons for common tasks
   - Stock and expiry alerts with color-coded urgency
   - Recent activity feed
   - Floating action button for adding requests

### Sales Management
6. **Sales Screen** - Transaction list with search and filtering
7. **Add Transaction** - Complete sales workflow
8. **Medicine Selection** - Search and select medicines with details
9. **Cart/Checkout** - Shopping cart with payment processing
10. **Transaction Details** - Detailed view of completed transactions

### Inventory Management
11. **Inventory Screen** - Medicine stock management
12. **Add Medicine** - Add new medicines to Recyleto platform
13. **Market/Search** - Browse and search medicines
14. **Stock Alerts** - Low stock and expiry notifications

### Request Management
15. **Request Medicine** - Submit requests for unavailable medicines
16. **Request Refund** - Process refund requests
17. **Support Chat** - Integrated customer support system

### Profile & Settings
18. **Profile Screen** - User profile with theme toggle
19. **Settings** - Comprehensive app configuration
20. **Edit Profile** - Update business information

## 🛠 Technical Stack

### Core Framework
- **Flutter 3.0+** - Cross-platform mobile development
- **Dart** - Programming language

### State Management
- **Provider** - State management and dependency injection

### UI/UX Libraries
- **Google Fonts** - Typography (Poppins font family)
- **Material Design 3** - Modern UI components
- **Custom Theme System** - Light/dark mode support

### Data & Storage
- **Shared Preferences** - Local data persistence
- **Flutter Secure Storage** - Secure credential storage

### Additional Features
- **Image Picker** - Photo upload functionality
- **HTTP** - API communication
- **Intl** - Internationalization support
- **Connectivity Plus** - Network status monitoring
- **Flutter Local Notifications** - Push notifications
- **Permission Handler** - Device permissions
- **Cached Network Image** - Image caching
- **Shimmer** - Loading animations
- **Lottie** - Animated illustrations

## 📁 Project Structure

```
lib/
├── main.dart                 # Application entry point
├── utils/
│   └── app_theme.dart        # Theme configuration
├── providers/
│   ├── auth_provider.dart    # Authentication state management
│   └── theme_provider.dart   # Theme state management
├── screens/
│   ├── auth/                 # Authentication screens
│   ├── main/                 # Main dashboard
│   ├── sales/                # Sales management
│   ├── inventory/            # Inventory management
│   ├── requests/             # Request management
│   └── profile/              # Profile and settings
└── widgets/
    ├── custom_button.dart    # Reusable button component
    ├── custom_text_field.dart # Reusable text field component
    ├── kpi_card.dart         # KPI display card
    ├── quick_action_card.dart # Quick action card
    ├── alert_card.dart       # Alert notification card
    └── recent_activity_card.dart # Activity feed card
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 2.19 or higher
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/recyleto_app.git
   cd recyleto_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Configuration

1. **Update pubspec.yaml** with your app details
2. **Configure assets** in the assets folder
3. **Set up API endpoints** for backend integration
4. **Configure signing** for app store deployment

## 🎯 Key Features

### For Pharmacists
- Process sales transactions with detailed medicine selection
- Manage customer requests for unavailable medicines
- Access real-time stock levels and expiry notifications
- Handle refund requests and transaction modifications
- Provide customer support through integrated chat

### For Managers
- Oversee complete pharmacy operations through dashboard
- Add new medicines to the Recyleto platform database
- Monitor sales performance, inventory levels, and metrics
- Manage user accounts and system settings
- Generate reports and analytics for business insights

### For Customers
- Browse and purchase medicines through sales interface
- Submit requests for unavailable medicines with images
- Track transaction history and manage refunds
- Receive notifications and updates on orders

## 🔧 Customization

### Theme Customization
The app uses a comprehensive theme system that can be easily customized:

```dart
// Update colors in lib/utils/app_theme.dart
static const Color primaryTeal = Color(0xFF20B2AA);
static const Color primaryGreen = Color(0xFF4CAF50);
```

### Adding New Screens
1. Create screen file in appropriate directory
2. Add navigation in main.dart or parent screen
3. Update bottom navigation if needed
4. Add any required providers or models

### Custom Components
The app includes reusable components that can be extended:
- `CustomButton` - Styled buttons with loading states
- `CustomTextField` - Form input fields with validation
- `KPICard` - Metric display cards
- `QuickActionCard` - Navigation action cards

## 📊 Business Impact

### Operational Efficiency
- Reduces manual processes through automation
- Minimizes errors in transaction processing
- Streamlines communication between staff and customers
- Provides real-time visibility into business operations

### Customer Service Enhancement
- Enables faster transaction processing
- Improves accuracy in medicine dispensing
- Provides transparent tracking of requests
- Offers multiple support channels

### Business Intelligence
- Delivers actionable insights through dashboards
- Enables data-driven decision making
- Supports inventory optimization
- Facilitates compliance reporting

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- Email: support@recyleto.com
- Documentation: [docs.recyleto.com](https://docs.recyleto.com)
- Issues: [GitHub Issues](https://github.com/your-username/recyleto_app/issues)

## 🔮 Roadmap

### Phase 1 (Current)
- ✅ Core authentication and navigation
- ✅ Dashboard with KPI cards
- ✅ Basic sales and inventory screens
- ✅ Profile and settings management

### Phase 2 (Next)
- 🔄 Complete transaction workflow
- 🔄 Medicine search and selection
- 🔄 Cart and checkout system
- 🔄 Real-time inventory management

### Phase 3 (Future)
- 📋 Advanced analytics and reporting
- 📋 Customer relationship management
- 📋 Multi-location support
- 📋 API integration and cloud sync

---

**Recyleto** - Transforming pharmacy operations through digital innovation. 