import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:recyleto_app/providers/auth_provider.dart';
import 'package:recyleto_app/providers/dashboard_provider.dart';
import 'package:recyleto_app/providers/locale_provider.dart';
import 'package:recyleto_app/providers/theme_provider.dart';
import 'package:recyleto_app/services/api_service.dart';
// import 'package:recyleto_app/services/payment_service.dart'; // Temporarily disabled
import 'package:recyleto_app/utils/app_routes.dart';
import 'package:recyleto_app/utils/app_theme.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

void main() async {
  print('🚀 main() function started');
  WidgetsFlutterBinding.ensureInitialized();
  print('🚀 WidgetsFlutterBinding.ensureInitialized() completed');

  // Initialize API service to load stored token2
  print('🚀 Initializing ApiService...');
  await ApiService().initialize();
  print('🚀 ApiService initialization completed');

  print('🚀 Starting RecyletoApp...');
  runApp(const RecyletoApp());
}

class RecyletoApp extends StatelessWidget {
  const RecyletoApp({super.key});

  // Create RouteObserver for tracking navigation
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'Recyleto',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
            navigatorObservers: [routeObserver],
            // navigatorKey: navigatorKey, // For Flutterwave integration - temporarily disabled
          );
        },
      ),
    );
  }
}
