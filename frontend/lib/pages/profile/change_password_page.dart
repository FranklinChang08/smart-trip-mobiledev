import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/components/app_notification.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/pages/profile/widgets/password_strength_meter.dart';
import 'package:frontend/pages/profile/widgets/profile_text_field.dart';
import 'package:frontend/services/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final bool isForgotPassword;

  const ChangePasswordPage({
    super.key,
    this.isForgotPassword = false,
  });

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  // Controller form
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controller & FocusNode untuk 6-digit OTP
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  int _forgotStep = 1;

  // Visibility toggle password
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Timer countdown OTP (1 menit, hitung mundur dari 59 detik)
  Timer? _otpTimer;
  int _otpCountdown = 59;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _otpFocusNodes[i].addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    setState(() => _otpCountdown = 59);
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_otpCountdown > 0) {
        setState(() => _otpCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _enteredOtp =>
      _otpControllers.map((c) => c.text.trim()).join();

  // ==========================================
  // HANDLERS UNTUK ALUR LUPA PASSWORD
  // ==========================================

  // Step 1: Kirim OTP ke Email
  Future<void> _handleSendEmailOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      AppNotification.showError(
        context,
        title: 'Email Belum Diisi',
        message: 'Masukkan alamat email akun terdaftar Anda.',
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      AppNotification.showError(
        context,
        title: 'Format Email Salah',
        message: 'Masukkan format email yang valid (contoh: user@mail.com).',
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await AuthService.sendForgotPasswordOtp(email);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      // Bersihkan kotak OTP
      for (final c in _otpControllers) {
        c.clear();
      }
      _startOtpTimer();
      setState(() => _forgotStep = 2);

      AppNotification.showSuccess(
        context,
        title: 'OTP Terkirim',
        message: res['debug_otp'] != null
            ? '${res['message']} (Kode: ${res['debug_otp']})'
            : (res['message'] ?? 'Kode verifikasi telah dikirim ke email.'),
      );
    } else {
      AppNotification.showError(
        context,
        title: 'Gagal Mengirim OTP',
        message: res['message'] ?? 'Email tidak ditemukan.',
      );
    }
  }

  // Step 2: Verifikasi Kode OTP
  Future<void> _handleVerifyOtp() async {
    final otp = _enteredOtp;
    if (otp.length < 6) {
      AppNotification.showError(
        context,
        title: 'Kode Belum Lengkap',
        message: 'Masukkan 6-digit kode OTP secara lengkap.',
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await AuthService.verifyForgotPasswordOtp(
      _emailController.text.trim(),
      otp,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _otpTimer?.cancel();
      setState(() => _forgotStep = 3);
      AppNotification.showSuccess(
        context,
        title: 'Verifikasi Berhasil',
        message: 'Silakan atur kata sandi baru untuk akun Anda.',
      );
    } else {
      AppNotification.showError(
        context,
        title: 'Verifikasi Gagal',
        message: res['message'] ?? 'Kode OTP salah atau telah kadaluwarsa.',
      );
    }
  }

  // Kirim Ulang OTP
  Future<void> _handleResendOtp() async {
    if (_otpCountdown > 0 || _isLoading) return;

    setState(() => _isLoading = true);
    final res = await AuthService.sendForgotPasswordOtp(
      _emailController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      for (final c in _otpControllers) {
        c.clear();
      }
      _startOtpTimer();
      AppNotification.showSuccess(
        context,
        title: 'Kode Dikirim Ulang',
        message: res['debug_otp'] != null
            ? '${res['message']} (Kode: ${res['debug_otp']})'
            : (res['message'] ?? 'Kode OTP baru telah dikirim ke email.'),
      );
    } else {
      AppNotification.showError(
        context,
        title: 'Gagal Kirim Ulang',
        message: res['message'] ?? 'Gagal mengirim ulang kode OTP.',
      );
    }
  }

  // Step 3: Simpan Kata Sandi Baru (Lupa Password)
  Future<void> _handleResetPassword() async {
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

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

    final res = await AuthService.resetForgotPassword(
      email: _emailController.text.trim(),
      otp: _enteredOtp,
      newPassword: newPass,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      AppNotification.showSuccess(
        context,
        title: 'Kata Sandi Berhasil Dibuat',
        message: res['message'] ?? 'Kata sandi berhasil diperbarui. Silakan login kembali.',
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      AppNotification.showError(
        context,
        title: 'Gagal Memperbarui Kata Sandi',
        message: res['message'] ?? 'Terjadi kesalahan saat menyimpan kata sandi.',
      );
    }
  }

  // ==========================================
  // HANDLER UNTUK UBAH KATA SANDI (NORMAL DARI PROFIL)
  // ==========================================
  Future<void> _handleSubmitNormal() async {
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

    final res = await AuthService.changePassword(
      currentPassword: currentPass,
      newPassword: newPass,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      AppNotification.showSuccess(
        context,
        title: 'Berhasil',
        message: res['message'] ?? 'Kata sandi Anda berhasil diperbarui.',
      );

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      AppNotification.showError(
        context,
        title: 'Gagal',
        message: res['message'] ?? 'Kata sandi lama tidak sesuai.',
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (widget.isForgotPassword) {
      // Alur Lupa Password
      String appTitle = 'Lupa Password';
      if (_forgotStep == 2) {
        appTitle = 'Kode OTP';
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              if (_forgotStep == 2) {
                setState(() => _forgotStep = 1);
              } else if (_forgotStep == 3) {
                setState(() => _forgotStep = 2);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: ManropeFont(
            appTitle,
            style: const TextStyle(
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
                  title: 'Bantuan Pemulihan Akun',
                  message:
                      'Pastikan email yang Anda gunakan sama dengan email yang didaftarkan pada aplikasi SmartTrip.',
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                if (_forgotStep == 1) ...[
                  _buildForgotPasswordEmailStep(),
                ] else if (_forgotStep == 2) ...[
                  _buildForgotPasswordOtpStep(),
                ] else ...[
                  _buildForgotPasswordNewPasswordStep(),
                ],
                const SizedBox(height: 16),
                _buildSecurityFooterBadge(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    } else {

      return _buildNormalChangePassword(context);
    }
  }

  // ==========================================
  // WIDGET STEP 1: MASUKKAN EMAIL TERDAFTAR
  // ==========================================
  Widget _buildForgotPasswordEmailStep() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon ilustrasi amplop/email
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE2F4EE),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 38,
                color: Color(0xFF0F766E),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const ManropeFont(
            'Lupa Password',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const ManropeFont(
            'Masukkan email akun yang terdaftar untuk menerima 6-digit kode OTP pemulihan kata sandi Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 26),

          ProfileTextField(
            label: 'Email Terdaftar',
            isRequired: true,
            controller: _emailController,
            hintText: 'contoh: wisatawan@gmail.com',
            keyboardType: TextInputType.emailAddress,
            prefix: const Icon(
              Icons.mail_outline_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 28),

          // Tombol Kirim Kode OTP
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSendEmailOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA4D0C), // Terracotta
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFFBA4D0C).withOpacity(0.3),
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
                        ManropeFont(
                          'Kirim Kode OTP',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Tombol Kembali
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const ManropeFont(
                'Kembali ke Halaman Login',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordOtpStep() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFE2F4EE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 46,
                    color: Color(0xFF0F766E),
                  ),
                  Positioned(
                    top: 10,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.explore_rounded,
                          size: 15,
                          color: Color(0xFFBA4D0C),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Badge Koordinat Batam: 1.1301° N, 104.0529° E (persis seperti gambar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBA4D0C),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const ManropeFont(
                  '1.1301° N, 104.0529° E',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Judul "Verifikasi Kode OTP"
          const ManropeFont(
            'Verifikasi Kode OTP',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle deskripsi
          const ManropeFont(
            'Masukkan 6-digit kode verifikasi yang kami kirimkan ke akun email anda:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (_emailController.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            ManropeFont(
              _emailController.text.trim(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F766E),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // 6 Kotak Input OTP
          _buildOtpInputRow(),

          const SizedBox(height: 20),

          // Indikator Timer Kadaluwarsa "Kode kadaluwarsa dalam 00:59"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 17,
                color: Color(0xFF0F766E),
              ),
              const SizedBox(width: 6),
              const ManropeFont(
                'Kode kadaluwarsa dalam ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              ManropeFont(
                '00:${_otpCountdown.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFBA4D0C),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tombol Oranye Terracotta "Verifikasi & Lanjutkan ->"
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleVerifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA4D0C),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFFBA4D0C).withOpacity(0.35),
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
                        ManropeFont(
                          'Verifikasi & Lanjutkan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 22),

          // Bagian Belum Menerima Kode OTP & Kirim Ulang Kode
          Column(
            children: [
              const ManropeFont(
                'Belum menerima kode OTP?',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: (_otpCountdown == 0 && !_isLoading)
                    ? _handleResendOtp
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: _otpCountdown == 0
                          ? const Color(0xFF0F766E)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 5),
                    ManropeFont(
                      _otpCountdown == 0
                          ? 'Kirim Ulang Kode'
                          : 'Kirim Ulang Kode (${_otpCountdown}s)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _otpCountdown == 0
                            ? const Color(0xFF0F766E)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Row 6 kotak OTP
  Widget _buildOtpInputRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isLast = index == 5;
        final hasFocus = _otpFocusNodes[index].hasFocus;
        final hasText = _otpControllers[index].text.isNotEmpty;

        return Container(
          width: 44,
          height: 54,
          margin: EdgeInsets.only(right: isLast ? 0 : 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hasFocus
                ? Colors.white
                : (hasText ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasFocus
                  ? const Color(0xFF0F766E)
                  : (hasText
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFFE2E8F0)),
              width: hasFocus ? 1.8 : 1.0,
            ),
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (val) {
              if (val.length > 1) {
                final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                for (int i = 0; i < 6 && i < digits.length; i++) {
                  _otpControllers[i].text = digits[i];
                }
                if (digits.length >= 6) {
                  _otpFocusNodes[5].requestFocus();
                } else {
                  _otpFocusNodes[digits.length].requestFocus();
                }
                setState(() {});
                return;
              }

              if (val.isNotEmpty) {
                if (index < 5) {
                  _otpFocusNodes[index + 1].requestFocus();
                } else {
                  _otpFocusNodes[index].unfocus();
                }
              } else {
                if (index > 0) {
                  _otpFocusNodes[index - 1].requestFocus();
                }
              }
              setState(() {});
            },
          ),
        );
      }),
    );
  }

  // ==========================================
  // WIDGET STEP 3: BUAT KATA SANDI BARU (LUPA PASSWORD)
  // (Tanpa form Kata Sandi Saat Ini karena pengguna lupa)
  // ==========================================
  Widget _buildForgotPasswordNewPasswordStep() {
    final bool isMatching = _newPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmPasswordController.text;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE2F4EE),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 40,
                  color: Color(0xFF0F766E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Center(
            child: ManropeFont(
              'Kata Sandi Baru',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: ManropeFont(
              'Buat kata sandi baru untuk akun Anda. Pastikan kata sandi aman dan mudah diingat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 1. Kata Sandi Baru
          ProfileTextField(
            label: 'Kata Sandi Baru',
            isRequired: true,
            controller: _newPasswordController,
            hintText: 'masukkan kata sandi baru',
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

          // 2. Konfirmasi Kata Sandi Baru
          ProfileTextField(
            label: 'Konfirmasi Kata Sandi Baru',
            isRequired: true,
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

          const SizedBox(height: 28),

          // Tombol Simpan Sandi Baru
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA4D0C), 
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFFBA4D0C).withOpacity(0.3),
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
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        ManropeFont(
                          'Simpan Kata Sandi Baru',
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
            height: 48,
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
        ],
      ),
    );
  }

  Widget _buildSecurityFooterBadge() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.verified_user_rounded,
            size: 17,
            color: Color(0xFF0F766E),
          ),
          const SizedBox(width: 8),
          const ManropeFont(
            'Data dan privasi Anda terenkripsi aman',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNormalChangePassword(BuildContext context) {
    final bool isMatching = _newPasswordController.text.isNotEmpty &&
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
                message:
                    'Gunakan minimal 8 karakter dengan kombinasi huruf besar, kecil, angka, dan simbol.',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ChangePasswordPage(isForgotPassword: true),
                      ),
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
                  onPressed: _isLoading ? null : _handleSubmitNormal,
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
