import 'package:flutter/material.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/core/theme/app_colors.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

class SmartTripExplorePage extends StatefulWidget {
  const SmartTripExplorePage({super.key});

  @override
  State<SmartTripExplorePage> createState() => _SmartTripExplorePageState();
}

class _SmartTripExplorePageState extends State<SmartTripExplorePage> {
  final String _apiUrl = 'http://127.0.0.1:8000/api/wisata';

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _destinations = [];

  bool _isLoading = false;
  String? _errorMessage;

  String _selectedCategory = 'Semua';
  String _selectedSort = 'Populer';

  final List<String> _categories = [
    'Semua',
    'Wisata Alam',
    'Kuliner',
    'Wisata Bahari',
    'Belanja & Oleh-oleh',
  ];

  List<Map<String, dynamic>> get _filteredDestinations {
    final query = _searchQuery.trim().toLowerCase();

    final results = _destinations.where((destination) {
      final title = (destination['title'] ?? '').toString().toLowerCase();

      final location = (destination['location'] ?? '').toString().toLowerCase();

      final tag = (destination['tag'] ?? '').toString().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          title.contains(query) ||
          location.contains(query) ||
          tag.contains(query);

      final matchesCategory =
          _selectedCategory == 'Semua' ||
          tag == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
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

          final imageUrl =
              'http://127.0.0.1:8000/storage/${linkFoto}';
          print(linkFoto);
          return {
            ...destination,
            'title': destination['nama_wisata'] ?? '',
            'tag': kategori,
            'location': destination['alamat_detail_wisata'] ?? '',
            'price': destination['harga_tiket_masuk'],
            'image': imageUrl,
            'rating': destination['rating'] ?? '-',
            'actionText': 'Lihat Detail →',
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
            _buildHeader(),
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
                  PopupMenuButton<String>(
                    initialValue: _selectedSort,
                    onSelected: (value) {
                      setState(() {
                        _selectedSort = value;
                      });
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'Populer',
                        child: Text('Paling Populer'),
                      ),
                      PopupMenuItem(
                        value: 'Rating Tertinggi',
                        child: Text('Rating Tertinggi'),
                      ),
                    ],
                    child: Row(
                      children: [
                        const ManropeFont(
                          'Urutkan: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        ManropeFont(
                          _selectedSort == 'Populer'
                              ? 'Paling Populer'
                              : 'Rating Tertinggi',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      (dest) => DestinationCard(
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.arrow_back_ios, size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              ManropeFont(
                'SmartTrip',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 6, minHeight: 6),
                ),
              ),
            ],
          ),
        ],
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
        _subFilterItem('Wisata & Kuliner', true),
        const SizedBox(width: 8),
        _subFilterItem('Kuliner & Belanja', false),
        const SizedBox(width: 8),
        _subFilterItem('Cagar Budaya', false),
      ],
    );
  }

  Widget _subFilterItem(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
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

  Widget DestinationCard({
    required Map<String, dynamic> data,
    VoidCallback? onItineraryPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    debugPrint('URL: ${data['image']}');
                    debugPrint('Error gambar: $error');

                    return const Center(
                      child: Icon(Icons.broken_image, size: 40),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      ),
                    ),
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
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ManropeFont(
                        data['location'] ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (data['price'] != null) ...[
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
                        '${data['price']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
