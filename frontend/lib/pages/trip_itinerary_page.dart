import 'package:flutter/material.dart';
import 'package:frontend/components/font/bebas_neue_font.dart';
import 'package:frontend/components/font/manrope_font.dart';
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
  final String transport;
  final String budgetPriority;
  final String notes;
  final List<DetailItineraryModel>? initialDetails;

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
    required this.budgetPriority,
    this.transport = '',
    this.notes = '',
    this.initialDetails,
  });

  @override
  State<TripItineraryPage> createState() => _TripItineraryPageState();
}

class _TripItineraryPageState extends State<TripItineraryPage> {
  int _selectedDayIndex = 0;
  final Set<String> _completedItems = {};
  late List<DetailItineraryModel> _details;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _details = widget.initialDetails ?? [];
    if (_details.isEmpty && widget.planId != null && widget.planId!.isNotEmpty) {
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoadingDetails = true);
    final plan = await TripPlanService.getTripPlanById(widget.planId!);
    if (mounted) {
      setState(() {
        _isLoadingDetails = false;
        if (plan != null && plan.details.isNotEmpty) {
          _details = plan.details;
        }
      });
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
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  String _formatFullMonth(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
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
            icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
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
            // 1. BANNER HEADER ITINERARY
            _buildTripHeaderCard(),

            // 2. DAY SELECTOR TABS
            _buildDaySelectorTabs(),

            // 3. DAY TITLE & HIGHLIGHT SUMMARY
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              // 4. VERTICAL TIMELINE CARDS WITH TRANSIT BADGES
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildTimelineForDay(_selectedDayIndex),
              ),

              // 5. ESTIMASI ANGGARAN HARIAN
              _buildDailyBudgetSummaryCard(),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ITINERARY RESMI SMARTTRIP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              if (widget.transport.isNotEmpty)
                _buildHeaderTag(
                  icon: Icons.directions_car_outlined,
                  label: widget.transport,
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
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
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

  Widget _buildTimelineForDay(int dayIndex) {
    final items = _getDestinationsForDay(dayIndex);

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _buildTimelineCard(items[i], i == items.length - 1),
          if (i < items.length - 1)
            _buildTransitConnector(
              duration: items[i]['nextTransitDuration'] as String? ?? '15 menit',
              distance: items[i]['nextTransitDistance'] as String? ?? '6.5 km',
              route: items[i]['nextTransitRoute'] as String? ?? 'via Jl. Protokol Batam',
            ),
        ],
      ],
    );
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
          // Baris Slot Waktu & Kategori
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

          // Judul Destinasi
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

          // Detail Info Bar (Waktu Kunjungan, Tiket Masuk, Fasilitas)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: AppColors.primary),
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
                const Icon(Icons.confirmation_number_outlined,
                    size: 14, color: Color(0xFFC05400)),
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

          // Tombol Tindakan (Buka Peta / Detail)
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Membuka navigasi peta untuk ${item['title']}...'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined, size: 14),
                label: const Text('Navigasi Peta', style: TextStyle(fontSize: 11.5)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                label: const Text('Info Lengkap', style: TextStyle(fontSize: 11.5)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              const Icon(Icons.directions_car_filled,
                  size: 16, color: AppColors.primary),
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
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.grey.shade600,
                  ),
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
                    Text(item['emoji'] as String? ?? '📍',
                        style: const TextStyle(fontSize: 28)),
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
                      _buildModalInfoRow('Waktu Kunjungan', item['timeSlot'] as String),
                      const Divider(height: 14),
                      _buildModalInfoRow('Estimasi Biaya', item['costEstimate'] as String),
                      const Divider(height: 14),
                      _buildModalInfoRow('Durasi Aktivitas', item['duration'] as String),
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
                    child: const Text('Tutup',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
    if (_details.isNotEmpty) {
      final dayItems =
          _details.where((d) => d.hariKe == dayIndex + 1).toList();
      if (dayItems.isNotEmpty) {
        final names = dayItems
            .where((d) => d.tipeItem != 'titik_awal')
            .take(3)
            .map((d) => d.namaTempat)
            .toList();
        if (names.isNotEmpty) {
          return names.join(' • ');
        }
      }
    }
    switch (dayIndex) {
      case 0:
        return 'Pusat Kota Batam, Sejarah & Landmark Barelang';
      case 1:
        return 'Wisata Bahari Barelang, Camp Vietnam & Kelong Seafood';
      case 2:
        return 'Kawasan Pantai Nongsa & Belanja Oleh-Oleh Kepulangan';
      default:
        return 'Jelajah Wisata Rekreasi & Bahari Batam';
    }
  }

  String _getDayBudgetEstimate(int dayIndex) {
    if (_details.isNotEmpty) {
      final dayItems =
          _details.where((d) => d.hariKe == dayIndex + 1).toList();
      final total =
          dayItems.fold<double>(0, (sum, item) => sum + item.estimasiBiaya);
      if (total > 0) {
        final formatted = total.toInt().toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]}.',
            );
        return '~Rp $formatted / orang (Total estimasi aktivitas & kuliner hari ini)';
      }
    }
    switch (dayIndex) {
      case 0:
        return '~Rp 320.000 / orang (Transport, Mie Tarempa & Seafood)';
      case 1:
        return '~Rp 450.000 / orang (Tiket Galang, Mirota & Kelong)';
      case 2:
        return '~Rp 280.000 / orang (Kafe Nongsa & Oleh-Oleh)';
      default:
        return '~Rp 350.000 / orang';
    }
  }


  List<Map<String, dynamic>> _getDestinationsForDay(int dayIndex) {
    if (_details.isNotEmpty) {
      final dayItems =
          _details.where((d) => d.hariKe == dayIndex + 1).toList();
      if (dayItems.isNotEmpty) {
        dayItems.sort((a, b) => a.urutan.compareTo(b.urutan));
        return dayItems.map((d) {
          String emoji = '📍';
          String timeOfDay = 'PAGI';
          final startHour = int.tryParse(d.waktuMulai.split(':').first) ?? 9;
          if (startHour < 12) {
            timeOfDay = 'PAGI';
          } else if (startHour < 15) {
            timeOfDay = 'SIANG';
          } else if (startHour < 18) {
            timeOfDay = 'SORE';
          } else {
            timeOfDay = 'MALAM';
          }

          final lowKat = d.kategori.toLowerCase();
          if (d.tipeItem == 'titik_awal') {
            emoji = '⛴';
          } else if (d.tipeItem == 'restoran' ||
              lowKat.contains('kuliner') ||
              lowKat.contains('seafood') ||
              lowKat.contains('santap')) {
            emoji = '🦞';
          } else if (lowKat.contains('pantai') || lowKat.contains('bahari')) {
            emoji = '🏖️';
          } else if (lowKat.contains('sejarah') || lowKat.contains('museum')) {
            emoji = '🏛️';
          } else if (lowKat.contains('belanja') || lowKat.contains('mall')) {
            emoji = '🛍️';
          } else if (lowKat.contains('alam') || lowKat.contains('taman')) {
            emoji = '🌲';
          }

          String costLabel = d.estimasiBiaya > 0
              ? 'Rp ${d.estimasiBiaya.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'
              : 'Bebas biaya';

          return {
            'emoji': emoji,
            'timeOfDay': timeOfDay,
            'timeSlot': '${d.waktuMulai} - ${d.waktuSelesai} WIB',
            'title': d.namaTempat,
            'category': d.kategori,
            'desc': d.catatan.isNotEmpty
                ? d.catatan
                : 'Destinasi wisata rekomendasi di Pulau Batam.',
            'duration': '${d.waktuMulai} s.d. ${d.waktuSelesai}',
            'costEstimate': costLabel,
            'nextTransitDuration': '15 menit',
            'nextTransitDistance': '5.5 km',
            'nextTransitRoute': 'via Jalur Lintas Batam',
          };
        }).toList();
      }
    }

    if (dayIndex == 0) {
      return [
        {
          'emoji': '⛴',
          'timeOfDay': 'PAGI',
          'timeSlot': '08:30 WIB • KEDATANGAN',
          'title': widget.startLocation,
          'category': 'Titik Awal & Penjemputan',
          'desc':
              'Titik kumpul wisatawan dan kedatangan di Batam. Persiapan bagasi dan pengarahan rute hari pertama.',
          'duration': '30 menit',
          'costEstimate': 'Bebas biaya',
          'nextTransitDuration': '15 menit',
          'nextTransitDistance': '6.2 km',
          'nextTransitRoute': 'via Jl. Engku Putri',
        },
        {
          'emoji': '🏛️',
          'timeOfDay': 'PAGI',
          'timeSlot': '09:15 - 11:30 WIB',
          'title': 'Museum Raja Ali Haji & Ikon Welcome to Batam',
          'category': 'Wisata Sejarah',
          'desc':
              'Mempelopori sejarah Kesultanan Riau-Lingga, naskah kuno gurindam, serta spot foto ikonik Welcome to Batam di bukit Clara.',
          'duration': '2 jam 15 menit',
          'costEstimate': 'Tiket Masuk: Gratis / Sukarela',
          'nextTransitDuration': '12 menit',
          'nextTransitDistance': '4.5 km',
          'nextTransitRoute': 'via Jl. Laksamana Bintan',
        },
        {
          'emoji': '🍜',
          'timeOfDay': 'SIANG',
          'timeSlot': '12:00 - 13:30 WIB • SANTAP SIANG',
          'title': 'Kuliner Mie Tarempa & Kopitiam Tradisional',
          'category': 'Kuliner Khas Kepulauan Riau • Halal',
          'desc':
              'Menikmati Mie Tarempa kuah kental ikan tongkol, roti prata kari, dan kopi O khas pagi Kepri yang lezat.',
          'duration': '1 jam 30 menit',
          'costEstimate': 'Estimasi: Rp 35.000 - Rp 50.000 / porsi',
          'nextTransitDuration': '18 menit',
          'nextTransitDistance': '7.8 km',
          'nextTransitRoute': 'via Jl. Sudirman Nagoya',
        },
        {
          'emoji': '🛍️',
          'timeOfDay': 'SIANG',
          'timeSlot': '14:00 - 16:00 WIB',
          'title': 'Grand Batam Mall & Pusat Belanja Nagoya',
          'category': 'Wisata Belanja',
          'desc':
              'Kawasan pusat belanja modern terlengkap di Batam. Berburu produk impor, cokelat bebas pajak, dan fashion.',
          'duration': '2 jam',
          'costEstimate': 'Sesuai belanja pribadi',
          'nextTransitDuration': '30 menit',
          'nextTransitDistance': '22 km',
          'nextTransitRoute': 'via Jl. Trans Barelang',
        },
        {
          'emoji': '🌉',
          'timeOfDay': 'SORE',
          'timeSlot': '16:45 - 18:30 WIB • GOLDEN HOUR',
          'title': 'Jembatan 1 Tengku Fisabilillah (Barelang)',
          'category': 'Wisata Pantai',
          'desc':
              'Ikon nomor satu Pulau Batam yang menghubungkan Pulau Batam dan Tonton. Menikmati matahari terbenam (sunset) di atas selat.',
          'duration': '1 jam 45 menit',
          'costEstimate': 'Parkir: Rp 10.000 / mobil',
          'nextTransitDuration': '10 menit',
          'nextTransitDistance': '3.5 km',
          'nextTransitRoute': 'ke arah dermaga Barelang',
        },
        {
          'emoji': '🦞',
          'timeOfDay': 'MALAM',
          'timeSlot': '19:00 - 21:00 WIB • SANTAP MALAM',
          'title': 'Restoran Seafood Kelong Terapung Barelang',
          'category': 'Kuliner Seafood & Ikan Bakar Pesisir',
          'desc':
              'Menikmati kepiting saus lada hitam khas Batam, gonggong rebus sambal cabai rawit, udang nestum, dan ikan bakar di atas kelong laut.',
          'duration': '2 jam',
          'costEstimate': 'Estimasi: Rp 150.000 - Rp 250.000 / orang',
        },
      ];
    } else if (dayIndex == 1) {
      return [
        {
          'emoji': '🚗',
          'timeOfDay': 'PAGI',
          'timeSlot': '08:30 WIB • PENJEMPUTAN',
          'title': 'Penjemputan Penginapan & Melintasi Jembatan 2-4',
          'category': 'Rute Bahari Trans Barelang',
          'desc':
              'Perjalanan menyusuri gugusan pulau Nipah, Setokok, dan Rempang dengan panorama laut tropis Kepri yang tenang.',
          'duration': '45 menit',
          'costEstimate': 'Termasuk sewa transportasi',
          'nextTransitDuration': '35 menit',
          'nextTransitDistance': '28 km',
          'nextTransitRoute': 'menuju Pulau Galang',
        },
        {
          'emoji': '🇻🇳',
          'timeOfDay': 'PAGI',
          'timeSlot': '09:45 - 12:00 WIB',
          'title': 'Situs Sejarah Eks-Camp Vietnam Pulau Galang',
          'category': 'Wisata Sejarah',
          'desc':
              'Kawasan suaka kemanusiaan pengungsi manusia perahu Vietnam tahun 1979-1996. Meliputi museum, barak, pagoda, dan gereja tua.',
          'duration': '2 jam 15 menit',
          'costEstimate': 'Tiket Masuk: Rp 15.000 / orang',
          'nextTransitDuration': '15 menit',
          'nextTransitDistance': '8 km',
          'nextTransitRoute': 'ke pesisir Pantai Mirota',
        },
        {
          'emoji': '🏝️',
          'timeOfDay': 'SIANG',
          'timeSlot': '12:30 - 15:30 WIB • BAHARI & SANTAI',
          'title': 'Pantai Mirota & Wahana Air Pulau Galang',
          'category': 'Wisata Pantai',
          'desc':
              'Pantai pasir putih berair jernih dengan gazebo teduh di tepi laut. Tersedia wahana banana boat, kano, dan kelapa muda segar.',
          'duration': '3 jam',
          'costEstimate': 'Tiket Masuk: Rp 20.000 / orang',
          'nextTransitDuration': '50 menit',
          'nextTransitDistance': '45 km',
          'nextTransitRoute': 'kembali ke area Nagoya',
        },
        {
          'emoji': '🍢',
          'timeOfDay': 'MALAM',
          'timeSlot': '18:30 - 21:00 WIB • WISATA KULINER MALAM',
          'title': 'Nagoya Foodcourt & Kawasan Jajanan Malam',
          'category': 'Pusat Kuliner Malam & Street Food',
          'desc':
              'Menjelajahi aneka kuliner malam khas Batam, sate madura, martabak har, roti bakar, dan aneka minuman buah tropis.',
          'duration': '2 jam 30 menit',
          'costEstimate': 'Estimasi: Rp 50.000 - Rp 80.000 / orang',
        },
      ];
    } else {
      return [
        {
          'emoji': '🏖️',
          'timeOfDay': 'PAGI',
          'timeSlot': '09:00 - 11:30 WIB',
          'title': 'Kawasan Resort Nongsa & Nuvasa Bay',
          'category': 'Wisata Pantai',
          'desc':
              'Kawasan pantai pasir putih bersih menghadap selat Singapura. Suasana tenang dengan padang golf tropis dan dermaga yacht.',
          'duration': '2 jam 30 menit',
          'costEstimate': 'Tiket Masuk: Rp 30.000 / orang',
          'nextTransitDuration': '20 menit',
          'nextTransitDistance': '14 km',
          'nextTransitRoute': 'ke pusat kota',
        },
        {
          'emoji': '🍫',
          'timeOfDay': 'SIANG',
          'timeSlot': '12:00 - 14:00 WIB • OLEH-OLEH KHAS',
          'title': 'Sentra Oleh-Oleh Lapis Legit & Cokelat Batam',
          'category': 'Wisata Belanja',
          'desc':
              'Membeli Lapis Legit Harum Manis khas Batam, bingka bakar pandan, cokelat impor, dan keripik gonggong renyah.',
          'duration': '2 jam',
          'costEstimate': 'Sesuai belanja pribadi',
          'nextTransitDuration': '20 menit',
          'nextTransitDistance': '10 km',
          'nextTransitRoute': 'menuju titik kepulangan',
        },
        {
          'emoji': '⛴',
          'timeOfDay': 'SORE',
          'timeSlot': '14:30 - 16:00 WIB • KEPULANGAN',
          'title': 'Pengantaran ke ${widget.startLocation}',
          'category': 'Selesai Perjalanan & Check-out',
          'desc':
              'Check-in tiket kapal ferry / boarding pesawat, pengembalian kendaraan sewa, dan persiapan kepulangan wisatawan.',
          'duration': '1 jam 30 menit',
          'costEstimate': 'Selesai',
        },
      ];
    }
  }
}
