import 'package:flutter/material.dart';

/// Model untuk data lokasi titik awal penjemputan / kedatangan di Batam
class TripLocationModel {
  final String name;
  final String type;
  final IconData icon;
  final bool isQuick;
  final String quickLabel;

  const TripLocationModel({
    required this.name,
    required this.type,
    required this.icon,
    required this.isQuick,
    required this.quickLabel,
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
  final String name;
  final String desc;
  final String icon;

  const TripAreaModel({
    required this.name,
    required this.desc,
    required this.icon,
  });
}

/// DATA & KONSTANTA KOTA BATAM

const List<String> kDefaultTripSuggestions = [
  'Liburan Akhir Pekan di Batam',
  'Wisata Keluarga & Santap Seafood',
  'Jelajah Pantai & Pulau Tropis',
  'Eksplorasi Belanja & Kuliner Nagoya',
];

const List<TripLocationModel> kBatamLocations = [
  TripLocationModel(
    name: 'Pelabuhan Ferry Batam Center',
    type: 'Pelabuhan Ferry Internasional',
    icon: Icons.directions_boat,
    isQuick: true,
    quickLabel: 'Batam Center',
  ),
  TripLocationModel(
    name: 'Bandara Internasional Hang Nadim (BTH)',
    type: 'Bandara Udara Domestik & Internasional',
    icon: Icons.flight_takeoff,
    isQuick: true,
    quickLabel: 'Bandara Hang Nadim',
  ),
  TripLocationModel(
    name: 'Pelabuhan Ferry Harbour Bay (Batu Ampar)',
    type: 'Pelabuhan Ferry Cepat Nagoya',
    icon: Icons.directions_boat_filled,
    isQuick: true,
    quickLabel: 'Harbour Bay',
  ),
  TripLocationModel(
    name: 'Pelabuhan Ferry Nongsa Pura',
    type: 'Kawasan Resort Bahari Nongsa',
    icon: Icons.sailing,
    isQuick: true,
    quickLabel: 'Nongsa Pura',
  ),
  TripLocationModel(
    name: 'Pelabuhan Ferry Sekupang',
    type: 'Pelabuhan Domestik & Internasional',
    icon: Icons.directions_boat_outlined,
    isQuick: false,
    quickLabel: 'Sekupang',
  ),
  TripLocationModel(
    name: 'Pelabuhan Roro Telaga Punggur',
    type: 'Penyeberangan Antar-Pulau (Bintan/Tj. Pinang)',
    icon: Icons.alt_route,
    isQuick: false,
    quickLabel: 'Telaga Punggur',
  ),
  TripLocationModel(
    name: 'Pusat Kota Nagoya / Grand Batam Mall',
    type: 'Pusat Perbelanjaan & Kawasan Hotel',
    icon: Icons.hotel,
    isQuick: false,
    quickLabel: 'Pusat Kota Nagoya',
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
    desc: 'Suasana sejuk, pantai segar, dan sarapan kopitiam khas Batam',
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

const List<TripAreaModel> kBatamAreaOptions = [
  TripAreaModel(
    name: 'Nagoya & Jodoh',
    desc: 'Pusat belanja terlengkap, Grand Batam Mall, kuliner kota & hotel',
    icon: '🏬',
  ),
  TripAreaModel(
    name: 'Batam Center',
    desc: 'Pusat pemerintahan, Museum Raja Ali Haji, Welcome to Batam & ferry',
    icon: '🏛️',
  ),
  TripAreaModel(
    name: 'Kawasan Nongsa',
    desc: 'Pantai pasir putih, resort tepi laut mewah, golf & suasana tropis',
    icon: '🏖️',
  ),
  TripAreaModel(
    name: 'Barelang & Pulau Galang',
    desc: 'Ikon 6 Jembatan Barelang, seafood kelong terapung & sejarah Camp Vietnam',
    icon: '🌉',
  ),
  TripAreaModel(
    name: 'Sekupang & Marina',
    desc: 'Taman wisata alam, bukit mata kucing, pelabuhan domestik & sunset barat',
    icon: '⛵',
  ),
];

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
