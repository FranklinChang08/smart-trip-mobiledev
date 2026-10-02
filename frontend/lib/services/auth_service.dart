import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool success;
  final String? token;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  const AuthResult({
    required this.success,
    this.token,
    this.user,
    this.errorMessage,
  });
}

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  static const String _tokenKey = 'auth_token';


  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final token = data['token'] as String;
        await saveToken(token);
        return AuthResult(
          success: true,
          token: token,
          user: data['user'] as Map<String, dynamic>?,
        );
      }

      String errorMsg = 'Login gagal. Coba lagi.';
      if (data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        errorMsg = errors.values.first is List
            ? (errors.values.first as List).first.toString()
            : errors.values.first.toString();
      } else if (data.containsKey('message')) {
        errorMsg = data['message'].toString();
      }

      return AuthResult(success: false, errorMessage: errorMsg);
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Tidak dapat terhubung ke server. Periksa koneksi internet.',
      );
    }
  }

  static Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));
      } catch (_) {}
    }
    await clearToken();
  }
}
