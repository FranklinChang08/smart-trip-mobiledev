import 'package:flutter/material.dart';
import 'package:frontend/components/app_notification.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/pages/profile/widgets/password_strength_meter.dart';
import 'package:frontend/pages/profile/widgets/profile_text_field.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final currentPass = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (currentPass.isEmpty) {
      AppNotification.showError(
        context,
        title: 'Form Belum Lengkap',
        message: 'Masukkan kata sandi lama Anda.',
      );
      return;
    }

    if (newPass.isEmpty) {
      AppNotification.showError(
        context,
        title: 'Form Belum Lengkap',
        message: 'Masukkan kata sandi baru Anda.',
      );
      return;
    }

    if (newPass.length < 6) {
      AppNotification.showError(
        context,
        title: 'Kata Sandi Terlalu Pendek',
        message: 'Kata sandi baru minimal harus 6 karakter.',
      );
      return;
    }

    if (newPass != confirmPass) {
      AppNotification.showError(
        context,
        title: 'Konfirmasi Tidak Cocok',
        message: 'Konfirmasi kata sandi baru tidak sama.',
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);

    AppNotification.showSuccess(
      context,
      title: 'Berhasil',
      message: 'Kata sandi Anda berhasil diperbarui.',
    );

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMatching =
        _newPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmPasswordController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const ManropeFont(
          'Changes Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
            onPressed: () {
              AppNotification.show(
                context,
                type: NotificationType.info,
                title: 'Bantuan Keamanan',
                message: 'Gunakan minimal 8 karakter dengan kombinasi huruf besar, kecil, angka, dan simbol.',
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 16, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ManropeFont(
                'Ubah Kata Sandi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const ManropeFont(
                'Perbarui kata sandi akun Anda untuk perlindungan maksimal.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // 1. Kata Sandi Saat Ini
              ProfileTextField(
                label: 'Kata Sandi Saat Ini',
                controller: _currentPasswordController,
                hintText: 'Masukkan kata sandi lama',
                obscureText: _obscureCurrent,
                prefix: const Icon(
                  Icons.vpn_key_outlined,
                  size: 19,
                  color: AppColors.textSecondary,
                ),
                suffix: IconButton(
                  icon: Icon(
                    _obscureCurrent
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscureCurrent = !_obscureCurrent);
                  },
                ),
                trailingLabel: GestureDetector(
                  onTap: () {
                    AppNotification.show(
                      context,
                      type: NotificationType.info,
                      title: 'Reset Kata Sandi',
                      message: 'Tautan pemulihan kata sandi telah dikirim ke email terdaftar Anda.',
                    );
                  },
                  child: const ManropeFont(
                    'Lupa Kata Sandi?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 2. Kata Sandi Baru
              ProfileTextField(
                label: 'Kata Sandi Baru',
                controller: _newPasswordController,
                hintText: 'masukan kata sandi baru',
                obscureText: _obscureNew,
                onChanged: (_) => setState(() {}),
                prefix: const Icon(
                  Icons.lock_outline_rounded,
                  size: 19,
                  color: AppColors.textSecondary,
                ),
                suffix: IconButton(
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscureNew = !_obscureNew);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Indikator Kekuatan Sandi
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: PasswordStrengthMeter(
                  password: _newPasswordController.text,
                ),
              ),

              const SizedBox(height: 18),

              // 3. Konfirmasi Kata Sandi Baru
              ProfileTextField(
                label: 'Konfirmasi Kata Sandi Baru',
                controller: _confirmPasswordController,
                hintText: 'konfirmasi sandi baru',
                obscureText: _obscureConfirm,
                onChanged: (_) => setState(() {}),
                prefix: const Icon(
                  Icons.lock_reset_rounded,
                  size: 21,
                  color: AppColors.textSecondary,
                ),
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
                trailingLabel: isMatching
                    ? const Row(
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: Color(0xFF0D9488),
                          ),
                          SizedBox(width: 4),
                          ManropeFont(
                            'Cocok',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),

              const SizedBox(height: 36),

              // Tombol Perbarui Kata Sandi
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            ManropeFont(
                              'Perbarui Kata Sandi',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Tombol Batal
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const ManropeFont(
                    'Batal',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
