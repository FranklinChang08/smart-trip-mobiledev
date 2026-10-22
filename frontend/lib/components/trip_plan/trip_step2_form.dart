import 'package:flutter/material.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';

/// Mengisi Preferensi Perjalanan (Minat Wisata, Kecamatan, dan Kuliner)
class TripStep2Form extends StatefulWidget {
  final Set<String> selectedThemes;
  final List<TripThemeModel> availableThemes;
  final Set<String> selectedAreas;
  final List<TripAreaModel> availableAreas;
  final bool isHalalOnly;
  final bool isSeafoodSpecialist;
  final TextEditingController notesController;
  final ValueChanged<String> onToggleTheme;
  final ValueChanged<String> onToggleArea;
  final ValueChanged<bool> onToggleHalal;
  final ValueChanged<bool> onToggleSeafood;

  final Set<String>? selectedVisitTimes;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final ValueChanged<String>? onToggleVisitTime;
  final VoidCallback? onPickStartTime;
  final VoidCallback? onPickEndTime;

  const TripStep2Form({
    super.key,
    required this.selectedThemes,
    this.availableThemes = kTripThemes,
    required this.selectedAreas,
    this.availableAreas = kBatamKecamatanList,
    required this.isHalalOnly,
    required this.isSeafoodSpecialist,
    required this.notesController,
    required this.onToggleTheme,
    required this.onToggleArea,
    required this.onToggleHalal,
    required this.onToggleSeafood,
    this.selectedVisitTimes,
    this.startTime,
    this.endTime,
    this.onToggleVisitTime,
    this.onPickStartTime,
    this.onPickEndTime,
  });

  @override
  State<TripStep2Form> createState() => _TripStep2FormState();
}

class _TripStep2FormState extends State<TripStep2Form> {
  final TextEditingController _kecamatanSearchController =
      TextEditingController();
  String _kecamatanSearchQuery = '';
  bool _isExpandedKecamatan = false;

  final TextEditingController _themeSearchController = TextEditingController();
  String _themeSearchQuery = '';

  @override
  void dispose() {
    _kecamatanSearchController.dispose();
    _themeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStep2Banner(),
        const SizedBox(height: 16),
        _buildThemesSection(),
        const SizedBox(height: 16),
        _buildAreasSection(),
        const SizedBox(height: 16),
        _buildFoodPreferencesSection(),
        const SizedBox(height: 16),
        _buildNotesSection(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep2Banner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tune,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Preferensi Liburan Batam',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tentukan minat wisata, kecamatan tujuan, serta preferensi kuliner Anda. Susunan rekomendasi perjalanan akan otomatis dirangkai sesuai pilihan Anda.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Bagian Pilihan Minat Wisata (Layout Ringkas Menggunakan Wrap Chips)
  Widget _buildThemesSection() {
    final filteredThemes = widget.availableThemes.where((theme) {
      if (_themeSearchQuery.isEmpty) return true;
      return theme.title
          .toLowerCase()
          .contains(_themeSearchQuery.toLowerCase());
    }).toList();

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionTitle(
                  icon: Icons.interests_outlined,
                  title: 'Minat Wisata di Batam',
                  isRequired: true,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.selectedThemes.length} dipilih',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih satu atau beberapa kategori wisata yang paling Anda minati.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Jika kategori banyak (> 8), sediakan pencarian cepat kategori
          if (widget.availableThemes.length > 8) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _themeSearchController,
                onChanged: (val) =>
                    setState(() => _themeSearchQuery = val.trim()),
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari kategori minat wisata...',
                  hintStyle:
                      TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: AppColors.primary),
                  suffixIcon: _themeSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _themeSearchController.clear();
                            setState(() => _themeSearchQuery = '');
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],

          // Wrap Chips Ringkas & Responsif
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filteredThemes.map((theme) {
              final isSelected = widget.selectedThemes.contains(theme.title);

              return InkWell(
                onTap: () => widget.onToggleTheme(theme.title),
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 8.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        theme.icon,
                        size: 16,
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        theme.title,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle,
                          size: 15,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Bagian Pilihan Kecamatan (Layout Ringkas Grid 2-Kolom dengan Pencarian & Toggle)
  Widget _buildAreasSection() {
    final filteredAreas = widget.availableAreas.where((area) {
      if (_kecamatanSearchQuery.isEmpty) return true;
      return area.name
          .toLowerCase()
          .contains(_kecamatanSearchQuery.toLowerCase());
    }).toList();

    // Jika sedang tidak mencari dan belum di-expand, tampilkan 6 kecamatan pertama agar hemat tempat
    final isSearching = _kecamatanSearchQuery.isNotEmpty;
    final displayedAreas = (isSearching || _isExpandedKecamatan)
        ? filteredAreas
        : filteredAreas.take(6).toList();

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionTitle(
                  icon: Icons.map_outlined,
                  title: 'Kecamatan Destinasi di Batam',
                  isRequired: true,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.selectedAreas.length} dipilih',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih kecamatan di Batam yang ingin dikunjungi pada agenda perjalanan.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Kolom Pencarian Cepat Kecamatan
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _kecamatanSearchController,
              onChanged: (val) =>
                  setState(() => _kecamatanSearchQuery = val.trim()),
              style: const TextStyle(
                  fontSize: 12.5, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari kecamatan (mis: Nongsa, Lubuk Baja, Galang)...',
                hintStyle:
                    TextStyle(fontSize: 12, color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search,
                    size: 18, color: AppColors.primary),
                suffixIcon: _kecamatanSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _kecamatanSearchController.clear();
                          setState(() => _kecamatanSearchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Grid 2-Kolom Ringkas
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedAreas.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.75,
            ),
            itemBuilder: (context, i) {
              final area = displayedAreas[i];
              final isSelected = widget.selectedAreas.contains(area.name);

              return InkWell(
                onTap: () => widget.onToggleArea(area.name),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
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
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.14)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          area.icon,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          area.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tombol Expand / Collapse jika tidak sedang mencari dan data > 6
          if (!isSearching && filteredAreas.length > 6) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isExpandedKecamatan = !_isExpandedKecamatan;
                  });
                },
                icon: Icon(
                  _isExpandedKecamatan
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  _isExpandedKecamatan
                      ? 'Tampilkan Lebih Sedikit'
                      : 'Lihat Semua Kecamatan (${widget.availableAreas.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Preferensi Kuliner (is_halal & is_seafood)
  Widget _buildFoodPreferencesSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.restaurant_menu_outlined,
            title: 'Preferensi Kuliner & Makanan',
          ),
          const SizedBox(height: 4),
          const Text(
            'Sesuaikan preferensi santap makanan selama agenda liburan Anda.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          _buildSwitchRow(
            title: 'Utamakan Makanan Halal Bersertifikat',
            subtitle:
                'Prioritaskan rekomendasi restoran, kafe & kedai kuliner halal',
            value: widget.isHalalOnly,
            onChanged: widget.onToggleHalal,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildSwitchRow(
            title: 'Sertakan Restoran Kelong Seafood Terapung',
            subtitle:
                'Pengalaman bersantap seafood segar pesisir laut khas Batam',
            value: widget.isSeafoodSpecialist,
            onChanged: widget.onToggleSeafood,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.note_alt_outlined,
            title: 'Catatan Khusus (Opsional)',
          ),
          const SizedBox(height: 4),
          const Text(
            'Tuliskan kebutuhan khusus seperti rombongan lansia, anak kecil, atau preferensi lainnya.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.notesController,
            maxLines: 3,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText:
                  'Contoh: Bersama rombongan keluarga 4 orang, utamakan destinasi ramah anak.',
              hintStyle:
                  TextStyle(fontSize: 12, color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(12),
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
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    bool isRequired = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 8),
        ManropeFont(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
