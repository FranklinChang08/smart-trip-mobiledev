import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


/// untuk mengambil data master rencana perjalanan langsung
class TripPlanService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000/api'
        : 'http://127.0.0.1:8000/api';
  }

  /// Pemetaan icon untuk kategori wisata Batam
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

  /// deskripsi ringkas untuk kategori wisata Batam
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

  /// Mengambil daftar kategori wisata
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

  /// Deskripsi khas kecamatan di Batam
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

  /// Icon khas kecamatan
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

  /// Mengambil daftar 12 kecamatan asli dari Database Backend
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

  static const String _storageKey = 'saved_batam_trip_plans';

  /// Menyimpan rencana perjalanan 
  static Future<void> saveTripPlan(SavedTripPlan plan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plans = await getAllTripPlans();

      // Tandai semua rencana lainnya menjadi tidak aktif
      final updatedPlans = plans.map((p) => SavedTripPlan(
        id: p.id,
        tripName: p.tripName,
        startDate: p.startDate,
        endDate: p.endDate,
        startLocation: p.startLocation,
        budget: p.budget,
        budgetPriority: p.budgetPriority,
        selectedThemes: p.selectedThemes,
        selectedAreas: p.selectedAreas,
        notes: p.notes,
        transport: p.transport,
        isActive: false,
        createdAt: p.createdAt,
      )).toList();

      // Tambahkan rencana yang baru di posisi pertama
      updatedPlans.insert(0, plan);

      final jsonList = updatedPlans.map((p) => p.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving trip plan: $e');
    }
  }

  /// Mengambil seluruh daftar rencana perjalanan yang tersimpan
  static Future<List<SavedTripPlan>> getAllTripPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = jsonDecode(jsonStr);
        return decoded
            .map((e) => SavedTripPlan.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading trip plans: $e');
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
}

