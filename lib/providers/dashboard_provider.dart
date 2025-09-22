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
  Map<String, dynamic>? get statistics => _dashboardData?['kpis'];
  List<Map<String, dynamic>> get alerts {
    final lowStock = _dashboardData?['lowStockItems'] ?? [];
    final expiring = _dashboardData?['expiringMedications'] ?? [];

    List<Map<String, dynamic>> alerts = [];

    // Add low stock alerts
    for (var item in lowStock) {
      alerts.add({
        'id': item['_id'] ?? item['id'],
        'title': 'Low Stock Alert',
        'message':
            '${item['productId']?['name'] ?? 'Medicine'} is low on stock',
        'type': 'low_stock',
        'priority': 'high',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    // Add expiring alerts
    for (var item in expiring) {
      alerts.add({
        'id': item['_id'] ?? item['id'],
        'title': 'Expiry Alert',
        'message':
            '${item['productId']?['name'] ?? 'Medicine'} is expiring soon',
        'type': 'expiry',
        'priority': 'critical',
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
    _isLoadingDashboard = true;
    _dashboardError = null;
    notifyListeners();

    try {
      final response = await _apiService.getDashboardData();
      _dashboardData = response['data'] ?? response;
      _dashboardError = null;
    } catch (e) {
      _dashboardError = e.toString();
      _dashboardData = null;
    } finally {
      _isLoadingDashboard = false;
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
