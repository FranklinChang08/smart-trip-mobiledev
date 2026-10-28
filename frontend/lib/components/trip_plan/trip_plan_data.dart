part of 'trip_plan_models.dart';

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
