import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/components/font/noto_font.dart';
import 'package:frontend/pages/build_tabs/detail_destination_tabs.dart';
import 'package:frontend/services/api_service.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/components/slider_home.dart';
import 'package:frontend/core/theme/app_colors.dart';

class HomeTabs extends StatefulWidget {
  final VoidCallback onSeeAllPressed;
  const HomeTabs({super.key, required this.onSeeAllPressed});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int currentIndex = 0;
  // ==========================================
  // VARIABEL API & STATE
  // ==========================================
  bool _isLoading = true;
  List<Map<String, dynamic>> _destinations = [];
  List<Map<String, dynamic>> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  String _resolveImageUrl(dynamic linkFoto, String endpointType) {
    if (linkFoto == null || linkFoto.toString().trim().isEmpty) {
      return 'http://127.0.0.1:8000/storage/placeholder.jpg';
    }

    final String fotoStr = linkFoto.toString().trim();

    // Jika sudah berupa URL lengkap, gunakan langsung.
    if (fotoStr.startsWith('http://') || fotoStr.startsWith('https://')) {
      return fotoStr;
    }

    // Pisahkan endpoint foto wisata dan restoran.
    if (endpointType == 'wisata') {
      return ApiService.fotoWisataUrl(fotoStr);
    } else {
      return ApiService.fotoRestoranUrl(fotoStr);
    }
  }

  Future<void> _fetchHomeData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([_fetchDestinations(), _fetchRestaurants()]);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchDestinations() async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.wisataUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        final List<dynamic> items = jsonResponse is List
            ? jsonResponse
            : (jsonResponse['data'] as List<dynamic>? ?? []);

        _destinations = items.take(8).map<Map<String, dynamic>>((item) {
          final destination = Map<String, dynamic>.from(item);

          final kategoris = destination['kategoris'] as List<dynamic>? ?? [];

          final kategori = kategoris.isNotEmpty
              ? kategoris[0]['nama_kategori'] ?? 'Wisata'
              : 'Wisata';

          final fotoDestinasis =
              destination['foto_destinasis'] as List<dynamic>? ?? [];

          final linkFoto = fotoDestinasis.isNotEmpty
              ? fotoDestinasis[0]['link_photo']
              : null;

          final imageUrl = _resolveImageUrl(
            linkFoto ?? destination['image_url'],
            'wisata',
          );

          final kecamatan = destination['kecamatan'];

          return {
            ...destination,
            'id': destination['id_wisata']?.toString() ?? '',
            'title': destination['nama_wisata'] ?? 'Destinasi Wisata',
            'desc':
                destination['deskripsi_wisata'] ??
                destination['deskripsi'] ??
                '',
            'tag': kategori,
            'district': kecamatan is Map
                ? kecamatan['nama_kecamatan'] ?? ''
                : '',
            'address': destination['alamat_detail_wisata'] ?? 'Kecamatan Batam',
            'price': destination['harga_tiket_masuk'] ?? 'Gratis',
            'image': imageUrl,
            'rating': double.tryParse('${destination['rating']}') ?? 4.8,
            'total_visit': destination['total_visit'] ?? '85k+ visit',
          };
        }).toList();
      } else {
        debugPrint('Gagal mengambil wisata: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching destinations: $e');
    }
  }

  Future<void> _fetchRestaurants() async {
    try {
      final responseResto = await http.get(
        Uri.parse(ApiService.restoranUrl),
        headers: {'Accept': 'application/json'},
      );

      if (responseResto.statusCode == 200) {
        final jsonResponseResto = jsonDecode(responseResto.body);

        final List<dynamic> items = jsonResponseResto is List
            ? jsonResponseResto
            : (jsonResponseResto['data'] as List<dynamic>? ?? []);

        _restaurants = items.take(5).map<Map<String, dynamic>>((item) {
          final resto = Map<String, dynamic>.from(item);

          final fotoResto = resto['foto_destinasis'] as List<dynamic>? ?? [];

          final linkFoto = fotoResto.isNotEmpty
              ? fotoResto[0]['link_photo']
              : null;

          final imageUrl = _resolveImageUrl(
            linkFoto ?? resto['image_url'],
            'restoran',
          );

          final kecamatan = resto['kecamatan'];

          return {
            ...resto,
            'id': resto['id_restoran']?.toString() ?? '',
            'title': resto['nama_restoran'] ?? 'Restoran Pilihan',
            'location': kecamatan is Map
                ? kecamatan['nama_kecamatan'] ?? 'Kelong Apung'
                : 'Kelong Apung',
            'price': resto['harga_rata_rata'] ?? 'Rp 45.000',
            'desc': resto['deskripsi'] ?? 'Kuliner lezat khas Batam.',
            'jam': resto['jam_operasional'] ?? '10:00 - 21:00 WIB',
            'image': imageUrl,
            'jenis_data': 'restoran',
          };
        }).toList();
      } else {
        debugPrint('Gagal mengambil restoran: ${responseResto.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching restaurants: $e');

      // Fallback data dummy jika endpoint restoran gagal diakses.
      _restaurants = [
        {
          'title': 'Gonggong Rebus Piayu Laut',
          'location': 'Kelong Apung',
          'price': 'Rp 45.000',
          'desc':
              'Siput laut khas Kepri dengan sambal asam pedas jeruk kesturi.',
          'jam': '10:00 - 21:00 WIB',
          'image': _resolveImageUrl('placeholder.jpg', 'restoran'),
          'jenis_data': 'restoran',
        },
        {
          'title': 'Mie Lendir Harum Manis',
          'location': 'Sarapan Favorit',
          'price': 'Rp 18.000',
          'desc': 'Kuah kacang kental rempah ubi manis telur rebus khas Tanjungpinang.',
          'jam': '06:30 - 13:00 WIB',
          'image': _resolveImageUrl('placeholder.jpg', 'restoran'),
          'jenis_data': 'restoran',
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: Color(0xFF00685F)),
        ),
      );
    }

    // Ambil 3 teratas untuk Destinasi Populer (bisa disorting berdasarkan rating / kunjungan)
    final popularDestinations = List<Map<String, dynamic>>.from(
      _destinations,
    )..sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    final top3Popular = popularDestinations.take(3).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AutoSlider(),
            const SizedBox(height: 20),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari destinasi atau kuliner...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 8),
                    child: Icon(Icons.search_rounded, color: Color(0xFF006399)),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00685F).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFF00685F),
                        ),
                      ),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(0, 99, 153, 1),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const ManropeFont(
              'Jelajahi Batam',
              style: TextStyle(color: Color(0xFF00685F), fontSize: 16),
            ),

            // Header Destinasi
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      NotoFont(
                        'Rekomendasi Terbaik di Batam',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: widget.onSeeAllPressed,
                  child: const Row(
                    children: [
                      ManropeFont('Lihat Semua'),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ],
            ),

            // Horizontal List Destinasi dari API
            SizedBox(
              height: 350,
              child: _destinations.isEmpty
                  ? const Center(child: ManropeFont('Belum ada data destinasi'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _destinations.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final dest = _destinations[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailDestinationTabs(wisataId: dest['id']),
                              ),
                            );
                          },
                          child: _buildDestinationCard(
                            dest['title'],
                            dest['desc'],
                            dest['district'],
                            dest['price'],
                            dest['image'],
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),
            const ManropeFont(
              'Pilihan Restoran & Kuliner',
              style: TextStyle(color: AppColors.tertiary, fontSize: 16),
            ),

            // Header Kuliner/Restoran
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      NotoFont(
                        'Kuliner Ikonik Batam',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {},
                  child: const Row(
                    children: [
                      ManropeFont('Jelajah Rasa'),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ],
            ),

            // List Restoran
            Column(
              children: _restaurants.map((resto) {
                return _buildFoodCard(
                  resto['title'],
                  resto['location'],
                  resto['price'],
                  resto['desc'],
                  resto['jam'],
                  resto['image'],
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const ManropeFont(
              'PALING RAMAI DIKUNJUNGI',
              style: TextStyle(
                color: Color(0xFF006399),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const NotoFont(
              'Destinasi Terpopuler di Batam',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            // List Destinasi Populer (3 Teratas Dinamis)
            Column(
              children: List.generate(top3Popular.length, (index) {
                final dest = top3Popular[index];
                final colors = [0xFFC05400, 0xFF00685F, 0xFF006399];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailDestinationTabs(wisataId: dest['id']),
                      ),
                    );
                  },
                  child: _buildPopularDestinationCard(
                    colors[index % colors.length],
                    '#${index + 1}',
                    dest['title'],
                    dest['total_visit'],
                    dest['district'],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI HELPER CARD ---

  Widget _buildDestinationCard(
    String title,
    String desc,
    String district,
    String price,
    String image,
  ) {
    return SizedBox(
      width: 340,
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.bookmark_outline, size: 20),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ManropeFont(
                      district,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NotoFont(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ManropeFont(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Divider(thickness: 0.25),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ManropeFont(
                        'Tiket Masuk',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ManropeFont(
                        (double.tryParse(price.toString()) ?? 0) == 0
                            ? 'Gratis'
                            : "Rp $price",
                        style: const TextStyle(
                          color: Color(0xFF00685F),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(
    String title,
    String location,
    String price,
    String desc,
    String jam,
    String image,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00685F)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ManropeFont(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF00685F),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.clock,
                              size: 14,
                              color: AppColors.tertiary,
                            ),
                            const SizedBox(width: 4),
                            ManropeFont(
                              jam,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    NotoFont(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ManropeFont(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ManropeFont(
                          price,
                          style: const TextStyle(
                            color: AppColors.tertiary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const ManropeFont(
                          ' / Porsi',
                          style: TextStyle(
                            color: AppColors.tertiary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularDestinationCard(
    int color,
    String rank,
    String title,
    String totalVisit,
    String desc,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Color(color),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: ManropeFont(
                    rank,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ManropeFont(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ManropeFont(
                      desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00685F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ManropeFont(
                  totalVisit,
                  style: const TextStyle(
                    color: Color(0xFF00685F),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
