import 'package:flutter/material.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';
import 'package:frontend/services/trip_plan_service.dart';

class TripLocationModal {
  /// Menampilkan dialog pemilihan lokasi dengan fitur pencarian real-time,
  /// filter kategori (Semua, Hotel, Pelabuhan, Bandara), dan tombol lihat detail.
  static void showLocationDialog({
    required BuildContext context,
    required List<TripLocationModel> availableLocations,
    required String currentSelectedName,
    bool isEndLocation = false,
    required ValueChanged<TripLocationModel> onLocationSelected,
    ValueChanged<TripLocationModel>? onShowDetail,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String searchQuery = '';
        String selectedCategory = 'all';
        final searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Filter lokasi berdasarkan kategori dan kata kunci pencarian
            List<TripLocationModel> filtered = availableLocations.where((loc) {
              final matchesCategory =
                  selectedCategory == 'all' || loc.category == selectedCategory;
              final query = searchQuery.trim().toLowerCase();
              final matchesQuery = query.isEmpty ||
                  loc.name.toLowerCase().contains(query) ||
                  loc.type.toLowerCase().contains(query) ||
                  loc.quickLabel.toLowerCase().contains(query);
              return matchesCategory && matchesQuery;
            }).toList();

            // Urutkan lokasi (lokasi yang sedang aktif ditaruh di atas)
            filtered.sort((a, b) {
              if (a.name == currentSelectedName) return -1;
              if (b.name == currentSelectedName) return 1;
              return 0;
            });

            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Handle Penarik
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Modal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isEndLocation
                                ? Icons.flag_outlined
                                : Icons.location_on_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEndLocation
                                    ? 'Pilih Titik Akhir / Kepulangan'
                                    : 'Pilih Titik Awal Perjalanan',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEndLocation
                                    ? 'Titik kepulangan akhir (pelabuhan, bandara, atau hotel)'
                                    : 'Mulai dari pelabuhan, bandara, atau hotel tempat menginap',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Kolom Pencarian Cepat
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Cari hotel, pelabuhan, bandara (mis: Aston)...',
                        hintStyle: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  searchController.clear();
                                  setModalState(() {
                                    searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Filter Kategori Pill Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildFilterCategoryPill(
                            label: 'Semua',
                            isSelected: selectedCategory == 'all',
                            onTap: () =>
                                setModalState(() => selectedCategory = 'all'),
                          ),
                          const SizedBox(width: 6),
                          _buildFilterCategoryPill(
                            label: '🏨 Hotel & Resort',
                            isSelected: selectedCategory == 'hotel',
                            onTap: () =>
                                setModalState(() => selectedCategory = 'hotel'),
                          ),
                          const SizedBox(width: 6),
                          _buildFilterCategoryPill(
                            label: '🚢 Pelabuhan Ferry',
                            isSelected: selectedCategory == 'pelabuhan',
                            onTap: () => setModalState(
                              () => selectedCategory = 'pelabuhan',
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildFilterCategoryPill(
                            label: '✈️ Bandara',
                            isSelected: selectedCategory == 'bandara',
                            onTap: () => setModalState(
                              () => selectedCategory = 'bandara',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),

                  // Daftar Lokasi
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tidak ditemukan lokasi "$searchQuery"',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Coba gunakan kata kunci lain seperti nama hotel atau pelabuhan.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            itemCount: filtered.length,
                            separatorBuilder: (context, i) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final loc = filtered[i];
                              final isSelected = currentSelectedName == loc.name;

                              return InkWell(
                                onTap: () {
                                  onLocationSelected(loc);
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(
                                            alpha: 0.07,
                                          )
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : const Color(0xFFE2E8F0),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(9),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          loc.icon,
                                          size: 18,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (isSelected)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 3,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isEndLocation
                                                      ? '🏁 TITIK AKHIR TERPILIH'
                                                      : '📍 TITIK AWAL TERPILIH',
                                                  style: const TextStyle(
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            Text(
                                              loc.name,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              loc.type,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.info_outline,
                                          size: 20,
                                          color: AppColors.textSecondary,
                                        ),
                                        tooltip: 'Lihat Detail Lokasi',
                                        onPressed: () {
                                          if (onShowDetail != null) {
                                            onShowDetail(loc);
                                          } else {
                                            showLocationDetail(
                                              context: context,
                                              location: loc,
                                            );
                                          }
                                        },
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                          size: 22,
                                        )
                                      else
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey.shade400,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Menampilkan detail lengkap titik lokasi dari database berdasarkan ID
  static Future<void> showLocationDetailById({
    required BuildContext context,
    required String locationId,
    String? fallbackName,
  }) async {
    final detail = await TripPlanService.fetchLocationDetail(locationId);
    if (!context.mounted) return;
    if (detail != null) {
      final model = TripLocationModel.fromJson(detail);
      showLocationDetail(context: context, location: model);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fallbackName != null && fallbackName.isNotEmpty
                ? 'Detail informasi untuk "$fallbackName" belum tersedia.'
                : 'Detail informasi lokasi belum tersedia.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Menampilkan detail lengkap titik lokasi dari database
  static void showLocationDetail({
    required BuildContext context,
    required TripLocationModel location,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(location.icon, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ManropeFont(
                          location.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            location.type,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              if (location.address != null && location.address!.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 17, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location.address!,
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textPrimary,
                            height: 1.35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (location.deskripsi != null && location.deskripsi!.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description_outlined,
                        size: 17, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location.deskripsi!,
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black87,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (location.harga != null && location.harga! > 0) ...[
                Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        size: 17, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Mulai Rp ${location.harga!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} / malam',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Tutup Detail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildFilterCategoryPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// KOMPONEN CONTAINER 1: PILIHAN LOKASI AWAL DAN AKHIR
/// ============================================================================

class TripLocationSection extends StatelessWidget {
  final String selectedStartLocation;
  final String? selectedEndLocation;
  final TripLocationModel? selectedStartLocationModel;
  final TripLocationModel? selectedEndLocationModel;
  final List<TripLocationModel> availableLocations;
  final ValueChanged<TripLocationModel> onSelectStartLocation;
  final ValueChanged<TripLocationModel>? onSelectEndLocation;
  final ValueChanged<TripLocationModel>? onShowLocationDetail;
  final bool isRequired;
  final bool showEndLocation;

  const TripLocationSection({
    super.key,
    required this.selectedStartLocation,
    this.selectedEndLocation,
    this.selectedStartLocationModel,
    this.selectedEndLocationModel,
    this.availableLocations = kBatamLocations,
    required this.onSelectStartLocation,
    this.onSelectEndLocation,
    this.onShowLocationDetail,
    this.isRequired = true,
    this.showEndLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Seksi Container 1
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    showEndLocation
                        ? Icons.alt_route_rounded
                        : Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ManropeFont(
                      showEndLocation
                          ? 'Pilihan Lokasi Awal & Akhir'
                          : 'Lokasi Awal & Titik Kumpul',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      showEndLocation
                          ? 'Titik penjemputan awal & kepulangan dari database'
                          : 'Pilih titik penjemputan awal di Kota Batam',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isRequired)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Wajib',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // 1. Lokasi Awal
          _buildLocationPickerBox(
            context: context,
            isEndLocation: false,
            badgeTitle: 'LOKASI AWAL (KEDATANGAN / PENJEMPUTAN)',
            selectedName: selectedStartLocation,
            selectedModel: selectedStartLocationModel,
            onTap: () {
              TripLocationModal.showLocationDialog(
                context: context,
                availableLocations: availableLocations,
                currentSelectedName: selectedStartLocation,
                isEndLocation: false,
                onLocationSelected: onSelectStartLocation,
                onShowDetail: onShowLocationDetail,
              );
            },
            onQuickSelect: (loc) => onSelectStartLocation(loc),
          ),

          if (showEndLocation &&
              onSelectEndLocation != null &&
              selectedEndLocation != null) ...[
            // Divider Alur Perjalanan
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Rute Wisata Batam',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Lokasi Akhir
            _buildLocationPickerBox(
              context: context,
              isEndLocation: true,
              badgeTitle: 'LOKASI AKHIR (KEPULANGAN / TITIK SELESAI)',
              selectedName: selectedEndLocation!,
              selectedModel: selectedEndLocationModel,
              onTap: () {
                TripLocationModal.showLocationDialog(
                  context: context,
                  availableLocations: availableLocations,
                  currentSelectedName: selectedEndLocation!,
                  isEndLocation: true,
                  onLocationSelected: onSelectEndLocation!,
                  onShowDetail: onShowLocationDetail,
                );
              },
              onQuickSelect: (loc) => onSelectEndLocation!(loc),
              extraTrailingAction: selectedEndLocation != selectedStartLocation
                  ? InkWell(
                      onTap: () {
                        final startModel = selectedStartLocationModel ??
                            availableLocations
                                .where((l) => l.name == selectedStartLocation)
                                .firstOrNull ??
                            availableLocations.first;
                        onSelectEndLocation!(startModel);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sync,
                                size: 12, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Sama dgn awal',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationPickerBox({
    required BuildContext context,
    required bool isEndLocation,
    required String badgeTitle,
    required String selectedName,
    required TripLocationModel? selectedModel,
    required VoidCallback onTap,
    required ValueChanged<TripLocationModel> onQuickSelect,
    Widget? extraTrailingAction,
  }) {
    final currentLoc = selectedModel ??
        availableLocations.where((l) => l.name == selectedName).firstOrNull ??
        kBatamLocations.where((l) => l.name == selectedName).firstOrNull;

    final locIcon = currentLoc?.icon ??
        (selectedName.toLowerCase().contains('hotel')
            ? Icons.hotel
            : Icons.directions_boat_outlined);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              badgeTitle,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AppColors.textSecondary,
              ),
            ),
            ?extraTrailingAction,
          ],
        ),
        const SizedBox(height: 8),

        // Box Selector
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    locIcon,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ManropeFont(
                        selectedName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (currentLoc != null)
                        Text(
                          currentLoc.type,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (currentLoc != null) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      size: 19,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Lihat detail tempat',
                    onPressed: () {
                      if (onShowLocationDetail != null) {
                        onShowLocationDetail!(currentLoc);
                      } else {
                        TripLocationModal.showLocationDetail(
                          context: context,
                          location: currentLoc,
                        );
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(
                  Icons.unfold_more,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Cepat pilih chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              Text(
                'Cepat pilih:',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              for (final loc in availableLocations.take(5)) ...[
                InkWell(
                  onTap: () => onQuickSelect(loc),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: selectedName == loc.name
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selectedName == loc.name
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          loc.icon,
                          size: 13,
                          color: selectedName == loc.name
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          loc.quickLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selectedName == loc.name
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: selectedName == loc.name
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
