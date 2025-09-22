import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userTokenKey = 'user_token';

  // Save login credentials
  static Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_rememberMeKey, rememberMe);
    
    if (rememberMe) {
      await prefs.setString(_savedEmailKey, email);
      // Note: In production, don't save password in plain text
      // Use encrypted storage or just save email only
      await prefs.setString(_savedPasswordKey, password);
    } else {
      // Clear saved credentials if remember me is disabled
      await prefs.remove(_savedEmailKey);
      await prefs.remove(_savedPasswordKey);
    }
  }

  // Get saved credentials
  static Future<Map<String, dynamic>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'rememberMe': prefs.getBool(_rememberMeKey) ?? false,
      'email': prefs.getString(_savedEmailKey) ?? '',
      'password': prefs.getString(_savedPasswordKey) ?? '',
    };
  }

  // Save login state
  static Future<void> saveLoginState({
    required bool isLoggedIn,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
    if (token != null) {
      await prefs.setString(_userTokenKey, token);
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTokenKey);
  }

  // Clear all data (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userTokenKey);
    
    // Only clear credentials if remember me is false
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    if (!rememberMe) {
      await prefs.remove(_savedEmailKey);
      await prefs.remove(_savedPasswordKey);
      await prefs.remove(_rememberMeKey);
    }
  }
}