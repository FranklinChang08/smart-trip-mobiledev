import 'package:flutter/material.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/components/font/noto_font.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/pages/create_trip_plan_page.dart';
import 'package:frontend/pages/trip_itinerary_page.dart';
import 'package:frontend/services/trip_plan_service.dart';

class TripItineraryTab extends StatefulWidget {
  const TripItineraryTab({super.key});

  @override
  State<TripItineraryTab> createState() => _TripItineraryTabState();
}

class _TripItineraryTabState extends State<TripItineraryTab> {
  SavedTripPlan? _activePlan;

  @override
  void initState() {
    super.initState();
    _loadActivePlan();
  }

  Future<void> _loadActivePlan() async {
    final plan = await TripPlanService.getActiveTripPlan();
    if (mounted) {
      setState(() {
        _activePlan = plan;
      });
    }
  }


  Future<void> _openCreateTripPlan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTripPlanPage(),
      ),
    );
    if (result == true) {
      await _loadActivePlan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = _activePlan ?? SavedTripPlan.defaultPlan();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NotoFont(
                    'Rencana Perjalanan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  ManropeFont(
                    'Susunan rencana wisata Batam Anda',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _openCreateTripPlan,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Kartu Rencana Perjalanan Batam (Wanderlog Itinerary)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Gambar / Banner Kartu
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E293B),
                        AppColors.primary.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 11,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  plan.durationLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC05400),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              plan.isActive ? 'Aktif' : 'Tersimpan',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        plan.tripName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Isi Ringkasan
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Mulai dari: ${plan.startLocation}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Rute: ${plan.routeLabel}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Estimasi Anggaran: ${plan.budget.startsWith('Rp') ? plan.budget : 'Rp ${plan.budget}'}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tombol Aksi Buka Itinerary
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TripItineraryPage(
                                  tripName: plan.tripName,
                                  startDate: plan.startDate,
                                  endDate: plan.endDate,
                                  startLocation: plan.startLocation,
                                  budget: plan.budget,
                                  selectedThemes: plan.selectedThemes,
                                  selectedAreas: plan.selectedAreas,
                                  transport: plan.transport,
                                  budgetPriority: plan.budgetPriority,
                                  notes: plan.notes,
                                ),
                              ),
                            );
                          },
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
                              Icon(Icons.timeline, size: 16),
                              SizedBox(width: 8),
                              ManropeFont(
                                'Buka Susunan Itinerary',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward, size: 15),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Info Penjelasan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_location_alt_outlined,
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
                        'Ingin Rencana Lain?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Atur periode, lokasi awal, minat wisata, dan anggaran Anda sendiri dengan tombol + di kanan atas atau tombol di bawah.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
