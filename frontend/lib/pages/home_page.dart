import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/components/font/bebas_neue_font.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/pages/build_tabs/explore_tabs.dart';
import 'package:frontend/pages/build_tabs/home_tabs.dart';
import 'package:frontend/pages/build_tabs/itenary_tabs.dart';
import 'package:frontend/pages/create_trip_plan_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  bool isBellHovered = false;

  Future<void> _openCreateTripPlan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTripPlanPage(),
      ),
    );
    if (result == true && mounted) {
      setState(() => currentIndex = 2);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 60,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        image: const DecorationImage(
                          image: AssetImage('assets/images/profile.jpg'),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
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
          ? HomeTabs()
          : currentIndex == 1
          ? SmartTripExplorePage()
          : currentIndex == 2
          ? TripItineraryTab()
          : const Center(child: Text('Profile')),
      floatingActionButton: Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
      ),
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
