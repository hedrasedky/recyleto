import '../services/api_service.dart';

class DashboardTest {
  static final ApiService _apiService = ApiService();

  static Future<void> testDashboardEndpoints() async {
    print('🧪 Testing Dashboard APIs...');

    try {
      await _apiService.initialize();

      // Test main dashboard endpoint
      print('📊 Testing /api/dashboard...');
      final dashboard = await _apiService.getDashboardData();
      print('✅ Dashboard data: ${dashboard['success']}');

      // Test notifications endpoint
      print('🔔 Testing /api/dashboard/notifications...');
      final notifications = await _apiService.getNotifications();
      print('✅ Notifications: ${notifications['success']}');

      print('🎉 All dashboard tests passed!');
    } catch (e) {
      print('❌ Dashboard test failed: $e');
    }
  }
}
