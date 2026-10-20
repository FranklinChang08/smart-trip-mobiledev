import 'package:flutter/material.dart';

/// Model untuk data lokasi titik awal penjemputan / kedatangan di Batam
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

/// Model untuk minat wisata
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

/// Model untuk pilihan waktu kunjungan
class TripVisitTimeModel {
  final String label;
  final String desc;

  const TripVisitTimeModel({
    required this.label,
    required this.desc,
  });
}

/// Model untuk area destinasi di Kota Batam
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

/// DATA & KONSTANTA KOTA BATAM

const List<String> kDefaultTripSuggestions = [
  'Liburan Akhir Pekan di Batam',
  'Wisata Keluarga & Santap Seafood',
  'Jelajah Pantai & Pulau Tropis',
  'Eksplorasi Belanja & Kuliner Nagoya',
];

/// Daftar lengkap Titik Awal (Pelabuhan, Bandara, & Hotel-Hotel Ternama di Batam)
const List<TripLocationModel> kBatamLocations = [
  // 1. Pelabuhan & Transportasi Utama
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

  // 2. Hotel & Resort Ternama di Batam 
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

  // 3. Pelabuhan Lainnya & Kawasan Sentral
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

const List<String> kBudgetPresets = [
  '1.500.000',
  '3.000.000',
  '5.000.000',
  '8.000.000',
];

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

/// 12 Kecamatan Resmi Kota Batam Sesuai Database Basis Data
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

/// Alias untuk kompatibilitas
const List<TripAreaModel> kBatamAreaOptions = kBatamKecamatanList;

const List<String> kBudgetPriorityOptions = [
  'Kuliner & Seafood Kelong',
  'Penginapan Hotel & Resort',
  'Tiket Atraksi & Wisata Bahari',
  'Belanja & Oleh-Oleh Khas',
];

/// Helper format bulan Bahasa Indonesia
String formatMonth(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return months[month - 1];
}

String formatFullMonth(int month) {
  const months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  return months[month - 1];
}

/// Model untuk detail setiap item kunjungan itinerary dari database
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
}

/// Model data rencana perjalanan yang disimpan pengguna
class SavedTripPlan {
  final String id;
  final String tripName;
  final DateTime startDate;
  final DateTime endDate;
  final String startLocation;
  final String budget;
  final String budgetPriority;
  final List<String> selectedThemes;
  final List<String> selectedAreas;
  final String notes;
  final String transport;
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
    required this.budgetPriority,
    required this.selectedThemes,
    required this.selectedAreas,
    this.notes = '',
    this.transport = 'Mobil Sewa + Driver Lokal',
    this.isActive = true,
    this.details = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'tripName': tripName,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'startLocation': startLocation,
    'budget': budget,
    'budgetPriority': budgetPriority,
    'selectedThemes': selectedThemes,
    'selectedAreas': selectedAreas,
    'notes': notes,
    'transport': transport,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'detail_itineraries': details.map((d) => d.toJson()).toList(),
  };

  factory SavedTripPlan.fromJson(Map<String, dynamic> json) {
    final preferensi = json['preferensi'] as Map<String, dynamic>?;

    final id = json['id_rencana']?.toString() ?? json['id']?.toString() ?? '';
    final name = json['nama_rencana']?.toString() ??
        json['tripName']?.toString() ??
        'Liburan Akhir Pekan di Batam';

    final start = DateTime.tryParse(
          json['tanggal_mulai']?.toString() ?? json['startDate']?.toString() ?? '',
        ) ??
        DateTime.now();
    final end = DateTime.tryParse(
          json['tanggal_selesai']?.toString() ?? json['endDate']?.toString() ?? '',
        ) ??
        DateTime.now().add(const Duration(days: 2));

    final location = json['titik_awal']?.toString() ??
        json['startLocation']?.toString() ??
        'Pelabuhan Ferry Batam Center';

    String budgetVal = json['total_anggaran']?.toString() ??
        json['budget']?.toString() ??
        '5.000.000';
    if (double.tryParse(budgetVal) != null) {
      final num = double.parse(budgetVal).toInt();
      budgetVal = num.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    }

    final priority = json['prioritas_anggaran']?.toString() ??
        json['budgetPriority']?.toString() ??
        'Kuliner & Seafood Kelong';

    final themesList = (json['selectedThemes'] as List?) ??
        (preferensi?['kategori_minat'] as List?) ??
        ['Pantai & Bahari', 'Kuliner & Seafood Khas'];

    final areasList = (json['selectedAreas'] as List?) ??
        (preferensi?['kecamatan_pilihan'] as List?) ??
        ['Batam Kota', 'Nongsa'];

    final transportVal = json['transportasi']?.toString() ??
        json['transport']?.toString() ??
        'Mobil Sewa + Driver Lokal';

    final detailList = (json['detail_itineraries'] as List?) ??
        (json['details'] as List?) ??
        [];
    final parsedDetails = detailList
        .map((e) => DetailItineraryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return SavedTripPlan(
      id: id,
      tripName: name,
      startDate: start,
      endDate: end,
      startLocation: location,
      budget: budgetVal,
      budgetPriority: priority,
      selectedThemes: themesList.map((e) => e.toString()).toList(),
      selectedAreas: areasList.map((e) => e.toString()).toList(),
      notes: json['catatan']?.toString() ?? json['notes']?.toString() ?? '',
      transport: transportVal,
      isActive: json['status'] != null
          ? json['status'] == 'aktif'
          : (json['isActive'] as bool? ?? false),
      details: parsedDetails,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  /// Default / Template rencana perjalanan awal jika belum ada yang disimpan
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
      budgetPriority: 'Kuliner & Seafood Kelong',
      selectedThemes: const ['Pantai & Bahari', 'Kuliner & Seafood Khas'],
      selectedAreas: const ['Batam Center', 'Barelang', 'Galang', 'Nongsa'],
      notes: 'Rencana eksplorasi Batam 3 hari 2 malam',
      transport: 'Mobil Sewa + Driver Lokal',
      isActive: true,
    );
  }
}


