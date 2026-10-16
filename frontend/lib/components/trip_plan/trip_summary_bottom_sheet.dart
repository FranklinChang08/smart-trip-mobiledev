import 'package:flutter/material.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/components/font/noto_font.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';

/// Modal Lembar Bawah Ringkasan Rencana & Preferensi Perjalanan
class TripSummaryBottomSheet extends StatelessWidget {
  final String tripName;
  final DateTime startDate;
  final DateTime endDate;
  final String startLocation;
  final String budget;
  final String budgetPriority;
  final List<String> selectedThemes;
  final List<String> selectedAreas;
  final String notes;
  final VoidCallback onFinishAndGoHome;

  const TripSummaryBottomSheet({
    super.key,
    required this.tripName,
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    required this.budget,
    required this.budgetPriority,
    required this.selectedThemes,
    required this.selectedAreas,
    required this.notes,
    required this.onFinishAndGoHome,
  });

  int get _tripDays {
    final diff = endDate.difference(startDate).inDays;
    return diff >= 0 ? diff + 1 : 1;
  }

  int get _tripNights => _tripDays > 1 ? _tripDays - 1 : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle penarik modal
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
              const SizedBox(height: 18),

              // Header Status Berhasil
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BERHASIL DISIMPAN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        NotoFont(
                          tripName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Parameter rencana dan preferensi perjalanan Anda telah tersimpan rapi.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Kartu Ringkasan Detail
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      icon: Icons.bookmark_outline,
                      label: 'Rencana',
                      value: tripName,
                    ),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Periode',
                      value:
                          '$_tripDays Hari $_tripNights Malam\n(${startDate.day} ${formatMonth(startDate.month)} - ${endDate.day} ${formatFullMonth(endDate.month)} ${endDate.year})',
                    ),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      icon: Icons.location_on_outlined,
                      label: 'Lokasi Awal',
                      value: startLocation,
                    ),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Anggaran',
                      value: 'Rp $budget / orang\n(Fokus: $budgetPriority)',
                    ),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      icon: Icons.interests_outlined,
                      label: 'Minat Wisata',
                      value: selectedThemes.join(', '),
                    ),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      icon: Icons.map_outlined,
                      label: 'Area Batam',
                      value: selectedAreas.join(', '),
                    ),
                    if (notes.isNotEmpty) ...[
                      const Divider(height: 16),
                      _buildSummaryRow(
                        icon: Icons.note_outlined,
                        label: 'Catatan',
                        value: notes,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Tombol Utama: Selesai & Kembali ke Beranda
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onFinishAndGoHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 18),
                      SizedBox(width: 8),
                      ManropeFont(
                        'Selesai & Kembali ke Beranda',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
