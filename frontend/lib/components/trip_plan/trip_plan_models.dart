import 'package:flutter/material.dart';

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

/// Saran judul rencana perjalanan default
const List<String> kDefaultTripSuggestions = [
  'Liburan Akhir Pekan di Batam',
  'Wisata Keluarga & Santap Seafood',
  'Jelajah Pantai & Pulau Tropis',
  'Eksplorasi Belanja & Kuliner Nagoya',
];

/// Preset pilihan anggaran (Rp)
const List<String> kBudgetPresets = [
  '1.500.000',
  '3.000.000',
  '5.000.000',
  '8.000.000',
];

/// Titik awal keberangkatan/penjemputan di Batam (Pelabuhan, Bandara, Hotel)
const List<TripLocationModel> kBatamLocations = [
  TripLocationModel(
    name: 'Pelabuhan Ferry Batam Center',
    type: 'Pelabuhan Ferry Internasional • Batam Kota',
    icon: Icons.directions_boat,
    isQuick: true,
    quickLabel: 'Batam Center',
    category: 'pelabuhan',
  ),
  TripLocationModel(
    name: 'Bandara Internasional Hang Nadim (BTH)',
    type: 'Bandara Udara Domestik & Internasional • Nongsa',
    icon: Icons.flight_takeoff,
    isQuick: true,
    quickLabel: 'Bandara Hang Nadim',
    category: 'bandara',
  ),
  TripLocationModel(
    name: 'Pelabuhan Ferry Harbour Bay',
    type: 'Pelabuhan Ferry Cepat & Kawasan Kuliner • Batu Ampar',
    icon: Icons.directions_boat_filled,
    isQuick: true,
    quickLabel: 'Harbour Bay',
    category: 'pelabuhan',
  ),
  TripLocationModel(
    name: 'Aston Nagoya City Hotel',
    type: 'Hotel Bintang 4 • Komplek Thamrin City, Nagoya',
    icon: Icons.hotel,
    isQuick: true,
    quickLabel: 'Hotel Aston',
    category: 'hotel',
  ),
  TripLocationModel(
    name: 'Harris Resort Barelang Batam',
    type: 'Resort Bahari Tepi Laut Bintang 4 • Jembatan 1 Barelang',
    icon: Icons.beach_access,
    isQuick: true,
    quickLabel: 'Harris Barelang',
    category: 'hotel',
  ),
  TripLocationModel(
    name: 'Montigo Resorts Nongsa',
    type: 'Resort Villa Mewah Bintang 5 • Kawasan Nongsa',
    icon: Icons.villa_outlined,
    isQuick: false,
    quickLabel: 'Montigo Resorts',
    category: 'hotel',
  ),
  TripLocationModel(
    name: 'Radisson Golf & Convention Center',
    type: 'Hotel Bintang 5 & Padang Golf • Sukajadi, Batam Kota',
    icon: Icons.apartment,
    isQuick: false,
    quickLabel: 'Radisson Batam',
    category: 'hotel',
  ),
  TripLocationModel(
    name: 'Batam Marriott Hotel Harbour Bay',
    type: 'Hotel Mewah Bintang 5 Tepi Laut • Harbour Bay',
    icon: Icons.hotel,
    isQuick: false,
    quickLabel: 'Marriott Harbour Bay',
    category: 'hotel',
  ),
  TripLocationModel(
    name: 'Swiss-Belhotel Harbour Bay',
    type: 'Hotel Bisnis & Wisata Bintang 4 • Batu Ampar',
    icon: Icons.hotel,
    isQuick: false,
    quickLabel: 'Swiss-Belhotel',
    category: 'hotel',
  ),
  TripLocationModel(
    name: 'Best Western Premier Panbil',
    type: 'Hotel Bintang 4 Kawasan Industri & Alam • Mukakuning',
    icon: Icons.hotel,
    isQuick: false,
    quickLabel: 'BWP Panbil',
    category: 'hotel',
  ),
  TripLocationModel(
    name: 'Planet Holiday Hotel & Suites',
    type: 'Hotel Bintang 4 • Sei Jodoh, Batu Ampar',
    icon: Icons.hotel,
    isQuick: false,
    quickLabel: 'Planet Holiday',
    category: 'hotel',
  ),
  TripLocationModel(
    name: 'Nagoya Mansion Hotel & Residence',
    type: 'Hotel & Apartemen Terpadu • Lubuk Baja, Nagoya',
    icon: Icons.hotel,
    isQuick: false,
    quickLabel: 'Nagoya Mansion',
    category: 'hotel',
  ),
  TripLocationModel(
    name: 'Artotel Batam (Penuin)',
    type: 'Hotel Butik Seni & Gaya Hidup Modern • Lubuk Baja',
    icon: Icons.hotel,
    isQuick: false,
    quickLabel: 'Artotel Batam',
    category: 'hotel',
  ),
  TripLocationModel(
    name: 'I Hotel Baloi',
    type: 'Hotel Bintang 4 Dekat Pusat Belanja • Baloi, Nagoya',
    icon: Icons.hotel,
    isQuick: false,
    quickLabel: 'I Hotel Baloi',
    category: 'hotel',
  ),
  TripLocationModel(
    name: 'Pelabuhan Ferry Sekupang',
    type: 'Pelabuhan Domestik & Internasional • Sekupang',
    icon: Icons.directions_boat_outlined,
    isQuick: false,
    quickLabel: 'Sekupang',
    category: 'pelabuhan',
  ),
  TripLocationModel(
    name: 'Pelabuhan Ferry Nongsa Pura',
    type: 'Kawasan Resort Bahari Nongsa • Nongsa',
    icon: Icons.sailing,
    isQuick: false,
    quickLabel: 'Nongsa Pura',
    category: 'pelabuhan',
  ),
  TripLocationModel(
    name: 'Pelabuhan Roro Telaga Punggur',
    type: 'Penyeberangan Antar-Pulau Bintan/Tj. Pinang • Nongsa',
    icon: Icons.alt_route,
    isQuick: false,
    quickLabel: 'Telaga Punggur',
    category: 'pelabuhan',
  ),
  TripLocationModel(
    name: 'Pusat Kota Nagoya / Grand Batam Mall',
    type: 'Kawasan Belanja Terlengkap & Hotel • Lubuk Baja',
    icon: Icons.storefront,
    isQuick: false,
    quickLabel: 'Nagoya City',
    category: 'kota',
  ),
  TripLocationModel(
    name: 'Alun-Alun Engku Putri / Batam Center Point',
    type: 'Pusat Landmark Kota Batam & Museum • Batam Kota',
    icon: Icons.location_city,
    isQuick: false,
    quickLabel: 'Engku Putri',
    category: 'kota',
  ),
];

/// Kategori tema minat wisata Batam
const List<TripThemeModel> kTripThemes = [
  TripThemeModel(
    title: 'Wisata Alam',
    desc: 'Hutan mangrove, bukit pandang & konservasi alam',
    icon: Icons.forest_outlined,
  ),
  TripThemeModel(
    title: 'Wisata Pantai',
    desc: 'Pasir putih, pulau kecil & sunset pesisir laut',
    icon: Icons.beach_access_outlined,
  ),
  TripThemeModel(
    title: 'Wisata Sejarah',
    desc: 'Camp Vietnam, tugu sejarah & museum Kota Batam',
    icon: Icons.history_edu_outlined,
  ),
  TripThemeModel(
    title: 'Wisata Budaya',
    desc: 'Perkampungan Melayu & seni pertunjukan lokal',
    icon: Icons.theater_comedy_outlined,
  ),
  TripThemeModel(
    title: 'Wisata Religi',
    desc: 'Masjid Sultan Mahmud Riayat Syah & Vihara',
    icon: Icons.mosque_outlined,
  ),
  TripThemeModel(
    title: 'Wisata Edukasi',
    desc: 'Wisata belajar flora-fauna & kebun edukasi',
    icon: Icons.school_outlined,
  ),
  TripThemeModel(
    title: 'Wisata Rekreasi',
    desc: 'Taman bermain keluarga & wahana santai',
    icon: Icons.attractions_outlined,
  ),
  TripThemeModel(
    title: 'Wisata Belanja',
    desc: 'Kawasan belanja Nagoya & barang duty free',
    icon: Icons.shopping_bag_outlined,
  ),
];

/// Opsi slot waktu kunjungan wisata
const List<TripVisitTimeModel> kVisitTimeOptions = [
  TripVisitTimeModel(
    label: '🌅 Pagi Hari (08:00 - 12:00)',
    desc: 'Udara segar pesisir, jelajah pulau, dan spot foto tanpa terik',
  ),
  TripVisitTimeModel(
    label: '☀️ Siang Hari (12:00 - 15:00)',
    desc: 'Wisata dalam ruangan ber-AC, museum, dan belanja oleh-oleh mall',
  ),
  TripVisitTimeModel(
    label: '🌇 Sore Golden Hour (15:00 - 18:30)',
    desc: 'Sunset tepi laut, pemandangan Jembatan Barelang, suasana senja',
  ),
  TripVisitTimeModel(
    label: '🌃 Malam Hari (18:30 - 22:00)',
    desc: 'Santap seafood kelong tepi pantai dan gemerlap kota Batam',
  ),
];

/// 12 Kecamatan Resmi Kota Batam Sesuai Database
const List<TripAreaModel> kBatamKecamatanList = [
  TripAreaModel(
    id: 1,
    name: 'Batam Kota',
    desc: 'Pusat pemerintahan, Museum Raja Ali Haji, Welcome to Batam & ferry',
    icon: '🏛️',
  ),
  TripAreaModel(
    id: 8,
    name: 'Lubuk Baja',
    desc: 'Pusat belanja terlengkap Nagoya, Grand Batam Mall & sentra kuliner',
    icon: '🏬',
  ),
  TripAreaModel(
    id: 3,
    name: 'Batu Ampar',
    desc: 'Pelabuhan Ferry Harbour Bay, kawasan pesisir bisnis & hotel',
    icon: '🚢',
  ),
  TripAreaModel(
    id: 9,
    name: 'Nongsa',
    desc: 'Kawasan resort bahari mewah, pantai pasir putih & lapangan golf',
    icon: '🏖️',
  ),
  TripAreaModel(
    id: 7,
    name: 'Galang',
    desc: 'Jembatan 5-6 Barelang, situs sejarah Camp Vietnam & pantai eksotis',
    icon: '🏝️',
  ),
  TripAreaModel(
    id: 10,
    name: 'Sagulung',
    desc: 'Ikon Jembatan 1 Barelang & Masjid Agung Sultan Mahmud Riayat Syah',
    icon: '🌉',
  ),
  TripAreaModel(
    id: 12,
    name: 'Sekupang',
    desc: 'Taman Rusa, Hutan Mata Kucing, bukit senja & pelabuhan domestik',
    icon: '🌲',
  ),
  TripAreaModel(
    id: 4,
    name: 'Bengkong',
    desc: 'Pusat seafood Golden Prawn, replika kapal Cheng Ho & wahana rekreasi',
    icon: '🦐',
  ),
  TripAreaModel(
    id: 2,
    name: 'Batu Aji',
    desc: 'Pusat perdagangan grosir, kuliner lokal & sentra perumahan',
    icon: '🛍️',
  ),
  TripAreaModel(
    id: 11,
    name: 'Sei Beduk',
    desc: 'Waduk Duriangkang, kawasan industri Panbil & perbukitan hijau',
    icon: '🏞️',
  ),
  TripAreaModel(
    id: 5,
    name: 'Belakang Padang',
    desc: 'Pulau Penawar Rindu, wisata becak dayung, kuliner kopi & pesisir',
    icon: '⛵',
  ),
  TripAreaModel(
    id: 6,
    name: 'Bulang',
    desc: 'Kepulauan pesisir tradisi Melayu & ekowisata perairan mangrove',
    icon: '🛶',
  ),
];

const List<TripAreaModel> kBatamAreaOptions = kBatamKecamatanList;

/// Helper format bulan Bahasa Indonesia
String formatMonth(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  if (month < 1 || month > 12) return '';
  return months[month - 1];
}

String formatFullMonth(int month) {
  const months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  if (month < 1 || month > 12) return '';
  return months[month - 1];
}
