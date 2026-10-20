import 'package:flutter/material.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/pages/build_tabs/detail_destination_tabs.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

class ExploreTabs extends StatefulWidget {
  const ExploreTabs({super.key});

  @override
  State<ExploreTabs> createState() => _ExploreTabsState();
}

class _ExploreTabsState extends State<ExploreTabs> {
  final String _apiUrl = 'http://127.0.0.1:8000/api/wisata';

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _destinations = [];

  bool _isLoading = false;
  String? _errorMessage;

  String _selectedCategory = 'Semua';
  String _selectedFilter = 'Semua';
  String _selectedSort = 'Populer';
  // URL API kategori
  final String _kategoriApiUrl = 'http://127.0.0.1:8000/api/kategori-list';

  // Kategori diambil dari API
  List<String> _categories = ['Semua'];

  bool _isLoadingCategories = true;
  String? _categoryError;

  List<Map<String, dynamic>> get _filteredDestinations {
    final query = _searchQuery.trim().toLowerCase();

    final results = _destinations.where((destination) {
      final title = (destination['title'] ?? '').toString().toLowerCase();

      final location = (destination['location'] ?? '').toString().toLowerCase();

      final tag = (destination['tag'] ?? '').toString().toLowerCase();

      final jenis = (destination['jenis_data'] ?? '').toString().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          title.contains(query) ||
          location.contains(query) ||
          tag.contains(query);

      final matchesFilter = switch (_selectedFilter) {
        'Wisata' => jenis == 'wisata',
        'Restoran' => jenis == 'restoran',
        'Hotel' => jenis == 'hotel',
        _ => true,
      };

      final matchesCategory =
          _selectedCategory == 'Semua' ||
          tag == _selectedCategory.toLowerCase();

      return matchesSearch && matchesFilter && matchesCategory;
    }).toList();

    if (_selectedSort == 'Rating Tertinggi') {
      results.sort((a, b) {
        final ratingA = double.tryParse('${a['rating']}') ?? 0;
        final ratingB = double.tryParse('${b['rating']}') ?? 0;

        return ratingB.compareTo(ratingA);
      });
    }

    return results;
  }

  @override
  void initState() {
    super.initState();
    _fetchDestinations();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse(_kategoriApiUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil kategori: ${response.statusCode}');
      }

      final Map<String, dynamic> result =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> data = result['data'] as List<dynamic>;

      final List<String> categories = data
          .map((item) {
            final category = item as Map<String, dynamic>;
            return category['nama_kategori']?.toString() ?? '';
          })
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();

      if (!mounted) return;

      setState(() {
        _categories = ['Semua', ...categories];
        _isLoadingCategories = false;
        _categoryError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingCategories = false;
        _categoryError = e.toString();
      });

      debugPrint('Error mengambil kategori: $e');
    }
  }

  Future<void> _fetchDestinations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Mendukung respons berbentuk: [...] atau {"data": [...]}
        final List<dynamic> items = jsonResponse is List
            ? jsonResponse
            : (jsonResponse['data'] as List<dynamic>? ?? []);

        final destinations = items.map<Map<String, dynamic>>((item) {
          final destination = Map<String, dynamic>.from(item);

          // Mengambil kategori pertama dari relasi kategoris
          final kategoris = destination['kategoris'] as List<dynamic>? ?? [];
          final kategori = kategoris.isNotEmpty
              ? kategoris[0]['nama_kategori'] ?? 'Wisata'
              : 'Wisata';

          // Mengambil foto pertama dari relasi foto_destinasis
          final fotoDestinasis =
              destination['foto_destinasis'] as List<dynamic>? ?? [];

          final linkFoto = fotoDestinasis.isNotEmpty
              ? fotoDestinasis[0]['link_photo']
              : null;

          final imageUrl = 'http://127.0.0.1:8000/api/wisata/foto/$linkFoto';
          return {
            ...destination,
            'id': destination['id_wisata'] ?? '',
            'title': destination['nama_wisata'] ?? '',
            'tag': kategori,
            'location': destination['alamat_detail_wisata'] ?? '',
            'price': destination['harga_tiket_masuk'],
            'image': imageUrl,
            'rating': destination['rating'] ?? '-',
            'actionText': 'Lihat Detail →',

            'jenis_data': 'wisata',
          };
        }).toList();

        // Lanjutkan proses penggunaan destinations seperti kode kamu sebelumnya.

        if (!mounted) return;

        setState(() {
          _destinations = destinations;
        });
      } else {
        throw Exception('Gagal mengambil data wisata (${response.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildCategoryChips(),
                  const SizedBox(height: 12),
                  _buildSubFilters(),
                  const SizedBox(height: 12),

                  // Memanggil komponen DestinationCard yang di-import terpisah
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Gagal memuat destinasi',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _fetchDestinations,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    )
                  else if (_filteredDestinations.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Destinasi tidak ditemukan.'),
                      ),
                    )
                  else
                    ..._filteredDestinations.map(
                      (dest) => _buildDestinationCard(
                        context: context,
                        data: dest,
                        onItineraryPressed: () {
                          // Tambahkan logika itinerary di sini.
                        },
                      ),
                    ),

                  const SizedBox(height: 16),
                  _buildAiPlannerBanner(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.location_on, size: 14, color: AppColors.primary),
            SizedBox(width: 4),
            ManropeFont(
              'Eksplor Jembatan Barelang',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            SizedBox(width: 8),
            ManropeFont(
              '•',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            SizedBox(width: 8),
            ManropeFont(
              'Masjid 3 Sanctuary',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Spacer(),
          ],
        ),
        const SizedBox(height: 8),
        const ManropeFont(
          'Eksplorasi Batam',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const ManropeFont(
          'Temukan pesona bahari, kuliner khas lezat, dan destinasi religi premium.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari destinasi, kuliner, aktivitas...',
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          suffixIcon: _searchQuery.trim().isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.tune, color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    if (_isLoadingCategories) {
      return const SizedBox(
        height: 36,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_categoryError != null) {
      return SizedBox(
        height: 36,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: _fetchCategories,
            child: const Text('Gagal memuat kategori. Coba lagi'),
          ),
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: ManropeFont(
                category,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppColors.border,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubFilters() {
    return Row(
      children: [
        _subFilterItem('Semua', _selectedFilter == 'Semua'),
        const SizedBox(width: 8),
        _subFilterItem('Wisata', _selectedFilter == 'Wisata'),
        const SizedBox(width: 8),
        _subFilterItem('Restoran', _selectedFilter == 'Restoran'),
        const SizedBox(width: 8),
        _subFilterItem('Hotel', _selectedFilter == 'Hotel'),
      ],
    );
  }

  Widget _subFilterItem(String label, bool active) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: ManropeFont(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? AppColors.primary : AppColors.textSecondary,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAiPlannerBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              SizedBox(width: 6),
              ManropeFont(
                'AI SmartTrip Generator',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          SizedBox(height: 8),
          ManropeFont(
            'Bingung memilih destinasi?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          ManropeFont(
            'Buat itinerary otomatis dalam hitungan detik berdasarkan preferensi, durasi liburan, dan budget perjalananmu.',
            style: TextStyle(fontSize: 11, color: Colors.white70),
          ),
          SizedBox(height: 12),
          // ... tombol banner dll
        ],
      ),
    );
  }

  Widget _buildDestinationCard({
    required BuildContext context,
    required Map<String, dynamic> data,
    VoidCallback? onItineraryPressed,
  }) {
    // Helper untuk memformat harga
    String formatPrice(dynamic price) {
      if (price == null) return '';
      final parsedPrice = double.tryParse(price.toString());
      if (parsedPrice == null || parsedPrice == 0) {
        return 'Gratis';
      }
      return 'Rp $price';
    }

    final String priceText = formatPrice(data['price']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigasi ke Halaman Detail (Placeholder)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DetailDestinationTabs(wisataId: data['id']),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Gambar & Tag / Favorite ---
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      data['image'] ?? '',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('URL Error: ${data['image']}');
                        return Container(
                          height: 160,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if ((data['tag'] ?? '').isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ManropeFont(
                          data['tag'] ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              // --- Detail Konten ---
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul & Rating
                    Row(
                      children: [
                        Expanded(
                          child: ManropeFont(
                            data['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        ManropeFont(
                          '${data['rating'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Lokasi Kecamatan (Dipersingkat) & Harga Tiket
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: ManropeFont(
                            data['location'] ??
                                data['subdistrict'] ??
                                'Kecamatan tidak diketahui',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, // Memotong teks dengan titik-titik (...)
                          ),
                        ),
                        if (priceText.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const ManropeFont(
                            '•',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ManropeFont(
                            priceText,
                            style: TextStyle(
                              fontSize: 11,
                              color: priceText == 'Gratis'
                                  ? Colors.green
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Deskripsi Singkat Destinasi
                    if ((data['description'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ManropeFont(
                        data['description'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
