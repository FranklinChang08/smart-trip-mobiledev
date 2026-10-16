import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/components/font/noto_font.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';

/// Formulir Langkah 1
/// Tampilan premium terstruktur rapi: Nama Perjalanan, Periode & Ritme Harian,
/// Lokasi Awal & Titik Kumpul, dan Alokasi Anggaran.
class TripStep1Form extends StatelessWidget {
  final TextEditingController tripNameController;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String selectedLocation;
  final TextEditingController budgetController;
  final VoidCallback onSelectDateRange;
  final Function(int days) onSelectDurationPreset;
  final Function({required bool isStart})? onPickTime;
  final ValueChanged<String> onSelectLocation;
  final VoidCallback onOpenLocationDialog;
  final ValueChanged<String> onSelectBudgetPreset;
  final VoidCallback onGoToPreferences;

  const TripStep1Form({
    super.key,
    required this.tripNameController,
    required this.startDate,
    required this.endDate,
    this.startTime = const TimeOfDay(hour: 8, minute: 30),
    this.endTime = const TimeOfDay(hour: 21, minute: 0),
    required this.selectedLocation,
    required this.budgetController,
    required this.onSelectDateRange,
    required this.onSelectDurationPreset,
    this.onPickTime,
    required this.onSelectLocation,
    required this.onOpenLocationDialog,
    required this.onSelectBudgetPreset,
    required this.onGoToPreferences,
  });

  int get _tripDays {
    final diff = endDate.difference(startDate).inDays;
    return diff >= 0 ? diff + 1 : 1;
  }

  int get _tripNights => _tripDays > 1 ? _tripDays - 1 : 0;

  String _formatTime(TimeOfDay t) {
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. BANNER HERO ARCHIPELAGO GATEWAY
        _buildHeroBanner(),
        const SizedBox(height: 16),

        // 2. NAMA RENCANA PERJALANAN
        _buildTripNameSection(),
        const SizedBox(height: 16),

        // 3. LOKASI AWAL & TITIK KUMPUL
        _buildLocationSection(context),
        const SizedBox(height: 16),

        // 4. PERIODE & RITME HARIAN
        _buildPeriodSection(context),
        const SizedBox(height: 16),

        // 5. ALOKASI ANGGARAN
        _buildBudgetSection(context),
        const SizedBox(height: 16),

        // 6. KARTU AJAKAN LANGKAH 2 (PREFERENSI WISATA)
        _buildPreferencesNextStepBanner(),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Banner Hero Pengantar
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Icon(
                Icons.explore_outlined,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'BATAM ARCHIPELAGO GATEWAY',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const NotoFont(
            'Rencana Perjalanan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const ManropeFont(
            'Sesuaikan detail liburan impian Anda di Pulau Batam dengan memadukan ritme santai bahari, pesona kuliner pesisir, dan rute navigasi efisien.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 1. Nama Rencana Perjalanan
  Widget _buildTripNameSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionIcon(Icons.edit_outlined),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ManropeFont(
                      'Nama Rencana Perjalanan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Beri judul untuk rencana liburan Anda',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildRequiredBadge(),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: tripNameController,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              prefixIcon: const Icon(
                Icons.bookmark_outline,
                color: AppColors.primary,
                size: 20,
              ),
              hintText: 'Misal: Liburan Akhir Pekan di Batam',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                Text(
                  'Saran nama:',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                for (final suggestion in kDefaultTripSuggestions) ...[
                  InkWell(
                    onTap: () {
                      tripNameController.text = suggestion;
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: tripNameController.text == suggestion
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: tripNameController.text == suggestion
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: tripNameController.text == suggestion
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: tripNameController.text == suggestion
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Lokasi Awal & Titik Kumpul
  Widget _buildLocationSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Seksi
          Row(
            children: [
              _buildSectionIcon(Icons.location_on_outlined),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ManropeFont(
                      'Lokasi Awal & Titik Kumpul',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tempat penjemputan atau kedatangan',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildRequiredBadge(),
            ],
          ),
          const SizedBox(height: 16),

          // Dropdown Selector Box
          InkWell(
            onTap: onOpenLocationDialog,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_boat_outlined,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ManropeFont(
                      selectedLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.unfold_more,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Cepat Pilih Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                Text(
                  'Cepat pilih:',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                for (final loc in kBatamLocations.where((l) => l.isQuick)) ...[
                  InkWell(
                    onTap: () => onSelectLocation(loc.name),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: selectedLocation == loc.name
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selectedLocation == loc.name
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            loc.icon,
                            size: 14,
                            color: selectedLocation == loc.name
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            loc.quickLabel,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: selectedLocation == loc.name
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: selectedLocation == loc.name
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Periode & Ritme Harian
  Widget _buildPeriodSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionIcon(Icons.calendar_today_outlined),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ManropeFont(
                      'Periode & Ritme Harian',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tentukan durasi dan jam aktif perjalanan',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildRequiredBadge(),
            ],
          ),
          const SizedBox(height: 16),

          // Kotak Pilihan Tanggal
          InkWell(
            onTap: onSelectDateRange,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatMonth(startDate.month).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          startDate.day.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ManropeFont(
                          '${startDate.day} - ${endDate.day} ${formatFullMonth(endDate.month)} ${endDate.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_tripDays Hari $_tripNights Malam (Akhir Pekan Nyaman)',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dua Kotak Pilihan Jam (Mulai & Selesai)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onPickTime?.call(isStart: true),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.wb_sunny_outlined,
                                size: 14, color: Color(0xFFD97706)),
                            SizedBox(width: 6),
                            Text(
                              'Mulai Aktivitas',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(startTime),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Pagi',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => onPickTime?.call(isStart: false),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.nightlight_round_outlined,
                                size: 14, color: Color(0xFF4F46E5)),
                            SizedBox(width: 6),
                            Text(
                              'Selesai Istirahat',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(endTime),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Malam',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF4F46E5),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pilihan Cepat Durasi (Horizontal Scrollable Chips seperti di bagian Lokasi)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                Text(
                  'Cepat pilih durasi:',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                _buildDurationChip(days: 2, label: '2 Hari (2H 1M)'),
                const SizedBox(width: 6),
                _buildDurationChip(days: 3, label: '3 Hari (Rekomendasi)'),
                const SizedBox(width: 6),
                _buildDurationChip(days: 4, label: '4 Hari (4H 3M)'),
                const SizedBox(width: 6),
                _buildDurationChip(days: 5, label: '5 Hari (5H 4M)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChip({required int days, required String label}) {
    final isSelected = _tripDays == days;
    return InkWell(
      onTap: () => onSelectDurationPreset(days),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: 13,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 4. Alokasi Anggaran
  Widget _buildBudgetSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionIcon(Icons.account_balance_wallet_outlined),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ManropeFont(
                      'Alokasi Anggaran',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Estimasi pengeluaran per orang per hari',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, size: 20),
                color: Colors.grey.shade400,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text(
                        'Panduan Anggaran di Batam',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                        '• Backpacker: Rp 300rb - Rp 600rb / hari\n• Nyaman / Keluarga: Rp 1jt - Rp 2jt / hari\n• Resort & Kuliner Mewah: Rp 3jt+ / hari',
                        style: TextStyle(fontSize: 12.5, height: 1.6),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup',
                              style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Label Field
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimasi Anggaran',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildRequiredBadge(),
            ],
          ),
          const SizedBox(height: 8),

          // TextField Input Anggaran
          TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.payments_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              hintText: 'Cnth: 5.000.000',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Rekomendasi Nyaman Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.insights_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.45,
                        color: Colors.grey.shade700,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Rekomendasi Nyaman: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Mencakup santap seafood Barelang tepi laut, tiket atraksi utama, transportasi sewa harian teratur, dan kafe rileks.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Preset Chips Anggaran
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                Text(
                  'Cepat isi:',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                for (final preset in kBudgetPresets) ...[
                  InkWell(
                    onTap: () => onSelectBudgetPreset(preset),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: budgetController.text == preset
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: budgetController.text == preset
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        preset.replaceAll('.000', 'k'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: budgetController.text == preset
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: budgetController.text == preset
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Banner Melanjutkan ke Langkah 2
  Widget _buildPreferencesNextStepBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tune,
                  color: Color(0xFF16A34A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Langkah Berikutnya: Preferensi Wisata',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Setelah rencana dasar diisi, lanjutkan ke Langkah 2 untuk memilih minat wisata (pantai, seafood, mall) dan area Batam guna menyusun rekomendasi perjalanan terbaik.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.5,
              color: Color(0xFF166534),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onGoToPreferences,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF15803D),
                side: const BorderSide(color: Color(0xFF16A34A)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Atur Preferensi Sekarang',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Icon 
  Widget _buildSectionIcon(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 19,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildRequiredBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Wajib',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFFDC2626),
        ),
      ),
    );
  }
}
