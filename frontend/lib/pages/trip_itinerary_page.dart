import 'package:flutter/material.dart';
import 'package:frontend/components/font/bebas_neue_font.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/components/trip_plan/trip_location_selector.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/services/trip_plan_service.dart';

/// Halaman Detail Itinerary Rencana Perjalanan
class TripItineraryPage extends StatefulWidget {
  final String? planId;
  final String tripName;
  final DateTime startDate;
  final DateTime endDate;
  final String startLocation;
  final String budget;
  final List<String> selectedThemes;
  final List<String> selectedAreas;
  final String notes;
  final bool isDraft;

  // Menggunakan model hari perjalanan
  final List<HariPerjalananModel>? initialHariPerjalanan;

  const TripItineraryPage({
    super.key,
    this.planId,
    required this.tripName,
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    required this.budget,
    required this.selectedThemes,
    required this.selectedAreas,
    this.notes = '',
    this.isDraft = false,
    this.initialHariPerjalanan,
  });

  @override
  State<TripItineraryPage> createState() => _TripItineraryPageState();
}

class _TripItineraryPageState extends State<TripItineraryPage> {
  int _selectedDayIndex = 0;

  final Set<String> _completedItems = {};

  // Data hari perjalanan dari database
  List<HariPerjalananModel> _days = [];

  bool _isLoadingDetails = false;
  bool _isGeneratingAi = false;
  late bool _isDraft;

  List<TripLocationModel> _availableLocations = kBatamLocations;
  List<Map<String, dynamic>> _availableDestinations = [];

  @override
  void initState() {
    super.initState();
    _isDraft = widget.isDraft;

    // Gunakan data awal jika tersedia
    if (widget.initialHariPerjalanan != null &&
        widget.initialHariPerjalanan!.isNotEmpty) {
      _days = widget.initialHariPerjalanan!;
    }

    if (widget.planId != null && widget.planId!.isNotEmpty) {
      _loadDetails();
    }

    _loadLocationsAndDestinations();
  }

  Future<void> _loadLocationsAndDestinations() async {
    try {
      final locs = await TripPlanService.fetchLocations();
      if (mounted && locs.isNotEmpty) {
        setState(() => _availableLocations = locs);
      }
      final dests = await TripPlanService.fetchAllDestinationsForPicker();
      if (mounted && dests.isNotEmpty) {
        setState(() => _availableDestinations = dests);
      }
    } catch (_) {}
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoadingDetails = true);

    try {
      final plan = await TripPlanService.getTripPlanById(widget.planId!);

      if (!mounted) return;

      if (plan != null) {
        debugPrint('Plan ditemukan: ${plan.tripName}');
        debugPrint('Total hari: ${plan.hariPerjalanan.length}');

        for (final hari in plan.hariPerjalanan) {
          debugPrint('Hari ke-${hari.urutanHari}');
          debugPrint('Total item: ${hari.itemPerjalanan.length}');

          for (final item in hari.itemPerjalanan) {
            debugPrint('Destinasi: ${item.destinationName}');
          }
        }
      } else {
        debugPrint('Plan tidak ditemukan');
      }

      setState(() {
        _isLoadingDetails = false;

        if (plan != null) {
          // Langsung menggunakan relasi hari_perjalanan
          _days = plan.hariPerjalanan;
          _isDraft = (!widget.isDraft || plan.status == 'aktif') ? false : plan.isDraft;

          // Pastikan index hari yang dipilih masih valid
          if (_days.isEmpty) {
            _selectedDayIndex = 0;
          } else if (_selectedDayIndex >= _days.length) {
            _selectedDayIndex = 0;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoadingDetails = false);

      debugPrint('Gagal memuat detail itinerary: $e');
    }
  }

  int get _tripDays {
    final diff = widget.endDate.difference(widget.startDate).inDays;
    return diff >= 0 ? diff + 1 : 1;
  }

  int get _tripNights {
    return _tripDays > 1 ? _tripDays - 1 : 0;
  }

  String _formatMonth(int month) {
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

    return months[month - 1];
  }

  String _formatFullMonth(int month) {
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

    return months[month - 1];
  }

  DateTime _getDateForDay(int dayIndex) {
    return widget.startDate.add(Duration(days: dayIndex));
  }

  @override
  Widget build(BuildContext context) {
    final activeDate = _getDateForDay(_selectedDayIndex);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BebasNeueFont(
              'SmartTrip',
              style: TextStyle(
                fontSize: 20,
                letterSpacing: 0.5,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const ManropeFont(
                  'Jadwal Rencana Perjalanan Batam',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tautan jadwal itinerary berhasil disalin!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header itinerary
            _buildTripHeaderCard(),

            // Tab pemilih hari
            _buildDaySelectorTabs(),

            // Judul hari & ringkasan
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hari ${_selectedDayIndex + 1} • ${activeDate.day} ${_formatFullMonth(activeDate.month)} ${activeDate.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getDayThemeSubtitle(_selectedDayIndex),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_getDestinationsForDay(_selectedDayIndex).length} Destinasi',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2 Tombol Aksi Utama: Tambah Destinasi & Dapatkan Rekomendasi (Hanya di mode Draf)
            if (_isDraft)
              _buildDayActionButtons(_selectedDayIndex),

            if (_isGeneratingAi)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      Colors.blue.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SmartTrip AI Sedang Menyusun Rekomendasi...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Memilih tempat wisata, kuliner, dan rute terbaik untuk Anda.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (_isLoadingDetails)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Memuat susunan destinasi itinerary dari database...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Timeline destinasi harian
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildTimelineForDay(_selectedDayIndex),
              ),

              // Estimasi anggaran harian
              _buildDailyBudgetSummaryCard(),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _isDraft ? _buildDraftBottomBar(context) : null,
    );
  }

  Widget _buildTripHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isDraft
                      ? Colors.amber.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _isDraft ? 'DRAF RENCANA PERJALANAN' : 'ITINERARY RESMI SMARTTRIP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: _isDraft ? Colors.amber.shade900 : AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_tripDays Hari $_tripNights Malam',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ManropeFont(
            widget.tripName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildHeaderTag(
                icon: Icons.calendar_today_outlined,
                label:
                    '${widget.startDate.day} ${_formatMonth(widget.startDate.month)} - ${widget.endDate.day} ${_formatFullMonth(widget.endDate.month)} ${widget.endDate.year}',
              ),
              _buildHeaderTag(
                icon: Icons.location_on_outlined,
                label: widget.startLocation,
              ),
              _buildHeaderTag(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Rp ${widget.budget} / orang',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTag({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelectorTabs() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tripDays,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedDayIndex == index;
          final date = _getDateForDay(index);

          return InkWell(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF111827)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 14,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Hari ${index + 1} (${date.day} ${_formatMonth(date.month)})',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 2 Tombol Aksi Utama: Tambah Destinasi & Dapatkan Rekomendasi beserta Counter Destinasi Hari Ini
  Widget _buildDayActionButtons(int dayIndex) {
    final dayItems = _getDestinationsForDay(dayIndex);
    final totalDayItems = dayItems.length;

    // Hitung jumlah wisata dan kuliner pada hari ini
    int wisataCount = 0;
    int kulinerCount = 0;
    for (final item in dayItems) {
      final desc = (item['desc'] as String? ?? '').toLowerCase();
      final cat = (item['category'] as String? ?? '').toLowerCase();
      if (desc.contains('kuliner') || cat.contains('kuliner') || cat.contains('restoran') || cat.contains('seafood')) {
        kulinerCount++;
      } else {
        wisataCount++;
      }
    }

    final totalAllDays = _days.fold<int>(
      0,
      (sum, d) => sum + d.itemPerjalanan.length,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kartu Rangkuman / Counter Kesiapan Destinasi Hari Ini
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.primary,
                            size: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kesiapan Hari ke-${dayIndex + 1}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: totalDayItems > 0
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: totalDayItems > 0
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Text(
                        totalDayItems > 0
                            ? '$totalDayItems Destinasi Siap'
                            : 'Siap Rekomendasi AI',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: totalDayItems > 0
                              ? const Color(0xFF065F46)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Deretan Chip Counter (Total Destinasi Hari Ini, Wisata, Kuliner, Total Trip)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCounterChip(
                        icon: Icons.place_outlined,
                        label: 'Hari Ini: $totalDayItems',
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      _buildCounterChip(
                        icon: Icons.photo_camera_outlined,
                        label: '$wisataCount Wisata',
                        color: const Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 6),
                      _buildCounterChip(
                        icon: Icons.restaurant_outlined,
                        label: '$kulinerCount Kuliner',
                        color: const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 6),
                      _buildCounterChip(
                        icon: Icons.calendar_today_outlined,
                        label: 'Total Trip: $totalAllDays',
                        color: const Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2 Tombol Aksi Utama: Tambah Destinasi & Dapatkan Rekomendasi
          Row(
            children: [
              // Tombol 1: Tambah Destinasi
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAddDestinationDialog(dayIndex),
                  icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                  label: const Text(
                    'Tambah Destinasi',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Tombol 2: Dapatkan Rekomendasi AI
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingAi ? null : _onGenerateAiRecommendations,
                  icon: _isGeneratingAi
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.auto_awesome, size: 16),
                  label: Text(
                    _isGeneratingAi ? 'Menyusun...' : 'Dapatkan Rekomendasi',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Chip indikator counter
  Widget _buildCounterChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Bilah Navigasi Bawah khusus Draf (seperti tombol di langkah preferensi)
  Widget _buildDraftBottomBar(BuildContext context) {
    final totalAllDays = _days.fold<int>(
      0,
      (sum, d) => sum + d.itemPerjalanan.length,
    );

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 16, color: AppColors.textPrimary),
                SizedBox(width: 4),
                Text(
                  'Kembali',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _onSaveDraftClicked,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: Text(
                totalAllDays > 0
                    ? 'Simpan Rencana ($totalAllDays Destinasi)'
                    : 'Simpan Draf Rencana',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Simpan draf rencana perjalanan & kembali
  Future<void> _onSaveDraftClicked() async {
    if (widget.planId != null && widget.planId!.isNotEmpty) {
      await TripPlanService.setActivePlan(widget.planId!);
    }

    if (!mounted) return;

    final totalAllDays = _days.fold<int>(
      0,
      (sum, d) => sum + d.itemPerjalanan.length,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                totalAllDays > 0
                    ? 'Rencana perjalanan "${widget.tripName}" dengan $totalAllDays destinasi berhasil disimpan!'
                    : 'Draf rencana perjalanan "${widget.tripName}" berhasil disimpan!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pop(context, true);
  }

  /// Panggil AI untuk menyusun rekomendasi itinerary rencana perjalanan ini
  Future<void> _onGenerateAiRecommendations() async {
    if (widget.planId == null || widget.planId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID rencana tidak valid untuk menyusun rekomendasi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isGeneratingAi = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'SmartTrip AI sedang menyusun destinasi, rute, dan jadwal rekomendasi...',
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 5),
      ),
    );

    final updatedPlan = await TripPlanService.generateAiRecommendation(
      widget.planId!,
    );

    if (!mounted) return;

    setState(() => _isGeneratingAi = false);

    if (updatedPlan != null) {
      setState(() {
        _days = updatedPlan.hariPerjalanan;
        _isDraft = false; // Langsung beralih dari draf ke itinerary rekomendasi resmi
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Rekomendasi itinerary untuk ${updatedPlan.tripName} berhasil disusun!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyusun rekomendasi AI. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Timeline perjalanan per hari dengan titik awal dan akhir yang jelas
  Widget _buildTimelineForDay(int dayIndex) {
    final items = _getDestinationsForDay(dayIndex);

    // Jika BUKAN draf (Rekomendasi AI Resmi):
    // Tampilkan langsung timeline daftar destinasi rekomendasi AI secara bersih (tanpa node ubah titik awal/akhir)
    if (!_isDraft) {
      if (items.isEmpty) {
        return _buildEmptyDayState(dayIndex);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildTimelineCard(items[i], i == items.length - 1),
            if (i < items.length - 1)
              _buildTransitConnector(
                duration:
                    items[i]['nextTransitDuration'] as String? ?? '15 menit',
                distance:
                    items[i]['nextTransitDistance'] as String? ?? '6.5 km',
                route:
                    items[i]['nextTransitRoute'] as String? ??
                    'via Jalur Lintas Batam',
              ),
          ],
        ],
      );
    }

    // Jika DRAF:
    // Tampilkan titik awal (dengan tombol ubah), rute transit, destinasi (atau placeholder), dan titik akhir (dengan tombol ubah)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Titik Awal Node (Penjemputan / Keberangkatan)
        _buildStartLocationNode(dayIndex),

        // 2. Connector Rute dari Titik Awal
        _buildTransitConnector(
          duration: '15 menit',
          distance: '5.0 km',
          route: 'Berangkat dari titik awal',
        ),

        // 3. Destinasi atau Placeholder Kosong
        if (items.isEmpty)
          _buildEmptyDayState(dayIndex)
        else
          for (int i = 0; i < items.length; i++) ...[
            _buildTimelineCard(items[i], i == items.length - 1),
            if (i < items.length - 1)
              _buildTransitConnector(
                duration:
                    items[i]['nextTransitDuration'] as String? ?? '15 menit',
                distance:
                    items[i]['nextTransitDistance'] as String? ?? '6.5 km',
                route:
                    items[i]['nextTransitRoute'] as String? ??
                    'via Jl. Protokol Batam',
              ),
          ],

        // 4. Connector Rute Menuju Titik Akhir
        _buildTransitConnector(
          duration: '15 menit',
          distance: '6.0 km',
          route: 'Menuju lokasi kepulangan / penginapan',
        ),

        // 5. Titik Akhir Node (Kepulangan / Penginapan)
        _buildEndLocationNode(dayIndex),
      ],
    );
  }

  /// Node Titik Awal Penjemputan / Keberangkatan
  Widget _buildStartLocationNode(int dayIndex) {
    HariPerjalananModel? currentDay;
    if (_days.isNotEmpty) {
      final matches = _days.where((d) => d.urutanHari == dayIndex + 1);
      if (matches.isNotEmpty) {
        currentDay = matches.first;
      } else if (dayIndex >= 0 && dayIndex < _days.length) {
        currentDay = _days[dayIndex];
      }
    }

    final startLoc = currentDay?.lokasiAwal ?? widget.startLocation;
    final startLocId = currentDay?.lokasiAwalId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trip_origin_rounded,
              size: 20,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TITIK AWAL • PENJEMPUTAN',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  startLoc,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Tombol Ubah Titik Awal
          OutlinedButton.icon(
            onPressed: () => _openChangeLocationDialog(dayIndex, isEndLocation: false),
            icon: const Icon(Icons.edit_outlined, size: 13),
            label: const Text(
              'Ubah',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Detail titik awal',
            icon: const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              if (startLocId != null && startLocId.isNotEmpty) {
                TripLocationModal.showLocationDetailById(
                  context: context,
                  locationId: startLocId,
                  fallbackName: startLoc,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Detail tempat: $startLoc'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Node Titik Akhir Kepulangan / Penginapan
  Widget _buildEndLocationNode(int dayIndex) {
    HariPerjalananModel? currentDay;
    if (_days.isNotEmpty) {
      final matches = _days.where((d) => d.urutanHari == dayIndex + 1);
      if (matches.isNotEmpty) {
        currentDay = matches.first;
      } else if (dayIndex >= 0 && dayIndex < _days.length) {
        currentDay = _days[dayIndex];
      }
    }

    final endLoc = currentDay?.lokasiAkhir ?? widget.startLocation;
    final endLocId = currentDay?.lokasiAkhirId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              size: 20,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TITIK AKHIR • KEPULANGAN / PENGINAPAN',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  endLoc,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Tombol Ubah Titik Akhir
          OutlinedButton.icon(
            onPressed: () => _openChangeLocationDialog(dayIndex, isEndLocation: true),
            icon: const Icon(Icons.edit_outlined, size: 13),
            label: const Text(
              'Ubah',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Detail titik akhir',
            icon: const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              if (endLocId != null && endLocId.isNotEmpty) {
                TripLocationModal.showLocationDetailById(
                  context: context,
                  locationId: endLocId,
                  fallbackName: endLoc,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Detail tempat: $endLoc'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Placeholder ketika satu hari perjalanan belum memiliki destinasi
  Widget _buildEmptyDayState(int dayIndex) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Hari ke-${dayIndex + 1} Belum Ada Destinasi',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tekan "Dapatkan Rekomendasi" agar AI menyusunkan jadwal secara otomatis, atau tambahkan destinasi pilihan Anda secara mandiri.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // Badge counter status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  '0 Destinasi Hari Ini • Total Trip: ${_days.fold<int>(0, (sum, d) => sum + d.itemPerjalanan.length)} Destinasi',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAddDestinationDialog(dayIndex),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    'Tambah Destinasi',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingAi ? null : _onGenerateAiRecommendations,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text(
                    'Rekomendasi AI',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Dialog pemilihan Titik Awal / Akhir Perjalanan pada hari tertentu
  void _openChangeLocationDialog(int dayIndex, {required bool isEndLocation}) {
    HariPerjalananModel? currentDay;
    if (_days.isNotEmpty) {
      final matches = _days.where((d) => d.urutanHari == dayIndex + 1);
      if (matches.isNotEmpty) {
        currentDay = matches.first;
      } else if (dayIndex >= 0 && dayIndex < _days.length) {
        currentDay = _days[dayIndex];
      }
    }

    final currentLocName = isEndLocation
        ? (currentDay?.lokasiAkhir ?? widget.startLocation)
        : (currentDay?.lokasiAwal ?? widget.startLocation);

    TripLocationModal.showLocationDialog(
      context: context,
      availableLocations: _availableLocations,
      currentSelectedName: currentLocName,
      isEndLocation: isEndLocation,
      onLocationSelected: (loc) async {
        if (currentDay == null) return;

        final updatedDay = isEndLocation
            ? currentDay.copyWith(
                lokasiAkhir: loc.name,
                lokasiAkhirId: loc.id,
                lokasiAkhirType: loc.modelType,
              )
            : currentDay.copyWith(
                lokasiAwal: loc.name,
                lokasiAwalId: loc.id,
                lokasiAwalType: loc.modelType,
              );

        setState(() {
          final idx = _days.indexWhere((d) => d.idHari == currentDay!.idHari);
          if (idx != -1) {
            _days[idx] = updatedDay;
          }
        });

        // Simpan pembaruan ke backend
        if (widget.planId != null &&
            widget.planId!.isNotEmpty &&
            currentDay.idHari.isNotEmpty) {
          await TripPlanService.updateDayLocation(
            widget.planId!,
            currentDay.idHari,
            lokasiAwal: !isEndLocation ? loc.name : null,
            lokasiAwalId: !isEndLocation ? loc.id : null,
            lokasiAwalType: !isEndLocation ? loc.modelType : null,
            lokasiAkhir: isEndLocation ? loc.name : null,
            lokasiAkhirId: isEndLocation ? loc.id : null,
            lokasiAkhirType: isEndLocation ? loc.modelType : null,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${isEndLocation ? "Titik akhir" : "Titik awal"} Hari ke-${dayIndex + 1} diubah ke ${loc.name}',
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onShowDetail: (loc) {
        TripLocationModal.showLocationDetail(
          context: context,
          location: loc,
        );
      },
    );
  }

  /// Menampilkan modal pemilih destinasi (Wisata & Restoran di Batam)
  void _showAddDestinationDialog(int dayIndex) {
    HariPerjalananModel? currentDay;
    if (_days.isNotEmpty) {
      final matches = _days.where((d) => d.urutanHari == dayIndex + 1);
      if (matches.isNotEmpty) {
        currentDay = matches.first;
      } else if (dayIndex >= 0 && dayIndex < _days.length) {
        currentDay = _days[dayIndex];
      }
    }

    String searchQuery = '';
    String selectedCategoryFilter = 'Semua';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredDestinations = _availableDestinations.where((item) {
              final name = (item['name'] ?? '').toString().toLowerCase();
              final category = (item['category'] ?? '').toString().toLowerCase();
              final area = (item['area'] ?? '').toString().toLowerCase();
              final type = (item['type'] ?? '').toString().toLowerCase();

              final matchesSearch = searchQuery.isEmpty ||
                  name.contains(searchQuery.toLowerCase()) ||
                  area.contains(searchQuery.toLowerCase()) ||
                  category.contains(searchQuery.toLowerCase());

              final matchesCategory = selectedCategoryFilter == 'Semua' ||
                  (selectedCategoryFilter == 'Wisata' && type == 'wisata') ||
                  (selectedCategoryFilter == 'Restoran' && type == 'restoran');

              return matchesSearch && matchesCategory;
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_location_alt_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tambah Destinasi Hari ke-${dayIndex + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'Pilih destinasi wisata atau kuliner di Kota Batam',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Kotak Pencarian
                  TextField(
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari tempat wisata, kuliner, daerah...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Filter Kategori
                  Row(
                    children: ['Semua', 'Wisata', 'Restoran'].map((tab) {
                      final isSelected = selectedCategoryFilter == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            tab,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                              color:
                                  isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (val) {
                            setModalState(() {
                              selectedCategoryFilter = tab;
                            });
                          },
                          backgroundColor: const Color(0xFFF1F5F9),
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Divider(height: 18),

                  // Daftar Destinasi
                  Expanded(
                    child: filteredDestinations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Destinasi tidak ditemukan',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredDestinations.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final dest = filteredDestinations[idx];
                              final isWisata = dest['type'] == 'wisata';

                              return InkWell(
                                onTap: () => _confirmAddDestination(
                                  modalContext: modalContext,
                                  dayIndex: dayIndex,
                                  currentDay: currentDay,
                                  destination: dest,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: isWisata
                                              ? Colors.blue.withValues(alpha: 0.1)
                                              : Colors.orange.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            isWisata ? '🏖️' : '🦞',
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dest['name'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${dest['category']} • ${dest['area']}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.add,
                                              size: 14,
                                              color: AppColors.primary,
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              'Pilih',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
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

  /// Eksekusi penambahan destinasi yang dipilih ke backend & update tampilan
  void _confirmAddDestination({
    required BuildContext modalContext,
    required int dayIndex,
    required HariPerjalananModel? currentDay,
    required Map<String, dynamic> destination,
  }) async {
    Navigator.pop(modalContext);

    if (currentDay == null || widget.planId == null || widget.planId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID rencana tidak valid.')),
      );
      return;
    }

    final count = currentDay.itemPerjalanan.length;
    final startHour = 9 + (count * 2);
    final depTime = '${startHour.toString().padLeft(2, '0')}:00';
    final arrTime = '${(startHour + 1).toString().padLeft(2, '0')}:30';

    final success = await TripPlanService.addItemToDay(
      widget.planId!,
      currentDay.idHari,
      destinasiId: destination['id'],
      destinasiType: destination['type'],
      departureTime: depTime,
      arrivalTime: arrTime,
    );

    if (success) {
      await _loadDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${destination['name']} berhasil ditambahkan ke Hari ke-${dayIndex + 1}!',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambahkan destinasi. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Hapus destinasi dari jadwal hari ini
  void _deleteDestinationItem(String itemId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Destinasi'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "$title" dari jadwal hari ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await TripPlanService.deleteItem(itemId);
      if (success) {
        await _loadDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"$title" berhasil dihapus dari jadwal.')),
          );
        }
      }
    }
  }

  Widget _buildTimelineCard(Map<String, dynamic> item, bool isLast) {
    final id = item['title'] as String;
    final isDone = _completedItems.contains(id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone ? Colors.green.shade200 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Waktu & kategori
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTimeColor(item['timeOfDay'] as String),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item['timeSlot'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getTimeTextColor(item['timeOfDay'] as String),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item['category'] as String,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    if (isDone) {
                      _completedItems.remove(id);
                    } else {
                      _completedItems.add(id);
                    }
                  });
                },
                child: Icon(
                  isDone ? Icons.check_circle : Icons.check_circle_outline,
                  color: isDone ? Colors.green : Colors.grey.shade400,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nama destinasi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['emoji'] as String? ?? '📍',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? Colors.grey : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['desc'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Info waktu & estimasi biaya
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  item['duration'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 14,
                  color: Color(0xFFC05400),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item['costEstimate'] as String,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tombol aksi
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Membuka navigasi peta untuk ${item['title']}...',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined, size: 14),
                label: const Text(
                  'Navigasi Peta',
                  style: TextStyle(fontSize: 11.5),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  _showDetailModal(item);
                },
                icon: const Icon(Icons.info_outline, size: 14),
                label: const Text(
                  'Info Lengkap',
                  style: TextStyle(fontSize: 11.5),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
              ),
              const Spacer(),
              if (item['id_item'] != null &&
                  (item['id_item'] as String).isNotEmpty)
                IconButton(
                  tooltip: 'Hapus destinasi dari jadwal',
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 19,
                    color: Colors.red.shade400,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _deleteDestinationItem(
                    item['id_item'] as String,
                    item['title'] as String? ?? 'Destinasi',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransitConnector({
    required String duration,
    required String distance,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Column(
            children: [
              Container(width: 2, height: 12, color: Colors.grey.shade300),
              const Icon(
                Icons.directions_car_filled,
                size: 16,
                color: AppColors.primary,
              ),
              Container(width: 2, height: 12, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Text(
                  '$duration ($distance)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '• $route',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBudgetSummaryCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimasi Pengeluaran Hari Ini:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getDayBudgetEstimate(_selectedDayIndex),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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

  void _showDetailModal(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      item['emoji'] as String? ?? '📍',
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            item['category'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  item['desc'] as String,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildModalInfoRow(
                        'Waktu Kunjungan',
                        item['timeSlot'] as String,
                      ),
                      const Divider(height: 14),
                      _buildModalInfoRow(
                        'Estimasi Biaya',
                        item['costEstimate'] as String,
                      ),
                      const Divider(height: 14),
                      _buildModalInfoRow(
                        'Durasi Aktivitas',
                        item['duration'] as String,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getTimeColor(String timeOfDay) {
    switch (timeOfDay) {
      case 'PAGI':
        return Colors.blue.shade50;
      case 'SIANG':
        return Colors.amber.shade50;
      case 'SORE':
        return Colors.orange.shade50;
      case 'MALAM':
        return Colors.indigo.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getTimeTextColor(String timeOfDay) {
    switch (timeOfDay) {
      case 'PAGI':
        return Colors.blue.shade800;
      case 'SIANG':
        return Colors.amber.shade900;
      case 'SORE':
        return Colors.orange.shade900;
      case 'MALAM':
        return Colors.indigo.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  String _getDayThemeSubtitle(int dayIndex) {
    if (_days.isNotEmpty && dayIndex < _days.length) {
      final day = _days.firstWhere(
        (d) => d.urutanHari == dayIndex + 1,
        orElse: () => _days[dayIndex],
      );

      if (day.itemPerjalanan.isNotEmpty) {
        final names = day.itemPerjalanan
            .take(3)
            .map((item) => item.destinationName)
            .where((name) => name.isNotEmpty)
            .toList();

        if (names.isNotEmpty) {
          return names.join(' • ');
        }
      } else {
        return 'Draf perjalanan • Belum ada destinasi ditentukan';
      }
    }

    if (widget.selectedThemes.isNotEmpty) {
      return widget.selectedThemes.join(', ');
    }

    return 'Draf perjalanan • Belum ada destinasi';
  }

  String _getDayBudgetEstimate(int dayIndex) {
    if (_days.isNotEmpty) {
      HariPerjalananModel? day;
      final matches = _days.where((d) => d.urutanHari == dayIndex + 1);

      if (matches.isNotEmpty) {
        day = matches.first;
      } else if (dayIndex >= 0 && dayIndex < _days.length) {
        day = _days[dayIndex];
      }

      if (day != null) {
        if (day.itemPerjalanan.isEmpty) {
          if (_isDraft) {
            return 'Rp 0 / orang (Draf - belum ada destinasi)';
          }
          return 'Rp 0 / orang (Belum ada destinasi)';
        }

        final total = day.estimasiBiaya;
        if (total > 0) {
          final formatted = total.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );

          return '~Rp $formatted / orang '
              '(Total estimasi aktivitas & kuliner hari ini)';
        } else {
          return 'Gratis / Bebas Biaya Tiket';
        }
      }
    }

    final items = _getDestinationsForDay(dayIndex);
    if (items.isEmpty) {
      if (_isDraft) {
        return 'Rp 0 / orang (Draf - belum ada destinasi)';
      }
      return 'Rp 0 / orang (Belum ada destinasi)';
    }

    return 'Gratis / Bebas Biaya Tiket';
  }

  List<Map<String, dynamic>> _getDestinationsForDay(int dayIndex) {
    if (_days.isNotEmpty) {
      final matchingDays = _days.where((d) => d.urutanHari == dayIndex + 1);

      if (matchingDays.isNotEmpty) {
        final dayItems = matchingDays.first.itemPerjalanan.toList();

        if (dayItems.isNotEmpty) {
          return dayItems.map((item) {
            String emoji = '📍';
            String timeOfDay = 'PAGI';

            // Mengambil jam dari departureTime
            final startHour =
                int.tryParse(item.departureTime.split(':').first) ?? 9;

            if (startHour < 12) {
              timeOfDay = 'PAGI';
            } else if (startHour < 15) {
              timeOfDay = 'SIANG';
            } else if (startHour < 18) {
              timeOfDay = 'SORE';
            } else {
              timeOfDay = 'MALAM';
            }

            // Mengambil informasi destinasi
            final lowType = item.type.toLowerCase();

            final kategori =
                item.destinasi?['kategori']?.toString() ??
                item.destinasi?['nama_kategori']?.toString() ??
                '';

            final lowKat = kategori.toLowerCase();

            // Menentukan emoji berdasarkan tipe dan kategori
            if (lowType.contains('restoran')) {
              emoji = '🦞';
            } else if (lowKat.contains('kuliner') ||
                lowKat.contains('seafood') ||
                lowKat.contains('santap')) {
              emoji = '🦞';
            } else if (lowKat.contains('pantai') || lowKat.contains('bahari')) {
              emoji = '🏖️';
            } else if (lowKat.contains('sejarah') ||
                lowKat.contains('museum')) {
              emoji = '🏛️';
            } else if (lowKat.contains('belanja') || lowKat.contains('mall')) {
              emoji = '🛍️';
            } else if (lowKat.contains('alam') || lowKat.contains('taman')) {
              emoji = '🌲';
            }

            // Mengubah HH:mm:ss menjadi HH:mm
            String formatTime(String time) {
              final parts = time.split(':');

              if (parts.length >= 2) {
                return '${parts[0]}:${parts[1]}';
              }

              return time;
            }

            final startTime = formatTime(item.departureTime);
            final endTime = formatTime(item.arrivalTime);

            final isRestaurant = lowType.contains('restoran');

            return {
              'id_item': item.idItem,
              'destination_id': item.destinasiId,
              'emoji': emoji,
              'timeOfDay': timeOfDay,
              'timeSlot': '$startTime - $endTime WIB',
              'title': item.destinationName,
              'category': kategori.isNotEmpty ? kategori : item.type,
              'desc': isRestaurant
                  ? 'Destinasi kuliner rekomendasi di Pulau Batam.'
                  : 'Destinasi wisata rekomendasi di Pulau Batam.',
              'duration': '$startTime s.d. $endTime',
              'costEstimate': 'Lihat estimasi biaya harian',
              'nextTransitDuration': '15 menit',
              'nextTransitDistance': '5.5 km',
              'nextTransitRoute': 'via Jalur Lintas Batam',
            };
          }).toList();
        }
      }
    }

    // Pertahankan seluruh fallback destinasi statis milikmu
    // mulai dari if (dayIndex == 0) sampai akhir fungsi.

    return [];
  }
}
