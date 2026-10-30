import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/components/app_notification.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/components/font/noto_font.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:frontend/pages/profile/change_password_page.dart';
import 'package:frontend/pages/profile/profile_settings_page.dart';
import 'package:frontend/pages/profile/widgets/profile_menu_item.dart';
import 'package:frontend/services/auth_service.dart';

class ProfileTabs extends StatefulWidget {
  final VoidCallback? onBackToHome;
  final bool isGuest;

  const ProfileTabs({
    super.key,
    this.onBackToHome,
    this.isGuest = false,
  });

  @override
  State<ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileTabs> {
  bool _isGuestMode = false;
  String _name = 'Nadira Safitri';
  String _email = 'nadira.safitri@gmail.com';
  String _phone = '+62 812-7890-8821';
  String _location = 'Singapura / Batam';
  String _passwordUpdated = '2 bulan lalu';
  final String _preferenceUpdated = '2 bulan lalu';

  @override
  void initState() {
    super.initState();
    _isGuestMode = widget.isGuest;
    _loadProfile();
  }

  @override
  void didUpdateWidget(covariant ProfileTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGuest != widget.isGuest) {
      _isGuestMode = widget.isGuest;
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    final loggedIn = await AuthService.isLoggedIn();
    final user = await AuthService.getSavedUser();
    if (mounted) {
      setState(() {
        _isGuestMode = widget.isGuest || !loggedIn || user == null;
        if (user != null) {
          if (user['nama_pengguna'] != null) {
            _name = user['nama_pengguna'].toString();
          }
          if (user['email'] != null) {
            _email = user['email'].toString();
          }
          if (user['no_hp'] != null) {
            _phone = user['no_hp'].toString();
          }
          if (user['domisili'] != null && user['domisili'].toString().isNotEmpty) {
            _location = user['domisili'].toString();
          } else if (user['lokasi'] != null && user['lokasi'].toString().isNotEmpty) {
            _location = user['lokasi'].toString();
          }
        }
      });
    }
  }

  String _formatMaskedPhone(String phoneRaw) {
    final phone = phoneRaw.trim();
    if (phone.isEmpty) return '+62 812-7890-xxxx';
    if (phone.length <= 6) return phone;
    final prefix = phone.substring(0, phone.length - 4);
    return '$prefix-xxxx';
  }

  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const ManropeFont(
          'Konfirmasi Keluar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: const ManropeFont(
          'Apakah Anda yakin ingin keluar dari akun SmartTrip?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const ManropeFont(
              'Batal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const ManropeFont(
              'Ya, Keluar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AuthService.logout();
    if (!mounted) return;

    AppNotification.showSuccess(
      context,
      title: 'Sampai Jumpa',
      message: 'Anda berhasil keluar dari akun.',
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showPreferenceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const ManropeFont(
              'Preferensi Perjalanan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const ManropeFont(
              'Kelola notifikasi promo, rekomendasi rute cerdas, dan tema tampilan aplikasi.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const ManropeFont(
                'Notifikasi Rekomendasi Rute',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              subtitle: const ManropeFont(
                'Dapatkan rekomendasi destinasi saat berada di Batam.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              value: true,
              onChanged: (val) {},
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const ManropeFont(
                'Pemberitahuan Waktu & Cuaca',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              subtitle: const ManropeFont(
                'Info operasional wisata dan prakiraan cuaca harian.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              value: true,
              onChanged: (val) {},
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isGuestMode) {
      return _buildGuestProfileView();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profil Saya
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (widget.onBackToHome != null) {
                        widget.onBackToHome!();
                      } else if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ManropeFont(
                    'Profil Saya',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Card Informasi Pengguna
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00685F).withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar dengan Camera Badge Overlay
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/profile.jpg'),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              AppNotification.show(
                                context,
                                type: NotificationType.info,
                                title: 'Ganti Foto',
                                message: 'Pilih foto baru dari galeri perangkat Anda.',
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // Detail Nama & Lokasi
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ManropeFont(
                            _name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          ManropeFont(
                            _email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Color(0xFF0D9488),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: ManropeFont(
                                  _location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0D9488),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Subjudul Keamanan & Akun
              const ManropeFont(
                'KEAMANAN & AKUN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              // Group Card Menu Keamanan
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 1. Profile Settings
                    ProfileMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Profile Settings',
                      subtitle: _formatMaskedPhone(_phone),
                      showDivider: true,
                      onTap: () async {
                        final res = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileSettingsPage(
                              initialName: _name,
                              initialEmail: _email,
                              initialPhone: _phone,
                              initialLocation: _location,
                            ),
                          ),
                        );
                        if (res != null && mounted) {
                          setState(() {
                            if (res['nama_pengguna'] != null) {
                              _name = res['nama_pengguna'].toString();
                            }
                            if (res['email'] != null) {
                              _email = res['email'].toString();
                            }
                            if (res['no_hp'] != null) {
                              _phone = res['no_hp'].toString();
                            }
                            if (res['domisili'] != null) {
                              _location = res['domisili'].toString();
                            } else if (res['lokasi'] != null) {
                              _location = res['lokasi'].toString();
                            }
                          });
                        }
                      },
                    ),

                    // 2. Changes Password
                    ProfileMenuItem(
                      icon: Icons.lock_outline_rounded,
                      title: 'Changes Password',
                      subtitle: _passwordUpdated.startsWith('Terakhir')
                          ? _passwordUpdated
                          : 'Terakhir diperbarui $_passwordUpdated',
                      showDivider: true,
                      onTap: () async {
                        final res = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordPage(),
                          ),
                        );
                        if (res == true && mounted) {
                          setState(() {
                            _passwordUpdated = 'Hari ini';
                          });
                        }
                      },
                    ),

                    // 3. Preferensi Settings
                    ProfileMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Preferensi Settings',
                      subtitle: _preferenceUpdated.startsWith('Terakhir')
                          ? _preferenceUpdated
                          : 'Terakhir diperbarui $_preferenceUpdated',
                      showDivider: false,
                      onTap: _showPreferenceModal,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Card Log Out
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Log out',
                  titleColor: const Color(0xFFE11D48),
                  iconColor: const Color(0xFFE11D48),
                  iconBackgroundColor: const Color(0xFFFEE2E2),
                  onTap: _handleLogout,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestProfileView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: <- Profil Saya
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (widget.onBackToHome != null) {
                        widget.onBackToHome!();
                      } else if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xFF0F172A),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ManropeFont(
                    'Profil Saya',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Card
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 26,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Avatar Icon with Compass badge
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE6F7F5),
                                  border: Border.all(
                                    color: const Color(0xFF99F6E4),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF0F766E),
                                    size: 40,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F766E),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.2,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.explore_outlined,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Heading
                          const ManropeFont(
                            'Masuk ke SmartTrip',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: ManropeFont(
                              'Akses rencana perjalanan dan eksplorasi Batam tanpa batas.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                height: 1.45,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Button Masuk
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                                if (mounted) {
                                  _loadProfile();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ManropeFont(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.login_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Button Daftar Akun
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                                if (mounted) {
                                  _loadProfile();
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0F172A),
                                side: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const ManropeFont(
                                'Daftar Akun',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Divider with ATAU badge
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: const ManropeFont(
                                  'ATAU',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Button Lanjut dengan Google
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                AppNotification.show(
                                  context,
                                  type: NotificationType.info,
                                  title: 'Google Sign-In',
                                  message:
                                      'Fitur masuk dengan Google akan segera tersedia.',
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0F172A),
                                side: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/google.svg',
                                    width: 18,
                                    height: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  const ManropeFont(
                                    'Lanjut dengan Google',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Disclaimer footer
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ManropeFont(
                        'Dengan masuk, kamu menyetujui Ketentuan Layanan SmartTrip.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
