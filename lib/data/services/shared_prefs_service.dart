import 'package:shared_preferences/shared_preferences.dart';
import 'package:group_project/core/constants/app_constants.dart';

/// Service for managing SharedPreferences operations
class SharedPrefsService {
  // Private constructor to enforce singleton
  SharedPrefsService._();

  // Singleton instance
  static final SharedPrefsService _instance = SharedPrefsService._();

  // Factory constructor to return the instance
  factory SharedPrefsService() => _instance;

  // SharedPreferences instance
  late SharedPreferences _prefs;

  /// Initialize the SharedPreferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save user login state
  Future<bool> saveUserLoginState({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      await _prefs.setString(AppConstants.prefUserId, uid);
      await _prefs.setString(AppConstants.prefUserName, name);
      await _prefs.setString(AppConstants.prefUserEmail, email);
      await _prefs.setBool(AppConstants.prefIsLoggedIn, true);
      return true;
    } catch (e) {
      print('Error saving user login state: $e');
      return false;
    }
  }

  /// Check if user is logged in
  bool isUserLoggedIn() {
    return _prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
  }

  /// Get user ID
  String? getUserId() {
    return _prefs.getString(AppConstants.prefUserId);
  }

  /// Get user name
  String? getUserName() {
    return _prefs.getString(AppConstants.prefUserName);
  }

  /// Get user email
  String? getUserEmail() {
    return _prefs.getString(AppConstants.prefUserEmail);
  }

  /// Get user data as a map
  Map<String, String?> getUserData() {
    return {
      'uid': getUserId(),
      'name': getUserName(),
      'email': getUserEmail(),
    };
  }

  /// Clear all user data (logout)
  Future<bool> clearUserData() async {
    try {
      await _prefs.remove(AppConstants.prefUserId);
      await _prefs.remove(AppConstants.prefUserName);
      await _prefs.remove(AppConstants.prefUserEmail);
      await _prefs.setBool(AppConstants.prefIsLoggedIn, false);
      return true;
    } catch (e) {
      print('Error clearing user data: $e');
      return false;
    }
  }
}
