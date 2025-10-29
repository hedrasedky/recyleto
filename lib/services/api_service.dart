import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://38.242.214.193:5000/api';
  static const String _tokenKey = 'auth_token';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  DateTime? _tokenExpiryTime;

  // Initialize service and load stored token
  Future<void> initialize() async {
    print('🚀 ApiService.initialize() called');
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);

    // Load token expiry time
    final expiryString = prefs.getString('${_tokenKey}_expiry');
    if (expiryString != null) {
      _tokenExpiryTime = DateTime.parse(expiryString);
    }

    // Debug: Check if token is loaded
    if (_authToken != null) {
      print('✅ Token loaded: ${_authToken!.substring(0, 20)}...');
      print('✅ Token length: ${_authToken!.length}');
      print('✅ Token expiry: $_tokenExpiryTime');

      // Check if token is expired
      if (_isTokenExpired()) {
        print('⚠️ Token is expired, attempting to refresh...');
        await _refreshToken();
      }
    } else {
      print('❌ No token found in storage');
      print('❌ Available keys: ${prefs.getKeys()}');
      print('❌ Looking for key: $_tokenKey');
    }
  }

  // Check if token is expired
  bool _isTokenExpired() {
    if (_tokenExpiryTime == null) return true;
    return DateTime.now().isAfter(_tokenExpiryTime!);
  }

  // Refresh token automatically
  Future<void> _refreshToken() async {
    try {
      print('🔄 Attempting to refresh token...');

      // Try to refresh token using stored credentials
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      final password = prefs.getString('user_password');

      if (email != null && password != null) {
        final loginData = {
          'email': email,
          'password': password,
        };

        final response = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(loginData),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            _authToken = data['data']['token'];
            _tokenExpiryTime = DateTime.now()
                .add(const Duration(hours: 24)); // 24 hours expiry

            // Save new token and expiry
            await prefs.setString(_tokenKey, _authToken!);
            await prefs.setString(
                '${_tokenKey}_expiry', _tokenExpiryTime!.toIso8601String());

            print('✅ Token refreshed successfully');
          }
        }
      }
    } catch (e) {
      print('❌ Failed to refresh token: $e');
      // Clear invalid token
      await _clearAuthData();
    }
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove('${_tokenKey}_expiry');
    await prefs.remove('user_email');
    await prefs.remove('user_password');
    _authToken = null;
    _tokenExpiryTime = null;
    print('🗑️ Authentication data cleared');
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
    print('💾 _saveToken called');
    print('💾 Token to save: ${token.substring(0, 20)}...');
    print('💾 Token length: ${token.length}');

    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    print('💾 Token saved to SharedPreferences');
    print('💾 _authToken set to: ${_authToken?.substring(0, 20)}...');
  }

  // Public method to save token
  Future<void> saveToken(String token) async {
    print(
        '🔍 ApiService.saveToken called with token: ${token.substring(0, 20)}...');
    await _saveToken(token);
    print('✅ ApiService.saveToken completed successfully');
  }

  // Clear auth token
  Future<void> _clearToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Authentication APIs
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Clear any existing token before login
    await _clearToken();

    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = _handleResponse(response);

    // Debug: Print the response structure
    print('Login response: $data');

    // Backend returns token in data.token according to API documentation
    final token = data['data']?['token'] ?? data['token'];
    print(
        'Extracted token: ${token != null ? '${token.toString().substring(0, 20)}...' : 'null'}');

    if (token != null) {
      await _saveToken(token);

      // Save user credentials for token refresh
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);

      // Set token expiry time (24 hours)
      _tokenExpiryTime = DateTime.now().add(const Duration(hours: 24));
      await prefs.setString(
          '${_tokenKey}_expiry', _tokenExpiryTime!.toIso8601String());

      print('✅ Login successful, token and credentials saved');
    } else {
      print('No token found in response');
    }

    return data;
  }

  // Logout and clear all auth data
  Future<void> logout() async {
    await _clearAuthData();
    print('✅ Logout successful, all auth data cleared');
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
    print(
        '🔍 ApiService.verifyOtp called with email: "$email" and code: "$code"');
    print('🔍 ApiService.verifyOtp URL: $baseUrl/auth/verify-otp');
    print('🔍 ApiService.verifyOtp Headers: $_headers');
    print('🔍 ApiService.verifyOtp Body: ${json.encode({
          'email': email,
          'code': code
        })}');

    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: _headers,
      body: json.encode({'email': email, 'code': code}),
    );

    print('🔍 ApiService.verifyOtp Response Status: ${response.statusCode}');
    print('🔍 ApiService.verifyOtp Response Body: ${response.body}');

    return _handleResponse(response);
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    String? otp,
    String? token,
  }) async {
    print('🔐 ApiService.resetPassword called with:');
    print('🔐 Email: $email');
    print('🔐 New Password: ${newPassword.substring(0, 3)}***');
    print('🔐 OTP: $otp');
    print('🔐 Token: $token');

    final body = {
      'email': email,
      'newPassword': newPassword, // تغيير من 'password' إلى 'newPassword'
    };
    if (otp != null) body['code'] = otp; // تغيير من 'otp' إلى 'code'
    if (token != null) body['token'] = token;

    print('🔐 ApiService.resetPassword URL: $baseUrl/auth/reset-password');
    print('🔐 ApiService.resetPassword Headers: $_headers');
    print('🔐 ApiService.resetPassword Body: ${json.encode(body)}');

    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: _headers,
      body: json.encode(body),
    );

    print(
        '🔐 ApiService.resetPassword Response Status: ${response.statusCode}');
    print('🔐 ApiService.resetPassword Response Body: ${response.body}');

    _handleResponse(response);
  }

  Future<Map<String, dynamic>> registerPharmacy(
      Map<String, dynamic> pharmacyData) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auth/register-pharmacy'),
    );

    // Add headers (remove Content-Type to let multipart set it)
    request.headers.addAll(Map.from(_headers)..remove('Content-Type'));

    // Add form fields
    if (pharmacyData['pharmacyName'] != null) {
      request.fields['pharmacyName'] = pharmacyData['pharmacyName'];
    }
    if (pharmacyData['businessEmail'] != null) {
      request.fields['businessEmail'] = pharmacyData['businessEmail'];
    }
    if (pharmacyData['businessPhone'] != null) {
      request.fields['businessPhone'] = pharmacyData['businessPhone'];
    }
    if (pharmacyData['mobileNumber'] != null) {
      request.fields['mobileNumber'] = pharmacyData['mobileNumber'];
    }
    if (pharmacyData['password'] != null) {
      request.fields['password'] = pharmacyData['password'];
    }
    if (pharmacyData['confirmPassword'] != null) {
      request.fields['confirmPassword'] = pharmacyData['confirmPassword'];
    }

    // Add address fields
    if (pharmacyData['businessAddress'] != null) {
      final address = pharmacyData['businessAddress'];
      if (address['street'] != null)
        request.fields['businessAddress[street]'] = address['street'];
      if (address['city'] != null)
        request.fields['businessAddress[city]'] = address['city'];
      if (address['state'] != null)
        request.fields['businessAddress[state]'] = address['state'];
      if (address['zipCode'] != null)
        request.fields['businessAddress[zipCode]'] = address['zipCode'];
    }

    // Add license image file
    if (pharmacyData['licenseImage'] != null) {
      final licenseImage = pharmacyData['licenseImage'];

      if (kIsWeb) {
        // Web platform - use bytes
        if (licenseImage is XFile) {
          final bytes = await licenseImage.readAsBytes();
          final fileName =
              licenseImage.name.isNotEmpty ? licenseImage.name : 'license.jpg';
          request.files.add(http.MultipartFile.fromBytes(
            'licenseImage',
            bytes,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ));
        }
      } else {
        // Mobile platform - use path
        if (licenseImage is XFile) {
          request.files.add(await http.MultipartFile.fromPath(
            'licenseImage',
            licenseImage.path,
            filename: licenseImage.name.isNotEmpty
                ? licenseImage.name
                : 'license.jpg',
            contentType: MediaType('image', 'jpeg'),
          ));
        } else if (licenseImage is File) {
          request.files.add(await http.MultipartFile.fromPath(
            'licenseImage',
            licenseImage.path,
            filename: 'license.jpg',
            contentType: MediaType('image', 'jpeg'),
          ));
        }
      }
    }

    print('🔍 ApiService: Sending pharmacy registration request');
    print('🔍 ApiService: Request fields: ${request.fields}');
    print('🔍 ApiService: Request files count: ${request.files.length}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print(
        '🔍 ApiService: Registration response status: ${response.statusCode}');
    print('🔍 ApiService: Registration response body: ${response.body}');

    return _handleResponse(response);
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
    if (kIsWeb) {
      // Web platform - convert path to bytes
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'licenseImage',
        bytes,
        filename: 'profile.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    } else {
      // Mobile platform - use path directly
      request.files.add(await http.MultipartFile.fromPath(
        'licenseImage',
        imagePath,
        filename: 'profile.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    }

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

    // Always add default parameters to get all medicines
    queryParams['limit'] =
        (limit ?? 100).toString(); // Get more medicines by default
    if (search != null) queryParams['q'] = search;
    if (category != null) queryParams['category'] = category;
    if (page != null) queryParams['page'] = page.toString();

    url +=
        '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    print('💊 Get Medicines API Call:');
    print('💊 URL: $url');
    print('💊 Headers: $_headers');

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );

    print('💊 Get Medicines Response Status: ${response.statusCode}');
    print('💊 Get Medicines Response Body: ${response.body}');

    final data = _handleResponse(response);

    // Backend returns medicines in data.medicines
    try {
      print('💊 Parsing response data: $data');

      if (data.containsKey('data')) {
        final medicinesData = data['data'];
        print('💊 Medicines data: $medicinesData');

        if (medicinesData is Map && medicinesData.containsKey('medicines')) {
          final medicinesList = medicinesData['medicines'];
          print('💊 Medicines list: $medicinesList');
          print('💊 Medicines list length: ${medicinesList.length}');

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
            print('💊 Final result: ${result.length} medicines');
            return result;
          }
        }
      }
      print('💊 No medicines found in response');
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
    if (data.containsKey('data')) {
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
    print('💊 Add Medicine API Call:');
    print('💊 URL: $baseUrl/medicines/');
    print('💊 Token available: ${_authToken != null}');
    if (_authToken != null) {
      print('💊 Token: ${_authToken!.substring(0, 20)}...');
    }
    print('💊 Headers: $_headers');
    // Convert stock to quantity for backend compatibility
    final backendData = Map<String, dynamic>.from(medicineData);
    if (backendData.containsKey('stock') &&
        !backendData.containsKey('quantity')) {
      backendData['quantity'] = backendData['stock'];
      backendData.remove('stock');
    }
    print('💊 Request Body: ${json.encode(backendData)}');
    final response = await http.post(
      Uri.parse('$baseUrl/medicines/'),
      headers: _headers,
      body: json.encode(backendData),
    );
    print('💊 Add Medicine Response Status: ${response.statusCode}');
    print('💊 Add Medicine Response Body: ${response.body}');
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
    print('🗓️ Getting expiring medicines from API...');
    final response = await http.get(
      Uri.parse('$baseUrl/medicines/expiring'),
      headers: _headers,
    );

    print('🗓️ Expiring medicines response status: ${response.statusCode}');
    print('🗓️ Expiring medicines response body: ${response.body}');

    final data = _handleResponse(response);

    // Backend returns data directly in the response
    if (data is List) {
      print('🗓️ Expiring medicines count: ${data.length}');
      return List<Map<String, dynamic>>.from(data as List);
    } else if (data.containsKey('data')) {
      final medicines = data['data'];
      if (medicines is List) {
        print('🗓️ Expiring medicines count: ${medicines.length}');
        return List<Map<String, dynamic>>.from(medicines);
      }
    }

    print('🗓️ No expiring medicines found');
    return <Map<String, dynamic>>[];
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
        final days = expiry.difference(now).inDays;
        return days >= 0 && days <= 10; // within next 0..10 days only
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
    print('💳 Create Transaction API Call:');
    print('💳 URL: $baseUrl/transactions');
    print('💳 Headers: $_headers');
    print('💳 Transaction Data: ${json.encode(transactionData)}');

    // Basic validation for required fields
    if (transactionData.containsKey('items')) {
      final items = transactionData['items'] as List;
      for (final item in items) {
        final medicineId = item['medicineId'];
        print('💊 Validating medicine ID: $medicineId');

        // Basic validation - just check if medicineId exists and is not empty
        if (medicineId == null || medicineId.toString().isEmpty) {
          throw Exception('Medicine ID is required for all items');
        }

        // Check if quantity is valid
        final quantity = item['quantity'];
        if (quantity == null || quantity <= 0) {
          throw Exception('Invalid quantity for medicine: $medicineId');
        }

        print('💊 Medicine ID validation passed: $medicineId');
      }
    }

    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: _headers,
      body: json.encode(transactionData),
    );

    print('💳 Create Transaction Response Status: ${response.statusCode}');
    print('💳 Create Transaction Response Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('❌ Create Transaction Error Details:');
      print('❌ Status Code: ${response.statusCode}');
      print('❌ Response Body: ${response.body}');
      print('❌ Request Headers: $_headers');
      print('❌ Request Body: ${json.encode(transactionData)}');

      // Try to parse error response
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map && errorData.containsKey('message')) {
          print('❌ Backend Error Message: ${errorData['message']}');
        }
      } catch (e) {
        print('❌ Could not parse error response: $e');
      }
    }

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getMedicineById(String id) async {
    print('💊 Get Medicine by ID: $id');
    final response = await http.get(
      Uri.parse('$baseUrl/medicines/$id'),
      headers: _headers,
    );

    print('💊 Get Medicine Response Status: ${response.statusCode}');
    print('💊 Get Medicine Response Body: ${response.body}');

    final data = _handleResponse(response);
    return data['data'] ?? data;
  }

  // Cart and Checkout APIs (using correct backend endpoints)
  Future<Map<String, dynamic>> addToCart(Map<String, dynamic> cartItem) async {
    print('🛒 Add to Cart API Call:');
    print('🛒 URL: $baseUrl/transactions');
    print('🛒 Headers: $_headers');
    print('🛒 Cart Item: ${json.encode(cartItem)}');

    // Check if this is a single medicine or an invoice with multiple items
    if (cartItem['items'] != null && cartItem['items'] is List) {
      // This is an invoice with multiple items
      print('🛒 Processing invoice with ${cartItem['items'].length} items');

      // Validate that all items have medicineId
      for (var item in cartItem['items']) {
        if (item['medicineId'] == null ||
            item['medicineId'].toString().isEmpty) {
          throw Exception('Medicine ID is required for all items');
        }
      }

      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: _headers,
        body: json.encode(cartItem),
      );

      print('🛒 Add to Cart Response Status: ${response.statusCode}');
      print('🛒 Add to Cart Response Body: ${response.body}');

      return _handleResponse(response);
    } else {
      // This is a single medicine
      if (cartItem['medicineId'] == null ||
          cartItem['medicineId'].toString().isEmpty) {
        throw Exception('Medicine ID is required');
      }
      if (cartItem['quantity'] == null || cartItem['quantity'] <= 0) {
        throw Exception('Quantity must be greater than 0');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: _headers,
        body: json.encode({
          'transactionType': 'sale',
          'description': 'Direct medicine purchase',
          'items': [
            {
              'medicineId': cartItem['medicineId'],
              'quantity': cartItem['quantity'],
              'unitPrice': 0.0 // Will be set by backend
            }
          ],
          'status': 'pending'
        }),
      );

      print('🛒 Add to Cart Response Status: ${response.statusCode}');
      print('🛒 Add to Cart Response Body: ${response.body}');

      if (response.statusCode != 200) {
        print('❌ Add to Cart Error Details:');
        print('❌ Status Code: ${response.statusCode}');
        print('❌ Response Body: ${response.body}');
        print('❌ Request Headers: $_headers');
        print('❌ Request Body: ${json.encode(cartItem)}');
      }

      return _handleResponse(response);
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    print('🛒 Get Cart Items API Call:');
    print('🛒 URL: $baseUrl/transactions?status=pending&transactionType=sale');
    print('🛒 Headers: $_headers');

    final response = await http.get(
      Uri.parse('$baseUrl/transactions?status=pending&transactionType=sale'),
      headers: _headers,
    );

    print('🛒 Get Cart Items Response Status: ${response.statusCode}');
    print('🛒 Get Cart Items Response Body: ${response.body}');

    final data = _handleResponse(response);

    print('🛒 Cart Data Response: $data');

    // Backend returns transactions data in data array
    if (data.containsKey('data')) {
      final transactions = data['data'];
      print('🛒 Transactions found: ${transactions.length}');

      if (transactions is List) {
        // Extract items from all pending transactions
        List<Map<String, dynamic>> allItems = [];
        for (var transaction in transactions) {
          print('🛒 Processing transaction: ${transaction['_id']}');
          print('🛒 Transaction items: ${transaction['items']}');

          if (transaction is Map && transaction.containsKey('items')) {
            final items = transaction['items'];
            if (items is List) {
              for (var item in items) {
                if (item is Map) {
                  print('🛒 Processing item: $item');

                  // Ensure item has required fields
                  if (item['medicineId'] != null && item['quantity'] != null) {
                    // Add transaction info to each item
                    item['transactionId'] = transaction['_id'];
                    item['transactionNumber'] =
                        transaction['transactionNumber'];
                    item['id'] =
                        item['_id'] ?? item['medicineId']; // Ensure item has ID
                    allItems.add(Map<String, dynamic>.from(item));
                    print('🛒 Added item to cart: ${item['medicineName']}');
                  } else {
                    print('🛒 Skipping invalid item: $item');
                  }
                }
              }
            }
          }
        }
        print('🛒 Total items in cart: ${allItems.length}');
        return allItems;
      }
    }

    print('🛒 No valid cart data found');
    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> updateCartItem(
      String itemId, Map<String, dynamic> updates) async {
    print('🛒 Update Cart Item API Call:');
    print('🛒 URL: $baseUrl/transactions/$itemId');
    print('🛒 Headers: $_headers');
    print('🛒 Updates: ${json.encode(updates)}');

    final response = await http.put(
      Uri.parse('$baseUrl/transactions/$itemId'),
      headers: _headers,
      body: json.encode(updates),
    );

    print('🛒 Update Cart Item Response Status: ${response.statusCode}');
    print('🛒 Update Cart Item Response Body: ${response.body}');

    return _handleResponse(response);
  }

  Future<void> removeFromCart(String itemId) async {
    print('🛒 Remove from Cart API Call:');
    print('🛒 URL: $baseUrl/transactions/$itemId');
    print('🛒 Headers: $_headers');

    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/$itemId'),
      headers: _headers,
    );

    print('🛒 Remove from Cart Response Status: ${response.statusCode}');
    print('🛒 Remove from Cart Response Body: ${response.body}');

    _handleResponse(response);
  }

  Future<void> clearCart() async {
    print('🛒 Clear Cart API Call:');
    print('🛒 URL: $baseUrl/cart/clear');
    print('🛒 Headers: $_headers');
    print('🛒 Body: {"transactionType": "sale"}');

    final response = await http.delete(
      Uri.parse('$baseUrl/cart/clear'),
      headers: _headers,
      body: json.encode({'transactionType': 'sale'}),
    );

    print('🛒 Clear Cart Response Status: ${response.statusCode}');
    print('🛒 Clear Cart Response Body: ${response.body}');

    _handleResponse(response);
  }

  Future<Map<String, dynamic>> processCheckout(
      Map<String, dynamic> checkoutData) async {
    print('💳 Process Checkout API Call:');
    print('💳 URL: $baseUrl/transactions/checkout');
    print('💳 Checkout Data: ${json.encode(checkoutData)}');

    final response = await http.post(
      Uri.parse('$baseUrl/transactions/checkout'),
      headers: _headers,
      body: json.encode(checkoutData),
    );

    print('💳 Process Checkout Response Status: ${response.statusCode}');
    print('💳 Process Checkout Response Body: ${response.body}');

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

    // Add image if provided (supports web bytes or mobile path)
    if (requestData['imageBytes'] != null && kIsWeb) {
      final bytes = (requestData['imageBytes'] as List<int>);
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'medicine_request.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    } else if (requestData['imageUrl'] != null &&
        requestData['imageUrl'].toString().isNotEmpty &&
        !kIsWeb) {
      final imagePath = requestData['imageUrl'].toString();
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imagePath,
        filename: 'medicine_request.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
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
    if (data.containsKey('data')) {
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
    if (data.containsKey('data')) {
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
    if (data.containsKey('data')) {
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
    print('🔍 Dashboard API Call:');
    print('🔍 Token available: ${_authToken != null}');
    if (_authToken != null) {
      print('🔍 Token: ${_authToken!.substring(0, 20)}...');
    }
    print('🔍 Headers: $_headers');

    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/'),
      headers: _headers,
    );

    print('🔍 Dashboard Response Status: ${response.statusCode}');
    print('🔍 Dashboard Response Body: ${response.body}');

    final result = _handleResponse(response);

    // Log the KPIs specifically
    if (result.containsKey('data')) {
      final data = result['data'];
      if (data is Map && data.containsKey('kpis')) {
        final kpis = data['kpis'];
        print('📊 Dashboard KPIs from API:');
        print('📊 Total Sales: ${kpis['totalSales']}');
        print('📊 Total Purchases: ${kpis['totalPurchases']}');
        print('📊 Sales Count: ${kpis['salesCount']}');
        print('📊 Purchases Count: ${kpis['purchasesCount']}');
      }
    }

    return result;
  }

  /// Get user notifications with unread count
  Future<Map<String, dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/notifications'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// Create a new notification
  Future<Map<String, dynamic>> createNotification(
      Map<String, dynamic> notificationData) async {
    print('🔔 Creating notification: $notificationData');

    final response = await http.post(
      Uri.parse('$baseUrl/notifications'),
      headers: _headers,
      body: jsonEncode(notificationData),
    );

    final result = _handleResponse(response);
    print('🔔 Notification created: $result');
    return result;
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

      if (data.containsKey('data')) {
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

    if (data.containsKey('data')) {
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

      if (data.containsKey('data')) {
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
    if (data.containsKey('data')) {
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
    if (data.containsKey('data')) {
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
    if (data.containsKey('data')) {
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
    if (data.containsKey('data')) {
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

      if (data.containsKey('data')) {
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

    if (data.containsKey('data')) {
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

  // Handle API response with automatic token refresh
  Map<String, dynamic> _handleResponse(http.Response response) {
    // Handle 401 Unauthorized - Session expired
    if (response.statusCode == 401) {
      // Try to refresh token automatically
      _refreshToken().then((_) {
        print('🔄 Token refresh attempted');
      }).catchError((e) {
        print('❌ Token refresh failed: $e');
        // Clear auth data if refresh fails
        _clearAuthData();
      });

      throw ApiException(
        message: 'Session expired. Please login again.',
        statusCode: 401,
      );
    }

    // Handle other HTTP errors
    if (response.statusCode >= 400) {
      final errorData = json.decode(response.body);
      final message = errorData['message'] ?? 'An error occurred';
      throw ApiException(
        message: message,
        statusCode: response.statusCode,
      );
    }

    // Parse successful response
    try {
      return json.decode(response.body);
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
