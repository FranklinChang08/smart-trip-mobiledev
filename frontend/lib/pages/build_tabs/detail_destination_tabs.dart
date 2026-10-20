import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/core/theme/app_colors.dart';

class DetailDestinationTabs extends StatefulWidget {
  final String wisataId;

  const DetailDestinationTabs({super.key, required this.wisataId});

  @override
  State<DetailDestinationTabs> createState() => _DetailDestinationTabsState();
}

class _DetailDestinationTabsState extends State<DetailDestinationTabs> {
  // ==========================================
  // KONFIGURASI URL & VARIABEL DATA (DI ATAS)
  // ==========================================
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _wisataData;

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDetailWisata();
  }

  String _resolveImageUrl(dynamic linkFoto) {
    if (linkFoto == null || linkFoto.toString().isEmpty) {
      return 'http://127.0.0.1:8000/storage/placeholder.jpg';
    }
    final String fotoStr = linkFoto.toString();
    if (fotoStr.startsWith('http://') || fotoStr.startsWith('https://')) {
      return fotoStr;
    }
    return '$_baseUrl/wisata/foto/$fotoStr';
  }

  Future<void> _fetchDetailWisata() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/wisata/${widget.wisataId}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final rawData = jsonResponse is Map && jsonResponse.containsKey('data')
            ? jsonResponse['data']
            : jsonResponse;

        if (rawData == null) {
          throw Exception('Data destinasi kosong.');
        }

        final destination = Map<String, dynamic>.from(rawData);

        final kategoris = destination['kategoris'] as List<dynamic>? ?? [];
        final kategori = kategoris.isNotEmpty
            ? kategoris[0]['nama_kategori'] ?? 'Wisata Alam'
            : 'Wisata Alam';

        final fotoDestinasis =
            destination['foto_destinasis'] as List<dynamic>? ?? [];
        final List<String> galleryImages = fotoDestinasis
            .map((foto) => _resolveImageUrl(foto['link_photo']))
            .toList();

        final mainFotoLink = fotoDestinasis.isNotEmpty
            ? fotoDestinasis[0]['link_photo']
            : null;
        final imageUrl = _resolveImageUrl(
          destination['image_url'] ?? mainFotoLink,
        );

        setState(() {
          _wisataData = {
            ...destination,
            'id': destination['id_wisata'] ?? widget.wisataId,
            'title': destination['nama_wisata'] ?? 'Destinasi Wisata',
            'subtitle': destination['subtitle'] ?? 'Landmark & Pesona Wisata',
            'tag': kategori,
            'location':
                destination['alamat_detail_wisata'] ??
                destination['alamat'] ??
                'Lokasi belum tersedia',
            'price': destination['harga_tiket_masuk'] ?? 'Gratis',
            'image': imageUrl,
            'gallery': galleryImages,
            'rating': destination['rating'] ?? '4.8',
            'review_count': destination['review_count'] ?? '1.2K+',
            'description':
                destination['deskripsi_wisata'] ??
                destination['deskripsi'] ??
                'Deskripsi belum tersedia.',
            'visit_duration': destination['visit_duration'] ?? '1.5 - 2 Jam',
            'ticket_price': destination['harga_tiket_masuk'] ?? 'Gratis (Free)',
            'parking_price': destination['harga_parkir'] ?? 'Rp 2.000 - 5.000',
            'distance': destination['distance'] ?? '14.2 km',
            'best_time':
                destination['best_time'] ?? 'Waktu Terbaik: 16.30 - 18.30 WIB',
            'main_advantages':
                destination['main_advantages'] ??
                ['Spot Foto Menarik', 'Panorama Indah', 'Akses Mudah'],
            'facilities':
                destination['facilities'] ??
                ['Area Parkir', 'Toilet Umum', 'Musholla', 'Warung Makan'],
            'reviews': destination['reviews'] ?? [],
          };
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Destinasi wisata tidak ditemukan.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data (Kode: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan jaringan atau format data. Periksa koneksi Anda.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background, body: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: 16),
              ManropeFont(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: _fetchDetailWisata,
                child: const ManropeFont(
                  'Coba Lagi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_wisataData == null) {
      return const Center(
        child: ManropeFont(
          'Data destinasi kosong.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final data = _wisataData!;
    final List gallery = data['gallery'] ?? [];
    final List mainAdvantages = data['main_advantages'] ?? [];
    final List facilities = data['facilities'] ?? [];

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Banner Gambar di Atas
              Stack(
                children: [
                  Image.network(
                    data['image'],
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 300,
                      color: AppColors.border,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  // Tombol Kembali & Aksi di atas banner
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.black45,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.black45,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.smartphone,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                backgroundColor: Colors.black45,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.share,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Container Konten Utama yang Menimpa Sedikit ke Gambar Banner
              Transform.translate(
                offset: const Offset(0, -30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card (Nama Lokasi & Judul menimpa ke atas gambar)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ManropeFont(
                                    data['tag'].toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ManropeFont(
                              data['title'].toString(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ManropeFont(
                              data['subtitle'].toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                ManropeFont(
                                  '${data['rating']} (${data['review_count']} ulasan wisatawan)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bagian Galeri Suasana (Card Terpisah)
                      if (gallery.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: _cardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const ManropeFont(
                                    'Galeri Suasana',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ManropeFont(
                                    '${gallery.length} Foto Suasana',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 90,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: gallery.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        gallery[index].toString(),
                                        width: 120,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 120,
                                          height: 90,
                                          color: AppColors.border,
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Info Ringkas Grid
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 2.4,
                            ),
                        children: [
                          _buildInfoCard(
                            Icons.access_time,
                            'Est. Waktu Kunjungan',
                            data['visit_duration'].toString(),
                          ),
                          _buildInfoCard(
                            Icons.confirmation_number_outlined,
                            'Tiket Masuk',
                            data['ticket_price'].toString(),
                          ),
                          _buildInfoCard(
                            Icons.local_parking,
                            'Biaya Parkir',
                            data['parking_price'].toString(),
                          ),
                          _buildInfoCard(
                            Icons.directions_car,
                            'Jarak Tempuh',
                            data['distance'].toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Waktu Kunjungan Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.tertiary.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.wb_sunny_outlined,
                                  color: AppColors.tertiary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const ManropeFont(
                                  'Waktu Kunjungan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.tertiary,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const ManropeFont(
                                    'Saran AI Jami',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ManropeFont(
                              data['best_time'].toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bagian Tentang Destinasi (Card Terpisah)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ManropeFont(
                              'Tentang Destinasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ManropeFont(
                              data['description'].toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            if (mainAdvantages.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const ManropeFont(
                                'KEUNGGULAN UTAMA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: mainAdvantages
                                    .map(
                                      (adv) => Chip(
                                        backgroundColor: AppColors.background,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          side: const BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        label: ManropeFont(
                                          adv.toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bagian Fasilitas & Kenyamanan (Card Terpisah)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                ManropeFont(
                                  'Fasilitas & Kenyamanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ManropeFont(
                                  'Lengkap',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                    childAspectRatio: 3.5,
                                  ),
                              itemCount: facilities.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ManropeFont(
                                          facilities[index].toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bagian Lokasi & Navigasi (Card Terpisah)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                ManropeFont(
                                  'Lokasi & Navigasi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ManropeFont(
                                  'Buka Peta Info',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.map,
                                  size: 40,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ManropeFont(
                              data['location'].toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.navigation,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    label: const ManropeFont(
                                      'Buka Peta',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.copy,
                                      size: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                    label: const ManropeFont(
                                      'Salin Alamat',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 100,
                      ), // Spasi bawah agar tidak tertutup bar aksi
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Action Bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ManropeFont(
                      'Tiket Masuk',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    ManropeFont(
                      data['price'].toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const ManropeFont(
                    '+ Tambahkan Itinerary',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper Dekorasi Card agar seragam (Berlatar putih, rounded, dan ber-shadow)
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ManropeFont(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                ManropeFont(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
