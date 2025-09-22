import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

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
import '../reports/reports_screen.dart';
import '../delivery/delivery_screen.dart';
import '../market/market_screen.dart';
import '../market/cart_screen.dart';
import '../market/checkout_screen.dart';
import '../requests/request_medicine_screen.dart';
import '../requests/requested_medicines_screen.dart';
import '../admin/admin_review_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardProvider = context.read<DashboardProvider>();
      dashboardProvider.loadDashboardData();
    });
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                        if (dashboardProvider.unreadNotificationsCount > 0)
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
                                  '${dashboardProvider.unreadNotificationsCount}',
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
    // Use the actual data structure from backend
    final totalSales = statistics['totalSales'] ?? 0;
    final totalPurchases = statistics['totalPurchases'] ?? 0;
    final expiringCount = statistics['expiringCount'] ?? 0;
    final pendingRequests = statistics['pendingRequestsCount'] ?? 0;

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
          value: '\$${totalSales.toStringAsFixed(2)}',
          change: AppLocalizations.of(context)!.today,
          isPositive: true,
          icon: Icons.trending_up,
          color: AppTheme.successGreen,
        ),
        KPICard(
          title: AppLocalizations.of(context)!.totalPurchases,
          value: '\$${totalPurchases.toStringAsFixed(2)}',
          change: AppLocalizations.of(context)!.today,
          isPositive: true,
          icon: Icons.shopping_cart,
          color: AppTheme.warningOrange,
        ),
        KPICard(
          title: AppLocalizations.of(context)!.expiringSoon,
          value: '$expiringCount',
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
          value: '$pendingRequests',
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final data = snapshot.data;
              final notifications = data?['notifications'] ?? [];
              final unreadCount = data?['unreadCount'] ?? 0;

              if (notifications.isEmpty) {
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
                  ...notifications.map((notification) => ListTile(
                        leading: Icon(
                          notification['type'] == 'system'
                              ? Icons.system_update
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
            title: AppLocalizations.of(context)!.checkout,
            subtitle: AppLocalizations.of(context)!.processPayment,
            icon: Icons.payment,
            color: AppTheme.errorRed,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CheckoutScreen(),
                ),
              );
            },
          ),
          QuickActionCard(
            title: AppLocalizations.of(context)!.reports,
            subtitle: AppLocalizations.of(context)!.viewAnalytics,
            icon: Icons.analytics,
            color: AppTheme.darkTeal,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReportsScreen(),
                ),
              );
            },
          ),
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
