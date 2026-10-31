import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Layanan manajemen data rencana perjalanan
class TripPlanService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000/api'
        : 'http://127.0.0.1:8000/api';
  }

  /// Pemetaan icon kategori
  static IconData getIconForCategory(String name) {
    switch (name.toLowerCase().trim()) {
      case 'wisata alam':
        return Icons.forest_outlined;
      case 'wisata pantai':
        return Icons.beach_access_outlined;
      case 'wisata sejarah':
        return Icons.history_edu_outlined;
      case 'wisata budaya':
        return Icons.theater_comedy_outlined;
      case 'wisata religi':
        return Icons.mosque_outlined;
      case 'wisata edukasi':
        return Icons.school_outlined;
      case 'wisata rekreasi':
        return Icons.attractions_outlined;
      case 'wisata belanja':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.explore_outlined;
    }
  }

  /// Deskripsi kategori wisata
  static String getDescForCategory(String name) {
    switch (name.toLowerCase().trim()) {
      case 'wisata alam':
        return 'Hutan mangrove, bukit pandang & konservasi alam';
      case 'wisata pantai':
        return 'Pasir putih, pulau kecil & sunset pesisir laut';
      case 'wisata sejarah':
        return 'Camp Vietnam, tugu sejarah & museum Kota Batam';
      case 'wisata budaya':
        return 'Perkampungan Melayu & seni pertunjukan lokal';
      case 'wisata religi':
        return 'Masjid Sultan Mahmud Riayat Syah & Vihara';
      case 'wisata edukasi':
        return 'Wisata belajar flora-fauna & kebun edukasi';
      case 'wisata rekreasi':
        return 'Taman bermain keluarga & wahana santai';
      case 'wisata belanja':
        return 'Kawasan belanja Nagoya & barang duty free';
      default:
        return 'Destinasi wisata unggulan di Pulau Batam';
    }
  }

  /// Daftar kategori wisata
  static Future<List<TripThemeModel>> fetchCategories() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/kategori?jenis=wisata'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] is List) {
          final list = json['data'] as List;
          if (list.isNotEmpty) {
            return list.map((item) {
              final name = item['nama_kategori'].toString();
              return TripThemeModel(
                title: name,
                desc: getDescForCategory(name),
                icon: getIconForCategory(name),
              );
            }).toList();
          }
        }
      }
    } catch (_) {
    }
    return kTripThemes;
  }

  /// Deskripsi kecamatan
  static String getDescForKecamatan(String name) {
    switch (name.toLowerCase().trim()) {
      case 'batam kota':
        return 'Pusat pemerintahan, Museum Raja Ali Haji, Welcome to Batam & ferry';
      case 'lubuk baja':
        return 'Pusat belanja terlengkap Nagoya, Grand Batam Mall & sentra kuliner';
      case 'batu ampar':
        return 'Pelabuhan Ferry Harbour Bay, kawasan pesisir bisnis & hotel';
      case 'nongsa':
        return 'Kawasan resort bahari mewah, pantai pasir putih & lapangan golf';
      case 'galang':
        return 'Jembatan 5-6 Barelang, situs sejarah Camp Vietnam & pantai eksotis';
      case 'sagulung':
        return 'Ikon Jembatan 1 Barelang & Masjid Agung Sultan Mahmud Riayat Syah';
      case 'sekupang':
        return 'Taman Rusa, Hutan Mata Kucing, bukit senja & pelabuhan domestik';
      case 'bengkong':
        return 'Pusat seafood Golden Prawn, replika kapal Cheng Ho & wahana rekreasi';
      case 'batu aji':
        return 'Pusat perdagangan grosir, kuliner lokal & sentra perumahan';
      case 'sei beduk':
        return 'Waduk Duriangkang, kawasan industri Panbil & perbukitan hijau';
      case 'belakang padang':
        return 'Pulau Penawar Rindu, wisata becak dayung, kuliner kopi & pesisir';
      case 'bulang':
        return 'Kepulauan pesisir tradisi Melayu & ekowisata perairan mangrove';
      default:
        return 'Wilayah administrasi dan destinasi Kota Batam';
    }
  }

  /// Icon kecamatan
  static String getIconForKecamatan(String name) {
    switch (name.toLowerCase().trim()) {
      case 'batam kota':
        return '🏛️';
      case 'lubuk baja':
        return '🏬';
      case 'batu ampar':
        return '🚢';
      case 'nongsa':
        return '🏖️';
      case 'galang':
        return '🏝️';
      case 'sagulung':
        return '🌉';
      case 'sekupang':
        return '🌲';
      case 'bengkong':
        return '🦐';
      case 'batu aji':
        return '🛍️';
      case 'sei beduk':
        return '🏞️';
      case 'belakang padang':
        return '⛵';
      case 'bulang':
        return '🛶';
      default:
        return '📍';
    }
  }

  /// Mengambil daftar 
  static Future<List<TripAreaModel>> fetchKecamatan() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/kecamatan'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] is List) {
          final list = json['data'] as List;
          if (list.isNotEmpty) {
            return list.map((item) {
              final id = item['id_kecamatan'] as int?;
              final name = item['nama_kecamatan'].toString();
              return TripAreaModel(
                id: id,
                name: name,
                desc: getDescForKecamatan(name),
                icon: getIconForKecamatan(name),
              );
            }).toList();
          }
        }
      }
    } catch (_) {}
    return kBatamKecamatanList;
  }

  static Future<String> _getStorageKey() async {
    final user = await AuthService.getSavedUser();
    final userId = user?['id_pengguna'] ?? user?['id'];
    if (userId != null) {
      return 'saved_batam_trip_plans_$userId';
    }
    return 'saved_batam_trip_plans_guest';
  }

  /// Menyimpan rencana perjalanan 
  static Future<SavedTripPlan?> saveTripPlan(SavedTripPlan plan) async {
    SavedTripPlan? savedResult;
    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final numericBudget = double.tryParse(
        plan.budget.replaceAll(RegExp(r'[^0-9]'), ''),
      );

      final body = jsonEncode({
        'nama_rencana': plan.tripName,
        'hari_start': plan.startDate.toIso8601String().split('T').first,
        'hari_end': plan.endDate.toIso8601String().split('T').first,
        'tanggal_mulai': plan.startDate.toIso8601String().split('T').first,
        'tanggal_selesai': plan.endDate.toIso8601String().split('T').first,
        'titik_awal': plan.startLocation,
        'budget_trip': numericBudget,
        'total_anggaran': numericBudget,
        'type_food': plan.isHalal ? 'Halal' : (plan.isSeafood ? 'Seafood' : 'Semua'),
        'kategori_minat': plan.selectedThemes,
        'kecamatan_pilihan': plan.selectedAreas,
        'is_halal': plan.isHalal,
        'is_seafood': plan.isSeafood,
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/rencana-perjalanan'),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] is Map) {
          savedResult = SavedTripPlan.fromJson(
            json['data'] as Map<String, dynamic>,
          );
        }
      }
    } catch (e) {
      debugPrint('Sinkronisasi backend rencana perjalanan: $e');
    }

    final planToSave = savedResult ?? plan;

    // Simpan ke cache lokal
    try {
      final storageKey = await _getStorageKey();
      final prefs = await SharedPreferences.getInstance();
      final plans = await getAllTripPlans();

      // Nonaktifkan rencana lainnya
      final updatedPlans = plans
          .where((p) => p.id != planToSave.id)
          .map((p) => p.copyWith(isActive: false))
          .toList();

      final activeNewPlan = planToSave.copyWith(isActive: true);

      // Tambahkan rencana baru
      updatedPlans.insert(0, activeNewPlan);

      final jsonList = updatedPlans.map((p) => p.toJson()).toList();
      await prefs.setString(storageKey, jsonEncode(jsonList));
      return activeNewPlan;
    } catch (e) {
      debugPrint('Error saving trip plan: $e');
      return planToSave;
    }
  }

  /// Seluruh daftar rencana perjalanan
  static Future<List<SavedTripPlan>> getAllTripPlans() async {
    final storageKey = await _getStorageKey();
    final prefs = await SharedPreferences.getInstance();

    // Bersihkan cache lama
    if (prefs.containsKey('saved_batam_trip_plans')) {
      await prefs.remove('saved_batam_trip_plans');
    }

    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/rencana-perjalanan'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] is List) {
          final list = (json['data'] as List)
              .map((e) => SavedTripPlan.fromJson(e as Map<String, dynamic>))
              .toList();

          // Perbarui cache lokal
          final jsonList = list.map((p) => p.toJson()).toList();
          await prefs.setString(storageKey, jsonEncode(jsonList));
          return list;
        }
      }
    } catch (e) {
      debugPrint('Notice fetch backend trip plans: $e');
    }

    try {
      final jsonStr = prefs.getString(storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = jsonDecode(jsonStr);
        return decoded
            .map((e) => SavedTripPlan.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading trip plans locally: $e');
    }
    return [];
  }

  /// Mengambil rencana perjalanan yang sedang berstatus aktif
  static Future<SavedTripPlan> getActiveTripPlan() async {
    final plans = await getAllTripPlans();
    if (plans.isEmpty) {
      return SavedTripPlan.defaultPlan();
    }
    return plans.firstWhere(
      (p) => p.isActive,
      orElse: () => plans.first,
    );
  }

  /// Mengambil satu rencana perjalanan beserta detail itinerarinya
  static Future<SavedTripPlan?> getTripPlanById(String id) async {
    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/rencana-perjalanan/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] is Map) {
          return SavedTripPlan.fromJson(json['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Notice fetch trip plan detail: $e');
    }
    return null;
  }

  /// Menjadikan rencana perjalanan tertentu sebagai rencana aktif
  static Future<void> setActivePlan(String planId) async {
    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      await http
          .put(
            Uri.parse('$_baseUrl/rencana-perjalanan/$planId/aktif'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 12));
    } catch (e) {
      debugPrint('Notice setActivePlan on backend: $e');
    }

    try {
      final storageKey = await _getStorageKey();
      final prefs = await SharedPreferences.getInstance();
      final plans = await getAllTripPlans();
      final updated = plans.map((p) {
        return SavedTripPlan(
          id: p.id,
          tripName: p.tripName,
          startDate: p.startDate,
          endDate: p.endDate,
          startLocation: p.startLocation,
          budget: p.budget,
          selectedThemes: p.selectedThemes,
          selectedAreas: p.selectedAreas,
          isHalal: p.isHalal,
          isSeafood: p.isSeafood,
          notes: p.notes,
          isActive: p.id == planId,
          details: p.details,
          createdAt: p.createdAt,
        );
      }).toList();

      final jsonList = updated.map((p) => p.toJson()).toList();
      await prefs.setString(storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error setting active plan: $e');
    }
  }

  static Future<bool> deleteTripPlan(String planId) async {
    bool isSuccess = false;
    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .delete(
            Uri.parse('$_baseUrl/rencana-perjalanan/$planId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        isSuccess = true;
      }
    } catch (e) {
      debugPrint('Notice delete trip plan from backend: $e');
    }

    try {
      final storageKey = await _getStorageKey();
      final prefs = await SharedPreferences.getInstance();
      final plans = await getAllTripPlans();
      final updated = plans.where((p) => p.id != planId).toList();
      final jsonList = updated.map((p) => p.toJson()).toList();
      await prefs.setString(storageKey, jsonEncode(jsonList));
      return true;
    } catch (_) {}

    return isSuccess;
  }
}


