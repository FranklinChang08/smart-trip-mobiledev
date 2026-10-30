import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/components/search_and_filter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/pages/build_tabs/detail_destination_tabs.dart';
import 'package:frontend/services/api_service.dart';

class ExploreTabs extends StatefulWidget {
  const ExploreTabs({super.key});

  @override
  State<ExploreTabs> createState() => _ExploreTabsState();
}

class _ExploreTabsState extends State<ExploreTabs> {
  // =========================================================
  // STATE
  // =========================================================

  int _currentPage = 1;
  final int _itemsPerPage = 5;

  final String _apiUrl = ApiService.wisataUrl;
  final String _restoranApiUrl = ApiService.restoranUrl;
  final String _kategoriApiUrl = ApiService.kategoriUrl;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _destinations = [];

  bool _isLoading = false;
  String? _errorMessage;

  Set<String> _selectedCategories = {};
  String _selectedFilter = 'Semua';
  final String _selectedSort = 'Populer';

  List<String> _categories = ['Semua'];

  bool _isLoadingCategories = true;
  String? _categoryError;

  // =========================================================
  // PAGINATION
  // =========================================================

  int get _totalPages => (_filteredDestinations.length / _itemsPerPage).ceil();

  List<Map<String, dynamic>> get _paginatedDestinations {
    final destinations = _filteredDestinations;

    if (destinations.isEmpty) {
      return [];
    }

    final safePage = _currentPage.clamp(1, _totalPages);
    final startIndex = (safePage - 1) * _itemsPerPage;

    return destinations.skip(startIndex).take(_itemsPerPage).toList();
  }

  // =========================================================
  // RESPONSE HELPER
  // Mendukung response [...] dan {"data": [...]}
  // =========================================================

  List<dynamic> _extractItems(String responseBody) {
    final decoded = jsonDecode(responseBody);

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map) {
      final data = decoded['data'];

      if (data is List) {
        return data;
      }
    }

    throw const FormatException('Format response API tidak sesuai.');
  }

  List<Map<String, dynamic>> _extractRelation(dynamic raw) {
    final result = <Map<String, dynamic>>[];

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          result.add(Map<String, dynamic>.from(item));
        }
      }
    } else if (raw is Map) {
      result.add(Map<String, dynamic>.from(raw));
    }

    return result;
  }

  String _firstNonEmpty(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ?? 0;
  }

  // =========================================================
  // NORMALISASI DATA
  // Menyamakan format wisata dan restoran.
  // =========================================================

  Map<String, dynamic> _normalizeDestination(
    Map<String, dynamic> item,
    String jenis,
  ) {
    final isWisata = jenis == 'wisata';

    final categories = _extractRelation(item['kategoris']);

    final photos = _extractRelation(item['foto_destinasis']);

    final firstPhoto = photos.isNotEmpty ? photos.first : null;
    final linkFoto = firstPhoto?['link_photo'];

    String? imageUrl;

    if (linkFoto != null && linkFoto.toString().trim().isNotEmpty) {
      if (isWisata) {
        imageUrl = ApiService.fotoWisataUrl(linkFoto);
      } else {
        imageUrl = ApiService.fotoRestoranUrl(linkFoto);
      }
    }

    final title = _firstNonEmpty([
      item[isWisata ? 'nama_wisata' : 'nama_restoran'],
      item['nama'],
    ]);

    final location = _firstNonEmpty([
      item[isWisata ? 'alamat_detail_wisata' : 'alamat_detail_restoran'],
      item['alamat'],
    ]);

    final id = _firstNonEmpty([
      item[isWisata ? 'id_wisata' : 'id_restoran'],
      item['id'],
    ]);

    final categoryName = categories.isNotEmpty
        ? _firstNonEmpty([
            categories.first['nama_kategori'],
            categories.first['nama'],
          ], fallback: isWisata ? 'Wisata' : 'Restoran')
        : (isWisata ? 'Wisata' : 'Restoran');

    final rawPrice = isWisata
        ? (item['harga_tiket_masuk'] ?? item['harga_tiket'] ?? item['harga'])
        : (item['harga_makan_per_orang'] ??
            item['harga_rata_rata'] ??
            item['harga_per_orang'] ??
            item['harga']);

    return {
      // Data asli dari API tetap dipertahankan.
      ...item,

      // Field umum yang digunakan UI Explore.
      'id': id,
      'title': title,
      'location': location,
      'tag': categoryName,
      'kategoris': categories,
      'foto_destinasis': photos,
      'image': imageUrl,
      'price': rawPrice,
      'rating': _toDouble(item['rating']),
      'actionText': 'Lihat Detail →',

      // Penanda tipe untuk filter dan navigasi.
      'jenis_data': jenis,
    };
  }

  // =========================================================
  // FETCH DATA API
  // =========================================================

  Future<List<Map<String, dynamic>>> _fetchFromApi(
    String url,
    String jenis,
  ) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data $jenis '
        '(${response.statusCode}).',
      );
    }

    final items = _extractItems(response.body);

    return items
        .whereType<Map>()
        .map(
          (item) =>
              _normalizeDestination(Map<String, dynamic>.from(item), jenis),
        )
        .toList();
  }

  Future<void> _fetchDestinations() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Ambil wisata dan restoran secara bersamaan.
      final responses = await Future.wait([
        _fetchFromApi(_apiUrl, 'wisata'),
        _fetchFromApi(_restoranApiUrl, 'restoran'),
      ]);

      final wisata = responses[0];
      final restoran = responses[1];

      // Gabungkan keduanya ke dalam satu daftar.
      final destinations = [...wisata, ...restoran];

      if (!mounted) return;

      setState(() {
        _destinations = destinations;
        _currentPage = 1;
      });

      debugPrint('Jumlah wisata: ${wisata.length}');
      debugPrint('Jumlah restoran: ${restoran.length}');
      debugPrint('Total destinasi: ${destinations.length}');
    } catch (e, stackTrace) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });

      debugPrint('Error mengambil destinasi: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =========================================================
  // FETCH KATEGORI
  // =========================================================

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse(_kategoriApiUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil kategori '
          '(${response.statusCode}).',
        );
      }

      final items = _extractItems(response.body);

      final categories = items
          .whereType<Map>()
          .map((item) => (item['nama_kategori'] ?? '').toString().trim())
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

  // =========================================================
  // FILTER KATEGORI
  // =========================================================

  bool _matchesDestinationCategory(Map<String, dynamic> destination) {
    if (_selectedCategories.isEmpty) {
      return true;
    }

    final rawCategories = destination['kategoris'];
    final destinationCategories = <String>[];

    if (rawCategories is List) {
      for (final item in rawCategories) {
        if (item is Map) {
          final name = item['nama_kategori']?.toString();

          if (name != null && name.trim().isNotEmpty) {
            destinationCategories.add(name.trim().toLowerCase());
          }
        }
      }
    } else if (rawCategories is Map) {
      final name = rawCategories['nama_kategori']?.toString();

      if (name != null && name.trim().isNotEmpty) {
        destinationCategories.add(name.trim().toLowerCase());
      }
    } else if (rawCategories is String && rawCategories.trim().isNotEmpty) {
      destinationCategories.add(rawCategories.trim().toLowerCase());
    }

    return _selectedCategories.any(
      (category) =>
          destinationCategories.contains(category.trim().toLowerCase()),
    );
  }

  // =========================================================
  // SEARCH, FILTER TIPE, DAN SORTING
  // =========================================================

  List<Map<String, dynamic>> get _filteredDestinations {
    final query = _searchQuery.trim().toLowerCase();

    final results = _destinations.where((destination) {
      final title = (destination['title'] ?? '').toString().toLowerCase();

      final location = (destination['location'] ?? '').toString().toLowerCase();

      final tag = (destination['tag'] ?? '').toString().toLowerCase();

      final jenis = (destination['jenis_data'] ?? '').toString().toLowerCase();

      final categoryNames = _extractRelation(destination['kategoris'])
          .map((item) => (item['nama_kategori'] ?? '').toString().toLowerCase())
          .join(' ');

      // Search berdasarkan nama, alamat, dan seluruh kategori.
      final matchesSearch =
          query.isEmpty ||
          title.contains(query) ||
          location.contains(query) ||
          tag.contains(query) ||
          categoryNames.contains(query);

      // Filter tipe destinasi.
      final matchesFilter = switch (_selectedFilter) {
        'Wisata' => jenis == 'wisata',
        'Restoran' => jenis == 'restoran',
        'Hotel' => jenis == 'hotel',
        _ => true,
      };

      // Filter kategori yang dipilih.
      final matchesCategory = _matchesDestinationCategory(destination);

      return matchesSearch && matchesFilter && matchesCategory;
    }).toList();

    // Sorting rating tertinggi.
    if (_selectedSort == 'Rating Tertinggi') {
      results.sort((a, b) {
        final ratingA = _toDouble(a['rating']);
        final ratingB = _toDouble(b['rating']);

        return ratingB.compareTo(ratingA);
      });
    } else if (_selectedSort == 'Nama A-Z') {
      results.sort(
        (a, b) => '${a['title']}'.toLowerCase().compareTo(
          '${b['title']}'.toLowerCase(),
        ),
      );
    }

    return results;
  }

  // =========================================================
  // CONTROL CALLBACKS
  // =========================================================

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _currentPage = 1;
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _currentPage = 1;
    });
  }

  void _onCategoriesChanged(Set<String> categories) {
    setState(() {
      _selectedCategories = Set<String>.from(categories);
      _currentPage = 1;
    });
  }

  void _goToPage(int page) {
    if (_totalPages == 0) return;

    setState(() {
      _currentPage = page.clamp(1, _totalPages);
    });
  }

  // =========================================================
  // LIFECYCLE
  // =========================================================

  @override
  void initState() {
    super.initState();
    _fetchDestinations();
    _fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // MAIN UI
  // Desain utama dipertahankan.
  // =========================================================

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
                          const Text('Gagal memuat destinasi'),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
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
                    Column(
                      children: [
                        ..._paginatedDestinations.map(
                          (dest) => _buildDestinationCard(
                            context: context,
                            data: dest,
                            onItineraryPressed: () {
                              // Logika itinerary tetap di sini.
                            },
                          ),
                        ),
                        _buildPagination(),
                      ],
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

  // =========================================================
  // PAGINATION UI
  // =========================================================

  Widget _buildPagination() {
    final totalPages = _totalPages;

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          IconButton(
            tooltip: 'Halaman sebelumnya',
            onPressed: _currentPage > 1
                ? () => _goToPage(_currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          ...List.generate(totalPages, (index) {
            final page = index + 1;
            final active = page == _currentPage;

            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _goToPage(page),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  '$page',
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
          IconButton(
            tooltip: 'Halaman berikutnya',
            onPressed: _currentPage < totalPages
                ? () => _goToPage(_currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SEARCH BAR DAN FILTER
  // =========================================================

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

        CustomSearchBar(
          controller: _searchController,
          onChanged: _onSearchChanged,
          categories: _categories,
          isLoadingCategories: _isLoadingCategories,
          categoryError: _categoryError,
          onRetryCategories: _fetchCategories,
          selectedFilter: _selectedFilter,
          selectedCategories: _selectedCategories,
          onApplyFilter: _onFilterChanged,
          onApplyCategories: _onCategoriesChanged,
        ),
      ],
    );
  }

  // =========================================================
  // AI BANNER
  // Desain dipertahankan.
  // =========================================================

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
        ],
      ),
    );
  }

  // =========================================================
  // DESTINATION CARD
  // Struktur desain card dipertahankan.
  // =========================================================

  Widget _buildDestinationCard({
    required BuildContext context,
    required Map<String, dynamic> data,
    VoidCallback? onItineraryPressed,
  }) {
    final String jenis = data['jenis_data']?.toString() ?? 'wisata';

    String formatPrice(dynamic price, String jenis) {
      if (price == null || price.toString().trim().isEmpty) {
        return jenis == 'restoran' ? 'Harga belum tersedia' : 'Gratis';
      }

      final parsedPrice = double.tryParse(price.toString());

      if (parsedPrice == null) {
        return price.toString();
      }

      if (parsedPrice == 0) {
        return jenis == 'restoran' ? 'Harga belum tersedia' : 'Gratis';
      }

      final int intVal = parsedPrice.toInt();
      final formatted = intVal.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );

      if (jenis == 'restoran') {
        return 'Rp $formatted / orang';
      }

      return 'Rp $formatted';
    }

    final String priceText = formatPrice(data['price'], jenis);
    final String title = data['title']?.toString() ?? 'Tanpa nama';

    final String location = _firstNonEmpty([
      data['location'],
      data['subdistrict'],
    ], fallback: 'Kecamatan tidak diketahui');

    final String description = data['deskripsi']?.toString().trim() ?? '';

    final String? imageUrl = data['image']?.toString().trim();
    final String tag = data['tag']?.toString() ?? '';
    final String rating = data['rating']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final id = data['id']?.toString() ?? '';
            if (id.isEmpty) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailDestinationTabs(
                  wisataId: id,
                  jenis: jenis,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Gagal memuat gambar: $imageUrl');

                              return Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 42,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 42,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 65,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (tag.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ManropeFont(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: AppColors.surface,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          // Hubungkan ke fitur favorit jika tersedia.
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(9),
                          child: Icon(
                            Icons.favorite_border,
                            size: 19,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 17,
                          ),
                          const SizedBox(width: 4),
                          ManropeFont(
                            rating,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ManropeFont(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 17,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: ManropeFont(
                            location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    ManropeFont(
                      description.isNotEmpty
                          ? description
                          : 'Informasi deskripsi belum tersedia.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 15),

                    Divider(height: 1, thickness: 0.8, color: AppColors.border),

                    const SizedBox(height: 13),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.confirmation_number_outlined,
                            size: 19,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ManropeFont(
                                jenis == 'restoran'
                                    ? 'Harga rata-rata'
                                    : 'Harga tiket',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              ManropeFont(
                                priceText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: priceText == 'Gratis'
                                      ? Colors.green.shade700
                                      : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: AppColors.primary,
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
}
