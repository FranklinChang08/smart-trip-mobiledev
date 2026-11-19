import 'package:flutter/material.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';
import 'package:frontend/components/trip_plan/trip_location_selector.dart';
import 'package:frontend/components/trip_plan/trip_step1_form.dart';
import 'package:frontend/components/trip_plan/trip_step2_form.dart';
import 'package:frontend/components/trip_plan/trip_summary_bottom_sheet.dart';
import 'package:frontend/pages/trip_itinerary_page.dart';
import 'package:frontend/services/trip_plan_service.dart';

/// Halaman Membuat Rencana Perjalanan & Mengisi Preferensi
class CreateTripPlanPage extends StatefulWidget {
  const CreateTripPlanPage({super.key});

  @override
  State<CreateTripPlanPage> createState() => _CreateTripPlanPageState();
}

class _CreateTripPlanPageState extends State<CreateTripPlanPage> {
  int _currentStep = 0;
  final ScrollController _scrollController = ScrollController();
  bool _planSaved = false;

  late final TextEditingController _tripNameController;
  late final TextEditingController _budgetController;
  late DateTime _startDate;
  late DateTime _endDate;
  String _selectedLocation = 'Pelabuhan Ferry Batam Center';
  TripLocationModel? _selectedLocationModel;
  String _selectedEndLocation = 'Pelabuhan Ferry Batam Center';
  TripLocationModel? _selectedEndLocationModel;
  List<TripLocationModel> _availableLocations = kBatamLocations;

  List<TripThemeModel> _availableThemes = kTripThemes;
  final Set<String> _selectedThemes = {
    'Wisata Pantai',
    'Wisata Belanja',
    'Wisata Alam',
  };

  List<TripAreaModel> _availableAreas = kBatamKecamatanList;
  final Set<String> _selectedAreas = {'Batam Kota', 'Lubuk Baja', 'Sagulung'};

  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);

  bool _isHalalOnly = true;
  bool _isSeafoodSpecialist = true;

  @override
  void initState() {
    super.initState();
    _tripNameController = TextEditingController(
      text: 'Liburan Akhir Pekan di Batam',
    );
    _budgetController = TextEditingController(text: '5.000.000');

    final now = DateTime.now();
    _startDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    _endDate = _startDate.add(const Duration(days: 2));

    _loadMasterDataFromApi();
  }

  Future<void> _loadMasterDataFromApi() async {
    final categories = await TripPlanService.fetchCategories();
    final kecamatanList = await TripPlanService.fetchKecamatan();
    final locations = await TripPlanService.fetchLocations();
    if (mounted) {
      setState(() {
        if (categories.isNotEmpty) _availableThemes = categories;
        if (kecamatanList.isNotEmpty) _availableAreas = kecamatanList;
        if (locations.isNotEmpty) {
          _availableLocations = locations;
          _selectedLocationModel = locations.firstWhere(
            (l) => l.name == _selectedLocation,
            orElse: () => locations.first,
          );
          _selectedLocation = _selectedLocationModel!.name;

          _selectedEndLocationModel = locations.firstWhere(
            (l) => l.name == _selectedEndLocation,
            orElse: () => _selectedLocationModel!,
          );
          _selectedEndLocation = _selectedEndLocationModel!.name;
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tripNameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final firstAllowedDate = DateTime(now.year, now.month, now.day);
    final lastAllowedDate = DateTime(now.year + 2, 12, 31);

    final initialStart = _startDate.isBefore(firstAllowedDate)
        ? firstAllowedDate
        : _startDate;
    final initialEnd = _endDate.isBefore(initialStart)
        ? initialStart.add(const Duration(days: 2))
        : _endDate;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstAllowedDate,
      lastDate: lastAllowedDate,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _selectDurationPreset(int days) {
    setState(() {
      _endDate = _startDate.add(Duration(days: days > 0 ? days - 1 : 0));
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  /// Menampilkan detail lengkap titik lokasi dari database
  void _showLocationDetail(TripLocationModel loc) {
    TripLocationModal.showLocationDetail(
      context: context,
      location: loc,
    );
  }

  /// Dialog pemilihan Titik Awal / Akhir Perjalanan
  void _openLocationDialog({bool isEndLocation = false}) {
    TripLocationModal.showLocationDialog(
      context: context,
      availableLocations: _availableLocations,
      currentSelectedName:
          isEndLocation ? _selectedEndLocation : _selectedLocation,
      isEndLocation: isEndLocation,
      onLocationSelected: (loc) {
        setState(() {
          if (isEndLocation) {
            _selectedEndLocation = loc.name;
            _selectedEndLocationModel = loc;
          } else {
            _selectedLocation = loc.name;
            _selectedLocationModel = loc;
          }
        });
      },
      onShowDetail: _showLocationDetail,
    );
  }

  // VALIDASI & NAVIGASI

  bool _validateStep1() {
    if (_tripNameController.text.trim().isEmpty) {
      _showWarningSnackBar('Masukkan nama rencana perjalanan terlebih dahulu.');
      return false;
    }
    if (_budgetController.text.trim().isEmpty) {
      _showWarningSnackBar('Masukkan estimasi anggaran perjalanan Anda.');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_selectedThemes.isEmpty) {
      _showWarningSnackBar('Pilih minimal 1 minat wisata yang diinginkan.');
      return false;
    }
    if (_selectedAreas.isEmpty) {
      _showWarningSnackBar(
        'Pilih minimal 1 kecamatan destinasi di Kota Batam.',
      );
      return false;
    }
    return true;
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFC05400),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _goToStep2() {
    if (!_validateStep1()) return;
    setState(() => _currentStep = 1);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _savePreferences() {
    if (!_validateStep2()) return;

    final newPlan = SavedTripPlan(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      tripName: _tripNameController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      startLocation: _selectedLocation,
      titikAwalId: _selectedLocationModel?.id,
      titikAwalType: _selectedLocationModel?.modelType,
      endLocation: _selectedEndLocation,
      titikAkhirId: _selectedEndLocationModel?.id,
      titikAkhirType: _selectedEndLocationModel?.modelType,
      budget: _budgetController.text.trim(),
      selectedThemes: _selectedThemes.toList(),
      selectedAreas: _selectedAreas.toList(),
      isHalal: _isHalalOnly,
      isSeafood: _isSeafoodSpecialist,
      isActive: true,
      isDraft: false,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return TripSummaryBottomSheet(
          tripName: _tripNameController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          startLocation: _selectedLocation,
          budget: _budgetController.text.trim(),
          selectedThemes: _selectedThemes.toList(),
          selectedAreas: _selectedAreas.toList(),
          onFinishAndGoHome: () async {
            _planSaved = true;
            final nav = Navigator.of(context);
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final modalNav = Navigator.of(bottomSheetContext);

            await TripPlanService.saveTripPlan(newPlan);

            modalNav.pop(); // Tutup bottom sheet
            nav.pop(true); // Kembali ke HomePage dengan hasil update
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Rencana "${_tripNameController.text.trim()}" berhasil disimpan & diaktifkan!',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 3),
              ),
            );
          },
        );
      },
    );
  }

  /// Buat rencana perjalanan langsung dengan AI & buka Jadwal Rekomendasi Resmi
  void _onRecommendationsClicked() async {
    if (!_validateStep1()) {
      setState(() => _currentStep = 0);
      return;
    }

    if (!_validateStep2()) return;

    final plan = SavedTripPlan(
      id: '',
      tripName: _tripNameController.text.trim().isNotEmpty
          ? _tripNameController.text.trim()
          : 'Liburan Akhir Pekan di Batam',
      startDate: _startDate,
      endDate: _endDate,
      startLocation: _selectedLocation,
      titikAwalId: _selectedLocationModel?.id,
      titikAwalType: _selectedLocationModel?.modelType,
      endLocation: _selectedEndLocation,
      titikAkhirId: _selectedEndLocationModel?.id,
      titikAkhirType: _selectedEndLocationModel?.modelType,
      budget: _budgetController.text.trim(),
      selectedThemes: _selectedThemes.toList(),
      selectedAreas: _selectedAreas.toList(),
      isHalal: _isHalalOnly,
      isSeafood: _isSeafoodSpecialist,
      isActive: true,
      isDraft: false,
    );

    _planSaved = true;

    // Tampilkan modal loading agar user melihat proses pembuatan rekomendasi AI
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Menyusun Rekomendasi AI...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SmartTrip sedang memilih destinasi wisata, restoran, dan rute terbaik untuk Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final saved = await TripPlanService.saveTripPlan(plan, isDraft: false);

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Tutup dialog loading

    if (saved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyusun rekomendasi AI. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final targetPlanId = saved.id.isNotEmpty ? saved.id : null;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripItineraryPage(
          planId: targetPlanId,
          tripName: saved.tripName,
          startDate: saved.startDate,
          endDate: saved.endDate,
          startLocation: saved.startLocation,
          budget: saved.budget,
          selectedThemes: saved.selectedThemes,
          selectedAreas: saved.selectedAreas,
          notes: saved.notes,
          isDraft: false,
          initialHariPerjalanan: saved.hariPerjalanan,
        ),
      ),
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  /// Simpan draf rencana perjalanan & buka Jadwal Perjalanan Draf (bisa kustom/ubah titik awal & akhir)
  void _onSaveAsDraftClicked() async {
    if (!_validateStep1()) {
      setState(() => _currentStep = 0);
      return;
    }

    if (!_validateStep2()) return;

    final plan = SavedTripPlan(
      id: '',
      tripName: _tripNameController.text.trim().isNotEmpty
          ? _tripNameController.text.trim()
          : 'Liburan Akhir Pekan di Batam',
      startDate: _startDate,
      endDate: _endDate,
      startLocation: _selectedLocation,
      titikAwalId: _selectedLocationModel?.id,
      titikAwalType: _selectedLocationModel?.modelType,
      endLocation: _selectedEndLocation,
      titikAkhirId: _selectedEndLocationModel?.id,
      titikAkhirType: _selectedEndLocationModel?.modelType,
      budget: _budgetController.text.trim(),
      selectedThemes: _selectedThemes.toList(),
      selectedAreas: _selectedAreas.toList(),
      isHalal: _isHalalOnly,
      isSeafood: _isSeafoodSpecialist,
      isActive: true,
      isDraft: true,
    );

    _planSaved = true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text('Menyiapkan draf rencana perjalanan Anda...'),
            ),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    final saved = await TripPlanService.saveTripPlan(plan, isDraft: true);

    if (!mounted) return;

    final targetPlanId = (saved?.id != null && saved!.id.isNotEmpty)
        ? saved.id
        : (plan.id.isNotEmpty ? plan.id : null);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripItineraryPage(
          planId: targetPlanId,
          tripName: saved?.tripName ?? plan.tripName,
          startDate: saved?.startDate ?? plan.startDate,
          endDate: saved?.endDate ?? plan.endDate,
          startLocation: saved?.startLocation ?? plan.startLocation,
          budget: saved?.budget ?? plan.budget,
          selectedThemes: saved?.selectedThemes ?? plan.selectedThemes,
          selectedAreas: saved?.selectedAreas ?? plan.selectedAreas,
          notes: saved?.notes ?? plan.notes,
          isDraft: true,
          initialHariPerjalanan: saved?.hariPerjalanan,
        ),
      ),
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: TripPlanHeader(
        currentStep: _currentStep,
        onBack: () {
          if (_currentStep == 0) {
            Navigator.pop(context, _planSaved);
          } else {
            setState(() => _currentStep = 0);
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        },
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: _currentStep == 0
            ? TripStep1Form(
                tripNameController: _tripNameController,
                startDate: _startDate,
                endDate: _endDate,
                startTime: _startTime,
                endTime: _endTime,
                selectedLocation: _selectedLocation,
                selectedEndLocation: _selectedEndLocation,
                selectedLocationModel: _selectedLocationModel,
                selectedEndLocationModel: _selectedEndLocationModel,
                availableLocations: _availableLocations,
                budgetController: _budgetController,
                onSelectDateRange: _selectDateRange,
                onSelectDurationPreset: _selectDurationPreset,
                onPickTime: _pickTime,
                onSelectLocation: (loc) {
                  setState(() {
                    _selectedLocation = loc;
                    _selectedLocationModel = _availableLocations.firstWhere(
                      (l) => l.name == loc,
                      orElse: () => _availableLocations.first,
                    );
                    _selectedEndLocation = loc;
                    _selectedEndLocationModel = _selectedLocationModel;
                  });
                },
                onSelectEndLocation: (loc) {
                  setState(() {
                    _selectedEndLocation = loc;
                    _selectedEndLocationModel = _availableLocations.firstWhere(
                      (l) => l.name == loc,
                      orElse: () => _availableLocations.first,
                    );
                  });
                },
                onOpenLocationDialog: _openLocationDialog,
                onShowLocationDetail: _showLocationDetail,
                onSelectBudgetPreset: (preset) {
                  setState(() => _budgetController.text = preset);
                },
                onGoToPreferences: _goToStep2,
              )
            : TripStep2Form(
                availableThemes: _availableThemes,
                selectedThemes: _selectedThemes,
                availableAreas: _availableAreas,
                selectedAreas: _selectedAreas,
                isHalalOnly: _isHalalOnly,
                isSeafoodSpecialist: _isSeafoodSpecialist,
                onToggleTheme: (theme) {
                  setState(() {
                    if (_selectedThemes.contains(theme)) {
                      if (_selectedThemes.length > 1) {
                        _selectedThemes.remove(theme);
                      } else {
                        _showWarningSnackBar('Pilih minimal 1 minat wisata.');
                      }
                    } else {
                      _selectedThemes.add(theme);
                    }
                  });
                },
                onToggleArea: (area) {
                  setState(() {
                    if (_selectedAreas.contains(area)) {
                      if (_selectedAreas.length > 1) {
                        _selectedAreas.remove(area);
                      } else {
                        _showWarningSnackBar(
                          'Pilih minimal 1 kecamatan destinasi.',
                        );
                      }
                    } else {
                      _selectedAreas.add(area);
                    }
                  });
                },
                onToggleHalal: (val) => setState(() => _isHalalOnly = val),
                onToggleSeafood: (val) =>
                    setState(() => _isSeafoodSpecialist = val),
                onGenerateRecommendations: _onRecommendationsClicked,
                onSaveAsDraft: _onSaveAsDraftClicked,
              ),
      ),
      bottomNavigationBar: TripBottomActionBar(
        currentStep: _currentStep,
        onCancelOrBack: () {
          if (_currentStep == 0) {
            Navigator.pop(context, _planSaved);
          } else {
            setState(() => _currentStep = 0);
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        },
        onContinueToStep2: _goToStep2,
        onSavePreferences: _savePreferences,
        onSaveAsDraft: _onSaveAsDraftClicked,
        onViewRecommendations: _onRecommendationsClicked,
      ),
    );
  }
}


/// Header AppBar khusus halaman pembuatan rencana perjalanan
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
          icon: const Icon(
            Icons.help_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
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

/// Bilah tombol navigasi bawah halaman pembuatan rencana perjalanan
class TripBottomActionBar extends StatelessWidget {
  final int currentStep;
  final VoidCallback onCancelOrBack;
  final VoidCallback onContinueToStep2;
  final VoidCallback onSavePreferences;
  final VoidCallback? onSaveAsDraft;
  final VoidCallback onViewRecommendations;

  const TripBottomActionBar({
    super.key,
    required this.currentStep,
    required this.onCancelOrBack,
    required this.onContinueToStep2,
    required this.onSavePreferences,
    this.onSaveAsDraft,
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

  Widget _buildStep1BottomBar() {
    return Row(
      children: [
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
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
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

  Widget _buildStep2BottomBar(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: onCancelOrBack,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
        OutlinedButton(
          onPressed: onSaveAsDraft ?? onSavePreferences,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(color: AppColors.primary, width: 1.2),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.note_add_outlined, size: 15, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'Ke Draf',
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
        Expanded(
          child: ElevatedButton(
            onPressed: onViewRecommendations,
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
                Icon(Icons.auto_awesome, size: 15),
                SizedBox(width: 5),
                Flexible(
                  child: ManropeFont(
                    'Rekomendasi AI',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
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
