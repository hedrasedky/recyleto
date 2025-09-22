import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_routes.dart';
import 'delivery_addresses_screen.dart';
import 'payment_methods_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();

  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _orderUpdates = true;
  bool _promotionalOffers = false;
  String _currency = 'USD';

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
  ];
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'SAR', 'EGP'];

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      await _apiService.initialize();
      final settings = await _apiService.getUserSettings();

      setState(() {
        _notificationsEnabled = settings['notificationsEnabled'] ?? true;
        _emailNotifications = settings['emailNotifications'] ?? true;
        _pushNotifications = settings['pushNotifications'] ?? true;
        _orderUpdates = settings['orderUpdates'] ?? true;
        _promotionalOffers = settings['promotionalOffers'] ?? false;
        _currency = settings['currency'] ?? 'USD';
      });
    } catch (e) {
      print('Error loading user settings: $e');
      // Keep default values if API fails
    }
  }

  Future<void> _saveUserSettings() async {
    try {
      await _apiService.initialize();
      final settings = {
        'notificationsEnabled': _notificationsEnabled,
        'emailNotifications': _emailNotifications,
        'pushNotifications': _pushNotifications,
        'orderUpdates': _orderUpdates,
        'promotionalOffers': _promotionalOffers,
        'currency': _currency,
      };

      await _apiService.updateUserSettings(settings);
    } catch (e) {
      print('Error saving user settings: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Settings
            _buildSectionHeader(
                AppLocalizations.of(context)!.accountSettings, theme),
            _buildAccountSettings(theme),

            const SizedBox(height: 24),

            // Notifications
            _buildSectionHeader(
                AppLocalizations.of(context)!.notifications, theme),
            _buildNotificationSettings(theme),

            const SizedBox(height: 24),

            // App Preferences
            _buildSectionHeader(
                AppLocalizations.of(context)!.appPreferences, theme),
            _buildAppPreferences(theme),

            const SizedBox(height: 24),

            // Privacy & Security
            _buildSectionHeader(
                AppLocalizations.of(context)!.privacySecurity, theme),
            _buildPrivacySettings(theme),

            const SizedBox(height: 24),

            // Support & Help
            _buildSectionHeader(
                AppLocalizations.of(context)!.supportHelp, theme),
            _buildSupportSettings(theme),

            const SizedBox(height: 24),

            // Administration (for managers)
            _buildSectionHeader(
                AppLocalizations.of(context)!.administration, theme),
            _buildAdministrationSettings(theme),

            const SizedBox(height: 24),

            // About
            _buildSectionHeader(AppLocalizations.of(context)!.about, theme),
            _buildAboutSettings(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildAccountSettings(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.person,
            title: AppLocalizations.of(context)!.editProfile,
            subtitle: AppLocalizations.of(context)!.updatePersonalInfo,
            onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.editProfile);
            },
            theme: theme,
          ),
          _buildDivider(theme),
          _buildSettingTile(
            icon: Icons.lock,
            title: AppLocalizations.of(context)!.changePassword,
            subtitle: AppLocalizations.of(context)!.updateAccountPassword,
            onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.forgotPassword);
            },
            theme: theme,
          ),
          _buildDivider(theme),
          _buildSettingTile(
            icon: Icons.location_on,
            title: AppLocalizations.of(context)!.deliveryAddresses,
            subtitle: AppLocalizations.of(context)!.manageDeliveryAddresses,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DeliveryAddressesScreen(),
                ),
              );
            },
            theme: theme,
          ),
          _buildDivider(theme),
          _buildSettingTile(
            icon: Icons.payment,
            title: AppLocalizations.of(context)!.paymentMethods,
            subtitle: AppLocalizations.of(context)!.managePaymentOptions,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PaymentMethodsScreen(),
                ),
              );
            },
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.enableNotifications),
            subtitle:
                Text(AppLocalizations.of(context)!.receiveAppNotifications),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                if (!value) {
                  _emailNotifications = false;
                  _pushNotifications = false;
                  _orderUpdates = false;
                  _promotionalOffers = false;
                }
              });
              _saveUserSettings();
            },
            secondary: const Icon(Icons.notifications),
          ),
          if (_notificationsEnabled) ...[
            _buildDivider(theme),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.emailNotifications),
              subtitle:
                  Text(AppLocalizations.of(context)!.receiveUpdatesViaEmail),
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
                _saveUserSettings();
              },
              secondary: const Icon(Icons.email),
            ),
            _buildDivider(theme),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.pushNotifications),
              subtitle:
                  Text(AppLocalizations.of(context)!.receivePushNotifications),
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
                _saveUserSettings();
              },
              secondary: const Icon(Icons.phone_android),
            ),
            _buildDivider(theme),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.orderUpdates),
              subtitle: Text(
                  AppLocalizations.of(context)!.getNotifiedAboutOrderStatus),
              value: _orderUpdates,
              onChanged: (value) {
                setState(() {
                  _orderUpdates = value;
                });
                _saveUserSettings();
              },
              secondary: const Icon(Icons.local_shipping),
            ),
            _buildDivider(theme),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.promotionalOffers),
              subtitle:
                  Text(AppLocalizations.of(context)!.receiveSpecialOffers),
              value: _promotionalOffers,
              onChanged: (value) {
                setState(() {
                  _promotionalOffers = value;
                });
                _saveUserSettings();
              },
              secondary: const Icon(Icons.local_offer),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppPreferences(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: Text(AppLocalizations.of(context)!.darkMode),
                subtitle: Text(AppLocalizations.of(context)!.useDarkTheme),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
                secondary: const Icon(Icons.dark_mode),
              );
            },
          ),
          _buildDivider(theme),
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              final currentLanguage = _languages.firstWhere(
                (lang) => lang['code'] == localeProvider.locale.languageCode,
                orElse: () => _languages[0],
              );

              return ListTile(
                leading: const Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.language),
                subtitle: Text(currentLanguage['nativeName']!),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showLanguageDialog(theme);
                },
              );
            },
          ),
          _buildDivider(theme),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(AppLocalizations.of(context)!.currency),
            subtitle: Text(_currency),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showCurrencyDialog(theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.privacy_tip,
            title: AppLocalizations.of(context)!.privacyPolicy,
            subtitle: AppLocalizations.of(context)!.readPrivacyPolicy,
            onTap: () {
              // TODO: Navigate to privacy policy
            },
            theme: theme,
          ),
          _buildDivider(theme),
          _buildSettingTile(
            icon: Icons.description,
            title: AppLocalizations.of(context)!.termsOfService,
            subtitle: AppLocalizations.of(context)!.readTermsOfService,
            onTap: () {
              // TODO: Navigate to terms of service
            },
            theme: theme,
          ),
          _buildDivider(theme),
          _buildSettingTile(
            icon: Icons.delete_forever,
            title: AppLocalizations.of(context)!.deleteAccount,
            subtitle: AppLocalizations.of(context)!.permanentlyDeleteAccount,
            onTap: () {
              _showDeleteAccountDialog(theme);
            },
            theme: theme,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSettings(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.support_agent,
            title: AppLocalizations.of(context)!.contactSupport,
            subtitle: AppLocalizations.of(context)!.getHelpFromSupportTeam,
            onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.supportChat);
            },
            theme: theme,
          ),
          _buildDivider(theme),
          _buildSettingTile(
            icon: Icons.help,
            title: AppLocalizations.of(context)!.helpCenter,
            subtitle: AppLocalizations.of(context)!.browseHelpArticles,
            onTap: () {
              // TODO: Navigate to help center
            },
            theme: theme,
          ),
          _buildDivider(theme),
          _buildSettingTile(
            icon: Icons.feedback,
            title: AppLocalizations.of(context)!.sendFeedback,
            subtitle: AppLocalizations.of(context)!.shareYourThoughts,
            onTap: () {
              // TODO: Navigate to feedback form
            },
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildAdministrationSettings(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.analytics,
            title: AppLocalizations.of(context)!.reportsAnalytics,
            subtitle: AppLocalizations.of(context)!.viewDetailedReports,
            onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.reports);
            },
            theme: theme,
          ),
          _buildDivider(theme),
          _buildSettingTile(
            icon: Icons.people,
            title: AppLocalizations.of(context)!.userManagement,
            subtitle: AppLocalizations.of(context)!.manageUsersAndPermissions,
            onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.userManagement);
            },
            theme: theme,
          ),
          _buildDivider(theme),
          _buildSettingTile(
            icon: Icons.local_shipping,
            title: AppLocalizations.of(context)!.deliveryManagement,
            subtitle: AppLocalizations.of(context)!.manageDeliveryOrders,
            onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.delivery);
            },
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context)!.appVersion),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Show version details
            },
          ),
          _buildDivider(theme),
          _buildSettingTile(
            icon: Icons.update,
            title: AppLocalizations.of(context)!.checkForUpdates,
            subtitle: AppLocalizations.of(context)!.checkForAppUpdates,
            onTap: () {
              // TODO: Check for updates
            },
            theme: theme,
          ),
          _buildDivider(theme),
          _buildSettingTile(
            icon: Icons.share,
            title: AppLocalizations.of(context)!.shareApp,
            subtitle: AppLocalizations.of(context)!.shareRecyletoWithFriends,
            onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.about);
            },
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.errorRed : AppTheme.primaryGreen,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.errorRed : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      color: Colors.grey[300],
      indent: 56,
    );
  }

  void _showLanguageDialog(ThemeData theme) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages
              .map((language) => RadioListTile<String>(
                    title: Row(
                      children: [
                        Text(language['nativeName']!),
                        const SizedBox(width: 8),
                        Text(
                          '(${language['name']!})',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    value: language['code']!,
                    groupValue: localeProvider.locale.languageCode,
                    onChanged: (value) {
                      localeProvider.setLocale(Locale(value!));
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectCurrency),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _currencies
              .map((currency) => RadioListTile<String>(
                    title: Text(currency),
                    value: currency,
                    groupValue: _currency,
                    onChanged: (value) {
                      setState(() {
                        _currency = value!;
                      });
                      _saveUserSettings();
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAccount),
        content: Text(
          AppLocalizations.of(context)!.areYouSureDeleteAccount,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.accountDeletionRequested),
                  backgroundColor: AppTheme.warningOrange,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}
