import 'package:flutter/material.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Bilah Tombol Aksi di Bagian Bawah Layar
class TripBottomActionBar extends StatelessWidget {
  final int currentStep;
  final VoidCallback onCancelOrBack;
  final VoidCallback onContinueToStep2;
  final VoidCallback onSavePreferences;
  final VoidCallback onViewRecommendations;

  const TripBottomActionBar({
    super.key,
    required this.currentStep,
    required this.onCancelOrBack,
    required this.onContinueToStep2,
    required this.onSavePreferences,
    required this.onViewRecommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: currentStep == 0
          ? _buildStep1BottomBar()
          : _buildStep2BottomBar(context),
    );
  }

  /// Bilah Tombol Langkah 1 (Rencana Dasar)
  Widget _buildStep1BottomBar() {
    return Row(
      children: [
        // Tombol Batal
        OutlinedButton(
          onPressed: onCancelOrBack,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: const Text(
            'Batal',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Tombol Utama: Lanjutkan ke Preferensi
        Expanded(
          child: ElevatedButton(
            onPressed: onContinueToStep2,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ManropeFont(
                  'Lanjutkan ke Preferensi',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Bilah Tombol Langkah 2 (Preferensi Wisata)
  /// Sesuai tampilan yang diinginkan pengguna:
  /// [Kembali] [Simpan] [Lihat Rekomendasi] (Bisa diklik, menampilkan info belum tersedia)
  Widget _buildStep2BottomBar(BuildContext context) {
    return Row(
      children: [
        // 1. Tombol Kembali ke Langkah 1
        OutlinedButton(
          onPressed: onCancelOrBack,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, size: 15, color: AppColors.textPrimary),
              SizedBox(width: 4),
              Text(
                'Kembali',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // 2. Tombol Simpan Preferensi
        OutlinedButton(
          onPressed: onSavePreferences,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(color: AppColors.primary, width: 1.2),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.save_outlined, size: 15, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'Simpan',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // 3. Tombol Lihat Rekomendasi
        Expanded(
          child: ElevatedButton(
            onPressed: onViewRecommendations,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.explore_outlined, size: 16),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Lihat Rekomendasi',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
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
}
