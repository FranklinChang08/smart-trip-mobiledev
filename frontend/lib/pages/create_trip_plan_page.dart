import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/components/trip_plan/trip_bottom_action_bar.dart';
import 'package:frontend/components/trip_plan/trip_plan_header.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';
import 'package:frontend/components/trip_plan/trip_step1_form.dart';
import 'package:frontend/components/trip_plan/trip_step2_form.dart';
import 'package:frontend/components/trip_plan/trip_summary_bottom_sheet.dart';
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

  late final TextEditingController _tripNameController;
  late final TextEditingController _budgetController;
  late DateTime _startDate;
  late DateTime _endDate;
  String _selectedLocation = 'Pelabuhan Ferry Batam Center';

  List<TripThemeModel> _availableThemes = kTripThemes;
  final Set<String> _selectedThemes = {
    'Wisata Pantai',
    'Wisata Belanja',
    'Wisata Alam',
  };

  final Set<String> _selectedVisitTimes = {
    '🌅 Pagi Hari (08:00 - 12:00)',
    '🌇 Sore Golden Hour (15:00 - 18:30)',
  };

  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);

  final Set<String> _selectedAreas = {
    'Nagoya & Jodoh',
    'Barelang & Pulau Galang',
  };

  String _budgetPriority = 'Kuliner & Seafood Kelong';
  bool _isHalalOnly = true;
  bool _isSeafoodSpecialist = true;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _tripNameController =
        TextEditingController(text: 'Liburan Akhir Pekan di Batam');
    _budgetController = TextEditingController(text: '5.000.000');
    _notesController = TextEditingController();

    final now = DateTime.now();
    _startDate =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    _endDate = _startDate.add(const Duration(days: 2));

    _loadCategoriesFromApi();
  }

  Future<void> _loadCategoriesFromApi() async {
    final categories = await TripPlanService.fetchCategories();
    if (mounted && categories.isNotEmpty) {
      setState(() {
        _availableThemes = categories;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tripNameController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
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
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
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

  void _openLocationDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Titik Awal Perjalanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tentukan pelabuhan ferry atau bandara kedatangan Anda di Batam.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: kBatamLocations.length,
                  separatorBuilder: (context, i) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final loc = kBatamLocations[i];
                    final isSelected = _selectedLocation == loc.name;
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          loc.icon,
                          size: 18,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade600,
                        ),
                      ),
                      title: Text(
                        loc.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        loc.type,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 20)
                          : null,
                      onTap: () {
                        setState(() => _selectedLocation = loc.name);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
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
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
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
      setState(() => _endTime = picked);
    }
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
      _showWarningSnackBar('Pilih minimal 1 area destinasi di Kota Batam.');
      return false;
    }
    return true;
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 20),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TripSummaryBottomSheet(
          tripName: _tripNameController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          startLocation: _selectedLocation,
          budget: _budgetController.text.trim(),
          budgetPriority: _budgetPriority,
          selectedThemes: _selectedThemes.toList(),
          selectedAreas: _selectedAreas.toList(),
          notes: _notesController.text.trim(),
          onFinishAndGoHome: () {
            Navigator.pop(context);
            Navigator.pop(context); 
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Rencana "${_tripNameController.text.trim()}" berhasil disimpan!',
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

  /// Tombol Rekomendasi
  void _onRecommendationsClicked() {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: TripPlanHeader(
        currentStep: _currentStep,
        onBack: () {
          if (_currentStep == 0) {
            Navigator.pop(context);
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
                budgetController: _budgetController,
                onSelectDateRange: _selectDateRange,
                onSelectDurationPreset: _selectDurationPreset,
                onPickTime: _pickTime,
                onSelectLocation: (loc) =>
                    setState(() => _selectedLocation = loc),
                onOpenLocationDialog: _openLocationDialog,
                onSelectBudgetPreset: (preset) {
                  setState(() => _budgetController.text = preset);
                },
                onGoToPreferences: _goToStep2,
              )
            : TripStep2Form(
                availableThemes: _availableThemes,
                selectedThemes: _selectedThemes,
                selectedVisitTimes: _selectedVisitTimes,
                startTime: _startTime,
                endTime: _endTime,
                selectedAreas: _selectedAreas,
                budgetPriority: _budgetPriority,
                isHalalOnly: _isHalalOnly,
                isSeafoodSpecialist: _isSeafoodSpecialist,
                notesController: _notesController,
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
                onToggleVisitTime: (time) {
                  setState(() {
                    if (_selectedVisitTimes.contains(time)) {
                      if (_selectedVisitTimes.length > 1) {
                        _selectedVisitTimes.remove(time);
                      }
                    } else {
                      _selectedVisitTimes.add(time);
                    }
                  });
                },
                onPickStartTime: _pickStartTime,
                onPickEndTime: _pickEndTime,
                onToggleArea: (area) {
                  setState(() {
                    if (_selectedAreas.contains(area)) {
                      if (_selectedAreas.length > 1) {
                        _selectedAreas.remove(area);
                      } else {
                        _showWarningSnackBar('Pilih minimal 1 area destinasi.');
                      }
                    } else {
                      _selectedAreas.add(area);
                    }
                  });
                },
                onSelectBudgetPriority: (p) =>
                    setState(() => _budgetPriority = p),
                onToggleHalal: (val) => setState(() => _isHalalOnly = val),
                onToggleSeafood: (val) =>
                    setState(() => _isSeafoodSpecialist = val),
              ),
      ),
      bottomNavigationBar: TripBottomActionBar(
        currentStep: _currentStep,
        onCancelOrBack: () {
          if (_currentStep == 0) {
            Navigator.pop(context);
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
        onViewRecommendations: _onRecommendationsClicked,
      ),
    );
  }
}
