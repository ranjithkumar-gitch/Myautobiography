import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Result returned by [AdminAuthService.login].
class AdminLoginResult {
  final bool success;
  final String? errorMessage;
  const AdminLoginResult._({required this.success, this.errorMessage});
  factory AdminLoginResult.ok() => const AdminLoginResult._(success: true);
  factory AdminLoginResult.fail(String message) =>
      AdminLoginResult._(success: false, errorMessage: message);
}

class AdminAuthService {
  static const _loginUrl = 'https://dev-mab.clearfocus.in/api/admin/login-v1';
  static const _tokenKey = 'admin_access_token';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// POST login credentials, store the returned access token securely.
  static Future<AdminLoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_loginUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final token = _extractToken(body);
        if (token == null || token.isEmpty) {
          return AdminLoginResult.fail(
            'Login succeeded but no token received.',
          );
        }
        await _storage.write(key: _tokenKey, value: token);
        return AdminLoginResult.ok();
      }

      final message = body['message'] as String? ?? 'Invalid credentials.';
      return AdminLoginResult.fail(message);
    } on http.ClientException {
      return AdminLoginResult.fail('Network error. Please try again.');
    } catch (_) {
      return AdminLoginResult.fail('An unexpected error occurred.');
    }
  }

  /// Retrieve the stored access token (null if not authenticated).
  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  /// Clear the stored token (logout).
  static Future<void> logout() => _storage.delete(key: _tokenKey);

  static String? _extractToken(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final dataAccessToken = data['accessToken'];
      if (dataAccessToken is String && dataAccessToken.isNotEmpty) {
        return dataAccessToken;
      }

      final dataToken = data['token'];
      if (dataToken is String && dataToken.isNotEmpty) {
        return dataToken;
      }
    }

    final rootAccessToken = body['accessToken'];
    if (rootAccessToken is String && rootAccessToken.isNotEmpty) {
      return rootAccessToken;
    }

    final rootToken = body['token'];
    if (rootToken is String && rootToken.isNotEmpty) {
      return rootToken;
    }

    return null;
  }
}
