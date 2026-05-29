import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  AdminModel? _admin;
  String? _error;

  AuthProvider(this._authService) {
    _checkAuthentication();
  }

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  AdminModel? get admin => _admin;
  String? get error => _error;

  Future<void> _checkAuthentication() async {
    _isAuthenticated = await _authService.isAuthenticated();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final (success, message, admin, token) = await _authService.login(username, password);

      if (success) {
        _isAuthenticated = true;
        _admin = admin;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isAuthenticated = false;
        _error = message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isAuthenticated = false;
      _error = 'Login error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _admin = null;
    _error = null;
    notifyListeners();
  }
}

// Factory function to create AuthProvider
Future<AuthProvider> createAuthProvider() async {
  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient(prefs: prefs);
  final authService = AuthService(apiClient: apiClient);
  return AuthProvider(authService);
}
