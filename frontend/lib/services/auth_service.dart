import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000/api'
        : 'http://127.0.0.1:8000/api';
  }

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

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

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null && userStr.isNotEmpty) {
      try {
        return jsonDecode(userStr) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
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
        final user = data['user'] as Map<String, dynamic>?;
        await saveToken(token);
        if (user != null) {
          await saveUser(user);
        }
        return AuthResult(
          success: true,
          token: token,
          user: user,
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
      return const AuthResult(
        success: false,
        errorMessage:
            'Tidak dapat terhubung ke server. Periksa koneksi internet.',
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
    await clearUser();
  }

  // Ambil profil pengguna
  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return await getSavedUser();
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/user'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>?;
        if (user != null) {
          final savedUser = await getSavedUser() ?? {};
          savedUser.addAll(user);
          await saveUser(savedUser);
          return savedUser;
        }
      }
    } catch (e) {
      debugPrint('Error fetch live profile: $e');
    }

    return await getSavedUser();
  }

  // Perbarui profil pengguna di database
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Sesi telah berakhir, silakan login kembali.',
      };
    }

    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/user/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'nama_pengguna': name,
              'email': email,
              'no_hp': phone,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final updatedUser = data['user'] as Map<String, dynamic>? ?? {};
        final savedUser = await getSavedUser() ?? {};
        savedUser.addAll(updatedUser);
        await saveUser(savedUser);

        return {
          'success': true,
          'message': data['message'] ?? 'Profil berhasil diperbarui.',
          'user': savedUser,
        };
      }

      String errorMsg = data['message'] ?? 'Gagal memperbarui profil.';
      if (data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        errorMsg = errors.values.first is List
            ? (errors.values.first as List).first.toString()
            : errors.values.first.toString();
      }

      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server. Periksa koneksi Anda.',
      };
    }
  }
}
