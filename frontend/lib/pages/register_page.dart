import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/font/bebas_neue_font.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/components/font/noto_font.dart';
import 'package:frontend/components/text_field_v1.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/services/auth/register_services.dart';

import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // STATE DI SINI

  bool isBellHovered = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? nameError;
  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;

  final AuthService authService = AuthService();

  Future<void> register() async {
    try {
      setState(() {
        nameError = null;
        emailError = null;
        phoneError = null;
        passwordError = null;
        confirmPasswordError = null;
      });

      final result = await authService.register(
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
      );

      final statusCode = result['statusCode'];
      final data = result['data'];

      if (statusCode == 422) {
        final errors = data['errors'];

        setState(() {
          nameError = errors['name']?[0];
          emailError = errors['email']?[0];
          phoneError = errors['phone']?[0];
          passwordError = errors['password']?[0];
          confirmPasswordError = errors['password_confirmation']?[0];
        });

        return;
      }

      if (statusCode == 201) {
        print('Registrasi berhasil');

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 60,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        image: const DecorationImage(
                          image: AssetImage('assets/icon_apps.png'),
                          fit: BoxFit.contain,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    BebasNeueFont(
                      'Smart',
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    BebasNeueFont(
                      'Trip',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            MouseRegion(
              onEnter: (_) {
                setState(() {
                  isBellHovered = true;
                });
              },
              onExit: (_) {
                setState(() {
                  isBellHovered = false;
                });
              },
              child: Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      isBellHovered
                          ? CupertinoIcons.question_circle_fill
                          : CupertinoIcons.question_circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/banner1.jpeg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 180,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.white.withOpacity(0.5),
                            Colors.white,
                          ],
                          stops: const [0, 0.1, 0.2],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          NotoFont(
                            "Selamat Datang Kembali di SmartTrip",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                            ),
                          ),

                          const SizedBox(height: 8),

                          ManropeFont(
                            "Masuk untuk melanjutkan perencanaan liburan dan mengakses itinerary Batam Anda.",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              AppTextField(
                label: 'Full Name',
                hintText: 'Your Full Name',
                prefixIcon: Icons.person_2_outlined,
                controller: nameController,
                errorText: nameError,
              ),
              const SizedBox(height: 25),

              AppTextField(
                label: 'Alamat Email',
                hintText: 'nama@email.com',
                prefixIcon: Icons.email_outlined,
                controller: emailController,
                errorText: emailError,
              ),

              const SizedBox(height: 25),

              AppTextField(
                label: 'Phone Number',
                hintText: '+62 8xx xxxx xxxx',
                prefixIcon: Icons.phone_android_outlined,
                controller: phoneController,
                errorText: phoneError,
              ),

              const SizedBox(height: 25),

              AppTextField(
                label: 'Kata Sandi',
                hintText: 'Minimal 8 karakter',
                prefixIcon: Icons.lock_outline,
                controller: passwordController,
                obscureText: true,
                errorText: passwordError,
              ),

              const SizedBox(height: 25),

              AppTextField(
                label: 'Konfirmasi Kata Sandi',
                hintText: 'Ulangi kata sandi Anda',
                prefixIcon: Icons.shield_outlined,
                controller: confirmPasswordController,
                obscureText: true,
                errorText: confirmPasswordError,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: ManropeFont(
                    'Buat Akun Wisatawan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
