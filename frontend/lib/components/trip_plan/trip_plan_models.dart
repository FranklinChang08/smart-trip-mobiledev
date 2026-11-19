import 'package:flutter/material.dart';

// ============================================================================
// 1. MODEL DATA PENDUKUNG FORM & PREFERENSI TRIP
// ============================================================================

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

/// Model titik awal & akhir penjemputan / kedatangan di Kota Batam
class TripLocationModel {
  final String? id;
  final String name;
  final String type;
  final String? modelType;
  final IconData icon;
  final bool isQuick;
  final String quickLabel;
  final String category;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? deskripsi;
  final double? harga;
  final String? linkOnMaps;

  const TripLocationModel({
    this.id,
    required this.name,
    required this.type,
    this.modelType,
    required this.icon,
    required this.isQuick,
    required this.quickLabel,
    this.category = 'hotel',
    this.address,
    this.latitude,
    this.longitude,
    this.deskripsi,
    this.harga,
    this.linkOnMaps,
  });

  factory TripLocationModel.fromJson(Map<String, dynamic> json) {
    final cat = (json['category'] ?? 'hotel').toString().toLowerCase();
    IconData icon = Icons.location_on;
    if (cat.contains('pelabuhan')) {
      icon = Icons.directions_boat;
    } else if (cat.contains('bandara')) {
      icon = Icons.flight_takeoff;
    } else if (cat.contains('resort')) {
      icon = Icons.beach_access;
    } else if (cat.contains('hotel')) {
      icon = Icons.hotel;
    }

    return TripLocationModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      modelType: json['model_type']?.toString(),
      icon: icon,
      isQuick: json['is_quick'] == true,
      quickLabel: json['quick_label']?.toString() ?? (json['name']?.toString() ?? ''),
      category: cat,
      address: json['alamat']?.toString(),
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude']?.toString() ?? ''),
      deskripsi: json['deskripsi']?.toString(),
      harga: json['harga'] is num
          ? (json['harga'] as num).toDouble()
          : double.tryParse(json['harga']?.toString() ?? ''),
      linkOnMaps: json['link_on_maps']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'model_type': modelType,
    'category': category,
    'alamat': address,
    'latitude': latitude,
    'longitude': longitude,
    'deskripsi': deskripsi,
    'harga': harga,
    'link_on_maps': linkOnMaps,
  };
}

/// Model pilihan waktu kunjungan wisata harian
class TripVisitTimeModel {
  final String label;
  final String desc;

  const TripVisitTimeModel({required this.label, required this.desc});
}

/// Model untuk detail setiap item destinasi/kunjungan pada itinerary
class DetailItineraryModel {
  final String idItem;
  final String idHari;
  final int urutanHari;
  final int urutanItem;

  // Data dari relasi destinasi
  final String destinasiId;
  final String destinasiType;
  final String namaTempat;
  final String kategori;

  final String departureTime;
  final String arrivalTime;

  const DetailItineraryModel({
    required this.idItem,
    required this.idHari,
    required this.urutanHari,
    required this.urutanItem,
    required this.destinasiId,
    required this.destinasiType,
    required this.namaTempat,
    required this.kategori,
    required this.departureTime,
    required this.arrivalTime,
  });

  Map<String, dynamic> toJson() => {
    'id_item': idItem,
    'id_hari': idHari,
    'urutan_hari': urutanHari,
    'urutan_item': urutanItem,
    'destinasi_id': destinasiId,
    'destinasi_type': destinasiType,
    'nama_tempat': namaTempat,
    'kategori': kategori,
    'departure_time': departureTime,
    'arrival_time': arrivalTime,
  };

  factory DetailItineraryModel.fromJson(Map<String, dynamic> json) {
    // Mengambil data destinasi dari relasi Laravel
    final destinasi = json['destinasi'] is Map
        ? json['destinasi'] as Map<String, dynamic>
        : <String, dynamic>{};

    // Mengambil data hari dari relasi Laravel
    final hari = json['hari_perjalanan'] is Map
        ? json['hari_perjalanan'] as Map<String, dynamic>
        : <String, dynamic>{};

    return DetailItineraryModel(
      idItem: json['id_item']?.toString() ?? '',
      idHari: json['id_hari']?.toString() ?? '',
      urutanHari:
          int.tryParse(
            (hari['urutan_hari'] ?? json['urutan_hari'])?.toString() ?? '1',
          ) ??
          1,
      urutanItem: int.tryParse(json['urutan_item']?.toString() ?? '1') ?? 1,
      destinasiId: json['destinasi_id']?.toString() ?? '',
      destinasiType: json['destinasi_type']?.toString() ?? '',
      namaTempat:
          destinasi['nama']?.toString() ??
          json['nama_tempat']?.toString() ??
          '',
      kategori:
          destinasi['kategori']?.toString() ??
          json['kategori']?.toString() ??
          '',
      // Menangani typo pada key backend ('depature_time' / 'departure_time')
      departureTime:
          json['departure_time']?.toString() ??
          json['depature_time']?.toString() ??
          '09:00:00',
      arrivalTime: json['arrival_time']?.toString() ?? '11:00:00',
    );
  }

  DetailItineraryModel copyWith({
    String? idItem,
    String? idHari,
    int? urutanHari,
    int? urutanItem,
    String? destinasiId,
    String? destinasiType,
    String? namaTempat,
    String? kategori,
    String? departureTime,
    String? arrivalTime,
  }) {
    return DetailItineraryModel(
      idItem: idItem ?? this.idItem,
      idHari: idHari ?? this.idHari,
      urutanHari: urutanHari ?? this.urutanHari,
      urutanItem: urutanItem ?? this.urutanItem,
      destinasiId: destinasiId ?? this.destinasiId,
      destinasiType: destinasiType ?? this.destinasiType,
      namaTempat: namaTempat ?? this.namaTempat,
      kategori: kategori ?? this.kategori,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }
}

/// Model pengelompokan hari perjalanan
class HariPerjalananModel {
  final String idHari;
  final String idRencana;
  final int urutanHari;
  final DateTime? tanggal;
  final String? lokasiAwal;
  final String? lokasiAwalId;
  final String? lokasiAwalType;
  final Map<String, dynamic>? lokasiAwalLocation;
  final String? lokasiAkhir;
  final String? lokasiAkhirId;
  final String? lokasiAkhirType;
  final Map<String, dynamic>? lokasiAkhirLocation;
  final List<ItemPerjalananModel> itemPerjalanan;
  final double? backendEstimasiBiaya;

  HariPerjalananModel({
    required this.idHari,
    required this.idRencana,
    required this.urutanHari,
    this.tanggal,
    this.lokasiAwal,
    this.lokasiAwalId,
    this.lokasiAwalType,
    this.lokasiAwalLocation,
    this.lokasiAkhir,
    this.lokasiAkhirId,
    this.lokasiAkhirType,
    this.lokasiAkhirLocation,
    this.itemPerjalanan = const [],
    this.backendEstimasiBiaya,
  });

  HariPerjalananModel copyWith({
    String? idHari,
    String? idRencana,
    int? urutanHari,
    DateTime? tanggal,
    String? lokasiAwal,
    String? lokasiAwalId,
    String? lokasiAwalType,
    Map<String, dynamic>? lokasiAwalLocation,
    String? lokasiAkhir,
    String? lokasiAkhirId,
    String? lokasiAkhirType,
    Map<String, dynamic>? lokasiAkhirLocation,
    List<ItemPerjalananModel>? itemPerjalanan,
    double? backendEstimasiBiaya,
  }) {
    return HariPerjalananModel(
      idHari: idHari ?? this.idHari,
      idRencana: idRencana ?? this.idRencana,
      urutanHari: urutanHari ?? this.urutanHari,
      tanggal: tanggal ?? this.tanggal,
      lokasiAwal: lokasiAwal ?? this.lokasiAwal,
      lokasiAwalId: lokasiAwalId ?? this.lokasiAwalId,
      lokasiAwalType: lokasiAwalType ?? this.lokasiAwalType,
      lokasiAwalLocation: lokasiAwalLocation ?? this.lokasiAwalLocation,
      lokasiAkhir: lokasiAkhir ?? this.lokasiAkhir,
      lokasiAkhirId: lokasiAkhirId ?? this.lokasiAkhirId,
      lokasiAkhirType: lokasiAkhirType ?? this.lokasiAkhirType,
      lokasiAkhirLocation: lokasiAkhirLocation ?? this.lokasiAkhirLocation,
      itemPerjalanan: itemPerjalanan ?? this.itemPerjalanan,
      backendEstimasiBiaya: backendEstimasiBiaya ?? this.backendEstimasiBiaya,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_hari': idHari,
    'id_rencana': idRencana,
    'urutan_hari': urutanHari,
    'tanggal': tanggal?.toIso8601String(),
    'lokasi_awal': lokasiAwal,
    'lokasi_awal_id': lokasiAwalId,
    'lokasi_awal_type': lokasiAwalType,
    'lokasi_akhir': lokasiAkhir,
    'lokasi_akhir_id': lokasiAkhirId,
    'lokasi_akhir_type': lokasiAkhirType,
    'estimasi_biaya': estimasiBiaya,
    'item_perjalanan': itemPerjalanan.map((item) => item.toJson()).toList(),
  };
  // Total estimasi biaya seluruh item dalam satu hari
  double get estimasiBiaya {
    final itemTotal = itemPerjalanan.fold<double>(
      0.0,
      (total, item) => total + item.estimasiBiaya,
    );
    if (itemTotal > 0) return itemTotal;
    return backendEstimasiBiaya ?? 0.0;
  }

  factory HariPerjalananModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['item_perjalanan'];

    return HariPerjalananModel(
      idHari:
          (json['id_hari'] ?? json['id_hari_perjalanan'] ?? json['id'])
              ?.toString() ??
          '',
      idRencana: json['id_rencana']?.toString() ?? '',
      urutanHari:
          int.tryParse(
            (json['urutan_hari'] ?? json['hari_ke'] ?? 1).toString(),
          ) ??
          1,
      tanggal: DateTime.tryParse(json['tanggal']?.toString() ?? ''),
      lokasiAwal: json['lokasi_awal']?.toString(),
      lokasiAwalId: json['lokasi_awal_id']?.toString(),
      lokasiAwalType: json['lokasi_awal_type']?.toString(),
      lokasiAwalLocation: json['lokasi_awal_location'] is Map
          ? Map<String, dynamic>.from(json['lokasi_awal_location'])
          : (json['lokasiAwalLocation'] is Map
              ? Map<String, dynamic>.from(json['lokasiAwalLocation'])
              : null),
      lokasiAkhir: json['lokasi_akhir']?.toString(),
      lokasiAkhirId: json['lokasi_akhir_id']?.toString(),
      lokasiAkhirType: json['lokasi_akhir_type']?.toString(),
      lokasiAkhirLocation: json['lokasi_akhir_location'] is Map
          ? Map<String, dynamic>.from(json['lokasi_akhir_location'])
          : (json['lokasiAkhirLocation'] is Map
              ? Map<String, dynamic>.from(json['lokasiAkhirLocation'])
              : null),
      backendEstimasiBiaya: json['estimasi_biaya'] is num
          ? (json['estimasi_biaya'] as num).toDouble()
          : double.tryParse(json['estimasi_biaya']?.toString() ?? ''),
      itemPerjalanan: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => ItemPerjalananModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : [],
    );
  }
}

class ItemPerjalananModel {
  final String idItem;
  final String idHari;
  final String type;
  final String departureTime;
  final String arrivalTime;
  final Map<String, dynamic>? destinasi;
  final String? customDestinasiId;

  ItemPerjalananModel({
    required this.idItem,
    required this.idHari,
    required this.type,
    required this.departureTime,
    required this.arrivalTime,
    this.destinasi,
    this.customDestinasiId,
  });

  String get destinasiId {
    if (customDestinasiId != null && customDestinasiId!.isNotEmpty) {
      return customDestinasiId!;
    }
    if (destinasi != null) {
      return destinasi!['id_wisata']?.toString() ??
          destinasi!['id_restoran']?.toString() ??
          destinasi!['id_penginapan']?.toString() ??
          destinasi!['id']?.toString() ??
          '';
    }
    return '';
  }

  // Nama destinasi berdasarkan tipe destinasi
  String get destinationName {
    if (destinasi == null) return 'Destinasi tidak tersedia';

    return destinasi!['nama_wisata']?.toString() ??
        destinasi!['nama_restoran']?.toString() ??
        destinasi!['nama_penginapan']?.toString() ??
        destinasi!['nama']?.toString() ??
        'Destinasi tidak tersedia';
  }

  // Mengambil estimasi biaya berdasarkan jenis destinasi
  double get estimasiBiaya {
    if (destinasi == null) return 0;

    final rawPrice = destinasi!['harga_tiket_masuk'] ??
        destinasi!['harga_makan_per_orang'] ??
        destinasi!['harga'] ??
        (type.toLowerCase().contains('wisata')
            ? destinasi!['harga_tiket_masuk']
            : destinasi!['harga_makan_per_orang']);

    return _parsePrice(rawPrice);
  }

  // Mengubah harga menjadi angka
  static double _parsePrice(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    final str = value.toString().trim();
    if (str.isEmpty) return 0;

    // Jika format string desimal dari database seperti "25000.00" atau "25000"
    final direct = double.tryParse(str);
    if (direct != null) {
      return direct;
    }

    // Jika format string berformat mata uang teks seperti "Rp 25.000"
    final cleaned = str
        .replaceAll('Rp', '')
        .replaceAll('rp', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(cleaned) ?? 0;
  }

  Map<String, dynamic> toJson() => {
    'id_item': idItem,
    'id_hari': idHari,
    'type': type,
    'departure_time': departureTime,
    'arrival_time': arrivalTime,
    'destinasi': destinasi,
  };

  factory ItemPerjalananModel.fromJson(Map<String, dynamic> json) {
    final rawDestination = json['destinasi'];

    return ItemPerjalananModel(
      idItem:
          (json['id_item'] ?? json['id_item_perjalanan'] ?? json['id'])
              ?.toString() ??
          '',
      idHari: (json['id_hari'] ?? json['id_hari_perjalanan'])?.toString() ?? '',
      type: json['type']?.toString() ??
          json['tipe_destinasi']?.toString() ??
          (json['destinasi_type'] != null
              ? (json['destinasi_type'].toString().toLowerCase().contains('wisata')
                  ? 'wisata'
                  : 'restoran')
              : ''),
      departureTime: json['departure_time']?.toString() ?? '',
      arrivalTime: json['arrival_time']?.toString() ?? '',
      destinasi: rawDestination is Map
          ? Map<String, dynamic>.from(rawDestination)
          : null,
      customDestinasiId:
          (json['destinasi_id'] ?? json['destination_id'])?.toString(),
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
  final String? titikAwalId;
  final String? titikAwalType;
  final String endLocation;
  final String? titikAkhirId;
  final String? titikAkhirType;
  final String budget;
  final List<String> selectedThemes;
  final List<String> selectedAreas;
  final bool isHalal;
  final bool isSeafood;
  final String notes;
  final bool isActive;
  final bool isDraft;
  final DateTime createdAt;
  final Map<String, dynamic>? titikAwalLocation;
  final Map<String, dynamic>? titikAkhirLocation;

  // Relasi ke hari perjalanan
  final List<HariPerjalananModel> hariPerjalanan;

  SavedTripPlan({
    required this.id,
    required this.tripName,
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    this.titikAwalId,
    this.titikAwalType,
    String? endLocation,
    this.titikAkhirId,
    this.titikAkhirType,
    required this.budget,
    required this.selectedThemes,
    required this.selectedAreas,
    this.isHalal = false,
    this.isSeafood = false,
    this.notes = '',
    this.isActive = true,
    this.isDraft = false,
    this.titikAwalLocation,
    this.titikAkhirLocation,
    this.hariPerjalanan = const [],
    DateTime? createdAt,
  })  : endLocation = endLocation ?? startLocation,
        createdAt = createdAt ?? DateTime.now();

  int get totalDays {
    final diff = endDate.difference(startDate).inDays;
    return diff >= 0 ? diff + 1 : 1;
  }

  int get days => totalDays;

  int get totalNights => totalDays > 1 ? totalDays - 1 : 0;

  String get durationLabel => '$totalDays Hari $totalNights Malam';

  String get routeLabel {
    if (selectedAreas.isEmpty) {
      return 'Batam Center → Nagoya → Nongsa';
    }

    return selectedAreas.join(' → ');
  }

  // Total seluruh item perjalanan
  int get totalItems => hariPerjalanan.fold(
    0,
    (total, hari) => total + hari.itemPerjalanan.length,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tripName': tripName,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'startLocation': startLocation,
    'titik_awal': startLocation,
    'titik_awal_id': titikAwalId,
    'titik_awal_type': titikAwalType,
    'endLocation': endLocation,
    'titik_akhir': endLocation,
    'titik_akhir_id': titikAkhirId,
    'titik_akhir_type': titikAkhirType,
    'budget': budget,
    'selectedThemes': selectedThemes,
    'selectedAreas': selectedAreas,
    'is_halal': isHalal,
    'is_seafood': isSeafood,
    'notes': notes,
    'isActive': isActive,
    'is_draft': isDraft,
    'createdAt': createdAt.toIso8601String(),
    'hari_perjalanan': hariPerjalanan.map((hari) => hari.toJson()).toList(),
  };

  factory SavedTripPlan.fromJson(Map<String, dynamic> json) {
    final preferensi = json['preferensi'] is Map
        ? Map<String, dynamic>.from(json['preferensi'])
        : null;

    final start = _parseDate(
      json['hari_start'] ?? json['tanggal_mulai'] ?? json['startDate'],
      fallback: DateTime.now(),
    );

    final end = _parseDate(
      json['hari_end'] ?? json['tanggal_selesai'] ?? json['endDate'],
      fallback: start.add(const Duration(days: 2)),
    );

    final rawBudget =
        json['budget_trip'] ??
        json['total_anggaran'] ??
        json['maks_budget_trip'] ??
        json['budget'] ??
        '5.000.000';

    final hariList = _extractHariPerjalanan(json);

    final startLoc = json['titik_awal']?.toString() ??
        json['startLocation']?.toString() ??
        (hariList.isNotEmpty ? hariList.first.lokasiAwal : null) ??
        'Pelabuhan Ferry Batam Center';

    final endLoc = json['titik_akhir']?.toString() ??
        json['endLocation']?.toString() ??
        (hariList.isNotEmpty ? hariList.last.lokasiAkhir : null) ??
        startLoc;

    final isDraftPlan = json['status'] == 'draf' ||
        json['is_draft'] == true ||
        json['isDraft'] == true;

    return SavedTripPlan(
      id: json['id_rencana']?.toString() ?? json['id']?.toString() ?? '',
      tripName:
          json['nama_rencana']?.toString() ??
          json['tripName']?.toString() ??
          'Liburan Akhir Pekan di Batam',
      startDate: start,
      endDate: end,
      startLocation: startLoc,
      titikAwalId: json['titik_awal_id']?.toString() ??
          (hariList.isNotEmpty ? hariList.first.lokasiAwalId : null),
      titikAwalType: json['titik_awal_type']?.toString() ??
          (hariList.isNotEmpty ? hariList.first.lokasiAwalType : null),
      endLocation: endLoc,
      titikAkhirId: json['titik_akhir_id']?.toString() ??
          (hariList.isNotEmpty ? hariList.last.lokasiAkhirId : null),
      titikAkhirType: json['titik_akhir_type']?.toString() ??
          (hariList.isNotEmpty ? hariList.last.lokasiAkhirType : null),
      budget: _formatBudgetString(rawBudget.toString()),
      selectedThemes: _extractThemes(json, preferensi),
      selectedAreas: _extractAreas(json, preferensi),
      isHalal: _extractIsHalal(json, preferensi),
      isSeafood: _extractIsSeafood(json, preferensi),
      notes: json['catatan']?.toString() ?? json['notes']?.toString() ?? '',
      isActive: _extractIsActive(json),
      isDraft: isDraftPlan,
      titikAwalLocation: json['titik_awal_location'] is Map
          ? Map<String, dynamic>.from(json['titik_awal_location'])
          : (json['titikAwalLocation'] is Map
              ? Map<String, dynamic>.from(json['titikAwalLocation'])
              : (hariList.isNotEmpty ? hariList.first.lokasiAwalLocation : null)),
      titikAkhirLocation: json['titik_akhir_location'] is Map
          ? Map<String, dynamic>.from(json['titik_akhir_location'])
          : (json['titikAkhirLocation'] is Map
              ? Map<String, dynamic>.from(json['titikAkhirLocation'])
              : (hariList.isNotEmpty ? hariList.last.lokasiAkhirLocation : null)),
      hariPerjalanan: hariList,
      createdAt: _parseDate(
        json['created_at'] ?? json['createdAt'],
        fallback: DateTime.now(),
      ),
    );
  }

  static DateTime _parseDate(dynamic value, {required DateTime fallback}) {
    if (value == null) return fallback;

    return DateTime.tryParse(value.toString()) ?? fallback;
  }

  static String _formatBudgetString(String raw) {
    final number = double.tryParse(raw);

    if (number == null) return raw;

    return number.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  static List<String> _extractThemes(
    Map<String, dynamic> json,
    Map<String, dynamic>? preferensi,
  ) {
    final preferensiKategoris = preferensi?['kategoris'] as List?;

    final themesFromPivot = preferensiKategoris
        ?.whereType<Map>()
        .map((k) => k['nama_kategori']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    final themesList =
        json['selectedThemes'] as List? ??
        themesFromPivot ??
        preferensi?['kategori_minat'] as List? ??
        ['Pantai & Bahari', 'Kuliner & Seafood Khas'];

    return themesList.map((e) => e.toString()).toList();
  }

  static List<String> _extractAreas(
    Map<String, dynamic> json,
    Map<String, dynamic>? preferensi,
  ) {
    // 1. Ekstrak dari relasi tabel pivot preferensi_kecamatan
    final areasFromPivot = (preferensi?['kecamatans'] as List?)
        ?.map((k) => k['nama_kecamatan']?.toString())
        .whereType<String>()
        .toList();

    if (areasFromPivot != null && areasFromPivot.isNotEmpty) {
      return areasFromPivot;
    }

    final areasList =
        json['selectedAreas'] as List? ??
        preferensi?['kecamatan_pilihan'] as List? ??
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
        json['is_halal'] == true ||
        preferensi?['is_halal'] == true ||
        json['isHalal'] == true ||
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
        json['is_seafood'] == true ||
        preferensi?['is_seafood'] == true ||
        json['isSeafood'] == true ||
        (preferensi?['preferensi_kuliner'] is Map &&
            preferensi!['preferensi_kuliner']['seafood'] == true);
  }

  static bool _extractIsActive(Map<String, dynamic> json) {
    if (json['status'] != null) {
      return json['status'] == 'aktif';
    }

    return json['isActive'] as bool? ?? false;
  }

  static List<HariPerjalananModel> _extractHariPerjalanan(
    Map<String, dynamic> json,
  ) {
    final rawList = json['hari_perjalanan'];

    if (rawList is! List) return [];

    return rawList
        .whereType<Map>()
        .map((e) => HariPerjalananModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  SavedTripPlan copyWith({
    String? id,
    String? tripName,
    DateTime? startDate,
    DateTime? endDate,
    String? startLocation,
    String? titikAwalId,
    String? titikAwalType,
    String? endLocation,
    String? titikAkhirId,
    String? titikAkhirType,
    String? budget,
    List<String>? selectedThemes,
    List<String>? selectedAreas,
    bool? isHalal,
    bool? isSeafood,
    String? notes,
    bool? isActive,
    bool? isDraft,
    DateTime? createdAt,
    Map<String, dynamic>? titikAwalLocation,
    Map<String, dynamic>? titikAkhirLocation,
    List<HariPerjalananModel>? hariPerjalanan,
  }) {
    return SavedTripPlan(
      id: id ?? this.id,
      tripName: tripName ?? this.tripName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startLocation: startLocation ?? this.startLocation,
      titikAwalId: titikAwalId ?? this.titikAwalId,
      titikAwalType: titikAwalType ?? this.titikAwalType,
      endLocation: endLocation ?? this.endLocation,
      titikAkhirId: titikAkhirId ?? this.titikAkhirId,
      titikAkhirType: titikAkhirType ?? this.titikAkhirType,
      budget: budget ?? this.budget,
      selectedThemes: selectedThemes ?? this.selectedThemes,
      selectedAreas: selectedAreas ?? this.selectedAreas,
      isHalal: isHalal ?? this.isHalal,
      isSeafood: isSeafood ?? this.isSeafood,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      isDraft: isDraft ?? this.isDraft,
      titikAwalLocation: titikAwalLocation ?? this.titikAwalLocation,
      titikAkhirLocation: titikAkhirLocation ?? this.titikAkhirLocation,
      createdAt: createdAt ?? this.createdAt,
      hariPerjalanan: hariPerjalanan ?? this.hariPerjalanan,
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
// ============================================================================
// 4. DATA KONSTANTA & PRESET (LOKASI, TEMA, KECAMATAN)
// ============================================================================

const List<String> kDefaultTripSuggestions = [
  'Liburan Akhir Pekan di Batam',
  'Wisata Keluarga & Santap Seafood',
  'Jelajah Pantai & Pulau Tropis',
  'Eksplorasi Belanja & Kuliner Nagoya',
];

const List<String> kBudgetPresets = [
  '1.500.000',
  '3.000.000',
  '5.000.000',
  '8.000.000',
];

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
    desc:
        'Pusat seafood Golden Prawn, replika kapal Cheng Ho & wahana rekreasi',
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

// ============================================================================
// 5. HELPER FUNCTIONS FOR DATE & TIME FORMATTING
// ============================================================================

String formatMonth(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  if (month < 1 || month > 12) return '';
  return months[month - 1];
}

String formatFullMonth(int month) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  if (month < 1 || month > 12) return '';
  return months[month - 1];
}

String formatDateShort(DateTime date) {
  return '${date.day} ${formatMonth(date.month)} ${date.year}';
}

String formatDateRange(DateTime start, DateTime end) {
  if (start.year == end.year && start.month == end.month) {
    return '${start.day} - ${end.day} ${formatMonth(start.month)} ${start.year}';
  }
  return '${start.day} ${formatMonth(start.month)} - ${end.day} ${formatMonth(end.month)} ${end.year}';
}
