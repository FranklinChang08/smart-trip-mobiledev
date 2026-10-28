import 'package:flutter/material.dart';

part 'trip_plan_data.dart';

/// Model kategori minat tema wisata (Alam, Pantai, Budaya, Kuliner, dll.)
class TripThemeModel {
  final String title;
  final String desc;
  final IconData icon;

  const TripThemeModel({
    required this.title,
    required this.desc,
    required this.icon,
  });
}

/// Model wilayah kecamatan destinasi di Kota Batam
class TripAreaModel {
  final int? id;
  final String name;
  final String desc;
  final String icon;

  const TripAreaModel({
    this.id,
    required this.name,
    required this.desc,
    this.icon = '📍',
  });
}

/// Model titik awal penjemputan / kedatangan di Kota Batam
class TripLocationModel {
  final String name;
  final String type;
  final IconData icon;
  final bool isQuick;
  final String quickLabel;
  final String category;

  const TripLocationModel({
    required this.name,
    required this.type,
    required this.icon,
    required this.isQuick,
    required this.quickLabel,
    this.category = 'hotel',
  });
}

/// Model pilihan waktu kunjungan wisata harian
class TripVisitTimeModel {
  final String label;
  final String desc;

  const TripVisitTimeModel({
    required this.label,
    required this.desc,
  });
}

/// Model untuk detail setiap item destinasi/kunjungan pada itinerary
class DetailItineraryModel {
  final String id;
  final int hariKe;
  final int urutan;
  final String tipeItem;
  final String namaTempat;
  final String kategori;
  final String waktuMulai;
  final String waktuSelesai;
  final double estimasiBiaya;
  final String catatan;
  final bool isKustom;

  const DetailItineraryModel({
    required this.id,
    required this.hariKe,
    required this.urutan,
    required this.tipeItem,
    required this.namaTempat,
    required this.kategori,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.estimasiBiaya,
    this.catatan = '',
    this.isKustom = false,
  });

  Map<String, dynamic> toJson() => {
    'id_detail': id,
    'hari_ke': hariKe,
    'urutan': urutan,
    'tipe_item': tipeItem,
    'nama_tempat': namaTempat,
    'kategori': kategori,
    'waktu_mulai': waktuMulai,
    'waktu_selesai': waktuSelesai,
    'estimasi_biaya': estimasiBiaya,
    'catatan': catatan,
    'is_kustom': isKustom,
  };

  factory DetailItineraryModel.fromJson(Map<String, dynamic> json) {
    return DetailItineraryModel(
      id: json['id_detail']?.toString() ?? json['id']?.toString() ?? '',
      hariKe: int.tryParse(json['hari_ke']?.toString() ?? '1') ?? 1,
      urutan: int.tryParse(json['urutan']?.toString() ?? '1') ?? 1,
      tipeItem: json['tipe_item']?.toString() ?? 'wisata',
      namaTempat: json['nama_tempat']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? 'Wisata',
      waktuMulai: json['waktu_mulai']?.toString() ?? '09:00',
      waktuSelesai: json['waktu_selesai']?.toString() ?? '11:00',
      estimasiBiaya:
          double.tryParse(json['estimasi_biaya']?.toString() ?? '0') ?? 0.0,
      catatan: json['catatan']?.toString() ?? '',
      isKustom: json['is_kustom'] == true || json['is_kustom'] == 1,
    );
  }

  DetailItineraryModel copyWith({
    String? id,
    int? hariKe,
    int? urutan,
    String? tipeItem,
    String? namaTempat,
    String? kategori,
    String? waktuMulai,
    String? waktuSelesai,
    double? estimasiBiaya,
    String? catatan,
    bool? isKustom,
  }) {
    return DetailItineraryModel(
      id: id ?? this.id,
      hariKe: hariKe ?? this.hariKe,
      urutan: urutan ?? this.urutan,
      tipeItem: tipeItem ?? this.tipeItem,
      namaTempat: namaTempat ?? this.namaTempat,
      kategori: kategori ?? this.kategori,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      waktuSelesai: waktuSelesai ?? this.waktuSelesai,
      estimasiBiaya: estimasiBiaya ?? this.estimasiBiaya,
      catatan: catatan ?? this.catatan,
      isKustom: isKustom ?? this.isKustom,
    );
  }
}

// ============================================================================
// 3. MODEL UTAMA RENCANA PERJALANAN (SavedTripPlan)
// ============================================================================

/// Model lengkap rencana perjalanan pengguna yang terintegrasi dengan backend
/// (tabel `rencana_perjalanan` & `preferensi_perjalanan`) dan penyimpanan lokal.
class SavedTripPlan {
  final String id;
  final String tripName;
  final DateTime startDate;
  final DateTime endDate;
  final String startLocation;
  final String budget;
  final List<String> selectedThemes;
  final List<String> selectedAreas;
  final bool isHalal;
  final bool isSeafood;
  final String notes;
  final bool isActive;
  final DateTime createdAt;
  final List<DetailItineraryModel> details;

  SavedTripPlan({
    required this.id,
    required this.tripName,
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    required this.budget,
    required this.selectedThemes,
    required this.selectedAreas,
    this.isHalal = false,
    this.isSeafood = false,
    this.notes = '',
    this.isActive = true,
    this.details = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // --- Getters Durasi & Rute ---
  int get totalDays {
    final diff = endDate.difference(startDate).inDays;
    return diff >= 0 ? diff + 1 : 1;
  }

  int get totalNights => totalDays > 1 ? totalDays - 1 : 0;
  String get durationLabel => '$totalDays Hari $totalNights Malam';

  String get routeLabel {
    if (selectedAreas.isEmpty) return 'Batam Center → Nagoya → Nongsa';
    return selectedAreas.join(' → ');
  }

  // --- Serialization ---
  Map<String, dynamic> toJson() => {
    'id': id,
    'tripName': tripName,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'startLocation': startLocation,
    'budget': budget,
    'selectedThemes': selectedThemes,
    'selectedAreas': selectedAreas,
    'is_halal': isHalal,
    'is_seafood': isSeafood,
    'notes': notes,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'detail_itineraries': details.map((d) => d.toJson()).toList(),
  };

  factory SavedTripPlan.fromJson(Map<String, dynamic> json) {
    final preferensi = json['preferensi'] as Map<String, dynamic>?;

    final start = _parseDate(
      json['hari_start'] ?? json['tanggal_mulai'] ?? json['startDate'],
      fallback: DateTime.now(),
    );

    final end = _parseDate(
      json['hari_end'] ?? json['tanggal_selesai'] ?? json['endDate'],
      fallback: start.add(const Duration(days: 2)),
    );

    final rawBudget = json['budget_trip'] ??
        json['total_anggaran'] ??
        json['maks_budget_trip'] ??
        json['budget'] ??
        '5.000.000';

    return SavedTripPlan(
      id: json['id_rencana']?.toString() ?? json['id']?.toString() ?? '',
      tripName: json['nama_rencana']?.toString() ??
          json['tripName']?.toString() ??
          'Liburan Akhir Pekan di Batam',
      startDate: start,
      endDate: end,
      startLocation: json['titik_awal']?.toString() ??
          json['startLocation']?.toString() ??
          'Pelabuhan Ferry Batam Center',
      budget: _formatBudgetString(rawBudget.toString()),
      selectedThemes: _extractThemes(json, preferensi),
      selectedAreas: _extractAreas(json, preferensi),
      isHalal: _extractIsHalal(json, preferensi),
      isSeafood: _extractIsSeafood(json, preferensi),
      notes: json['catatan']?.toString() ?? json['notes']?.toString() ?? '',
      isActive: _extractIsActive(json),
      details: _extractDetails(json),
      createdAt: _parseDate(
        json['created_at'] ?? json['createdAt'],
        fallback: DateTime.now(),
      ),
    );
  }

  // --- Helper Parser (Menjaga kode bersih & modular) ---
  static DateTime _parseDate(dynamic value, {required DateTime fallback}) {
    if (value == null) return fallback;
    return DateTime.tryParse(value.toString()) ?? fallback;
  }

  static String _formatBudgetString(String raw) {
    if (double.tryParse(raw) != null) {
      final number = double.parse(raw).toInt();
      return number.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    }
    return raw;
  }

  static List<String> _extractThemes(
    Map<String, dynamic> json,
    Map<String, dynamic>? preferensi,
  ) {
    final preferensiKategoris = preferensi?['kategoris'] as List?;
    final themesFromPivot = preferensiKategoris
        ?.map((k) => k['nama_kategori']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    final themesList = (json['selectedThemes'] as List?) ??
        themesFromPivot ??
        (preferensi?['kategori_minat'] as List?) ??
        ['Pantai & Bahari', 'Kuliner & Seafood Khas'];

    return themesList.map((e) => e.toString()).toList();
  }

  static List<String> _extractAreas(
    Map<String, dynamic> json,
    Map<String, dynamic>? preferensi,
  ) {
    final areasList = (json['selectedAreas'] as List?) ??
        (preferensi?['kecamatan_pilihan'] as List?) ??
        ['Batam Kota', 'Nongsa'];

    return areasList.map((e) => e.toString()).toList();
  }

  static bool _extractIsHalal(
    Map<String, dynamic> json,
    Map<String, dynamic>? preferensi,
  ) {
    final typeFood = (json['type_food'] ?? preferensi?['type_food'])
        ?.toString()
        .toLowerCase();

    return typeFood == 'halal' ||
        (json['is_halal'] == true) ||
        (preferensi?['is_halal'] == true) ||
        (json['isHalal'] == true) ||
        (preferensi?['preferensi_kuliner'] is Map &&
            preferensi!['preferensi_kuliner']['halal'] == true);
  }

  static bool _extractIsSeafood(
    Map<String, dynamic> json,
    Map<String, dynamic>? preferensi,
  ) {
    final typeFood = (json['type_food'] ?? preferensi?['type_food'])
        ?.toString()
        .toLowerCase();

    return typeFood == 'seafood' ||
        (json['is_seafood'] == true) ||
        (preferensi?['is_seafood'] == true) ||
        (json['isSeafood'] == true) ||
        (preferensi?['preferensi_kuliner'] is Map &&
            preferensi!['preferensi_kuliner']['seafood'] == true);
  }

  static bool _extractIsActive(Map<String, dynamic> json) {
    if (json['status'] != null) {
      return json['status'] == 'aktif';
    }
    return json['isActive'] as bool? ?? false;
  }

  static List<DetailItineraryModel> _extractDetails(Map<String, dynamic> json) {
    final list = (json['detail_itineraries'] as List?) ??
        (json['details'] as List?) ??
        [];
    return list
        .map((e) => DetailItineraryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --- CopyWith & Template Default ---
  SavedTripPlan copyWith({
    String? id,
    String? tripName,
    DateTime? startDate,
    DateTime? endDate,
    String? startLocation,
    String? budget,
    List<String>? selectedThemes,
    List<String>? selectedAreas,
    bool? isHalal,
    bool? isSeafood,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    List<DetailItineraryModel>? details,
  }) {
    return SavedTripPlan(
      id: id ?? this.id,
      tripName: tripName ?? this.tripName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startLocation: startLocation ?? this.startLocation,
      budget: budget ?? this.budget,
      selectedThemes: selectedThemes ?? this.selectedThemes,
      selectedAreas: selectedAreas ?? this.selectedAreas,
      isHalal: isHalal ?? this.isHalal,
      isSeafood: isSeafood ?? this.isSeafood,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      details: details ?? this.details,
    );
  }

  factory SavedTripPlan.defaultPlan() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day + 1);
    final end = start.add(const Duration(days: 2));

    return SavedTripPlan(
      id: 'default_batam_plan',
      tripName: 'Liburan Akhir Pekan di Batam',
      startDate: start,
      endDate: end,
      startLocation: 'Pelabuhan Ferry Batam Center',
      budget: '5.000.000',
      selectedThemes: const ['Pantai & Bahari', 'Kuliner & Seafood Khas'],
      selectedAreas: const ['Batam Center', 'Barelang', 'Galang', 'Nongsa'],
      isHalal: true,
      isSeafood: true,
      notes: 'Rencana eksplorasi Batam 3 hari 2 malam',
      isActive: true,
    );
  }
}
