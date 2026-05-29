import 'dart:convert';
import '../models/admin.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Login with username and password
  /// Returns: (success, message, admin, token)
  Future<(bool, String, AdminModel?, String?)> login(
    String username,
    String password,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/admin/login',
        {
          'username': username,
          'password': password,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response['success'] == true) {
        final token = response['token'] as String;
        final adminData = response['admin'] as Map<String, dynamic>;
        final message = (response['message'] as String?) ?? 'Login successful';
        
        await _apiClient.setToken(token);
        // Also persist admin data
        await _apiClient.setAdminData(jsonEncode(adminData));
        
        final admin = AdminModel.fromJson(adminData);
        return (true, message, admin, token);
      } else {
        final message = (response['message'] as String?) ?? 'Login failed';
        return (false, message, null, null);
      }
    } catch (e) {
      return (false, 'Login error: $e', null, null);
    }
  }

  Future<(bool success, String message)> logout() async {
    try {
      await _apiClient.clearToken();
      await _apiClient.clearAdminData(); // clear admin too
      return (true, 'Logged out successfully');
    } catch (e) {
      return (false, 'Logout error: $e');
    }
  }

  Future<AdminModel?> getSavedAdmin() async {
    final adminJson = await _apiClient.getAdminData();
    if (adminJson == null) return null;
    try {
      return AdminModel.fromJson(jsonDecode(adminJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    return _apiClient.getToken();
  }
}
