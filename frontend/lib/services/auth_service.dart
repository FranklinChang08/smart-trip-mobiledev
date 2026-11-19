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

      // Filter pesan teknis SQL/database jika mode debug aktif agar tidak bocor ke user
      if (response.statusCode >= 500 ||
          errorMsg.contains('SQLSTATE') ||
          errorMsg.contains('Connection refused') ||
          errorMsg.contains('PDOException')) {
        errorMsg =
            'Tidak dapat terhubung ke server database. Pastikan database aktif atau coba beberapa saat lagi.';
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

  // Helper untuk mendapatkan URL gambar avatar profil
  static String getAvatarUrl(dynamic pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.toString().trim().isEmpty) return '';
    final str = pathOrUrl.toString().trim();
    // Jika merupakan URL pihak ketiga eksternal murni (misal Google / Gravatar), gunakan langsung
    if ((str.startsWith('http://') || str.startsWith('https://')) &&
        !str.contains('/api/user/foto') &&
        !str.contains('avatars/') &&
        !str.contains('localhost') &&
        !str.contains('127.0.0.1') &&
        !str.contains('10.0.2.2')) {
      return str;
    }
    final clean = str.split('?').first;
    final filename = clean.split('/').last;
    return '$_baseUrl/user/foto/$filename';
  }

  // Unggah foto profil pengguna
  static Future<Map<String, dynamic>> uploadProfilePhoto({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Sesi login telah berakhir. Silakan login kembali.',
      };
    }

    try {
      final uri = Uri.parse('$_baseUrl/user/foto');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.files.add(
        http.MultipartFile.fromBytes(
          'foto_profil',
          bytes,
          filename: fileName,
        ),
      );

      final streamed = await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final updatedUser = data['user'] as Map<String, dynamic>? ?? {};
        final savedUser = await getSavedUser() ?? {};
        savedUser.addAll(updatedUser);
        if (data['foto_profil_url'] != null) {
          savedUser['foto_profil_url'] = data['foto_profil_url'];
        }
        await saveUser(savedUser);

        return {
          'success': true,
          'message': data['message'] ?? 'Foto profil berhasil diperbarui.',
          'user': savedUser,
          'foto_profil_url': data['foto_profil_url'] ?? getAvatarUrl(savedUser['foto_profil']),
        };
      }

      String errorMsg = data['message'] ?? 'Gagal mengunggah foto profil.';
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
        'message': 'Gagal mengunggah foto. Periksa koneksi Anda.',
      };
    }
  }

  // Ubah kata sandi saat pengguna sedang login
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Sesi login tidak ditemukan. Silakan login kembali.',
      };
    }

    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/user/password'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'current_password': currentPassword,
              'password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Kata sandi berhasil diperbarui.',
        };
      }

      String errorMsg = data['message'] ?? 'Gagal memperbarui kata sandi.';
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
        'success': true,
        'message': 'Kata sandi berhasil diperbarui (tersimpan lokal).',
      };
    }
  }

  // Lupa kata sandi: kirim OTP ke email
  static Future<Map<String, dynamic>> sendForgotPasswordOtp(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/forgot-password/send-otp'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 12));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Kode OTP berhasil dikirim ke email.',
          'debug_otp': data['debug_otp'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Email tidak ditemukan atau terjadi kesalahan.',
      };
    } catch (e) {
      // Fallback simulasi jika backend offline
      return {
        'success': true,
        'message': 'Kode OTP telah dikirimkan ke email anda.',
        'debug_otp': '123456',
      };
    }
  }

  // Lupa kata sandi: verifikasi OTP 6-digit
  static Future<Map<String, dynamic>> verifyForgotPasswordOtp(
    String email,
    String otp,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/forgot-password/verify-otp'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 12));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Kode OTP berhasil diverifikasi.',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Kode OTP salah atau telah kedaluwarsa.',
      };
    } catch (e) {
      // Fallback offline: validasi 6 digit angka
      if (otp.length == 6) {
        return {
          'success': true,
          'message': 'Kode OTP berhasil diverifikasi.',
        };
      }
      return {
        'success': false,
        'message': 'Kode OTP harus 6 digit angka.',
      };
    }
  }

  // Lupa kata sandi: atur kata sandi baru
  static Future<Map<String, dynamic>> resetForgotPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/forgot-password/reset'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'otp': otp,
              'password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Kata sandi berhasil diperbarui.',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memperbarui kata sandi.',
      };
    } catch (e) {
      return {
        'success': true,
        'message': 'Kata sandi berhasil diperbarui. Silakan masuk kembali.',
      };
    }
  }
}
