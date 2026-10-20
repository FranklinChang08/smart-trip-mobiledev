import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/components/trip_plan/trip_bottom_action_bar.dart';
import 'package:frontend/components/trip_plan/trip_plan_header.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';
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

  List<TripThemeModel> _availableThemes = kTripThemes;
  final Set<String> _selectedThemes = {
    'Wisata Pantai',
    'Wisata Belanja',
    'Wisata Alam',
  };

  List<TripAreaModel> _availableAreas = kBatamKecamatanList;
  final Set<String> _selectedAreas = {
    'Batam Kota',
    'Lubuk Baja',
    'Sagulung',
  };

  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);

  bool _isHalalOnly = true;
  bool _isSeafoodSpecialist = true;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _tripNameController = TextEditingController(
      text: 'Liburan Akhir Pekan di Batam',
    );
    _budgetController = TextEditingController(text: '5.000.000');
    _notesController = TextEditingController();

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
    if (mounted) {
      setState(() {
        if (categories.isNotEmpty) _availableThemes = categories;
        if (kecamatanList.isNotEmpty) _availableAreas = kecamatanList;
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

  /// Dialog pemilihan Titik Awal Perjalanan dengan fitur pencarian real-time, filter kategori,
  /// dan meletakkan item yang terpilih di paling atas daftar.
  void _openLocationDialog() {
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
            List<TripLocationModel> filtered = kBatamLocations.where((loc) {
              final matchesCategory = selectedCategory == 'all' ||
                  loc.category == selectedCategory;
              final query = searchQuery.trim().toLowerCase();
              final matchesQuery = query.isEmpty ||
                  loc.name.toLowerCase().contains(query) ||
                  loc.type.toLowerCase().contains(query) ||
                  loc.quickLabel.toLowerCase().contains(query);
              return matchesCategory && matchesQuery;
            }).toList();

            // Urutkan lokasi
            filtered.sort((a, b) {
              if (a.name == _selectedLocation) return -1;
              if (b.name == _selectedLocation) return 1;
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
                          child: const Icon(Icons.location_on_outlined,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pilih Titik Awal Perjalanan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Mulai dari pelabuhan, bandara, atau hotel tempat menginap',
                                style: TextStyle(
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
                        hintText: 'Cari hotel, pelabuhan, bandara (mis: Aston)...',
                        hintStyle:
                            TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search,
                            size: 20, color: AppColors.primary),
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
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
                                () => selectedCategory = 'pelabuhan'),
                          ),
                          const SizedBox(width: 6),
                          _buildFilterCategoryPill(
                            label: '✈️ Bandara',
                            isSelected: selectedCategory == 'bandara',
                            onTap: () => setModalState(
                                () => selectedCategory = 'bandara'),
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
                                  Icon(Icons.search_off,
                                      size: 40, color: Colors.grey.shade400),
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
                                horizontal: 16, vertical: 12),
                            itemCount: filtered.length,
                            separatorBuilder: (context, i) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final loc = filtered[i];
                              final isSelected = _selectedLocation == loc.name;

                              return InkWell(
                                onTap: () {
                                  setState(() => _selectedLocation = loc.name);
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                            .withValues(alpha: 0.07)
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                                    bottom: 3),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  '📍 TITIK AWAL TERPILIH',
                                                  style: TextStyle(
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
                                      if (isSelected)
                                        const Icon(Icons.check_circle,
                                            color: AppColors.primary, size: 22)
                                      else
                                        Icon(Icons.chevron_right,
                                            color: Colors.grey.shade400,
                                            size: 20),
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

  Widget _buildFilterCategoryPill({
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
      _showWarningSnackBar('Pilih minimal 1 kecamatan destinasi di Kota Batam.');
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
      budget: _budgetController.text.trim(),
      budgetPriority: _isSeafoodSpecialist
          ? 'Seafood Pesisir & Kuliner'
          : 'Kuliner & Wisata Batam',
      selectedThemes: _selectedThemes.toList(),
      selectedAreas: _selectedAreas.toList(),
      notes: _notesController.text.trim(),
      transport: 'Mobil Sewa + Driver Lokal',
      isActive: true,
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
          budgetPriority: _isSeafoodSpecialist
              ? 'Seafood Pesisir & Kuliner'
              : 'Kuliner & Wisata Batam',
          selectedThemes: _selectedThemes.toList(),
          selectedAreas: _selectedAreas.toList(),
          notes: _notesController.text.trim(),
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

  /// Tombol Rekomendasi
  void _onRecommendationsClicked() async {
    if (!_validateStep1()) {
      setState(() => _currentStep = 0);
      return;
    }
    if (!_validateStep2()) return;

    final plan = SavedTripPlan(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      tripName: _tripNameController.text.trim().isNotEmpty
          ? _tripNameController.text.trim()
          : 'Liburan Akhir Pekan di Batam',
      startDate: _startDate,
      endDate: _endDate,
      startLocation: _selectedLocation,
      budget: _budgetController.text.trim(),
      selectedThemes: _selectedThemes.toList(),
      selectedAreas: _selectedAreas.toList(),
      budgetPriority: _isSeafoodSpecialist
          ? 'Seafood Pesisir & Kuliner'
          : 'Kuliner & Wisata Batam',
      notes: _notesController.text.trim(),
      transport: 'Mobil Sewa + Driver Lokal',
      isActive: true,
    );

    // Simpan otomatis sebagai rencana aktif ke backend & local cache
    _planSaved = true;
    final saved = await TripPlanService.saveTripPlan(plan);

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripItineraryPage(
          planId: saved?.id ?? plan.id,
          tripName: saved?.tripName ?? plan.tripName,
          startDate: saved?.startDate ?? plan.startDate,
          endDate: saved?.endDate ?? plan.endDate,
          startLocation: saved?.startLocation ?? plan.startLocation,
          budget: saved?.budget ?? plan.budget,
          selectedThemes: saved?.selectedThemes ?? plan.selectedThemes,
          selectedAreas: saved?.selectedAreas ?? plan.selectedAreas,
          budgetPriority: saved?.budgetPriority ?? plan.budgetPriority,
          notes: saved?.notes ?? plan.notes,
          transport: saved?.transport ?? plan.transport,
          initialDetails: saved?.details,
        ),
      ),
    );

    // Ketika kembali dari melihat susunan itinerary, kembali ke halaman utama (HomePage) dengan sinyal update
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
                availableAreas: _availableAreas,
                selectedAreas: _selectedAreas,
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
                onToggleArea: (area) {
                  setState(() {
                    if (_selectedAreas.contains(area)) {
                      if (_selectedAreas.length > 1) {
                        _selectedAreas.remove(area);
                      } else {
                        _showWarningSnackBar('Pilih minimal 1 kecamatan destinasi.');
                      }

                    } else {
                      _selectedAreas.add(area);
                    }
                  });
                },
                onToggleHalal: (val) => setState(() => _isHalalOnly = val),
                onToggleSeafood: (val) =>
                    setState(() => _isSeafoodSpecialist = val),
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
        onViewRecommendations: _onRecommendationsClicked,
      ),
    );
  }
}