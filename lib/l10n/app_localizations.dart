import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Management'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @supportHelp.
  ///
  /// In en, this message translates to:
  /// **'Support & Help'**
  String get supportHelp;

  /// No description provided for @administration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get administration;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @useDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get useDarkTheme;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @manageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage account'**
  String get manageAccount;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @viewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View analytics'**
  String get viewAnalytics;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @getHelp.
  ///
  /// In en, this message translates to:
  /// **'Get Help'**
  String get getHelp;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updatePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get updatePersonalInfo;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updateAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updateAccountPassword;

  /// No description provided for @deliveryAddresses.
  ///
  /// In en, this message translates to:
  /// **'Delivery Addresses'**
  String get deliveryAddresses;

  /// No description provided for @manageDeliveryAddresses.
  ///
  /// In en, this message translates to:
  /// **'Manage your delivery addresses'**
  String get manageDeliveryAddresses;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @managePaymentOptions.
  ///
  /// In en, this message translates to:
  /// **'Manage your payment options'**
  String get managePaymentOptions;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @receiveAppNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive app notifications'**
  String get receiveAppNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @receiveUpdatesViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Receive updates via email'**
  String get receiveUpdatesViaEmail;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @receivePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications'**
  String get receivePushNotifications;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order Updates'**
  String get orderUpdates;

  /// No description provided for @getNotifiedAboutOrderStatus.
  ///
  /// In en, this message translates to:
  /// **'Get notified about order status'**
  String get getNotifiedAboutOrderStatus;

  /// No description provided for @promotionalOffers.
  ///
  /// In en, this message translates to:
  /// **'Promotional Offers'**
  String get promotionalOffers;

  /// No description provided for @receiveSpecialOffers.
  ///
  /// In en, this message translates to:
  /// **'Receive special offers and discounts'**
  String get receiveSpecialOffers;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @readPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get readPrivacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @readTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get readTermsOfService;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @permanentlyDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get permanentlyDeleteAccount;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @getHelpFromSupportTeam.
  ///
  /// In en, this message translates to:
  /// **'Get help from our support team'**
  String get getHelpFromSupportTeam;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @browseHelpArticles.
  ///
  /// In en, this message translates to:
  /// **'Browse help articles and FAQs'**
  String get browseHelpArticles;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @shareYourThoughts.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts with us'**
  String get shareYourThoughts;

  /// No description provided for @reportsAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Reports & Analytics'**
  String get reportsAnalytics;

  /// No description provided for @viewDetailedReports.
  ///
  /// In en, this message translates to:
  /// **'View detailed reports and analytics'**
  String get viewDetailedReports;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @manageUsersAndPermissions.
  ///
  /// In en, this message translates to:
  /// **'Manage users and permissions'**
  String get manageUsersAndPermissions;

  /// No description provided for @deliveryManagement.
  ///
  /// In en, this message translates to:
  /// **'Delivery Management'**
  String get deliveryManagement;

  /// No description provided for @manageDeliveryOrders.
  ///
  /// In en, this message translates to:
  /// **'Manage delivery orders and tracking'**
  String get manageDeliveryOrders;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @checkForAppUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for app updates'**
  String get checkForAppUpdates;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @shareRecyletoWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share Recyleto with friends'**
  String get shareRecyletoWithFriends;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @accountDeletionRequested.
  ///
  /// In en, this message translates to:
  /// **'Account deletion requested'**
  String get accountDeletionRequested;

  /// No description provided for @areYouSureDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get areYouSureDeleteAccount;

  /// No description provided for @todaySales.
  ///
  /// In en, this message translates to:
  /// **'Today Sales'**
  String get todaySales;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock!'**
  String get lowStock;

  /// No description provided for @expiring.
  ///
  /// In en, this message translates to:
  /// **'Expiring'**
  String get expiring;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get addMedicine;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @viewInventory.
  ///
  /// In en, this message translates to:
  /// **'View Inventory'**
  String get viewInventory;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @weeklyPerformance.
  ///
  /// In en, this message translates to:
  /// **'Weekly Performance'**
  String get weeklyPerformance;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// No description provided for @totalCustomers.
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get totalCustomers;

  /// No description provided for @inventoryValue.
  ///
  /// In en, this message translates to:
  /// **'Inventory Value'**
  String get inventoryValue;

  /// No description provided for @addNewMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add New Medicine'**
  String get addNewMedicine;

  /// No description provided for @addNewTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add New Transaction'**
  String get addNewTransaction;

  /// No description provided for @viewAllInventory.
  ///
  /// In en, this message translates to:
  /// **'View All Inventory'**
  String get viewAllInventory;

  /// No description provided for @viewAllReports.
  ///
  /// In en, this message translates to:
  /// **'View All Reports'**
  String get viewAllReports;

  /// No description provided for @viewAllUsers.
  ///
  /// In en, this message translates to:
  /// **'View All Users'**
  String get viewAllUsers;

  /// No description provided for @viewAllDeliveries.
  ///
  /// In en, this message translates to:
  /// **'View All Deliveries'**
  String get viewAllDeliveries;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get signingIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @registerPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Register Pharmacy'**
  String get registerPharmacy;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @demoCredentials.
  ///
  /// In en, this message translates to:
  /// **'Demo Credentials'**
  String get demoCredentials;

  /// No description provided for @tapToFillCredentials.
  ///
  /// In en, this message translates to:
  /// **'Tap here to fill credentials'**
  String get tapToFillCredentials;

  /// No description provided for @testBackendConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Backend Connection'**
  String get testBackendConnection;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @pharmacyManagementSystem.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Management System'**
  String get pharmacyManagementSystem;

  /// No description provided for @signInToAccess.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your pharmacy dashboard'**
  String get signInToAccess;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @recyleto.
  ///
  /// In en, this message translates to:
  /// **'Recyleto'**
  String get recyleto;

  /// No description provided for @newTransaction.
  ///
  /// In en, this message translates to:
  /// **'New Transaction'**
  String get newTransaction;

  /// No description provided for @processNewSale.
  ///
  /// In en, this message translates to:
  /// **'Process New Sale Transaction'**
  String get processNewSale;

  /// No description provided for @addMedicinesProcess.
  ///
  /// In en, this message translates to:
  /// **'Add medicines and process customer transaction'**
  String get addMedicinesProcess;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// No description provided for @customerNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Customer Name (Optional)'**
  String get customerNameOptional;

  /// No description provided for @enterCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Enter customer name'**
  String get enterCustomerName;

  /// No description provided for @customerPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Customer Phone (Optional)'**
  String get customerPhoneOptional;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @addTransactionNotes.
  ///
  /// In en, this message translates to:
  /// **'Add transaction notes...'**
  String get addTransactionNotes;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @pricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get pricePerUnit;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @stockAvailable.
  ///
  /// In en, this message translates to:
  /// **'Stock Available'**
  String get stockAvailable;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @processTransaction.
  ///
  /// In en, this message translates to:
  /// **'Process Transaction'**
  String get processTransaction;

  /// No description provided for @searchMedicines.
  ///
  /// In en, this message translates to:
  /// **'Search medicines...'**
  String get searchMedicines;

  /// No description provided for @noMedicinesFound.
  ///
  /// In en, this message translates to:
  /// **'No medicines found'**
  String get noMedicinesFound;

  /// No description provided for @transactionItems.
  ///
  /// In en, this message translates to:
  /// **'Transaction Items'**
  String get transactionItems;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @resetTransaction.
  ///
  /// In en, this message translates to:
  /// **'Reset Transaction'**
  String get resetTransaction;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicineName;

  /// No description provided for @genericName.
  ///
  /// In en, this message translates to:
  /// **'Generic Name'**
  String get genericName;

  /// No description provided for @packSize.
  ///
  /// In en, this message translates to:
  /// **'Pack Size'**
  String get packSize;

  /// No description provided for @manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get manufacturer;

  /// No description provided for @batchNumber.
  ///
  /// In en, this message translates to:
  /// **'Batch Number'**
  String get batchNumber;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @addNewMedicineToPlatform.
  ///
  /// In en, this message translates to:
  /// **'Add New Medicine to Platform'**
  String get addNewMedicineToPlatform;

  /// No description provided for @fillDetailsMakeAvailable.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details to make this medicine available in your inventory'**
  String get fillDetailsMakeAvailable;

  /// No description provided for @medicineNameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Paracetamol 500mg'**
  String get medicineNameExample;

  /// No description provided for @genericNameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Acetaminophen'**
  String get genericNameExample;

  /// No description provided for @batchNumberExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., BATCH123456'**
  String get batchNumberExample;

  /// No description provided for @descriptionExample.
  ///
  /// In en, this message translates to:
  /// **'Brief description of the medicine and its uses...'**
  String get descriptionExample;

  /// No description provided for @pleaseEnterMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Please enter medicine name'**
  String get pleaseEnterMedicineName;

  /// No description provided for @pleaseEnterGenericName.
  ///
  /// In en, this message translates to:
  /// **'Please enter generic name'**
  String get pleaseEnterGenericName;

  /// No description provided for @failedToAddMedicine.
  ///
  /// In en, this message translates to:
  /// **'Failed to add medicine'**
  String get failedToAddMedicine;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @inventoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Inventory Management'**
  String get inventoryManagement;

  /// No description provided for @inventoryDescription.
  ///
  /// In en, this message translates to:
  /// **'This screen will display all medicines in inventory with stock levels, expiry dates, and management options.'**
  String get inventoryDescription;

  /// No description provided for @filterMedicines.
  ///
  /// In en, this message translates to:
  /// **'Filter medicines'**
  String get filterMedicines;

  /// No description provided for @editMedicine.
  ///
  /// In en, this message translates to:
  /// **'Edit Medicine'**
  String get editMedicine;

  /// No description provided for @deleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Delete Medicine'**
  String get deleteMedicine;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @enterEmailResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password'**
  String get enterEmailResetPassword;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @confirmReset.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reset'**
  String get confirmReset;

  /// No description provided for @doYouWantResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Do you want to reset your password? This action cannot be undone.'**
  String get doYouWantResetPassword;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get resetYourPassword;

  /// No description provided for @verifyYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Account'**
  String get verifyYourAccount;

  /// No description provided for @sentVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit verification code to'**
  String get sentVerificationCode;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resendInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} seconds'**
  String resendInSeconds(Object seconds);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @havingTroubleContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Having trouble? Contact support'**
  String get havingTroubleContactSupport;

  /// No description provided for @updateInformation.
  ///
  /// In en, this message translates to:
  /// **'Update information'**
  String get updateInformation;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get appInformation;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @addressName.
  ///
  /// In en, this message translates to:
  /// **'Address Name'**
  String get addressName;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddress;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @zipCode.
  ///
  /// In en, this message translates to:
  /// **'ZIP Code'**
  String get zipCode;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @addNewCard.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addNewCard;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get editCard;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderName;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @setAsDefaultCard.
  ///
  /// In en, this message translates to:
  /// **'Set as Default Card'**
  String get setAsDefaultCard;

  /// No description provided for @addNewUser.
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get addNewUser;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @userEmail.
  ///
  /// In en, this message translates to:
  /// **'User Email'**
  String get userEmail;

  /// No description provided for @userRole.
  ///
  /// In en, this message translates to:
  /// **'User Role'**
  String get userRole;

  /// No description provided for @userStatus.
  ///
  /// In en, this message translates to:
  /// **'User Status'**
  String get userStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @activeUsers.
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get activeUsers;

  /// No description provided for @inactiveUsers.
  ///
  /// In en, this message translates to:
  /// **'Inactive Users'**
  String get inactiveUsers;

  /// No description provided for @welcomeToApp.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Recyleto'**
  String get welcomeToApp;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @requestMedicine.
  ///
  /// In en, this message translates to:
  /// **'Request Medicine'**
  String get requestMedicine;

  /// No description provided for @supportChat.
  ///
  /// In en, this message translates to:
  /// **'Support Chat'**
  String get supportChat;

  /// No description provided for @requestRefund.
  ///
  /// In en, this message translates to:
  /// **'Request Refund'**
  String get requestRefund;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @performanceMetrics.
  ///
  /// In en, this message translates to:
  /// **'Performance Metrics'**
  String get performanceMetrics;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @weeklySales.
  ///
  /// In en, this message translates to:
  /// **'Weekly Sales'**
  String get weeklySales;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @satisfaction.
  ///
  /// In en, this message translates to:
  /// **'Satisfaction'**
  String get satisfaction;

  /// No description provided for @dailySalesTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily Sales Trend'**
  String get dailySalesTrend;

  /// No description provided for @vsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'vs {amount} last week'**
  String vsLastWeek(Object amount);

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @manageDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Manage deliveries'**
  String get manageDeliveries;

  /// No description provided for @browseProducts.
  ///
  /// In en, this message translates to:
  /// **'Browse products'**
  String get browseProducts;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @processPayment.
  ///
  /// In en, this message translates to:
  /// **'Process payment'**
  String get processPayment;

  /// No description provided for @manageRequests.
  ///
  /// In en, this message translates to:
  /// **'Manage requests'**
  String get manageRequests;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// No description provided for @highestAmount.
  ///
  /// In en, this message translates to:
  /// **'Highest Amount'**
  String get highestAmount;

  /// No description provided for @lowestAmount.
  ///
  /// In en, this message translates to:
  /// **'Lowest Amount'**
  String get lowestAmount;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @addRequest.
  ///
  /// In en, this message translates to:
  /// **'Add Request'**
  String get addRequest;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated'**
  String get profilePictureUpdated;

  /// No description provided for @failedToUpdateProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile picture'**
  String get failedToUpdateProfilePicture;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @nameMustBeAtLeast2Characters.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMustBeAtLeast2Characters;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// No description provided for @phoneNumberIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberIsRequired;

  /// No description provided for @pleaseEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhoneNumber;

  /// No description provided for @tapToChangeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Tap to change profile picture'**
  String get tapToChangeProfilePicture;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterYourEmailAddress;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @enterYourAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get enterYourAddress;

  /// No description provided for @pharmacyName.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Name'**
  String get pharmacyName;

  /// No description provided for @userExampleCom.
  ///
  /// In en, this message translates to:
  /// **'user@example.com'**
  String get userExampleCom;

  /// No description provided for @toggleBetweenLightAndDarkThemes.
  ///
  /// In en, this message translates to:
  /// **'Toggle between light and dark themes'**
  String get toggleBetweenLightAndDarkThemes;

  /// No description provided for @addMedicineToRecyleto.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine to Recyleto'**
  String get addMedicineToRecyleto;

  /// No description provided for @resetForm.
  ///
  /// In en, this message translates to:
  /// **'Reset Form'**
  String get resetForm;

  /// No description provided for @packSizeExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., 10 tablets, 100ml bottle'**
  String get packSizeExample;

  /// No description provided for @pleaseEnterPackSize.
  ///
  /// In en, this message translates to:
  /// **'Please enter pack size'**
  String get pleaseEnterPackSize;

  /// No description provided for @pricingInventory.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Inventory'**
  String get pricingInventory;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantity;

  /// No description provided for @enterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter valid quantity'**
  String get enterValidQuantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// No description provided for @enterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter valid price'**
  String get enterValidPrice;

  /// No description provided for @manufacturerDetails.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer Details'**
  String get manufacturerDetails;

  /// No description provided for @manufacturerExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., PharmaCorp Ltd.'**
  String get manufacturerExample;

  /// No description provided for @medicineType.
  ///
  /// In en, this message translates to:
  /// **'Medicine Type'**
  String get medicineType;

  /// No description provided for @otc.
  ///
  /// In en, this message translates to:
  /// **'OTC'**
  String get otc;

  /// No description provided for @overTheCounter.
  ///
  /// In en, this message translates to:
  /// **'Over the Counter'**
  String get overTheCounter;

  /// No description provided for @rx.
  ///
  /// In en, this message translates to:
  /// **'Rx'**
  String get rx;

  /// No description provided for @prescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Prescription Required'**
  String get prescriptionRequired;

  /// No description provided for @medicineAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Medicine \"{medicineName}\" added successfully!'**
  String medicineAddedSuccessfully(Object medicineName);

  /// No description provided for @addToRecyleto.
  ///
  /// In en, this message translates to:
  /// **'Add to Recyleto'**
  String get addToRecyleto;

  /// No description provided for @form.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get form;

  /// No description provided for @pleaseSelectForm.
  ///
  /// In en, this message translates to:
  /// **'Please select a form'**
  String get pleaseSelectForm;

  /// No description provided for @tablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get tablet;

  /// No description provided for @capsule.
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get capsule;

  /// No description provided for @syrup.
  ///
  /// In en, this message translates to:
  /// **'Syrup'**
  String get syrup;

  /// No description provided for @injection.
  ///
  /// In en, this message translates to:
  /// **'Injection'**
  String get injection;

  /// No description provided for @cream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get cream;

  /// No description provided for @ointment.
  ///
  /// In en, this message translates to:
  /// **'Ointment'**
  String get ointment;

  /// No description provided for @drops.
  ///
  /// In en, this message translates to:
  /// **'Drops'**
  String get drops;

  /// No description provided for @inhaler.
  ///
  /// In en, this message translates to:
  /// **'Inhaler'**
  String get inhaler;

  /// No description provided for @patch.
  ///
  /// In en, this message translates to:
  /// **'Patch'**
  String get patch;

  /// No description provided for @powder.
  ///
  /// In en, this message translates to:
  /// **'Powder'**
  String get powder;

  /// No description provided for @gel.
  ///
  /// In en, this message translates to:
  /// **'Gel'**
  String get gel;

  /// No description provided for @lotion.
  ///
  /// In en, this message translates to:
  /// **'Lotion'**
  String get lotion;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @orderPlacedOn.
  ///
  /// In en, this message translates to:
  /// **'Order placed on {date} at {time}'**
  String orderPlacedOn(Object date, Object time);

  /// No description provided for @customerInformation.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInformation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItems;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummary;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @transactionNotes.
  ///
  /// In en, this message translates to:
  /// **'Transaction Notes'**
  String get transactionNotes;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @returnTransaction.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnTransaction;

  /// No description provided for @exchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get exchange;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// No description provided for @addMedicineToTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine to Transaction'**
  String get addMedicineToTransaction;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @lineTotal.
  ///
  /// In en, this message translates to:
  /// **'Line Total'**
  String get lineTotal;

  /// No description provided for @pleaseAddAtLeastOneMedicine.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one medicine to the transaction'**
  String get pleaseAddAtLeastOneMedicine;

  /// No description provided for @transactionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction Completed!'**
  String get transactionCompleted;

  /// No description provided for @transactionReference.
  ///
  /// In en, this message translates to:
  /// **'Transaction Reference'**
  String get transactionReference;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @addAnother.
  ///
  /// In en, this message translates to:
  /// **'Add Another'**
  String get addAnother;

  /// No description provided for @failedToLoadMedicines.
  ///
  /// In en, this message translates to:
  /// **'Failed to load medicines'**
  String get failedToLoadMedicines;

  /// No description provided for @addedToTransaction.
  ///
  /// In en, this message translates to:
  /// **'{medicineName} added to transaction'**
  String addedToTransaction(Object medicineName);

  /// No description provided for @unknownItem.
  ///
  /// In en, this message translates to:
  /// **'Unknown Item'**
  String get unknownItem;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @digitalWallet.
  ///
  /// In en, this message translates to:
  /// **'Digital Wallet'**
  String get digitalWallet;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @refunded.
  ///
  /// In en, this message translates to:
  /// **'REFUNDED'**
  String get refunded;

  /// No description provided for @failedToLoadTransactions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load transactions: {error}'**
  String failedToLoadTransactions(Object error);

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @noTransactionsMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No transactions match your filters'**
  String get noTransactionsMatchFilters;

  /// No description provided for @startByCreatingFirstSale.
  ///
  /// In en, this message translates to:
  /// **'Start by creating your first sale'**
  String get startByCreatingFirstSale;

  /// No description provided for @tryAdjustingSearchFilter.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filter criteria'**
  String get tryAdjustingSearchFilter;

  /// No description provided for @newSale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get newSale;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @at.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get at;

  /// No description provided for @addMedicineItems.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine Items'**
  String get addMedicineItems;

  /// No description provided for @searchByNameGenericManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Search by name, generic, or manufacturer...'**
  String get searchByNameGenericManufacturer;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @out.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get out;

  /// No description provided for @batch.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get batch;

  /// No description provided for @exp.
  ///
  /// In en, this message translates to:
  /// **'Exp'**
  String get exp;

  /// No description provided for @tax5.
  ///
  /// In en, this message translates to:
  /// **'Tax (5%):'**
  String get tax5;

  /// No description provided for @addToTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add to Transaction'**
  String get addToTransaction;

  /// No description provided for @invalidQuantityInsufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Invalid quantity or insufficient stock'**
  String get invalidQuantityInsufficientStock;

  /// No description provided for @tax5Percent.
  ///
  /// In en, this message translates to:
  /// **'Tax (5%)'**
  String get tax5Percent;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @salesReport.
  ///
  /// In en, this message translates to:
  /// **'Sales Report'**
  String get salesReport;

  /// No description provided for @inventoryReport.
  ///
  /// In en, this message translates to:
  /// **'Inventory Report'**
  String get inventoryReport;

  /// No description provided for @performanceReport.
  ///
  /// In en, this message translates to:
  /// **'Performance Report'**
  String get performanceReport;

  /// No description provided for @averageOrderValue.
  ///
  /// In en, this message translates to:
  /// **'Average Order Value'**
  String get averageOrderValue;

  /// No description provided for @topSellingMedicines.
  ///
  /// In en, this message translates to:
  /// **'Top Selling Medicines'**
  String get topSellingMedicines;

  /// No description provided for @lowStockItems.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Items'**
  String get lowStockItems;

  /// No description provided for @expiringItems.
  ///
  /// In en, this message translates to:
  /// **'Expiring Items'**
  String get expiringItems;

  /// No description provided for @totalInventoryValue.
  ///
  /// In en, this message translates to:
  /// **'Total Inventory Value'**
  String get totalInventoryValue;

  /// No description provided for @totalMedicines.
  ///
  /// In en, this message translates to:
  /// **'Total Medicines'**
  String get totalMedicines;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon'**
  String get expiringSoon;

  /// No description provided for @customerSatisfaction.
  ///
  /// In en, this message translates to:
  /// **'Customer Satisfaction'**
  String get customerSatisfaction;

  /// No description provided for @responseTime.
  ///
  /// In en, this message translates to:
  /// **'Response Time'**
  String get responseTime;

  /// No description provided for @orderAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Order Accuracy'**
  String get orderAccuracy;

  /// No description provided for @deliveryOnTime.
  ///
  /// In en, this message translates to:
  /// **'Delivery on Time'**
  String get deliveryOnTime;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// No description provided for @filterByPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Filter by Payment Method'**
  String get filterByPaymentMethod;

  /// No description provided for @filterByStockStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by Stock Status'**
  String get filterByStockStatus;

  /// No description provided for @filterByExpiryStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by Expiry Status'**
  String get filterByExpiryStatus;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @exportReport.
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @loadingReport.
  ///
  /// In en, this message translates to:
  /// **'Loading report...'**
  String get loadingReport;

  /// No description provided for @failedToLoadReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to load report'**
  String get failedToLoadReport;

  /// No description provided for @deliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveries;

  /// No description provided for @addNewDelivery.
  ///
  /// In en, this message translates to:
  /// **'Add New Delivery'**
  String get addNewDelivery;

  /// No description provided for @deliveryDetails.
  ///
  /// In en, this message translates to:
  /// **'Delivery Details'**
  String get deliveryDetails;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @customerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get customerPhone;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @deliveryType.
  ///
  /// In en, this message translates to:
  /// **'Delivery Type'**
  String get deliveryType;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @express.
  ///
  /// In en, this message translates to:
  /// **'Express'**
  String get express;

  /// No description provided for @sameDay.
  ///
  /// In en, this message translates to:
  /// **'Same Day'**
  String get sameDay;

  /// No description provided for @deliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery Date'**
  String get deliveryDate;

  /// No description provided for @deliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Delivery Time'**
  String get deliveryTime;

  /// No description provided for @deliveryNotes.
  ///
  /// In en, this message translates to:
  /// **'Delivery Notes'**
  String get deliveryNotes;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @inTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get inTransit;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @trackDelivery.
  ///
  /// In en, this message translates to:
  /// **'Track Delivery'**
  String get trackDelivery;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @deliveryHistory.
  ///
  /// In en, this message translates to:
  /// **'Delivery History'**
  String get deliveryHistory;

  /// No description provided for @noDeliveriesFound.
  ///
  /// In en, this message translates to:
  /// **'No deliveries found'**
  String get noDeliveriesFound;

  /// No description provided for @searchDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Search deliveries...'**
  String get searchDeliveries;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get filterByStatus;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get filterByDate;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @userDetails.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get userDetails;

  /// No description provided for @pharmacist.
  ///
  /// In en, this message translates to:
  /// **'Pharmacist'**
  String get pharmacist;

  /// No description provided for @cashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get cashier;

  /// No description provided for @suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspended;

  /// No description provided for @lastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last Login'**
  String get lastLogin;

  /// No description provided for @createdDate.
  ///
  /// In en, this message translates to:
  /// **'Created Date'**
  String get createdDate;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @filterByRole.
  ///
  /// In en, this message translates to:
  /// **'Filter by Role'**
  String get filterByRole;

  /// No description provided for @filterByUserStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get filterByUserStatus;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @suspendUser.
  ///
  /// In en, this message translates to:
  /// **'Suspend User'**
  String get suspendUser;

  /// No description provided for @activateUser.
  ///
  /// In en, this message translates to:
  /// **'Activate User'**
  String get activateUser;

  /// No description provided for @areYouSureDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user?'**
  String get areYouSureDeleteUser;

  /// No description provided for @areYouSureSuspendUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to suspend this user?'**
  String get areYouSureSuspendUser;

  /// No description provided for @areYouSureActivateUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to activate this user?'**
  String get areYouSureActivateUser;

  /// No description provided for @userDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User deleted successfully'**
  String get userDeletedSuccessfully;

  /// No description provided for @userSuspendedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User suspended successfully'**
  String get userSuspendedSuccessfully;

  /// No description provided for @userActivatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User activated successfully'**
  String get userActivatedSuccessfully;

  /// No description provided for @userUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User updated successfully'**
  String get userUpdatedSuccessfully;

  /// No description provided for @userAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User added successfully'**
  String get userAddedSuccessfully;

  /// No description provided for @failedToDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete user'**
  String get failedToDeleteUser;

  /// No description provided for @failedToSuspendUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to suspend user'**
  String get failedToSuspendUser;

  /// No description provided for @failedToActivateUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to activate user'**
  String get failedToActivateUser;

  /// No description provided for @failedToUpdateUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to update user'**
  String get failedToUpdateUser;

  /// No description provided for @failedToAddUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to add user'**
  String get failedToAddUser;

  /// No description provided for @pleaseEnterUserName.
  ///
  /// In en, this message translates to:
  /// **'Please enter user name'**
  String get pleaseEnterUserName;

  /// No description provided for @pleaseEnterUserEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter user email'**
  String get pleaseEnterUserEmail;

  /// No description provided for @pleaseEnterUserPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter user phone'**
  String get pleaseEnterUserPhone;

  /// No description provided for @pleaseSelectUserRole.
  ///
  /// In en, this message translates to:
  /// **'Please select user role'**
  String get pleaseSelectUserRole;

  /// No description provided for @userPhone.
  ///
  /// In en, this message translates to:
  /// **'User Phone'**
  String get userPhone;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get confirmAction;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @reportExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Report exported successfully!'**
  String get reportExportedSuccessfully;

  /// No description provided for @failedToExportReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to export report'**
  String get failedToExportReport;

  /// No description provided for @exportCSV.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCSV;

  /// No description provided for @exportPDF.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPDF;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @stockStatus.
  ///
  /// In en, this message translates to:
  /// **'Stock Status'**
  String get stockStatus;

  /// No description provided for @expiryStatus.
  ///
  /// In en, this message translates to:
  /// **'Expiry Status'**
  String get expiryStatus;

  /// No description provided for @noSalesDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No sales data available'**
  String get noSalesDataAvailable;

  /// No description provided for @noInventoryDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No inventory data available'**
  String get noInventoryDataAvailable;

  /// No description provided for @noPerformanceDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No performance data available'**
  String get noPerformanceDataAvailable;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @createNewDelivery.
  ///
  /// In en, this message translates to:
  /// **'Create New Delivery'**
  String get createNewDelivery;

  /// No description provided for @customerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Customer name is required'**
  String get customerNameRequired;

  /// No description provided for @customerPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Customer phone is required'**
  String get customerPhoneRequired;

  /// No description provided for @deliveryAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Delivery address is required'**
  String get deliveryAddressRequired;

  /// No description provided for @orderItemsRequired.
  ///
  /// In en, this message translates to:
  /// **'Order items are required'**
  String get orderItemsRequired;

  /// No description provided for @standardDelivery.
  ///
  /// In en, this message translates to:
  /// **'Standard (2-3 days)'**
  String get standardDelivery;

  /// No description provided for @expressDelivery.
  ///
  /// In en, this message translates to:
  /// **'Express (1-2 days)'**
  String get expressDelivery;

  /// No description provided for @sameDayDelivery.
  ///
  /// In en, this message translates to:
  /// **'Same Day'**
  String get sameDayDelivery;

  /// No description provided for @createDelivery.
  ///
  /// In en, this message translates to:
  /// **'Create Delivery'**
  String get createDelivery;

  /// No description provided for @deliveryCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Delivery created successfully!'**
  String get deliveryCreatedSuccessfully;

  /// No description provided for @failedToCreateDelivery.
  ///
  /// In en, this message translates to:
  /// **'Failed to create delivery'**
  String get failedToCreateDelivery;

  /// No description provided for @updateDeliveryStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Delivery Status'**
  String get updateDeliveryStatus;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current status'**
  String get currentStatus;

  /// No description provided for @selectNewStatus.
  ///
  /// In en, this message translates to:
  /// **'Select new status'**
  String get selectNewStatus;

  /// No description provided for @failedToUpdateDeliveryStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update delivery status'**
  String get failedToUpdateDeliveryStatus;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @requestUnavailableMedicine.
  ///
  /// In en, this message translates to:
  /// **'Request Unavailable Medicine'**
  String get requestUnavailableMedicine;

  /// No description provided for @requestUnavailableMedicineDescription.
  ///
  /// In en, this message translates to:
  /// **'Request medicines that are not currently available in our inventory'**
  String get requestUnavailableMedicineDescription;

  /// No description provided for @medicineImage.
  ///
  /// In en, this message translates to:
  /// **'Medicine Image'**
  String get medicineImage;

  /// No description provided for @uploadMedicineImageDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload an image of the medicine packaging or prescription'**
  String get uploadMedicineImageDescription;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImage;

  /// No description provided for @medicineDetails.
  ///
  /// In en, this message translates to:
  /// **'Medicine Details'**
  String get medicineDetails;

  /// No description provided for @medicineNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Amoxicillin 250mg'**
  String get medicineNameHint;

  /// No description provided for @genericNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Amoxicillin'**
  String get genericNameHint;

  /// No description provided for @packSizeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 20 capsules, 100ml bottle'**
  String get packSizeHint;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @requestPriority.
  ///
  /// In en, this message translates to:
  /// **'Request Priority'**
  String get requestPriority;

  /// No description provided for @lowPriority.
  ///
  /// In en, this message translates to:
  /// **'Low Priority'**
  String get lowPriority;

  /// No description provided for @mediumPriority.
  ///
  /// In en, this message translates to:
  /// **'Medium Priority'**
  String get mediumPriority;

  /// No description provided for @highPriority.
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get highPriority;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @lowPriorityDescription.
  ///
  /// In en, this message translates to:
  /// **'Can wait 3-7 days'**
  String get lowPriorityDescription;

  /// No description provided for @mediumPriorityDescription.
  ///
  /// In en, this message translates to:
  /// **'Needed within 1-3 days'**
  String get mediumPriorityDescription;

  /// No description provided for @highPriorityDescription.
  ///
  /// In en, this message translates to:
  /// **'Needed within 24 hours'**
  String get highPriorityDescription;

  /// No description provided for @urgentDescription.
  ///
  /// In en, this message translates to:
  /// **'Needed immediately'**
  String get urgentDescription;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @additionalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any additional information about the medicine, dosage, or specific requirements...'**
  String get additionalNotesHint;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @medicineMarket.
  ///
  /// In en, this message translates to:
  /// **'Medicine Market'**
  String get medicineMarket;

  /// No description provided for @searchMedicinesHint.
  ///
  /// In en, this message translates to:
  /// **'Search medicines...'**
  String get searchMedicinesHint;

  /// No description provided for @medicinesFound.
  ///
  /// In en, this message translates to:
  /// **'medicines found'**
  String get medicinesFound;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingSearch;

  /// No description provided for @shoppingCart.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get shoppingCart;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get yourCartIsEmpty;

  /// No description provided for @addSomeMedicinesToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add some medicines to get started'**
  String get addSomeMedicinesToGetStarted;

  /// No description provided for @browseMedicines.
  ///
  /// In en, this message translates to:
  /// **'Browse Medicines'**
  String get browseMedicines;

  /// No description provided for @itemRemovedFromCart.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get itemRemovedFromCart;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @cartClearedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cart cleared successfully'**
  String get cartClearedSuccessfully;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @backToCart.
  ///
  /// In en, this message translates to:
  /// **'Back to Cart'**
  String get backToCart;

  /// No description provided for @transactionSummary.
  ///
  /// In en, this message translates to:
  /// **'Transaction Summary'**
  String get transactionSummary;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference Number'**
  String get referenceNumber;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @receiptOptions.
  ///
  /// In en, this message translates to:
  /// **'Receipt Options'**
  String get receiptOptions;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @registeredUserPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Registered users can use all payment methods'**
  String get registeredUserPaymentMethods;

  /// No description provided for @guestUserPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Guest users can only use cash and bank transfer'**
  String get guestUserPaymentMethods;

  /// No description provided for @emailAddressOptional.
  ///
  /// In en, this message translates to:
  /// **'Email Address (Optional)'**
  String get emailAddressOptional;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmailAddress;

  /// No description provided for @emailHelperText.
  ///
  /// In en, this message translates to:
  /// **'Enter email to unlock more payment options'**
  String get emailHelperText;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// No description provided for @paymentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been processed successfully. Thank you for your purchase!'**
  String get paymentSuccessMessage;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// No description provided for @loadingMedicines.
  ///
  /// In en, this message translates to:
  /// **'Loading medicines...'**
  String get loadingMedicines;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @painRelief.
  ///
  /// In en, this message translates to:
  /// **'Pain Relief'**
  String get painRelief;

  /// No description provided for @antibiotics.
  ///
  /// In en, this message translates to:
  /// **'Antibiotics'**
  String get antibiotics;

  /// No description provided for @vitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get vitamins;

  /// No description provided for @coldFlu.
  ///
  /// In en, this message translates to:
  /// **'Cold & Flu'**
  String get coldFlu;

  /// No description provided for @heart.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get heart;

  /// No description provided for @diabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get diabetes;

  /// No description provided for @gastrointestinal.
  ///
  /// In en, this message translates to:
  /// **'Gastrointestinal'**
  String get gastrointestinal;

  /// No description provided for @allergy.
  ///
  /// In en, this message translates to:
  /// **'Allergy'**
  String get allergy;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or category'**
  String get tryDifferentSearch;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @sideEffects.
  ///
  /// In en, this message translates to:
  /// **'Side Effects'**
  String get sideEffects;

  /// No description provided for @warnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get warnings;

  /// No description provided for @originalPrice.
  ///
  /// In en, this message translates to:
  /// **'Original Price'**
  String get originalPrice;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @itemAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Item added to cart'**
  String get itemAddedToCart;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailed;

  /// No description provided for @nameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get nameAsc;

  /// No description provided for @nameDesc.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get nameDesc;

  /// No description provided for @priceAsc.
  ///
  /// In en, this message translates to:
  /// **'Price (Low to High)'**
  String get priceAsc;

  /// No description provided for @priceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price (High to Low)'**
  String get priceDesc;

  /// No description provided for @ratingDesc.
  ///
  /// In en, this message translates to:
  /// **'Rating (High to Low)'**
  String get ratingDesc;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newest;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @unitsAvailable.
  ///
  /// In en, this message translates to:
  /// **'units available'**
  String get unitsAvailable;

  /// No description provided for @failedToAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cart'**
  String get failedToAddToCart;

  /// No description provided for @failedToLoadCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cart'**
  String get failedToLoadCart;

  /// No description provided for @failedToUpdateQuantity.
  ///
  /// In en, this message translates to:
  /// **'Failed to update quantity'**
  String get failedToUpdateQuantity;

  /// No description provided for @failedToRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove item'**
  String get failedToRemoveItem;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @discountCode.
  ///
  /// In en, this message translates to:
  /// **'Discount Code'**
  String get discountCode;

  /// No description provided for @enterDiscountCode.
  ///
  /// In en, this message translates to:
  /// **'Enter discount code'**
  String get enterDiscountCode;

  /// No description provided for @discountCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., WELCOME10'**
  String get discountCodeHint;

  /// No description provided for @applying.
  ///
  /// In en, this message translates to:
  /// **'Applying...'**
  String get applying;

  /// No description provided for @discountApplied.
  ///
  /// In en, this message translates to:
  /// **'Discount Applied!'**
  String get discountApplied;

  /// No description provided for @codeDiscount.
  ///
  /// In en, this message translates to:
  /// **'Code Discount'**
  String get codeDiscount;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get off;

  /// No description provided for @tryDiscountCodes.
  ///
  /// In en, this message translates to:
  /// **'Try: WELCOME10, SAVE20, FIRST15, HEALTH5'**
  String get tryDiscountCodes;

  /// No description provided for @pleaseEnterDiscountCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a discount code'**
  String get pleaseEnterDiscountCode;

  /// No description provided for @invalidDiscountCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid discount code'**
  String get invalidDiscountCode;

  /// No description provided for @discountCodeRemoved.
  ///
  /// In en, this message translates to:
  /// **'Discount code removed'**
  String get discountCodeRemoved;

  /// No description provided for @itemDiscount.
  ///
  /// In en, this message translates to:
  /// **'Item Discount'**
  String get itemDiscount;

  /// No description provided for @codeDiscountPercent.
  ///
  /// In en, this message translates to:
  /// **'Code Discount'**
  String get codeDiscountPercent;

  /// No description provided for @taxPercent.
  ///
  /// In en, this message translates to:
  /// **'Tax (5%)'**
  String get taxPercent;

  /// No description provided for @printReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get printReceipt;

  /// No description provided for @emailReceipt.
  ///
  /// In en, this message translates to:
  /// **'Email Receipt'**
  String get emailReceipt;

  /// No description provided for @smsReceipt.
  ///
  /// In en, this message translates to:
  /// **'SMS Receipt'**
  String get smsReceipt;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @totalPurchases.
  ///
  /// In en, this message translates to:
  /// **'Total Purchases'**
  String get totalPurchases;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @allGood.
  ///
  /// In en, this message translates to:
  /// **'All Good!'**
  String get allGood;

  /// No description provided for @noAlertsAtMoment.
  ///
  /// In en, this message translates to:
  /// **'No alerts at the moment'**
  String get noAlertsAtMoment;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No Recent Activity'**
  String get noRecentActivity;

  /// No description provided for @failedToLoadStatistics.
  ///
  /// In en, this message translates to:
  /// **'Failed to load statistics'**
  String get failedToLoadStatistics;

  /// No description provided for @failedToLoadAlerts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load alerts'**
  String get failedToLoadAlerts;

  /// No description provided for @failedToLoadActivities.
  ///
  /// In en, this message translates to:
  /// **'Failed to load activities'**
  String get failedToLoadActivities;

  /// No description provided for @testDashboardApi.
  ///
  /// In en, this message translates to:
  /// **'Test Dashboard API'**
  String get testDashboardApi;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'unread notification'**
  String get unreadNotifications;

  /// No description provided for @unreadNotificationsPlural.
  ///
  /// In en, this message translates to:
  /// **'unread notifications'**
  String get unreadNotificationsPlural;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @vsLastWeekAmount.
  ///
  /// In en, this message translates to:
  /// **'vs {amount} last week'**
  String vsLastWeekAmount(Object amount);

  /// No description provided for @expiringMedicines.
  ///
  /// In en, this message translates to:
  /// **'Expiring Medicines'**
  String get expiringMedicines;

  /// No description provided for @expiringMedicinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Medicines Expiring Soon'**
  String get expiringMedicinesTitle;

  /// No description provided for @expiringMedicinesDescription.
  ///
  /// In en, this message translates to:
  /// **'Medicines expiring within 10 days'**
  String get expiringMedicinesDescription;

  /// No description provided for @daysUntilExpiry.
  ///
  /// In en, this message translates to:
  /// **'Days Until Expiry'**
  String get daysUntilExpiry;

  /// No description provided for @noExpiringMedicines.
  ///
  /// In en, this message translates to:
  /// **'No medicines expiring soon'**
  String get noExpiringMedicines;

  /// No description provided for @allMedicinesAreFresh.
  ///
  /// In en, this message translates to:
  /// **'All medicines are fresh and within expiry date'**
  String get allMedicinesAreFresh;

  /// No description provided for @fullReceipt.
  ///
  /// In en, this message translates to:
  /// **'Full Receipt'**
  String get fullReceipt;

  /// No description provided for @perMedicine.
  ///
  /// In en, this message translates to:
  /// **'Per Medicine'**
  String get perMedicine;

  /// No description provided for @commercialName.
  ///
  /// In en, this message translates to:
  /// **'Commercial Name'**
  String get commercialName;

  /// No description provided for @searchByCommercialName.
  ///
  /// In en, this message translates to:
  /// **'Search by commercial name'**
  String get searchByCommercialName;

  /// No description provided for @searchByGenericName.
  ///
  /// In en, this message translates to:
  /// **'Search by generic name'**
  String get searchByGenericName;

  /// No description provided for @heartDisease.
  ///
  /// In en, this message translates to:
  /// **'Heart Disease'**
  String get heartDisease;

  /// No description provided for @respiratory.
  ///
  /// In en, this message translates to:
  /// **'Respiratory'**
  String get respiratory;

  /// No description provided for @neurological.
  ///
  /// In en, this message translates to:
  /// **'Neurological'**
  String get neurological;

  /// No description provided for @dermatological.
  ///
  /// In en, this message translates to:
  /// **'Dermatological'**
  String get dermatological;

  /// No description provided for @ophthalmology.
  ///
  /// In en, this message translates to:
  /// **'Ophthalmology'**
  String get ophthalmology;

  /// No description provided for @urology.
  ///
  /// In en, this message translates to:
  /// **'Urology'**
  String get urology;

  /// No description provided for @gynecology.
  ///
  /// In en, this message translates to:
  /// **'Gynecology'**
  String get gynecology;

  /// No description provided for @pediatrics.
  ///
  /// In en, this message translates to:
  /// **'Pediatrics'**
  String get pediatrics;

  /// No description provided for @oncology.
  ///
  /// In en, this message translates to:
  /// **'Oncology'**
  String get oncology;

  /// No description provided for @psychiatry.
  ///
  /// In en, this message translates to:
  /// **'Psychiatry'**
  String get psychiatry;

  /// No description provided for @endocrinology.
  ///
  /// In en, this message translates to:
  /// **'Endocrinology'**
  String get endocrinology;

  /// No description provided for @rheumatology.
  ///
  /// In en, this message translates to:
  /// **'Rheumatology'**
  String get rheumatology;

  /// No description provided for @immunology.
  ///
  /// In en, this message translates to:
  /// **'Immunology'**
  String get immunology;

  /// No description provided for @infectiousDiseases.
  ///
  /// In en, this message translates to:
  /// **'Infectious Diseases'**
  String get infectiousDiseases;

  /// No description provided for @emergencyMedicine.
  ///
  /// In en, this message translates to:
  /// **'Emergency Medicine'**
  String get emergencyMedicine;

  /// No description provided for @requestedMedicines.
  ///
  /// In en, this message translates to:
  /// **'Requested Medicines'**
  String get requestedMedicines;

  /// No description provided for @medicineRequests.
  ///
  /// In en, this message translates to:
  /// **'Medicine Requests'**
  String get medicineRequests;

  /// No description provided for @approvedRequests.
  ///
  /// In en, this message translates to:
  /// **'Approved Requests'**
  String get approvedRequests;

  /// No description provided for @rejectedRequests.
  ///
  /// In en, this message translates to:
  /// **'Rejected Requests'**
  String get rejectedRequests;

  /// No description provided for @requestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get requestStatus;

  /// No description provided for @requestDate.
  ///
  /// In en, this message translates to:
  /// **'Request Date'**
  String get requestDate;

  /// No description provided for @approveRequest.
  ///
  /// In en, this message translates to:
  /// **'Approve Request'**
  String get approveRequest;

  /// No description provided for @rejectRequest.
  ///
  /// In en, this message translates to:
  /// **'Reject Request'**
  String get rejectRequest;

  /// No description provided for @requestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request Approved'**
  String get requestApproved;

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request Rejected'**
  String get requestRejected;

  /// No description provided for @medicineRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Medicine request sent to admin for approval'**
  String get medicineRequestSent;

  /// No description provided for @waitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for admin approval'**
  String get waitingForApproval;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No Pending Requests'**
  String get noPendingRequests;

  /// No description provided for @noPendingRequestsDescription.
  ///
  /// In en, this message translates to:
  /// **'All medicine requests have been processed'**
  String get noPendingRequestsDescription;

  /// No description provided for @noApprovedRequests.
  ///
  /// In en, this message translates to:
  /// **'No Approved Requests'**
  String get noApprovedRequests;

  /// No description provided for @noApprovedRequestsDescription.
  ///
  /// In en, this message translates to:
  /// **'No medicine requests have been approved yet'**
  String get noApprovedRequestsDescription;

  /// No description provided for @noRejectedRequests.
  ///
  /// In en, this message translates to:
  /// **'No Rejected Requests'**
  String get noRejectedRequests;

  /// No description provided for @noRejectedRequestsDescription.
  ///
  /// In en, this message translates to:
  /// **'No medicine requests have been rejected'**
  String get noRejectedRequestsDescription;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No Requests'**
  String get noRequests;

  /// No description provided for @noRequestsDescription.
  ///
  /// In en, this message translates to:
  /// **'No medicine requests found'**
  String get noRequestsDescription;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get rejectionReason;

  /// No description provided for @enterRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Enter reason for rejection'**
  String get enterRejectionReason;

  /// No description provided for @areYouSureApprove.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve'**
  String get areYouSureApprove;

  /// No description provided for @areYouSureReject.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject'**
  String get areYouSureReject;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @approvedAt.
  ///
  /// In en, this message translates to:
  /// **'Approved At'**
  String get approvedAt;

  /// No description provided for @noRequestedMedicines.
  ///
  /// In en, this message translates to:
  /// **'No Requested Medicines'**
  String get noRequestedMedicines;

  /// No description provided for @noRequestedMedicinesDescription.
  ///
  /// In en, this message translates to:
  /// **'No medicines have been requested and approved yet'**
  String get noRequestedMedicinesDescription;

  /// No description provided for @viewApprovedMedicines.
  ///
  /// In en, this message translates to:
  /// **'View approved medicines'**
  String get viewApprovedMedicines;

  /// No description provided for @reviewRequests.
  ///
  /// In en, this message translates to:
  /// **'Review medicine requests'**
  String get reviewRequests;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @requestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested By'**
  String get requestedBy;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @medicines.
  ///
  /// In en, this message translates to:
  /// **'medicines'**
  String get medicines;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @pharmacyAddress.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Address'**
  String get pharmacyAddress;

  /// No description provided for @pharmacyPhone.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Phone'**
  String get pharmacyPhone;

  /// No description provided for @invoiceDate.
  ///
  /// In en, this message translates to:
  /// **'Invoice Date'**
  String get invoiceDate;

  /// No description provided for @finalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get finalAmount;

  /// No description provided for @medicinesInInvoice.
  ///
  /// In en, this message translates to:
  /// **'Medicines in Invoice'**
  String get medicinesInInvoice;

  /// No description provided for @addCompleteInvoice.
  ///
  /// In en, this message translates to:
  /// **'Add Complete Invoice'**
  String get addCompleteInvoice;

  /// No description provided for @selectPartial.
  ///
  /// In en, this message translates to:
  /// **'Select Partial'**
  String get selectPartial;

  /// No description provided for @selectMedicines.
  ///
  /// In en, this message translates to:
  /// **'Select Medicines'**
  String get selectMedicines;

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'Add Selected'**
  String get addSelected;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @transactionNumber.
  ///
  /// In en, this message translates to:
  /// **'Transaction Number'**
  String get transactionNumber;

  /// No description provided for @purchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get purchaseDate;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @unknownMedicine.
  ///
  /// In en, this message translates to:
  /// **'Unknown Medicine'**
  String get unknownMedicine;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @invoiceType.
  ///
  /// In en, this message translates to:
  /// **'Invoice Type'**
  String get invoiceType;

  /// No description provided for @completeInvoice.
  ///
  /// In en, this message translates to:
  /// **'Complete Invoice'**
  String get completeInvoice;

  /// No description provided for @partialInvoice.
  ///
  /// In en, this message translates to:
  /// **'Partial Invoice'**
  String get partialInvoice;

  /// No description provided for @mustBuyComplete.
  ///
  /// In en, this message translates to:
  /// **'Must buy complete'**
  String get mustBuyComplete;

  /// No description provided for @canSelectPartial.
  ///
  /// In en, this message translates to:
  /// **'Can select partial'**
  String get canSelectPartial;

  /// No description provided for @selectPartialInvoice.
  ///
  /// In en, this message translates to:
  /// **'Select Partial Invoice'**
  String get selectPartialInvoice;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
