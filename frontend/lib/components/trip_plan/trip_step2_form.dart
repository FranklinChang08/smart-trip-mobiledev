import 'package:flutter/material.dart';
import 'package:frontend/components/font/noto_font.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/components/trip_plan/trip_plan_models.dart';

/// Formulir Langkah 2: Mengisi Preferensi Perjalanan 
/// Berisi: Minat Wisata, Waktu Kunjungan, Area Batam, Prioritas Anggaran, & Catatan
class TripStep2Form extends StatelessWidget {
  final Set<String> selectedThemes;
  final Set<String> selectedVisitTimes;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Set<String> selectedAreas;
  final String budgetPriority;
  final bool isHalalOnly;
  final bool isSeafoodSpecialist;
  final TextEditingController notesController;
  final List<TripThemeModel> availableThemes;
  final ValueChanged<String> onToggleTheme;
  final ValueChanged<String> onToggleVisitTime;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final ValueChanged<String> onToggleArea;
  final ValueChanged<String> onSelectBudgetPriority;
  final ValueChanged<bool> onToggleHalal;
  final ValueChanged<bool> onToggleSeafood;

  const TripStep2Form({
    super.key,
    required this.selectedThemes,
    this.availableThemes = kTripThemes,
    required this.selectedVisitTimes,
    required this.startTime,
    required this.endTime,
    required this.selectedAreas,
    required this.budgetPriority,
    required this.isHalalOnly,
    required this.isSeafoodSpecialist,
    required this.notesController,
    required this.onToggleTheme,
    required this.onToggleVisitTime,
    required this.onPickStartTime,
    required this.onPickEndTime,
    required this.onToggleArea,
    required this.onSelectBudgetPriority,
    required this.onToggleHalal,
    required this.onToggleSeafood,
  });

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
        _buildVisitTimeSection(),
        const SizedBox(height: 16),
        _buildAreasSection(),
        const SizedBox(height: 16),
        _buildBudgetPrioritySection(),
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
            'Tentukan minat wisata, rentang waktu aktivitas harian, serta koridor area Batam yang ingin dikunjungi. Susunan rekomendasi perjalanan akan otomatis dirangkai sesuai pilihan Anda.',
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

  Widget _buildThemesSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.interests_outlined,
            title: 'Minat Wisata di Batam',
            isRequired: true,
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih satu atau beberapa kategori wisata yang paling Anda minati.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: availableThemes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.75,
            ),
            itemBuilder: (context, index) {
              final theme = availableThemes[index];
              final isSelected = selectedThemes.contains(theme.title);

              return InkWell(
                onTap: () => onToggleTheme(theme.title),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          theme.icon,
                          size: 18,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              theme.title,
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
                            const SizedBox(height: 2),
                            Text(
                              theme.desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9.5,
                                height: 1.25,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVisitTimeSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.schedule_outlined,
            title: 'Waktu Kunjungan Aktivitas',
            isRequired: true,
          ),
          const SizedBox(height: 4),
          const Text(
            'Kapan waktu favorit Anda untuk beraktivitas selama liburan?',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Column(
            children: kVisitTimeOptions.map((opt) {
              final isSelected = selectedVisitTimes.contains(opt.label);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => onToggleVisitTime(opt.label),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 18,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt.label,
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
                              Text(
                                opt.desc,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Rentang Jam Aktivitas Harian:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTimePickerBox(
                  label: 'Mulai Aktivitas',
                  timeString: _formatTime(startTime),
                  onTap: onPickStartTime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTimePickerBox(
                  label: 'Selesai Aktivitas',
                  timeString: _formatTime(endTime),
                  onTap: onPickEndTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerBox({
    required String label,
    required String timeString,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$timeString WIB',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreasSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.map_outlined,
            title: 'Area / Koridor Destinasi di Batam',
            isRequired: true,
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih area yang ingin Anda jelajahi untuk pengelompokan rute yang efisien.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Column(
            children: kBatamAreaOptions.map((area) {
              final isSelected = selectedAreas.contains(area.name);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => onToggleArea(area.name),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
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
                        Text(area.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                area.name,
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
                                area.desc,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade400,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetPrioritySection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.pie_chart_outline,
            title: 'Prioritas Alokasi Anggaran',
          ),
          const SizedBox(height: 4),
          const Text(
            'Fokuskan anggaran Anda pada elemen liburan yang paling diprioritaskan.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kBudgetPriorityOptions.map((opt) {
              final isSelected = budgetPriority == opt;
              return ChoiceChip(
                label: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: const Color(0xFFF1F5F9),
                onSelected: (val) {
                  if (val) onSelectBudgetPriority(opt);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _buildSwitchRow(
            title: 'Utamakan Makanan Halal Bersertifikat',
            subtitle: 'Filter rekomendasi restoran & kedai kuliner halal',
            value: isHalalOnly,
            onChanged: onToggleHalal,
          ),
          const SizedBox(height: 10),
          _buildSwitchRow(
            title: 'Sertakan Restoran Kelong Seafood Terapung',
            subtitle: 'Pengalaman bersantap seafood segar di atas laut Barelang',
            value: isSeafoodSpecialist,
            onChanged: onToggleSeafood,
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
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
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
          activeTrackColor: AppColors.primary,
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
            icon: Icons.notes,
            title: 'Catatan Khusus (Opsional)',
          ),
          const SizedBox(height: 4),
          const Text(
            'Tuliskan kebutuhan khusus seperti rombongan lansia, anak kecil, atau preferensi lainnya.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Contoh: Bersama keluarga 4 orang, utamakan destinasi ramah anak.',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
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
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
        NotoFont(
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
