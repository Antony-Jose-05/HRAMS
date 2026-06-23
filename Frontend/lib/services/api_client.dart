import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../app_config.dart';

class ApiClient {
  static String get baseUrl => AppConfig.apiBaseUrl;
  
  final http.Client _httpClient;
  final SharedPreferences _prefs;

  ApiClient({
    http.Client? httpClient,
    required SharedPreferences prefs,
  })  : _httpClient = httpClient ?? http.Client(),
        _prefs = prefs;

  Future<String?> getToken() async {
    return _prefs.getString('auth_token');
  }

  Future<void> setToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
  }

  Future<String?> getAdminData() async {
    return _prefs.getString('admin_data');
  }

  Future<void> setAdminData(String adminJson) async {
    await _prefs.setString('admin_data', adminJson);
  }

  Future<void> clearAdminData() async {
    await _prefs.remove('admin_data');
  }

  Future<void> clearSession() async {
    await clearToken();
    await clearAdminData();
  }

  /// Get HTTP headers (without auth token)
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    return headers;
  }

  /// Get HTTP headers with JWT authorization token
  Future<Map<String, String>> _getHeadersWithAuth() async {
    final headers = _getHeaders();
    final token = await getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<T> get<T>(
    String endpoint, {
    required T Function(dynamic) fromJson,
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth
          ? await _getHeadersWithAuth()
          : _getHeaders();

      final response = await _httpClient.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      throw ApiException('Failed to fetch from $endpoint: $e');
    }
  }

  Future<T> post<T>(
    String endpoint,
    dynamic body, {
    required T Function(dynamic) fromJson,
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth
          ? await _getHeadersWithAuth()
          : _getHeaders();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      throw ApiException('Failed to post to $endpoint: $e');
    }
  }

  Future<T> put<T>(
    String endpoint,
    dynamic body, {
    required T Function(dynamic) fromJson,
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth
          ? await _getHeadersWithAuth()
          : _getHeaders();

      final response = await _httpClient.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      throw ApiException('Failed to put to $endpoint: $e');
    }
  }

  Future<void> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth
          ? await _getHeadersWithAuth()
          : _getHeaders();

      final response = await _httpClient.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        await clearSession();
        throw UnauthorizedException('Session expired. Please login again.');
      }

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw ApiException('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnauthorizedException || e is ApiException) rethrow;
      throw ApiException('Failed to delete $endpoint: $e');
    }
  }

  T _handleResponse<T>(http.Response response, T Function(dynamic) fromJson) {
    if (response.statusCode == 401) {
      unawaited(clearSession());
      throw UnauthorizedException('Unauthorized. Please login again.');
    }

    if (response.statusCode >= 400) {
      final errorBody = jsonDecode(response.body);
      final message = errorBody['message'] ?? 'An error occurred';
      throw ApiException(message);
    }

    if (response.statusCode == 204) {
      return fromJson(null);
    }

    try {
      final jsonBody = jsonDecode(response.body);
      return fromJson(jsonBody);
    } catch (e) {
      throw ApiException('Failed to parse response: $e');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}
