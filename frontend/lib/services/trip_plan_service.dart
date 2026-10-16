import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';
import 'package:http/http.dart' as http;

/// Service untuk mengambil data master rencana perjalanan langsung
class TripPlanService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000/api'
        : 'http://127.0.0.1:8000/api';
  }

  /// Pemetaan icon Material yang representatif untuk kategori wisata Batam
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

  /// Pemetaan deskripsi ringkas untuk kategori wisata Batam
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
}
