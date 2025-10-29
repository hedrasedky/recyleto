import 'package:flutter/material.dart';

import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Dashboard Data
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _notifications;

  // Loading States
  bool _isLoadingDashboard = false;
  bool _isLoadingNotifications = false;

  // Error States
  String? _dashboardError;
  String? _notificationsError;

  // Getters
  Map<String, dynamic>? get dashboardData => _dashboardData;
  Map<String, dynamic>? get notifications => _notifications;

  // Extracted data for easier access
  Map<String, dynamic>? get statistics {
    final kpis = _dashboardData?['kpis'];
    if (kpis is Map) {
      // Ensure a strongly-typed map to avoid LinkedMap<dynamic,dynamic> issues
      final stats = Map<String, dynamic>.from(kpis);
      print(
          '📊 DashboardProvider: statistics getter called, returning: $stats');
      return stats;
    }
    print(
        '⚠️ DashboardProvider: statistics getter called, but kpis is null or not a Map');
    return null;
  }

  List<Map<String, dynamic>> get alerts {
    final lowStock = _dashboardData?['lowStockItems'] ?? [];
    final expiring = _dashboardData?['expiringMedications'] ?? [];

    List<Map<String, dynamic>> alerts = [];

    // Add low stock alerts
    for (var item in lowStock) {
      final stock = item['quantity'] ?? item['stock'] ?? 0;
      alerts.add({
        'id': item['_id'] ?? item['id'],
        'title': 'Low Stock Alert',
        'message':
            '${item['productId']?['name'] ?? 'Medicine'} is low on stock (${stock} remaining)',
        'type': 'low_stock',
        'priority': stock <= 5 ? 'critical' : 'high',
        'currentStock': stock,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    // Add expiring alerts
    for (var item in expiring) {
      final expiryDate = item['expiryDate'];
      final daysUntilExpiry = item['daysUntilExpiry'] ?? 0;
      alerts.add({
        'id': item['_id'] ?? item['id'],
        'title': 'Expiry Alert',
        'message':
            '${item['productId']?['name'] ?? 'Medicine'} is expiring in $daysUntilExpiry days',
        'type': 'expiry',
        'priority': daysUntilExpiry <= 7 ? 'critical' : 'medium',
        'daysUntilExpiry': daysUntilExpiry,
        'expiryDate': expiryDate,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    return alerts;
  }

  List<Map<String, dynamic>> get recentActivities {
    return List<Map<String, dynamic>>.from(
        _dashboardData?['recentActivity'] ?? []);
  }

  bool get isLoadingStatistics => _isLoadingDashboard;
  bool get isLoadingAlerts => _isLoadingDashboard;
  bool get isLoadingActivities => _isLoadingDashboard;
  bool get isLoadingNotifications => _isLoadingNotifications;

  String? get statisticsError => _dashboardError;
  String? get alertsError => _dashboardError;
  String? get activitiesError => _dashboardError;
  String? get notificationsError => _notificationsError;

  // Get unread notifications count
  int get unreadNotificationsCount {
    if (_notifications == null) return 0;
    return _notifications!['total'] ?? 0;
  }

  // Get critical alerts count
  int get criticalAlertsCount {
    return alerts.where((alert) => alert['priority'] == 'critical').length;
  }

  // Get high priority alerts count
  int get highPriorityAlertsCount {
    return alerts.where((alert) => alert['priority'] == 'high').length;
  }

  /// Load all dashboard data
  Future<void> loadDashboardData() async {
    await Future.wait([
      loadDashboard(),
      loadNotifications(),
    ]);
  }

  /// Load dashboard data (main endpoint)
  Future<void> loadDashboard() async {
    print('📊 DashboardProvider.loadDashboard() called');
    _isLoadingDashboard = true;
    _dashboardError = null;
    notifyListeners();

    try {
      print('📊 Calling _apiService.getDashboardData()...');
      final response = await _apiService.getDashboardData();
      print('📊 Dashboard response received: ${response.keys}');

      // Get medicine stats and expiring list to mirror Expiring screen count precisely
      final medicineStats = await _apiService.getMedicineStats();
      final expiringList = await _apiService.getExpiringMedicines();
      final expiringCount = expiringList.length;
      print('📊 Medicine stats: $medicineStats');
      print('📊 Expiring list count (0..10 days): $expiringCount');

      // Merge dashboard data with medicine stats
      final dashboardData = response['data'] ?? response;
      final existingKPIs = _dashboardData?['kpis'] ?? {};

      dashboardData['kpis'] = {
        ...dashboardData['kpis'] ?? {},
        // Use the exact count from getExpiringMedicines() so Home card matches Expiring screen
        'expiringCount': expiringCount,
        'lowStockCount': medicineStats['lowStockCount'],
        'totalMedicines': medicineStats['totalMedicines'],
        // Preserve calculated sales if they exist
        'totalSales': existingKPIs['totalSales'] ??
            dashboardData['kpis']['totalSales'] ??
            0,
        'totalPurchases': existingKPIs['totalPurchases'] ??
            dashboardData['kpis']['totalPurchases'] ??
            0,
      };

      print('📊 Dashboard data from backend:');
      print('📊 Raw response: $response');
      print('📊 Existing KPIs before merge: $existingKPIs');
      print('📊 KPIs: ${dashboardData['kpis']}');
      print('📊 Total Sales: ${dashboardData['kpis']['totalSales']}');
      print('📊 Total Purchases: ${dashboardData['kpis']['totalPurchases']}');

      _dashboardData = dashboardData;
      _dashboardError = null;
      print('✅ Dashboard data loaded successfully');
    } catch (e) {
      print('❌ Dashboard error: ${e.toString()}');

      // Check if it's a 401 error (token expired)
      if (e.toString().contains('401') ||
          e.toString().contains('Session expired')) {
        print('🔍 Token expired, clearing dashboard data');
        _dashboardError = 'Session expired. Please login again.';
      } else {
        _dashboardError = e.toString();
      }
      _dashboardData = null;
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  /// Update statistics with new data
  void updateStatistics(Map<String, dynamic> newStats) {
    print('📊 DashboardProvider: Updating statistics with: $newStats');
    if (_dashboardData != null) {
      final oldKpis = _dashboardData!['kpis'] ?? {};
      _dashboardData!['kpis'] = {
        ...oldKpis,
        ...newStats,
      };

      print('📊 DashboardProvider: Updated KPIs:');
      print(
          '📊 DashboardProvider: Total Sales: ${_dashboardData!['kpis']['totalSales']}');
      print(
          '📊 DashboardProvider: Total Purchases: ${_dashboardData!['kpis']['totalPurchases']}');

      notifyListeners();
    } else {
      print(
          '⚠️ DashboardProvider: _dashboardData is null, cannot update statistics');
    }
  }

  /// Update sales data from Sales Screen
  void updateSalesData(double totalSales) {
    print('📊 DashboardProvider: updateSalesData called with: $totalSales');
    print(
        '📊 DashboardProvider: _dashboardData is null: ${_dashboardData == null}');

    if (_dashboardData != null) {
      final oldKpis = _dashboardData!['kpis'] ?? {};
      print('📊 DashboardProvider: Old KPIs: $oldKpis');

      _dashboardData!['kpis'] = {
        ...oldKpis,
        'totalSales': totalSales,
      };

      print('📊 DashboardProvider: New KPIs: ${_dashboardData!['kpis']}');
      print(
          '📊 DashboardProvider: Sales data updated - Total Sales: $totalSales');
      print('📊 DashboardProvider: Calling notifyListeners()...');
      notifyListeners();
      print('📊 DashboardProvider: notifyListeners() completed');
    } else {
      print(
          '⚠️ DashboardProvider: _dashboardData is null, cannot update sales data');
      print('⚠️ DashboardProvider: Initializing dashboard data first...');

      // Initialize dashboard data if null
      _dashboardData = {
        'kpis': {
          'totalSales': totalSales,
          'totalPurchases': 0.0,
          'expiringCount': 0,
          'pendingRequestsCount': 0,
        }
      };

      print(
          '📊 DashboardProvider: Dashboard data initialized with sales: $totalSales');
      notifyListeners();
    }
  }

  /// Update purchases data (checkout transactions)
  void updatePurchasesData(double totalPurchases) {
    print(
        '🛒 DashboardProvider: updatePurchasesData called with: $totalPurchases');
    print(
        '🛒 DashboardProvider: _dashboardData is null: ${_dashboardData == null}');

    if (_dashboardData != null) {
      final oldKpis = _dashboardData!['kpis'] ?? {};
      print('🛒 DashboardProvider: Old KPIs: $oldKpis');

      _dashboardData!['kpis'] = {
        ...oldKpis,
        'totalPurchases': totalPurchases,
      };

      print('🛒 DashboardProvider: New KPIs: ${_dashboardData!['kpis']}');
      print(
          '🛒 DashboardProvider: Purchases data updated - Total Purchases: $totalPurchases');
      print('🛒 DashboardProvider: Calling notifyListeners()...');
      notifyListeners();
      print('🛒 DashboardProvider: notifyListeners() completed');
    } else {
      print(
          '⚠️ DashboardProvider: _dashboardData is null, cannot update purchases data');
      print('⚠️ DashboardProvider: Initializing dashboard data first...');

      // Initialize dashboard data if null
      _dashboardData = {
        'kpis': {
          'totalSales': 0.0,
          'totalPurchases': totalPurchases,
          'expiringCount': 0,
          'pendingRequestsCount': 0,
        }
      };

      print(
          '🛒 DashboardProvider: Dashboard data initialized with purchases: $totalPurchases');
      notifyListeners();
    }
  }

  /// Load notifications
  Future<void> loadNotifications() async {
    _isLoadingNotifications = true;
    _notificationsError = null;
    notifyListeners();

    try {
      final response = await _apiService.getNotifications();
      final notificationsData = response['data'] ?? response;
      _notifications = {
        'notifications': notificationsData['notifications'] ?? [],
        'total': notificationsData['total'] ?? 0,
        'unreadCount': notificationsData['unreadCount'] ?? 0,
      };
      _notificationsError = null;
    } catch (e) {
      _notificationsError = e.toString();
      _notifications = null;
    } finally {
      _isLoadingNotifications = false;
      notifyListeners();
    }
  }

  /// Mark alert as read
  void markAlertAsRead(String alertId) {
    // Since alerts are generated from dashboard data, we don't need to mark them as read
    // This is just for UI state management
    notifyListeners();
  }

  /// Mark notification as read
  void markNotificationAsRead(String notificationId) {
    // Notifications are read-only from backend, just update UI state
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadDashboardData();
  }

  /// Clear all data
  void clear() {
    _dashboardData = null;
    _notifications = null;
    _dashboardError = null;
    _notificationsError = null;
    notifyListeners();
  }

  // ===== Market Search =====
  Future<Map<String, dynamic>> searchMarketMedicines({
    String? query,
    String? form,
    String? manufacturer,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _apiService.searchMarketMedicines(
        query: query,
        form: form,
        manufacturer: manufacturer,
        page: page,
        limit: limit,
      );

      final medicinesData = response['data'] ?? response;
      notifyListeners();
      return {
        'medicines': medicinesData['medicines'] ?? [],
        'total': medicinesData['pagination']?['total'] ?? 0,
        'page': medicinesData['pagination']?['page'] ?? page ?? 1,
        'limit': medicinesData['pagination']?['limit'] ?? limit ?? 10,
      };
    } catch (e) {
      throw Exception('Failed to search market medicines: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getMarketMedicineById(String id) async {
    try {
      final response = await _apiService.getMarketMedicineById(id);
      final medicineData = response['data'] ?? response;
      notifyListeners();
      return {'medicine': medicineData['medicine'] ?? {}};
    } catch (e) {
      throw Exception('Failed to get market medicine: ${e.toString()}');
    }
  }

  // ===== Refund System =====
  Future<List<Map<String, dynamic>>> getRefundEligibleTransactions() async {
    try {
      final transactions = await _apiService.getRefundEligibleTransactions();
      notifyListeners();
      return transactions;
    } catch (e) {
      throw Exception(
          'Failed to get refund eligible transactions: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> requestRefund(
      Map<String, dynamic> refundData) async {
    try {
      final response = await _apiService.requestRefund(refundData);
      notifyListeners();
      return response;
    } catch (e) {
      throw Exception('Failed to request refund: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getRefundHistory() async {
    try {
      final history = await _apiService.getRefundHistory();
      notifyListeners();
      return history;
    } catch (e) {
      throw Exception('Failed to get refund history: ${e.toString()}');
    }
  }

  // ===== Business Settings =====
  Future<Map<String, dynamic>> getBusinessSettings() async {
    try {
      final response = await _apiService.getBusinessSettings();
      final settingsData = response['data'] ?? response;
      notifyListeners();
      return {'settings': settingsData['settings'] ?? {}};
    } catch (e) {
      throw Exception('Failed to get business settings: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updateBusinessSettings(
      Map<String, dynamic> settings) async {
    try {
      final response = await _apiService.updateBusinessSettings(settings);
      notifyListeners();
      return response;
    } catch (e) {
      throw Exception('Failed to update business settings: ${e.toString()}');
    }
  }
}
