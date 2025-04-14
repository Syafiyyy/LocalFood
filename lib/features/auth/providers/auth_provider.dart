import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_project/data/models/user_model.dart';
import 'package:group_project/data/services/auth_service.dart';
import 'package:group_project/data/services/shared_prefs_service.dart';

/// Auth state enum
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Provider to manage authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SharedPrefsService _prefsService = SharedPrefsService();

  // Current auth state
  AuthState _authState = AuthState.initial;
  AuthState get authState => _authState;

  // Current user
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Error message
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Constructor
  AuthProvider() {
    _init();
  }

  /// Initialize the auth provider
  Future<void> _init() async {
    _authState = AuthState.loading;
    notifyListeners();

    // Check if user is logged in using SharedPreferences
    if (_prefsService.isUserLoggedIn()) {
      final userData = _prefsService.getUserData();
      if (userData['uid'] != null) {
        // Create user model from shared prefs
        _currentUser = UserModel(
          uid: userData['uid']!,
          name: userData['name'] ?? 'User',
          email: userData['email'] ?? '',
        );
        _authState = AuthState.authenticated;
      } else {
        // No valid user data in shared prefs
        _authState = AuthState.unauthenticated;
      }
    } else {
      // Not logged in
      _authState = AuthState.unauthenticated;
    }

    notifyListeners();

    // Listen to Firebase Auth state changes
    _authService.authStateChanges.listen((User? user) {
      if (user == null && _authState == AuthState.authenticated) {
        // User signed out from Firebase, update local state
        _signOut(notify: true);
      }
    });
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _authState = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    final result = await _authService.signUp(
      email: email,
      password: password,
      name: name,
    );

    if (result['success']) {
      // Don't set as authenticated - user needs to sign in
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _authState = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _authState = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    final result = await _authService.signIn(
      email: email,
      password: password,
    );

    if (result['success']) {
      _currentUser = result['user'];
      _authState = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _authState = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _signOut(notify: true);
  }

  /// Internal sign out method
  Future<void> _signOut({bool notify = false}) async {
    _authState = AuthState.loading;
    if (notify) notifyListeners();

    await _authService.signOut();

    _currentUser = null;
    _authState = AuthState.unauthenticated;
    if (notify) notifyListeners();
  }

  /// Refresh user profile
  Future<void> refreshUserProfile() async {
    if (_currentUser == null) return;

    final userProfile = await _authService.getUserProfile(_currentUser!.uid);
    if (userProfile != null) {
      _currentUser = userProfile;
      notifyListeners();
    }
  }
}
