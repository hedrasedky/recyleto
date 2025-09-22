import 'package:flutter/material.dart';

import '../screens/about/about_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_pharmacy_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/delivery/delivery_screen.dart';
import '../screens/inventory/add_medicine_screen.dart';
import '../screens/inventory/inventory_screen.dart';
import '../screens/main/home_screen.dart';
import '../screens/market/cart_screen.dart';
import '../screens/market/checkout_screen.dart';
import '../screens/market/market_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/requests/request_medicine_screen.dart';
import '../screens/sales/add_transaction_screen.dart';
import '../screens/sales/sales_screen.dart';
import '../screens/sales/transaction_detail_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/payment_methods_screen.dart';
import '../screens/settings/delivery_addresses_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/support/request_refund_screen.dart';
import '../screens/support/support_chat_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String sales = '/sales';
  static const String addTransaction = '/add-transaction';
  static const String transactionDetail = '/transaction-detail';
  static const String inventory = '/inventory';
  static const String addMedicine = '/add-medicine';
  static const String requestMedicine = '/request-medicine';
  static const String market = '/market';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String supportChat = '/support-chat';
  static const String requestRefund = '/request-refund';
  static const String about = '/about';
  static const String reports = '/reports';
  static const String userManagement = '/user-management';
  static const String delivery = '/delivery';
  static const String paymentMethods = '/payment-methods';
  static const String deliveryAddresses = '/delivery-addresses';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(
            builder: (_) => const RegisterPharmacyScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case otp:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OTPScreen(
            email: args?['email'] ?? '',
            purpose: args?['purpose'] ?? 'verification',
          ),
        );

      case resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case sales:
        return MaterialPageRoute(builder: (_) => const SalesScreen());

      case addTransaction:
        return MaterialPageRoute(builder: (_) => const AddTransactionScreen());

      case transactionDetail:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TransactionDetailScreen(
            transaction: args?['transaction'] ?? {},
          ),
        );

      case inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());

      case addMedicine:
        return MaterialPageRoute(builder: (_) => const AddMedicineScreen());

      case requestMedicine:
        return MaterialPageRoute(builder: (_) => const RequestMedicineScreen());

      case market:
        return MaterialPageRoute(builder: (_) => const MarketScreen());

      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case supportChat:
        return MaterialPageRoute(builder: (_) => const SupportChatScreen());

      case requestRefund:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RequestRefundScreen(
            transactionId: args?['transactionId'],
          ),
        );

      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());

      case userManagement:
        return MaterialPageRoute(builder: (_) => const UserManagementScreen());

      case delivery:
        return MaterialPageRoute(builder: (_) => const DeliveryScreen());

      case paymentMethods:
        return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());

      case deliveryAddresses:
        return MaterialPageRoute(
            builder: (_) => const DeliveryAddressesScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }

  static void navigateTo(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  static void navigateToAndRemoveUntil(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void navigateToAndReplace(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
  }

  static void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void goBackWithResult(BuildContext context, Object result) {
    Navigator.of(context).pop(result);
  }
}
