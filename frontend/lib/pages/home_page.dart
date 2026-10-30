import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/components/font/bebas_neue_font.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/pages/build_tabs/explore_tabs.dart';
import 'package:frontend/pages/build_tabs/home_tabs.dart';
import 'package:frontend/pages/build_tabs/itenary_tabs.dart';
import 'package:frontend/pages/create_trip_plan_page.dart';
import 'package:frontend/pages/build_tabs/profile_tabs.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/services/auth_service.dart';

class HomePage extends StatefulWidget {
  final bool isGuest;

  const HomePage({super.key, this.isGuest = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  bool isBellHovered = false;
  Key _itineraryKey = UniqueKey();
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _isGuest = widget.isGuest;
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isGuest = widget.isGuest || !loggedIn;
      });
    }
  }

  void _showLoginPrompt({
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            ManropeFont(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ManropeFont(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const ManropeFont(
                  'Masuk Sekarang',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const ManropeFont(
                'Lanjutkan Eksplorasi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateTripPlan() async {
    if (_isGuest) {
      _showLoginPrompt(
        title: 'Buat Rencana Perjalanan',
        message:
            'Silakan masuk ke akun SmartTrip terlebih dahulu untuk mulai membuat dan menyimpan rencana liburan cerdas Anda.',
      );
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTripPlanPage()),
    );
    if (mounted) {
      setState(() {
        _itineraryKey = UniqueKey();
        if (result == true) {
          currentIndex = 2;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentIndex == 4
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              toolbarHeight: 60,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentIndex = 4;
                          });
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isGuest ? const Color(0xFFF1F5F9) : null,
                                border: _isGuest
                                    ? Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 1.5,
                                      )
                                    : null,
                                image: _isGuest
                                    ? null
                                    : const DecorationImage(
                                        image: AssetImage(
                                          'assets/images/profile.jpg',
                                        ),
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                      ),
                              ),
                              child: _isGuest
                                  ? const Icon(
                                      Icons.person_outline,
                                      color: AppColors.textSecondary,
                                      size: 24,
                                    )
                                  : null,
                            ),
                            if (!_isGuest)
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D9488),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BebasNeueFont(
                            'SmartTrip',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            spacing: 4,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.locationDot,
                                color: Colors.black,
                                size: 16,
                              ),
                              const ManropeFont(
                                'Batam, Kepulauan Riau',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
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
                                ? CupertinoIcons.bell_fill
                                : CupertinoIcons.bell,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC05400),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      body: currentIndex == 0
          ? HomeTabs(
              onSeeAllPressed: () {
                setState(() {
                  currentIndex = 1;
                });
              },
            )
          : currentIndex == 1
          ? ExploreTabs()
          : currentIndex == 2
          ? TripItineraryTab(key: _itineraryKey)
          : currentIndex == 3
          ? const Center(child: Text('Maps'))
          : ProfileTabs(
              isGuest: _isGuest,
              onBackToHome: () {
                setState(() {
                  currentIndex = 0;
                });
              },
            ),
      floatingActionButton: (currentIndex == 0 || currentIndex == 2)
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: _openCreateTripPlan,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFC05400),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 6),
                    ManropeFont(
                      'Buat Rencana Perjalanan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildCustomNavigationBar(),
    );
  }

  Widget _buildCustomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore,
            label: 'Explore',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.calendar_month_outlined,
            selectedIcon: Icons.calendar_month,
            label: 'Itenary',
            index: 2,
          ),
          _buildNavItem(
            icon: Icons.map_outlined,
            selectedIcon: Icons.map,
            label: 'Maps',
            index: 3,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
          if (index == 2) {
            _itineraryKey = UniqueKey();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? const Color(0xFF006399)
                  : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF006399)
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              width: 4,
              height: 4,
              child: isSelected
                  ? Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF006399),
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
