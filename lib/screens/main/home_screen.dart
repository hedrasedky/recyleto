import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../utils/dashboard_test.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/quick_action_card.dart';
import '../inventory/add_medicine_screen.dart';
import '../inventory/inventory_screen.dart';
import '../inventory/expiring_medicines_screen.dart';
import '../profile/profile_screen.dart';
import '../sales/add_transaction_screen.dart';
import '../sales/sales_screen.dart';
import '../delivery/delivery_screen.dart';
import '../market/market_screen.dart';
import '../market/cart_screen.dart';
import '../requests/request_medicine_screen.dart';
import '../requests/requested_medicines_screen.dart';
import '../admin/admin_review_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _loadDashboardData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to RouteObserver
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      RecyletoApp.routeObserver.subscribe(this, route);
    }
    // Only reload if this is the first time dependencies change
    if (!mounted) return;
  }

  @override
  void didPopNext() {
    print('🏠 HomeScreen: didPopNext - User returned to Home Screen');
    // Refresh data when user returns to Home Screen
    _refreshDashboardData();
  }

  @override
  void didPushNext() {
    print('🏠 HomeScreen: didPushNext - User navigated away from Home Screen');
  }

  // Refresh dashboard data when returning to Home Screen
  Future<void> _refreshDashboardData() async {
    try {
      print('🏠 HomeScreen: Refreshing dashboard data...');

      // Recalculate sales data to get latest transactions
      await _calculateAndUpdateSales();

      // Recalculate purchases data to get latest checkout transactions
      await _calculateAndUpdatePurchases();

      print('🏠 HomeScreen: Dashboard data refreshed successfully');
    } catch (e) {
      print('🏠 HomeScreen: Error refreshing dashboard data: $e');
    }
  }

  // Calculate and update sales data directly in Home Screen
  Future<void> _calculateAndUpdateSales() async {
    try {
      print('📊 Dashboard: Calculating sales data directly...');

      final apiService = ApiService();
      await apiService.initialize();

      // Get all transactions
      final allTransactions = await apiService.getTransactions();
      print(
          '📊 Dashboard: Total transactions found: ${allTransactions.length}');

      // Calculate recent sales from ALL completed transactions (last 2 days)
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final recentTransactions = allTransactions.where((tx) {
        final txDate = DateTime.parse(tx['createdAt'] ?? tx['date'] ?? '');
        final isToday = txDate.year == today.year &&
            txDate.month == today.month &&
            txDate.day == today.day;
        final isYesterday = txDate.year == yesterday.year &&
            txDate.month == yesterday.month &&
            txDate.day == yesterday.day;
        final isRecent = isToday || isYesterday;
        final isCompleted = tx['status'] == 'completed';
        return isRecent && isCompleted;
      }).toList();

      final recentSales = recentTransactions.fold<double>(
          0,
          (sum, tx) =>
              sum + (tx['totalAmount'] ?? tx['total'] ?? tx['amount'] ?? 0.0));

      print('📊 Dashboard: Calculated recent sales: $recentSales');
      print(
          '📊 Dashboard: Recent transactions count: ${recentTransactions.length}');

      // Update DashboardProvider with calculated sales
      if (mounted) {
        final dashboardProvider = context.read<DashboardProvider>();
        dashboardProvider.updateSalesData(recentSales);
        print(
            '📊 Dashboard: Updated DashboardProvider with sales: $recentSales');

        // Force UI update
        setState(() {});
      }
    } catch (e) {
      print('Error calculating sales in dashboard: $e');
    }
  }

  // Calculate and update purchases data (checkout transactions) directly in Home Screen
  Future<void> _calculateAndUpdatePurchases() async {
    try {
      print('🛒 Dashboard: Calculating checkout purchases data directly...');

      final apiService = ApiService();
      await apiService.initialize();

      // Get checkout transactions only
      final checkoutTransactions = await apiService.getTransactions();
      print(
          '🛒 Dashboard: Checkout transactions found: ${checkoutTransactions.length}');

      // Calculate recent purchases from checkout transactions (last 2 days)
      // These are all transactions completed through the checkout process
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final checkoutPurchases = checkoutTransactions.where((tx) {
        final txDate = DateTime.parse(tx['createdAt'] ?? tx['date'] ?? '');
        final isToday = txDate.year == today.year &&
            txDate.month == today.month &&
            txDate.day == today.day;
        final isYesterday = txDate.year == yesterday.year &&
            txDate.month == yesterday.month &&
            txDate.day == yesterday.day;
        final isRecent = isToday || isYesterday;

        // All checkout transactions from the last 2 days
        return isRecent;
      }).toList();

      final checkoutPurchasesTotal = checkoutPurchases.fold<double>(
          0,
          (sum, tx) =>
              sum + (tx['totalAmount'] ?? tx['total'] ?? tx['amount'] ?? 0.0));

      print(
          '🛒 Dashboard: Calculated checkout purchases: $checkoutPurchasesTotal');
      print(
          '🛒 Dashboard: Checkout transactions count: ${checkoutPurchases.length}');

      // Log each checkout purchase for debugging
      for (int i = 0; i < checkoutPurchases.length; i++) {
        final tx = checkoutPurchases[i];
        final amount = tx['totalAmount'] ?? tx['total'] ?? tx['amount'] ?? 0.0;
        final description = tx['description'] ?? 'No description';
        print(
            '🛒 Checkout Purchase ${i + 1}: \$${amount.toStringAsFixed(2)} - Type: ${tx['transactionType']} - Description: $description');
      }

      // Update DashboardProvider with calculated purchases
      if (mounted) {
        final dashboardProvider = context.read<DashboardProvider>();
        dashboardProvider.updatePurchasesData(checkoutPurchasesTotal);
        print(
            '🛒 Dashboard: Updated DashboardProvider with checkout purchases: $checkoutPurchasesTotal');

        // Force UI update
        setState(() {});
      }
    } catch (e) {
      print('Error calculating customer purchases in dashboard: $e');
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reload if returning from another screen
    print('🏠 HomeScreen didUpdateWidget - reloading data');
    _loadDashboardData();
  }

  void _checkAuthStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  void _loadDashboardData() {
    print('🏠 HomeScreen._loadDashboardData() called');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('🏠 PostFrameCallback executing...');
      final dashboardProvider = context.read<DashboardProvider>();
      print('🏠 DashboardProvider obtained, calling loadDashboardData()...');
      await dashboardProvider.loadDashboardData();

      // Check for notifications (low stock, expiring) - handled in HomeDashboard
      await _checkLowStockFromInventory();

      // Check for recent sales notifications
      await _checkRecentSalesInHome();
    });
  }

  // Check for low stock medicines from inventory
  Future<void> _checkLowStockFromInventory() async {
    try {
      final apiService = ApiService();
      await apiService.initialize();

      // Get all medicines
      final medicines = await apiService.getMedicines();

      // Find low stock medicines
      final lowStockMedicines = medicines.where((medicine) {
        final stock = medicine['stock'] ?? medicine['quantity'] ?? 0;
        return stock < 10;
      }).toList();

      if (lowStockMedicines.isNotEmpty) {
        print('⚠️ Home: Found ${lowStockMedicines.length} low stock medicines');
        // Low stock notifications are now handled in the dialog only
      }
    } catch (e) {
      print('❌ Error checking low stock from inventory: $e');
    }
  }

  // Check for recent sales in home screen
  Future<void> _checkRecentSalesInHome() async {
    try {
      final apiService = ApiService();
      await apiService.initialize();

      // Get recent transactions (today's sales)
      final allTransactions = await apiService.getTransactions();
      final today = DateTime.now();
      final todayTransactions = allTransactions.where((tx) {
        final txDate = DateTime.parse(tx['createdAt'] ?? tx['date'] ?? '');
        return txDate.year == today.year &&
            txDate.month == today.month &&
            txDate.day == today.day;
      }).toList();

      if (todayTransactions.isNotEmpty) {
        print('💰 Home: Found ${todayTransactions.length} sales today');
        // Sales notifications are now handled in the dialog only
      }
    } catch (e) {
      print('❌ Error checking recent sales in home: $e');
    }
  }

  int _getNavigationIndex() {
    // Map screen indices to navigation indices
    // 0: Home -> 0, 1: Market -> 1, 2: Sales -> 2, 3: Inventory -> hidden, 4: Profile -> 3
    if (_currentIndex == 0) return 0; // Home
    if (_currentIndex == 1) return 1; // Market
    if (_currentIndex == 2) return 2; // Sales
    if (_currentIndex == 3) return 2; // Inventory -> show Sales (fallback)
    if (_currentIndex == 4) return 3; // Profile
    return 0; // Default to Home
  }

  final List<Widget> _screens = [
    const HomeDashboard(),
    const MarketScreen(),
    const SalesScreen(),
    const InventoryScreen(), // Keep the screen but hide from navigation
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    // Unsubscribe from RouteObserver
    RecyletoApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _getNavigationIndex(),
          onTap: (index) {
            setState(() {
              // Map navigation indices to screen indices
              // 0: Home, 1: Market, 2: Sales, 3: Profile (Inventory is hidden)
              if (index == 0) {
                _currentIndex = 0; // Home
              } else if (index == 1) {
                _currentIndex = 1; // Market
              } else if (index == 2) {
                _currentIndex = 2; // Sales
              } else if (index == 3) {
                _currentIndex = 4; // Profile (skip Inventory at index 3)
              }
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryTeal,
          unselectedItemColor: Colors.grey,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined),
              activeIcon: Icon(Icons.store),
              label: AppLocalizations.of(context)!.market,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale_outlined),
              activeIcon: Icon(Icons.point_of_sale),
              label: AppLocalizations.of(context)!.sales,
            ),
            // Inventory hidden from navigation but kept in code for future use
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.inventory_2_outlined),
            //   activeIcon: Icon(Icons.inventory_2),
            //   label: AppLocalizations.of(context)!.inventory,
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: AppLocalizations.of(context)!.profile,
            ),
          ],
        ),
      ),
      floatingActionButton:
          (_currentIndex == 0 || _currentIndex == 1 || _currentIndex == 2)
              ? FloatingActionButton.extended(
                  onPressed: () {
                    AppRoutes.navigateTo(context, AppRoutes.requestMedicine);
                  },
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.requestMedicine),
                )
              : null,
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _showMoreQuickActions = false;
  late TabController _tabController;
  final List<Map<String, dynamic>> _localNotifications = [];
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    print('🏠 Dashboard: initState called');
    _tabController = TabController(length: 2, vsync: this);

    // Load data only once when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 Dashboard: PostFrameCallback executing...');
      _loadDashboardData();
    });
  }

  // Load all dashboard data once
  Future<void> _loadDashboardData() async {
    print('🏠 Dashboard: _loadDashboardData called');
    if (_isLoadingData) {
      print('🏠 Dashboard: Already loading, skipping...');
      return; // Prevent multiple calls
    }

    print('🏠 Dashboard: Starting data load...');
    setState(() {
      _isLoadingData = true;
    });

    try {
      await _apiService.initialize();
      print('🏠 Dashboard: API service initialized');

      // Load all data in parallel
      print('🏠 Dashboard: Loading data in parallel...');
      await Future.wait([
        _checkLowStockMedicines(),
        _calculateAndUpdateSales(),
        _loadTodayPurchases(),
      ]);
      print('🏠 Dashboard: All data loaded successfully');
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
        print('🏠 Dashboard: Data loading completed');
      }
    }
  }

  // Check for low stock medicines and add to local notifications
  Future<void> _checkLowStockMedicines() async {
    try {
      // Get all medicines
      final medicines = await _apiService.getMedicines();

      // Find low stock medicines
      final lowStockMedicines = medicines.where((medicine) {
        final stock = medicine['stock'] ?? medicine['quantity'] ?? 0;
        return stock < 10;
      }).toList();

      if (lowStockMedicines.isNotEmpty) {
        // Add notification for each low stock medicine
        for (final medicine in lowStockMedicines) {
          final stock = medicine['stock'] ?? medicine['quantity'] ?? 0;
          addLocalNotification({
            'type': 'low_stock',
            'title': 'Low Stock Alert',
            'message':
                '${medicine['name']} is running low on stock ($stock remaining)',
            'medicineId': medicine['id'] ?? medicine['_id'],
            'medicineName': medicine['name'],
            'currentStock': stock,
            'threshold': 10,
            'priority': stock <= 3 ? 'high' : 'medium',
          });
        }
      }
    } catch (e) {
      print('❌ Error checking low stock medicines: $e');
    }
  }

  // Calculate and update sales data directly in Home Screen
  Future<void> _calculateAndUpdateSales() async {
    try {
      print('📊 Dashboard: Calculating sales data directly...');

      // Get all transactions
      final allTransactions = await _apiService.getTransactions();
      print(
          '📊 Dashboard: Total transactions found: ${allTransactions.length}');

      // Calculate recent sales from ALL completed transactions (last 2 days)
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final recentTransactions = allTransactions.where((tx) {
        final txDate = DateTime.parse(tx['createdAt'] ?? tx['date'] ?? '');
        final isToday = txDate.year == today.year &&
            txDate.month == today.month &&
            txDate.day == today.day;
        final isYesterday = txDate.year == yesterday.year &&
            txDate.month == yesterday.month &&
            txDate.day == yesterday.day;
        final isRecent = isToday || isYesterday;
        final isCompleted = tx['status'] == 'completed';
        return isRecent && isCompleted;
      }).toList();

      final recentSales = recentTransactions.fold<double>(
          0,
          (sum, tx) =>
              sum + (tx['totalAmount'] ?? tx['total'] ?? tx['amount'] ?? 0.0));

      print('📊 Dashboard: Calculated recent sales: $recentSales');
      print(
          '📊 Dashboard: Recent transactions count: ${recentTransactions.length}');

      // Update DashboardProvider with calculated sales
      if (mounted) {
        final dashboardProvider = context.read<DashboardProvider>();
        dashboardProvider.updateSalesData(recentSales);
        print(
            '📊 Dashboard: Updated DashboardProvider with sales: $recentSales');

        // Force UI update
        setState(() {});
      }
    } catch (e) {
      print('Error calculating sales in dashboard: $e');
    }
  }

  // Load today's purchases data
  Future<void> _loadTodayPurchases() async {
    try {
      // Get checkout transactions only
      final checkoutTransactions = await _apiService.getTransactions();
      print('🛒 Checkout transactions found: ${checkoutTransactions.length}');

      // Calculate recent purchases from checkout transactions (last 2 days)
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final recentPurchases = checkoutTransactions.where((tx) {
        final txDate = DateTime.parse(tx['createdAt'] ?? tx['date'] ?? '');
        final isToday = txDate.year == today.year &&
            txDate.month == today.month &&
            txDate.day == today.day;
        final isYesterday = txDate.year == yesterday.year &&
            txDate.month == yesterday.month &&
            txDate.day == yesterday.day;
        final isRecent = isToday || isYesterday;

        // All checkout transactions from the last 2 days
        return isRecent;
      }).toList();

      final recentPurchasesTotal = recentPurchases.fold<double>(
          0,
          (sum, tx) =>
              sum + (tx['totalAmount'] ?? tx['total'] ?? tx['amount'] ?? 0.0));

      print('🛒 Dashboard Recent Purchases calculated: $recentPurchasesTotal');
      print(
          '🛒 Dashboard Recent Checkout Transactions count: ${recentPurchases.length}');

      // Log each checkout purchase for debugging
      for (int i = 0; i < recentPurchases.length; i++) {
        final purchase = recentPurchases[i];
        final amount = purchase['totalAmount'] ??
            purchase['total'] ??
            purchase['amount'] ??
            0.0;
        final description = purchase['description'] ?? 'No description';
        print(
            '🛒 Dashboard Checkout Purchase ${i + 1}: \$${amount.toStringAsFixed(2)} - Type: ${purchase['transactionType']} - Description: $description');
      }

      // Update the dashboard data with today's purchases
      if (mounted) {
        final dashboardProvider = context.read<DashboardProvider>();

        // Initialize statistics if null
        if (dashboardProvider.statistics == null) {
          dashboardProvider.updateStatistics({
            'totalSales': 0.0,
            'totalPurchases': 0.0,
            'expiringCount': 0,
            'pendingRequestsCount': 0,
          });
        }

        final updatedStats =
            Map<String, dynamic>.from(dashboardProvider.statistics!);
        updatedStats['totalPurchases'] = recentPurchasesTotal;
        dashboardProvider.updateStatistics(updatedStats);
        print(
            '📊 Updated dashboard statistics: ${dashboardProvider.statistics}');

        // Force UI update
        setState(() {});
      }
    } catch (e) {
      print('Error loading today purchases in dashboard: $e');
    }
  }

  // Add local notification
  void addLocalNotification(Map<String, dynamic> notification) {
    setState(() {
      _localNotifications.insert(0, {
        ...notification,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });
    });

    // Notifications are now only shown in the dialog
    print('🔔 Notification added to dialog: ${notification['title']}');
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.notifications),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _apiService.getNotifications(),
            builder: (context, snapshot) {
              // Combine local and API notifications
              final apiNotifications = snapshot.data?['notifications'] ?? [];
              final allNotifications = [
                ..._localNotifications,
                ...apiNotifications
              ];
              final unreadCount =
                  allNotifications.where((n) => !(n['isRead'] ?? false)).length;

              if (allNotifications.isEmpty) {
                return Center(
                  child: Text(AppLocalizations.of(context)!.noNotifications),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (unreadCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        unreadCount > 1
                            ? '$unreadCount ${AppLocalizations.of(context)!.unreadNotificationsPlural}'
                            : '$unreadCount ${AppLocalizations.of(context)!.unreadNotifications}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                  ...allNotifications.map((notification) => ListTile(
                        leading: Icon(
                          notification['type'] == 'low_stock'
                              ? Icons.warning
                              : notification['type'] == 'sale'
                                  ? Icons.attach_money
                                  : notification['type'] == 'checkout'
                                      ? Icons.shopping_cart_checkout
                                      : notification['type'] == 'expiring'
                                          ? Icons.schedule
                                          : Icons.notifications,
                          color: AppTheme.primaryTeal,
                        ),
                        title: Text(notification['title'] ?? 'Notification'),
                        subtitle: Text(notification['message'] ?? ''),
                        trailing: notification['isRead'] == false
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.errorRed,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                        onTap: () {
                          // Mark as read
                          setState(() {
                            notification['isRead'] = true;
                          });
                        },
                      )),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();

    print(
        '🏠 Home: build() called - DashboardProvider statistics: ${dashboardProvider.statistics}');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () => dashboardProvider.refresh(),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Container(
                    constraints: const BoxConstraints(maxHeight: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.welcome,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppTheme.darkGray.withOpacity(0.7),
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Flexible(
                          child: Text(
                            authProvider.pharmacyName ?? 'Pharmacy',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                    icon: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CartScreen(),
                        ),
                      );
                    },
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          color: AppTheme.primaryTeal,
                        ),
                        // You can add cart item count here if needed
                        // Positioned(
                        //   right: 0,
                        //   top: 0,
                        //   child: Container(
                        //     width: 16,
                        //     height: 16,
                        //     decoration: const BoxDecoration(
                        //       color: AppTheme.errorRed,
                        //       shape: BoxShape.circle,
                        //     ),
                        //     child: Center(
                        //       child: Text(
                        //         '$_cartItemCount',
                        //         style: const TextStyle(
                        //           color: Colors.white,
                        //           fontSize: 10,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showNotificationsDialog();
                    },
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: AppTheme.primaryTeal,
                        ),
                        if (_localNotifications
                                .where((n) => !(n['isRead'] ?? false))
                                .length >
                            0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppTheme.errorRed,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${_localNotifications.where((n) => !(n['isRead'] ?? false)).length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Test notification button
                  IconButton(
                    onPressed: () {
                      addLocalNotification({
                        'type': 'test',
                        'title': 'Test Notification',
                        'message':
                            'This is a test notification to verify the system works',
                        'priority': 'medium',
                      });
                    },
                    icon: const Icon(
                      Icons.bug_report,
                      color: Colors.orange,
                    ),
                    tooltip: 'Test Notification',
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Tab Bar
              SliverToBoxAdapter(
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    indicatorColor: AppTheme.primaryTeal,
                    indicatorWeight: 3,
                    labelColor: AppTheme.primaryTeal,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.todaySales),
                      Tab(text: AppLocalizations.of(context)!.quickActions),
                    ],
                  ),
                ),
              ),

              // Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Today Sales
                    _buildTodaySalesTab(dashboardProvider),
                    // Tab 2: Quick Actions
                    _buildQuickActionsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPICards(Map<String, dynamic> statistics) {
    print('🏠 Home: _buildKPICards called with statistics: $statistics');

    // Use the actual data structure from backend
    final totalSales = statistics['totalSales'] ?? 0;
    final totalPurchases = statistics['totalPurchases'] ?? 0;
    final expiringCount = statistics['expiringCount'] ?? 0;
    final pendingRequests = statistics['pendingRequestsCount'] ?? 0;

    print(
        '🏠 Home: Raw values - totalSales: $totalSales, totalPurchases: $totalPurchases');

    // Ensure we have valid numbers
    final safeTotalSales = (totalSales is num) ? totalSales.toDouble() : 0.0;
    final safeTotalPurchases =
        (totalPurchases is num) ? totalPurchases.toDouble() : 0.0;
    final safeExpiringCount =
        (expiringCount is num) ? expiringCount.toInt() : 0;
    final safePendingRequests =
        (pendingRequests is num) ? pendingRequests.toInt() : 0;

    print(
        '🏠 Home: Safe values - safeTotalSales: $safeTotalSales, safeTotalPurchases: $safeTotalPurchases');

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        KPICard(
          title: AppLocalizations.of(context)!.totalSales,
          value: '\$${safeTotalSales.toStringAsFixed(2)}',
          change: AppLocalizations.of(context)!.today,
          isPositive: true,
          icon: Icons.trending_up,
          color: AppTheme.successGreen,
        ),
        KPICard(
          title: AppLocalizations.of(context)!.totalPurchases,
          value: '\$${safeTotalPurchases.toStringAsFixed(2)}',
          change: AppLocalizations.of(context)!.today,
          isPositive: true,
          icon: Icons.shopping_cart,
          color: AppTheme.warningOrange,
        ),
        KPICard(
          title: AppLocalizations.of(context)!.expiringSoon,
          value: '$safeExpiringCount',
          change: AppLocalizations.of(context)!.items,
          isPositive: false,
          icon: Icons.schedule,
          color: AppTheme.errorRed,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ExpiringMedicinesScreen(),
              ),
            );
          },
        ),
        KPICard(
          title: AppLocalizations.of(context)!.pendingRequests,
          value: '$safePendingRequests',
          change: AppLocalizations.of(context)!.items,
          isPositive: false,
          icon: Icons.assignment_return,
          color: AppTheme.primaryTeal,
        ),
      ],
    );
  }

  Widget _buildLoadingKPICards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: List.generate(
          4,
          (index) => const Card(
                child: Center(child: CircularProgressIndicator()),
              )),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        // الأولوية العالية - الأكثر استخداماً
        QuickActionCard(
          title: AppLocalizations.of(context)!.addNewTransaction,
          subtitle: AppLocalizations.of(context)!.addTransaction,
          icon: Icons.add_shopping_cart,
          color: AppTheme.primaryTeal,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddTransactionScreen(),
              ),
            );
          },
        ),
        QuickActionCard(
          title: AppLocalizations.of(context)!.sales,
          subtitle: AppLocalizations.of(context)!.viewAnalytics,
          icon: Icons.receipt_long,
          color: AppTheme.darkTeal,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SalesScreen(),
              ),
            );
          },
        ),
        QuickActionCard(
          title: AppLocalizations.of(context)!.requests,
          subtitle: AppLocalizations.of(context)!.manageRequests,
          icon: Icons.request_quote,
          color: AppTheme.lightTeal,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const RequestMedicineScreen(),
              ),
            );
          },
        ),
        QuickActionCard(
          title: AppLocalizations.of(context)!.market,
          subtitle: AppLocalizations.of(context)!.browseProducts,
          icon: Icons.store,
          color: AppTheme.successGreen,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const MarketScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorCard(String title, String message) {
    return Card(
      color: AppTheme.errorRed.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.errorRed,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.errorRed.withOpacity(0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySalesTab(DashboardProvider dashboardProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards with Real-time Data
          if (dashboardProvider.isLoadingStatistics)
            const Center(child: CircularProgressIndicator())
          else if (dashboardProvider.statisticsError != null)
            _buildErrorCard(
                AppLocalizations.of(context)!.failedToLoadStatistics,
                dashboardProvider.statisticsError!)
          else if (dashboardProvider.statistics != null)
            _buildKPICards(dashboardProvider.statistics!)
          else
            _buildLoadingKPICards(),

          const SizedBox(height: 16),

          // Debug Test Button (remove in production)
          OutlinedButton.icon(
            onPressed: () async {
              print('🧪 Starting dashboard test...');
              await DashboardTest.testDashboardEndpoints();
            },
            icon: const Icon(Icons.bug_report),
            label: Text(AppLocalizations.of(context)!.testDashboardApi),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
            ),
          ),

          const SizedBox(height: 100), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildQuickActionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.quickActions,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showMoreQuickActions = !_showMoreQuickActions;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showMoreQuickActions
                          ? AppLocalizations.of(context)!.less
                          : AppLocalizations.of(context)!.more,
                      style: TextStyle(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showMoreQuickActions
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppTheme.primaryTeal,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildQuickActions(context),

          // Additional Quick Actions (shown when More is pressed)
          if (_showMoreQuickActions) ...[
            const SizedBox(height: 16),
            _buildAdditionalQuickActions(context),
          ],

          const SizedBox(height: 100), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildAdditionalQuickActions(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: [
          // الأولوية المتوسطة
          QuickActionCard(
            title: AppLocalizations.of(context)!.addNewMedicine,
            subtitle: AppLocalizations.of(context)!.addMedicine,
            icon: Icons.medication,
            color: AppTheme.primaryGreen,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddMedicineScreen(),
                ),
              );
            },
          ),
          QuickActionCard(
            title: AppLocalizations.of(context)!.delivery,
            subtitle: AppLocalizations.of(context)!.manageDeliveries,
            icon: Icons.local_shipping,
            color: AppTheme.warningOrange,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DeliveryScreen(),
                ),
              );
            },
          ),
          // الأولوية المنخفضة - للمدير
          QuickActionCard(
            title: AppLocalizations.of(context)!.requestedMedicines,
            subtitle: AppLocalizations.of(context)!.viewApprovedMedicines,
            icon: Icons.medication,
            color: AppTheme.successGreen,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RequestedMedicinesScreen(),
                ),
              );
            },
          ),
          QuickActionCard(
            title: AppLocalizations.of(context)!.medicineRequests,
            subtitle: AppLocalizations.of(context)!.reviewRequests,
            icon: Icons.admin_panel_settings,
            color: AppTheme.warningOrange,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AdminReviewScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
