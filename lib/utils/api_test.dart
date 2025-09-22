import '../services/api_service.dart';

class ApiTest {
  static final ApiService _apiService = ApiService();

  static Future<void> testConnection() async {
    try {
      print('🔌 Testing connection to backend...');
      
      // Initialize API service
      await _apiService.initialize();
      print('✅ API Service initialized');
      
      // Test login with demo credentials
      print('🔐 Testing login with demo credentials...');
      final loginResponse = await _apiService.login('admin@recyleto.com', 'demo123');
      print('✅ Login successful: ${loginResponse['access_token'] != null}');
      
      // Test getting user profile
      print('👤 Testing user profile retrieval...');
      final profile = await _apiService.getUserProfile();
      print('✅ Profile loaded: ${profile['email']}');
      
      // Test getting medicines
      print('💊 Testing medicines retrieval...');
      final medicines = await _apiService.getMedicines();
      print('✅ Medicines loaded: ${medicines.length} medicines found');
      
      // Test logout
      print('🚪 Testing logout...');
      await _apiService.logout();
      print('✅ Logout successful');
      
      print('\n🎉 All API tests passed! Flutter is connected to backend.');
      
    } catch (e) {
      print('❌ API Test failed: $e');
      print('\n🔧 Troubleshooting:');
      print('1. Ensure backend is running on http://localhost:3000');
      print('2. Check if demo user exists: admin@recyleto.com');
      print('3. Verify CORS is enabled on backend');
    }
  }
}
