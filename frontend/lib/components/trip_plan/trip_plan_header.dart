import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Header
class TripPlanHeader extends StatelessWidget implements PreferredSizeWidget {
  final int currentStep;
  final VoidCallback onBack;

  const TripPlanHeader({
    super.key,
    required this.currentStep,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: onBack,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SmartTrip',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Langkah ${currentStep + 1} dari 2',
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: AppColors.textSecondary, size: 20),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Lengkapi formulir rencana dan preferensi liburan Anda di Batam.',
                  style: TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.grey.shade800,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: LinearProgressIndicator(
          value: (currentStep + 1) / 2.0,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 3,
        ),
      ),
    );
  }
}
