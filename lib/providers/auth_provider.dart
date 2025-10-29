import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userRole;
  String? _pharmacyName;
  String? _firstName;
  String? _lastName;
  Map<String, dynamic>? _userProfile;
  // Temporary state for password reset flow
  String? _pendingResetEmail;
  String? _resetTokenOrCode;

  final ApiService _apiService = ApiService();

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  String? get pharmacyName => _pharmacyName;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get pendingResetEmail => _pendingResetEmail;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userEmail = prefs.getString('userEmail');
    _userRole = prefs.getString('userRole');
    _pharmacyName = prefs.getString('pharmacyName');
    _firstName = prefs.getString('firstName');
    _lastName = prefs.getString('lastName');

    // If we have a token, verify it's still valid
    if (_isAuthenticated) {
      try {
        await _loadUserProfile();
      } catch (e) {
        // Token is invalid, logout
        await logout();
      }
    }

    notifyListeners();
  }

  Future<void> _saveAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', _isAuthenticated);
    if (_userEmail != null) await prefs.setString('userEmail', _userEmail!);
    if (_userRole != null) await prefs.setString('userRole', _userRole!);
    if (_pharmacyName != null)
      await prefs.setString('pharmacyName', _pharmacyName!);
    if (_firstName != null) await prefs.setString('firstName', _firstName!);
    if (_lastName != null) await prefs.setString('lastName', _lastName!);
  }

  Future<void> _loadUserProfile() async {
    try {
      print(
          '👤 _loadUserProfile: Attempting to load user profile with token...');
      if (_apiService.authToken != null) {
        print(
            '👤 _loadUserProfile: ApiService has token: ${_apiService.authToken!.substring(0, 20)}...');
      } else {
        print('👤 _loadUserProfile: ApiService does NOT have a token.');
      }
      final response = await _apiService.getUserProfile();
      _userProfile = response['data']?['profile'] ?? response;
      _updateUserFromProfile(_userProfile!);
      notifyListeners();
    } catch (e) {
      print('❌ _loadUserProfile error: ${e.toString()}');

      // Check if it's a 401 error (token expired)
      if (e.toString().contains('401') ||
          e.toString().contains('Session expired')) {
        print('🔍 Token expired, logging out user');
        await logout();
      }
      // Handle other profile loading errors silently
      // Don't rethrow to avoid breaking login flow
    }
  }

  Future<void> refreshUserProfile() async {
    await _loadUserProfile();
  }

  void _updateUserFromProfile(Map<String, dynamic> profile) {
    _userEmail = profile['email'] ?? profile['businessEmail'];
    _pharmacyName = profile['pharmacyName'] ?? profile['businessName'];
    _firstName = profile['firstName'];
    _lastName = profile['lastName'];
    _userRole = profile['role'];
  }

  Future<void> login(String email, String password) async {
    try {
      print('🔐 AuthProvider.login() called');
      print('🔐 Email: $email');

      final response = await _apiService.login(email, password);

      // Check if login was successful from API response
      if (response['success'] == true &&
          (response['data']?['token'] != null || response['token'] != null)) {
        print('✅ Login successful');
        _isAuthenticated = true;
        _userEmail = email;

        // Reinitialize API service with new token
        print('🔄 Reinitializing API service...');
        await _apiService.initialize();

        // Load user profile to get complete user data
        print('👤 Loading user profile...');
        await _loadUserProfile();

        print('💾 Saving auth state...');
        await _saveAuthState();
        notifyListeners();
        print('✅ Login completed successfully');
      } else {
        print('❌ Login failed: Invalid response from server');
        throw Exception('Login failed: Invalid response from server');
      }
    } catch (e) {
      print('❌ Login error: ${e.toString()}');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }

    _isAuthenticated = false;
    _userEmail = null;
    _userRole = null;
    _pharmacyName = null;
    _firstName = null;
    _lastName = null;
    _userProfile = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  Future<void> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.register(userData);

      if (response['success'] == true) {
        // Registration successful, auto-login the user
        final email = userData['email'];
        final password = userData['password'];

        if (email != null && password != null) {
          // Auto-login after successful registration
          await login(email, password);
        }
      } else {
        throw Exception('Registration failed: Invalid response from server');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> registerPharmacy(Map<String, dynamic> pharmacyData) async {
    try {
      print('🔍 AuthProvider: Starting pharmacy registration');
      final response = await _apiService.registerPharmacy(pharmacyData);
      print('🔍 AuthProvider: Registration response: $response');

      if (response['success'] == true) {
        // Pharmacy registration successful
        print('✅ AuthProvider: Registration successful');
        notifyListeners();
      } else {
        print('❌ AuthProvider: Registration failed - Invalid response');
        throw Exception(
            'Pharmacy registration failed: Invalid response from server');
      }
    } catch (e) {
      print('❌ AuthProvider: Registration error: $e');
      // Re-throw with more context but don't clear form data
      throw Exception('Pharmacy registration failed: ${e.toString()}');
    }
  }

  // ===== Password reset flow =====
  Future<void> requestPasswordReset(String email) async {
    try {
      print(
          '🔍 AuthProvider: Request password reset called with email: $email');
      await _apiService.requestPasswordReset(email);
      _pendingResetEmail = email;
      print('🔍 AuthProvider: _pendingResetEmail set to: $_pendingResetEmail');
      notifyListeners();
      print(
          '✅ AuthProvider: Request password reset successful and listeners notified');
    } catch (e) {
      print('❌ AuthProvider: Request password reset failed: ${e.toString()}');
      throw Exception('Forgot password failed: ${e.toString()}');
    }
  }

  Future<void> verifyResetCode(String email, String code) async {
    try {
      print(
          '🔍 AuthProvider: verifyResetCode called with email: "$email" and code: "$code"');
      print('🔍 AuthProvider: _pendingResetEmail is: "$_pendingResetEmail"');

      // Use the email from parameter or fallback to pendingResetEmail
      final emailToUse = email.isNotEmpty ? email : _pendingResetEmail;
      print('🔍 AuthProvider: Using email: "$emailToUse"');

      if (emailToUse == null || emailToUse.isEmpty) {
        print('❌ AuthProvider: No email available for OTP verification');
        throw Exception('No email available for OTP verification');
      }

      print(
          '🔍 AuthProvider: Attempting to verify OTP for email: $emailToUse with code: $code');
      final response = await _apiService.verifyOtp(emailToUse, code);
      print(
          '🔍 AuthProvider: Received response from verifyOtp: ${response.toString()}');

      // Extract token from response
      final token = response['data']?['token'] ?? response['token'];
      print(
          '🔍 AuthProvider: Extracted token: ${token != null ? 'FOUND' : 'NULL'}');

      if (token != null) {
        print('🔍 AuthProvider: Token found in response. Saving token...');
        await _apiService.saveToken(token);
        print('✅ Token saved after OTP verification');

        // Update auth state
        _isAuthenticated = true;
        _userEmail = emailToUse;
        await _saveAuthState();
        print('✅ Auth state saved');

        // Load user profile
        await _loadUserProfile();
        print('✅ User profile loaded');
      } else {
        print('❌ AuthProvider: No token received after OTP verification');
        print('❌ AuthProvider: Full response: $response');
        throw Exception(
            'No authentication token received after OTP verification');
      }

      _pendingResetEmail = emailToUse;
      _resetTokenOrCode = code;
      notifyListeners();
      print(
          '✅ AuthProvider: OTP verification successful and listeners notified.');
    } catch (e) {
      print(
          '❌ AuthProvider: OTP verification failed in AuthProvider: ${e.toString()}');
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  Future<void> performPasswordReset(String newPassword) async {
    try {
      if (_pendingResetEmail == null || _resetTokenOrCode == null) {
        throw Exception('Reset session not initialized');
      }

      await _apiService.resetPassword(
        email: _pendingResetEmail!,
        newPassword: newPassword,
        otp: _resetTokenOrCode!,
      );

      // Clear temporary state after success
      _pendingResetEmail = null;
      _resetTokenOrCode = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Reset password failed: ${e.toString()}');
    }
  }

  // ===== 2FA Authentication =====
  Future<Map<String, dynamic>> enable2FA() async {
    try {
      final response = await _apiService.enable2FA();
      notifyListeners();
      return response;
    } catch (e) {
      throw Exception('Failed to enable 2FA: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> verify2FA(String token) async {
    try {
      final response = await _apiService.verify2FA(token);
      notifyListeners();
      return response;
    } catch (e) {
      throw Exception('Failed to verify 2FA: ${e.toString()}');
    }
  }

  Future<void> disable2FA() async {
    try {
      await _apiService.disable2FA();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to disable 2FA: ${e.toString()}');
    }
  }
}
