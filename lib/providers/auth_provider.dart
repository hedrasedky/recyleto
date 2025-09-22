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
      final response = await _apiService.getUserProfile();
      _userProfile = response['data']?['profile'] ?? response;
      _updateUserFromProfile(_userProfile!);
      notifyListeners();
    } catch (e) {
      // Handle profile loading error
      rethrow;
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
      final response = await _apiService.login(email, password);

      // Check if login was successful from API response
      if (response['success'] == true &&
          (response['data']?['token'] != null || response['token'] != null)) {
        _isAuthenticated = true;
        _userEmail = email;

        // Load user profile to get complete user data
        await _loadUserProfile();

        await _saveAuthState();
        notifyListeners();
      } else {
        throw Exception('Login failed: Invalid response from server');
      }
    } catch (e) {
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
      final response = await _apiService.registerPharmacy(pharmacyData);

      if (response['success'] == true) {
        // Pharmacy registration successful
        notifyListeners();
      } else {
        throw Exception(
            'Pharmacy registration failed: Invalid response from server');
      }
    } catch (e) {
      throw Exception('Pharmacy registration failed: ${e.toString()}');
    }
  }

  // ===== Password reset flow =====
  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiService.requestPasswordReset(email);
      _pendingResetEmail = email;
      notifyListeners();
    } catch (e) {
      throw Exception('Forgot password failed: ${e.toString()}');
    }
  }

  Future<void> verifyResetCode(String email, String code) async {
    try {
      await _apiService.verifyOtp(email, code);
      _pendingResetEmail = email;
      _resetTokenOrCode = code;
      notifyListeners();
    } catch (e) {
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
