import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.246.251:5000/api';
  static const String _tokenKey = 'auth_token';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  // Initialize service and load stored token
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
  }

  // Get headers with authentication
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Save auth token
  Future<void> _saveToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear auth token
  Future<void> _clearToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    final data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        message: data['message'] ?? 'An error occurred',
        statusCode: response.statusCode,
      );
    }
  }

  // Authentication APIs
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = _handleResponse(response);

    // Backend returns token in data.token according to API documentation
    final token = data['data']?['token'] ?? data['token'];
    if (token != null) {
      await _saveToken(token);
    }

    return data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: json.encode(userData),
    );

    return _handleResponse(response);
  }

  // Password reset flow
  Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: _headers,
      body: json.encode({'email': email}),
    );
    _handleResponse(response);
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: _headers,
      body: json.encode({'email': email, 'code': code}),
    );
    return _handleResponse(response);
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    String? otp,
    String? token,
  }) async {
    final body = {
      'email': email,
      'newPassword': newPassword, // تغيير من 'password' إلى 'newPassword'
    };
    if (otp != null) body['code'] = otp; // تغيير من 'otp' إلى 'code'
    if (token != null) body['token'] = token;

    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: _headers,
      body: json.encode(body),
    );
    _handleResponse(response);
  }

  Future<Map<String, dynamic>> registerPharmacy(
      Map<String, dynamic> pharmacyData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register-pharmacy'),
      headers: _headers,
      body: json.encode(pharmacyData),
    );

    return _handleResponse(response);
  }

  Future<void> logout() async {
    await _clearToken();
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> profileData) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/profile/'),
    );

    // Add headers (remove Content-Type to let multipart set it)
    request.headers.addAll(Map.from(_headers)..remove('Content-Type'));

    // Add form fields
    if (profileData['pharmacyName'] != null) {
      request.fields['pharmacyName'] = profileData['pharmacyName'];
    }
    if (profileData['businessEmail'] != null) {
      request.fields['businessEmail'] = profileData['businessEmail'];
    }
    if (profileData['businessPhone'] != null) {
      request.fields['businessPhone'] = profileData['businessPhone'];
    }
    if (profileData['mobileNumber'] != null) {
      request.fields['mobileNumber'] = profileData['mobileNumber'];
    }

    // Add address fields
    if (profileData['businessAddress'] != null) {
      final address = profileData['businessAddress'];
      if (address['street'] != null)
        request.fields['businessAddress[street]'] = address['street'];
      if (address['city'] != null)
        request.fields['businessAddress[city]'] = address['city'];
      if (address['state'] != null)
        request.fields['businessAddress[state]'] = address['state'];
      if (address['zipCode'] != null)
        request.fields['businessAddress[zipCode]'] = address['zipCode'];
      if (address['country'] != null)
        request.fields['businessAddress[country]'] = address['country'];
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> uploadProfileImage(String imagePath) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/profile/'),
    );

    // Add headers (remove Content-Type to let multipart set it)
    request.headers.addAll(Map.from(_headers)..remove('Content-Type'));

    // Add image file with correct field name
    request.files
        .add(await http.MultipartFile.fromPath('licenseImage', imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/change-password'),
      headers: _headers,
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    return _handleResponse(response);
  }

  // Medicine APIs
  Future<List<Map<String, dynamic>>> getMedicines({
    String? search,
    String? category,
    int? page,
    int? limit,
  }) async {
    var url = '$baseUrl/medicines/search';
    final queryParams = <String, String>{};

    if (search != null) queryParams['q'] = search;
    if (category != null) queryParams['category'] = category;
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    if (queryParams.isNotEmpty) {
      url +=
          '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );

    final data = _handleResponse(response);

    // Backend returns medicines in data.medicines
    try {
      if (data is Map && data.containsKey('data')) {
        final medicinesData = data['data'];
        if (medicinesData is Map && medicinesData.containsKey('medicines')) {
          final medicinesList = medicinesData['medicines'];
          if (medicinesList is List) {
            final List<Map<String, dynamic>> result = [];
            for (final item in medicinesList) {
              if (item is Map) {
                // Convert quantity to stock for compatibility
                final medicine = Map<String, dynamic>.from(item);
                if (medicine.containsKey('quantity') &&
                    !medicine.containsKey('stock')) {
                  medicine['stock'] = medicine['quantity'];
                }
                result.add(medicine);
              }
            }
            return result;
          }
        }
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      print('Error parsing medicines: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<Map<String, dynamic>> getMedicine(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/medicines/$id'),
      headers: _headers,
    );

    final data = _handleResponse(response);

    // Convert quantity to stock for compatibility
    if (data is Map && data.containsKey('data')) {
      final medicineData = data['data'];
      if (medicineData is Map && medicineData.containsKey('medicine')) {
        final medicine = Map<String, dynamic>.from(medicineData['medicine']);
        if (medicine.containsKey('quantity') &&
            !medicine.containsKey('stock')) {
          medicine['stock'] = medicine['quantity'];
        }
        data['data']['medicine'] = medicine;
      }
    }

    return data;
  }

  Future<Map<String, dynamic>> addMedicine(
      Map<String, dynamic> medicineData) async {
    // Convert stock to quantity for backend compatibility
    final backendData = Map<String, dynamic>.from(medicineData);
    if (backendData.containsKey('stock') &&
        !backendData.containsKey('quantity')) {
      backendData['quantity'] = backendData['stock'];
      backendData.remove('stock');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/medicines/'),
      headers: _headers,
      body: json.encode(backendData),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateMedicine(
      String id, Map<String, dynamic> medicineData) async {
    // Convert stock to quantity for backend compatibility
    final backendData = Map<String, dynamic>.from(medicineData);
    if (backendData.containsKey('stock') &&
        !backendData.containsKey('quantity')) {
      backendData['quantity'] = backendData['stock'];
      backendData.remove('stock');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/medicines/$id'),
      headers: _headers,
      body: json.encode(backendData),
    );

    return _handleResponse(response);
  }

  Future<void> deleteMedicine(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/medicines/$id'),
      headers: _headers,
    );

    _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateMedicineStock(
      String id, int quantity) async {
    // Use updateMedicine instead since stock endpoint doesn't exist
    final response = await updateMedicine(id, {'stock': quantity});
    return response;
  }

  Future<List<Map<String, dynamic>>> getLowStockMedicines() async {
    // Use getMedicines with filter instead since low-stock endpoint doesn't exist
    final medicines = await getMedicines();
    return medicines.where((m) => (m['stock'] ?? 0) < 10).toList();
  }

  Future<List<Map<String, dynamic>>> getExpiringMedicines() async {
    // Use getMedicines with filter instead since expiring endpoint doesn't exist
    final medicines = await getMedicines();
    return medicines.where((m) {
      if (m['expiryDate'] == null) return false;
      final expiry = DateTime.parse(m['expiryDate']);
      final now = DateTime.now();
      return expiry.difference(now).inDays <= 30;
    }).toList();
  }

  Future<Map<String, dynamic>> getMedicineStats() async {
    // Use getMedicines with filters instead since stats endpoint doesn't exist
    final medicines = await getMedicines();
    return {
      'totalMedicines': medicines.length,
      'lowStockCount': medicines.where((m) => (m['stock'] ?? 0) < 10).length,
      'expiringCount': medicines.where((m) {
        if (m['expiryDate'] == null) return false;
        final expiry = DateTime.parse(m['expiryDate']);
        final now = DateTime.now();
        return expiry.difference(now).inDays <= 30;
      }).length,
    };
  }

  // Transaction APIs (if available)
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data['data'] ?? data);
  }

  Future<Map<String, dynamic>> createTransaction(
      Map<String, dynamic> transactionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: _headers,
      body: json.encode(transactionData),
    );

    return _handleResponse(response);
  }

  // Cart and Checkout APIs (using transactions endpoints)
  Future<Map<String, dynamic>> addToCart(Map<String, dynamic> cartItem) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/item'),
      headers: _headers,
      body: json.encode(cartItem),
    );

    return _handleResponse(response);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/items'),
      headers: _headers,
    );

    final data = _handleResponse(response);

    // Backend returns cart data in data.items
    if (data is Map && data.containsKey('data')) {
      final cartData = data['data'];
      if (cartData is Map && cartData.containsKey('items')) {
        final items = cartData['items'];
        if (items is List) {
          return List<Map<String, dynamic>>.from(items);
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> updateCartItem(
      String itemId, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/item/$itemId'),
      headers: _headers,
      body: json.encode(updates),
    );

    return _handleResponse(response);
  }

  Future<void> removeFromCart(String itemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/item/$itemId'),
      headers: _headers,
    );

    _handleResponse(response);
  }

  Future<void> clearCart() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/items'),
      headers: _headers,
    );

    _handleResponse(response);
  }

  Future<Map<String, dynamic>> processCheckout(
      Map<String, dynamic> checkoutData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/checkout'),
      headers: _headers,
      body: json.encode(checkoutData),
    );

    return _handleResponse(response);
  }

  // Medicine Request APIs
  Future<Map<String, dynamic>> uploadMedicineImage(String imagePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/requests/medicine'),
    );

    request.headers.addAll(_headers);
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createMedicineRequest(
      Map<String, dynamic> requestData) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/requests/medicine'),
    );

    // Add headers (remove Content-Type to let multipart set it)
    request.headers.addAll(Map.from(_headers)..remove('Content-Type'));

    // Add form fields
    request.fields['medicineName'] = requestData['medicineName'] ?? '';
    request.fields['genericName'] = requestData['genericName'] ?? '';
    request.fields['form'] = requestData['form'] ?? '';
    request.fields['packSize'] = requestData['packSize'] ?? '';
    request.fields['additionalNotes'] = requestData['notes'] ?? '';
    request.fields['urgencyLevel'] = requestData['urgency'] ?? 'medium';

    // Add image if provided
    if (requestData['imageUrl'] != null && requestData['imageUrl'].isNotEmpty) {
      // If imageUrl is a file path, upload it
      if (requestData['imageUrl'].toString().startsWith('/')) {
        request.files.add(await http.MultipartFile.fromPath(
            'image', requestData['imageUrl']));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  Future<List<Map<String, dynamic>>> getMedicineRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/requests/medicine/user'),
      headers: _headers,
    );

    final data = _handleResponse(response);

    // Backend returns requests in data.requests
    if (data is Map && data.containsKey('data')) {
      final requestsData = data['data'];
      if (requestsData is Map && requestsData.containsKey('requests')) {
        final requests = requestsData['requests'];
        if (requests is List) {
          return List<Map<String, dynamic>>.from(requests);
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  // Support Chat APIs
  Future<Map<String, dynamic>> sendSupportMessage(
      String ticketId, Map<String, dynamic> messageData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/support/tickets/$ticketId/messages'),
      headers: _headers,
      body: json.encode(messageData),
    );

    return _handleResponse(response);
  }

  Future<List<Map<String, dynamic>>> getSupportMessages(String ticketId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/support/tickets/$ticketId'),
      headers: _headers,
    );

    final data = _handleResponse(response);

    // Backend returns messages in data.ticket.messages
    if (data is Map && data.containsKey('data')) {
      final ticketData = data['data'];
      if (ticketData is Map && ticketData.containsKey('ticket')) {
        final ticket = ticketData['ticket'];
        if (ticket is Map && ticket.containsKey('messages')) {
          final messages = ticket['messages'];
          if (messages is List) {
            return List<Map<String, dynamic>>.from(messages);
          }
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> createSupportTicket(
      Map<String, dynamic> ticketData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/support/tickets'),
      headers: _headers,
      body: json.encode(ticketData),
    );

    return _handleResponse(response);
  }

  Future<List<Map<String, dynamic>>> getSupportTickets() async {
    final response = await http.get(
      Uri.parse('$baseUrl/support/tickets'),
      headers: _headers,
    );

    final data = _handleResponse(response);

    // Backend returns tickets in data.tickets
    if (data is Map && data.containsKey('data')) {
      final ticketsData = data['data'];
      if (ticketsData is Map && ticketsData.containsKey('tickets')) {
        final tickets = ticketsData['tickets'];
        if (tickets is List) {
          return List<Map<String, dynamic>>.from(tickets);
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  // ===== Dashboard Endpoints =====

  /// Get dashboard data (main endpoint)
  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// Get user notifications with unread count
  Future<Map<String, dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/notifications'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ===== Reports APIs =====

  /// Get sales reports with filters
  Future<Map<String, dynamic>> getSalesReport({
    String? startDate,
    String? endDate,
    String? category,
    String? paymentMethod,
  }) async {
    // Use dashboard data instead since reports endpoint doesn't exist
    final response = await getDashboardData();
    return response;
  }

  /// Get inventory reports
  Future<Map<String, dynamic>> getInventoryReport({
    String? category,
    String? stockStatus,
    String? expiryStatus,
  }) async {
    // Use dashboard data instead since reports endpoint doesn't exist
    final response = await getDashboardData();
    return response;
  }

  /// Get performance reports
  Future<Map<String, dynamic>> getPerformanceReport({
    String? startDate,
    String? endDate,
    String? metric,
  }) async {
    // Use dashboard data instead since reports endpoint doesn't exist
    final response = await getDashboardData();
    return response;
  }

  // ===== User Management APIs =====

  /// Get all users (for managers) - Mock implementation since backend doesn't have this endpoint
  Future<List<Map<String, dynamic>>> getUsers() async {
    // This endpoint doesn't exist in backend, return empty list
    return <Map<String, dynamic>>[];
  }

  /// Create new user - Mock implementation since backend doesn't have this endpoint
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    return {
      'success': false,
      'message': 'User management not implemented in backend'
    };
  }

  /// Update user - Mock implementation since backend doesn't have this endpoint
  Future<Map<String, dynamic>> updateUser(
      String userId, Map<String, dynamic> userData) async {
    return {
      'success': false,
      'message': 'User management not implemented in backend'
    };
  }

  /// Delete user - Mock implementation since backend doesn't have this endpoint
  Future<void> deleteUser(String userId) async {
    // This endpoint doesn't exist in backend
  }

  /// Update user role - Mock implementation since backend doesn't have this endpoint
  Future<Map<String, dynamic>> updateUserRole(
      String userId, String role) async {
    return {
      'success': false,
      'message': 'User management not implemented in backend'
    };
  }

  // ===== Delivery & Tracking APIs =====

  /// Create delivery order - Mock implementation since backend doesn't have this endpoint
  Future<Map<String, dynamic>> createDelivery(
      Map<String, dynamic> deliveryData) async {
    return {
      'success': false,
      'message': 'Delivery management not implemented in backend'
    };
  }

  /// Get delivery status - Mock implementation since backend doesn't have this endpoint
  Future<Map<String, dynamic>> getDeliveryStatus(String deliveryId) async {
    return {
      'success': false,
      'message': 'Delivery management not implemented in backend'
    };
  }

  /// Update delivery status - Mock implementation since backend doesn't have this endpoint
  Future<Map<String, dynamic>> updateDeliveryStatus(
      String deliveryId, String status) async {
    return {
      'success': false,
      'message': 'Delivery management not implemented in backend'
    };
  }

  /// Get all deliveries - Mock implementation since backend doesn't have this endpoint
  Future<List<Map<String, dynamic>>> getDeliveries({
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    return <Map<String, dynamic>>[];
  }

  // ===== Payment Gateway APIs =====

  /// Process payment with payment gateway - Mock implementation since backend doesn't have this endpoint
  Future<Map<String, dynamic>> processPayment(
      Map<String, dynamic> paymentData) async {
    return {
      'success': false,
      'message': 'Payment gateway not implemented in backend'
    };
  }

  /// Get payment methods - Real API implementation
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment/methods'),
        headers: _headers,
      );

      final data = _handleResponse(response);

      if (data is Map && data.containsKey('data')) {
        final methods = data['data'];
        if (methods is List) {
          return List<Map<String, dynamic>>.from(methods);
        }
      }

      return <Map<String, dynamic>>[];
    } catch (e) {
      // Return empty list if API fails
      return <Map<String, dynamic>>[];
    }
  }

  /// Get payment history - Mock implementation since backend doesn't have this endpoint
  Future<List<Map<String, dynamic>>> getPaymentHistory({
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    return <Map<String, dynamic>>[];
  }

  /// Add payment method - Real API implementation
  Future<Map<String, dynamic>> addPaymentMethod(
      Map<String, dynamic> paymentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payment/methods'),
      headers: _headers,
      body: json.encode(paymentData),
    );

    final data = _handleResponse(response);

    if (data is Map && data.containsKey('data')) {
      return Map<String, dynamic>.from(data['data']);
    }

    // Return the payment data with generated ID if API doesn't return proper response
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      ...paymentData,
    };
  }

  /// Set default payment method - Real API implementation
  Future<void> setDefaultPaymentMethod(String methodId) async {
    await http.put(
      Uri.parse('$baseUrl/payment/methods/$methodId/default'),
      headers: _headers,
    );
  }

  /// Delete payment method - Real API implementation
  Future<void> deletePaymentMethod(String methodId) async {
    await http.delete(
      Uri.parse('$baseUrl/payment/methods/$methodId'),
      headers: _headers,
    );
  }

  // User Settings APIs
  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/settings/user'),
        headers: _headers,
      );

      final data = _handleResponse(response);

      if (data is Map && data.containsKey('data')) {
        return Map<String, dynamic>.from(data['data']);
      }

      // Return default settings if API doesn't return proper response
      return {
        'notificationsEnabled': true,
        'emailNotifications': true,
        'pushNotifications': true,
        'orderUpdates': true,
        'promotionalOffers': false,
        'currency': 'USD',
      };
    } catch (e) {
      // Return default settings if API fails
      return {
        'notificationsEnabled': true,
        'emailNotifications': true,
        'pushNotifications': true,
        'orderUpdates': true,
        'promotionalOffers': false,
        'currency': 'USD',
      };
    }
  }

  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    final response = await http.put(
      Uri.parse('$baseUrl/settings/user'),
      headers: _headers,
      body: json.encode(settings),
    );

    _handleResponse(response);
  }

  /// Refund payment - Mock implementation since backend doesn't have this endpoint
  Future<Map<String, dynamic>> refundPayment(
      String paymentId, Map<String, dynamic> refundData) async {
    return {
      'success': false,
      'message': 'Payment gateway not implemented in backend'
    };
  }

  // ===== Advanced Features =====

  /// Get system analytics - Use existing analytics endpoint
  Future<Map<String, dynamic>> getAnalytics({
    String? period,
    String? metric,
  }) async {
    final queryParams = <String, String>{};
    if (period != null) queryParams['period'] = period;
    if (metric != null) queryParams['metric'] = metric;

    final uri =
        Uri.parse('$baseUrl/analytics').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  /// Export data (CSV/PDF) - Mock implementation since backend doesn't have this endpoint
  Future<Map<String, dynamic>> exportData(
      String type, Map<String, dynamic> exportParams) async {
    return {
      'success': false,
      'message': 'Data export not implemented in backend'
    };
  }

  /// Get system settings - Mock implementation since backend doesn't have this endpoint
  Future<Map<String, dynamic>> getSystemSettings() async {
    return {
      'success': false,
      'message': 'System settings not implemented in backend'
    };
  }

  /// Update system settings - Mock implementation since backend doesn't have this endpoint
  Future<Map<String, dynamic>> updateSystemSettings(
      Map<String, dynamic> settings) async {
    return {
      'success': false,
      'message': 'System settings not implemented in backend'
    };
  }

  // Utility methods
  bool get isAuthenticated => _authToken != null;

  String? get authToken => _authToken;

  // 2FA Authentication APIs
  Future<Map<String, dynamic>> enable2FA() async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/2fa/enable'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> verify2FA(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/2fa/verify'),
      headers: _headers,
      body: json.encode({'twoFactorToken': token}),
    );
    return _handleResponse(response);
  }

  Future<void> disable2FA() async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/2fa/disable'),
      headers: _headers,
    );
    _handleResponse(response);
  }

  // Market Search APIs
  Future<Map<String, dynamic>> searchMarketMedicines({
    String? query,
    String? form,
    String? manufacturer,
    int? page,
    int? limit,
  }) async {
    var url = '$baseUrl/market/search';
    final queryParams = <String, String>{};

    if (query != null) queryParams['q'] = query;
    if (form != null) queryParams['form'] = form;
    if (manufacturer != null) queryParams['manufacturer'] = manufacturer;
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    if (queryParams.isNotEmpty) {
      url +=
          '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );
    final data = _handleResponse(response);

    // Convert quantity to stock for compatibility
    if (data is Map && data.containsKey('data')) {
      final marketData = data['data'];
      if (marketData is Map && marketData.containsKey('medicines')) {
        final medicines = marketData['medicines'];
        if (medicines is List) {
          for (final medicine in medicines) {
            if (medicine is Map &&
                medicine.containsKey('quantity') &&
                !medicine.containsKey('stock')) {
              medicine['stock'] = medicine['quantity'];
            }
          }
        }
      }
    }

    return data;
  }

  Future<Map<String, dynamic>> getMarketMedicineById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/market/$id'),
      headers: _headers,
    );
    final data = _handleResponse(response);

    // Convert quantity to stock for compatibility
    if (data is Map && data.containsKey('data')) {
      final marketData = data['data'];
      if (marketData is Map && marketData.containsKey('medicine')) {
        final medicine = marketData['medicine'];
        if (medicine is Map &&
            medicine.containsKey('quantity') &&
            !medicine.containsKey('stock')) {
          medicine['stock'] = medicine['quantity'];
        }
      }
    }

    return data;
  }

  // Refund APIs
  Future<List<Map<String, dynamic>>> getRefundEligibleTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/refunds/eligible-transactions'),
      headers: _headers,
    );
    final data = _handleResponse(response);

    // Backend returns eligible transactions in data.eligibleTransactions
    if (data is Map && data.containsKey('data')) {
      final refundData = data['data'];
      if (refundData is Map && refundData.containsKey('eligibleTransactions')) {
        final transactions = refundData['eligibleTransactions'];
        if (transactions is List) {
          return List<Map<String, dynamic>>.from(transactions);
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> requestRefund(
      Map<String, dynamic> refundData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/refunds/request'),
      headers: _headers,
      body: json.encode(refundData),
    );
    return _handleResponse(response);
  }

  Future<List<Map<String, dynamic>>> getRefundHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/refunds/history'),
      headers: _headers,
    );
    final data = _handleResponse(response);

    // Backend returns refunds in data.refunds
    if (data is Map && data.containsKey('data')) {
      final refundData = data['data'];
      if (refundData is Map && refundData.containsKey('refunds')) {
        final refunds = refundData['refunds'];
        if (refunds is List) {
          return List<Map<String, dynamic>>.from(refunds);
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  // Business Settings APIs
  Future<Map<String, dynamic>> getBusinessSettings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/settings/business'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateBusinessSettings(
      Map<String, dynamic> settings) async {
    final response = await http.put(
      Uri.parse('$baseUrl/settings/business'),
      headers: _headers,
      body: json.encode(settings),
    );
    return _handleResponse(response);
  }

  // Delivery Address APIs
  Future<List<Map<String, dynamic>>> getDeliveryAddresses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delivery/addresses'),
        headers: _headers,
      );

      final data = _handleResponse(response);

      if (data is Map && data.containsKey('data')) {
        final addresses = data['data'];
        if (addresses is List) {
          return List<Map<String, dynamic>>.from(addresses);
        }
      }

      return <Map<String, dynamic>>[];
    } catch (e) {
      // Return empty list if API fails
      return <Map<String, dynamic>>[];
    }
  }

  Future<Map<String, dynamic>> addDeliveryAddress(
      Map<String, dynamic> addressData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delivery/addresses'),
      headers: _headers,
      body: json.encode(addressData),
    );

    final data = _handleResponse(response);

    if (data is Map && data.containsKey('data')) {
      return Map<String, dynamic>.from(data['data']);
    }

    // Return the address data with generated ID if API doesn't return proper response
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      ...addressData,
    };
  }

  Future<void> setDefaultDeliveryAddress(String addressId) async {
    await http.put(
      Uri.parse('$baseUrl/delivery/addresses/$addressId/default'),
      headers: _headers,
    );
  }

  Future<void> deleteDeliveryAddress(String addressId) async {
    await http.delete(
      Uri.parse('$baseUrl/delivery/addresses/$addressId'),
      headers: _headers,
    );
  }

  // ===== Missing APIs - Updated existing implementations =====

  // Note: The following APIs already exist in the file but are updated to handle missing backend endpoints
  // They now return appropriate mock responses when backend endpoints are not available
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
