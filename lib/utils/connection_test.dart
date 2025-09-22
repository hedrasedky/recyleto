import 'dart:convert';

import 'package:http/http.dart' as http;

class ConnectionTest {
  static const String baseUrl = 'http://38.242.214.193:5000/api';

  static Future<void> testBackendConnection() async {
    try {
      print('Testing connection to backend...');
      print('Backend URL: $baseUrl');

      // Test 1: Test dashboard endpoint (should return 401 without auth)
      final healthResponse = await http.get(
        Uri.parse('$baseUrl/dashboard/statistics'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      print('Dashboard endpoint response: ${healthResponse.statusCode}');
      if (healthResponse.statusCode == 401) {
        print('✅ Server is working - authentication required');
      }

      // Test 2: Test login endpoint with correct credentials
      print('\nTesting login with demo credentials...');
      final loginResponse = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': 'demo@pharmacy.com',
              'password': 'demo123456',
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Login endpoint response: ${loginResponse.statusCode}');
      print('Response body: ${loginResponse.body}');

      if (loginResponse.statusCode == 200 || loginResponse.statusCode == 201) {
        final data = json.decode(loginResponse.body);
        print('✅ Login successful!');
        final token = data['token'];
        print('Token received: ${token != null}');
        if (token != null) {
          print('Token length: ${token.length} characters');

          // Test 3: Test authenticated endpoint with token
          print('\nTesting authenticated endpoint...');
          final authResponse = await http.get(
            Uri.parse('$baseUrl/dashboard/statistics'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));

          print('Authenticated endpoint response: ${authResponse.statusCode}');
          if (authResponse.statusCode == 200) {
            print('✅ Authentication working - dashboard data accessible');
          }
        }
      } else {
        print('❌ Login failed: ${loginResponse.statusCode}');
        print('Error: ${loginResponse.body}');

        // Try alternative credentials if available
        print('\nTrying alternative credentials...');
        final altLoginResponse = await http
            .post(
              Uri.parse('$baseUrl/auth/login'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'email': 'admin@recyleto.com',
                'password': 'demo123',
              }),
            )
            .timeout(const Duration(seconds: 10));

        print('Alternative login response: ${altLoginResponse.statusCode}');
        print('Alternative response body: ${altLoginResponse.body}');
      }
    } catch (e) {
      print('Connection test failed: $e');

      if (e.toString().contains('Connection refused')) {
        print('Backend appears to be down or not accessible');
        print('Check if server is running on: $baseUrl');
      } else if (e.toString().contains('TimeoutException')) {
        print('Request timed out - check network connectivity');
      } else if (e.toString().contains('CORS')) {
        print('CORS issue detected');
      } else if (e.toString().contains('Failed to fetch')) {
        print('Network error - check internet connection');
        print('Verify server URL: $baseUrl');
      }
    }
  }
}
