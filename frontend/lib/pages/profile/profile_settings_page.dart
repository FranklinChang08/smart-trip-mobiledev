import 'package:flutter/material.dart';
import 'package:frontend/components/app_notification.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/pages/profile/widgets/profile_text_field.dart';
import 'package:frontend/services/auth_service.dart';

class ProfileSettingsPage extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String initialLocation;

  const ProfileSettingsPage({
    super.key,
    this.initialName = 'Nadira Safitri',
    this.initialEmail = 'nadira.safitri@gmail.com',
    this.initialPhone = '812-7890-8821',
    this.initialLocation = 'Singapura / Batam',
  });

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _locationController = TextEditingController(text: widget.initialLocation);

    String phone = widget.initialPhone;
    phone = phone.replaceFirst(RegExp(r'^\+?62\s*'), '');
    _phoneController = TextEditingController(text: phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty) {
      AppNotification.showError(
        context,
        title: 'Form Belum Lengkap',
        message: 'Nama lengkap wajib diisi.',
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      AppNotification.showError(
        context,
        title: 'Email Tidak Valid',
        message: 'Masukkan alamat email yang valid.',
      );
      return;
    }

    if (phone.isEmpty) {
      AppNotification.showError(
        context,
        title: 'Form Belum Lengkap',
        message: 'Nomor telepon wajib diisi.',
      );
      return;
    }

    if (location.isEmpty) {
      AppNotification.showError(
        context,
        title: 'Form Belum Lengkap',
        message: 'Domisili / Kota asal wajib diisi.',
      );
      return;
    }

    if (!phone.startsWith('+62') && !phone.startsWith('0')) {
      phone = '+62 $phone';
    } else if (phone.startsWith('0')) {
      phone = '+62 ${phone.substring(1)}';
    }

    setState(() => _isSaving = true);

    // Simpan ke sesi user yang sedang aktif
    final savedUser = await AuthService.getSavedUser() ?? {};
    savedUser['nama_pengguna'] = name;
    savedUser['email'] = email;
    savedUser['no_hp'] = phone;
    savedUser['domisili'] = location;
    savedUser['lokasi'] = location;
    await AuthService.saveUser(savedUser);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isSaving = false);

    AppNotification.showSuccess(
      context,
      title: 'Berhasil Disimpan',
      message: 'Perubahan profil Anda berhasil disimpan.',
    );

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    Navigator.pop(context, {
      'nama_pengguna': name,
      'email': email,
      'no_hp': phone,
      'domisili': location,
      'lokasi': location,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const ManropeFont(
          'Profile Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Soft gradient banner di background atas
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD4ECE8), Color(0xFFF8FAFC)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Card Foto Profil & Nama
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 0.9,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar dengan Tombol Ganti Foto
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE2E8F0),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                image: const DecorationImage(
                                  image: AssetImage(
                                    'assets/images/profile.jpg',
                                  ),
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
                                    title: 'Ganti Foto Profil',
                                    message: 'Pilih foto baru dari galeri perangkat Anda.',
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ManropeFont(
                          _nameController.text.isNotEmpty
                              ? _nameController.text
                              : widget.initialName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ManropeFont(
                          _emailController.text.isNotEmpty
                              ? _emailController.text
                              : widget.initialEmail,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Color(0xFF0D9488),
                            ),
                            const SizedBox(width: 4),
                            ManropeFont(
                              _locationController.text.isNotEmpty
                                  ? _locationController.text
                                  : widget.initialLocation,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0D9488),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Card Informasi Pribadi
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 0.9,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ManropeFont(
                          'Informasi Pribadi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Nama Lengkap *
                        ProfileTextField(
                          label: 'Nama Lengkap',
                          isRequired: true,
                          controller: _nameController,
                          hintText: 'Nama lengkap Anda',
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 16),

                        // Alamat Email *
                        ProfileTextField(
                          label: 'Alamat Email',
                          isRequired: true,
                          controller: _emailController,
                          hintText: 'contoh@gmail.com',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 16),

                        // Nomor Telepon *
                        ProfileTextField(
                          label: 'Nomor Telepon',
                          isRequired: true,
                          controller: _phoneController,
                          hintText: '812-7890-8821',
                          keyboardType: TextInputType.phone,
                          prefix: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                width: 0.8,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🇮🇩', style: TextStyle(fontSize: 13)),
                                SizedBox(width: 4),
                                Text(
                                  '+62',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Domisili / Kota Asal *
                        ProfileTextField(
                          label: 'Domisili / Kota Asal',
                          isRequired: true,
                          controller: _locationController,
                          hintText: 'Contoh: Singapura / Batam',
                          prefix: const Icon(
                            Icons.location_on_outlined,
                            size: 19,
                            color: AppColors.textSecondary,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Security Badge Notice
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      ManropeFont(
                        'Data Anda terenkripsi dan disimpan dengan aman.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tombol Simpan Perubahan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
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
                                  Icons.save_outlined,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                ManropeFont(
                                  'Simpan Perubahan',
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

                  // Tombol Batalkan Perubahan
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const ManropeFont(
                      'Batalkan Perubahan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
