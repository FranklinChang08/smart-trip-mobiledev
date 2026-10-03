import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/components/font/bebas_neue_font.dart';
import 'package:frontend/components/font/manrope_font.dart';
import 'package:frontend/components/font/noto_font.dart';
import 'package:frontend/components/slider_home.dart';
import 'package:frontend/core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  bool isBellHovered = false;

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
          ? _buildHomePage()
          : currentIndex == 1
          ? const Center(child: Text('Explore'))
          : currentIndex == 2
          ? const Center(child: Text('Itenary'))
          : const Center(child: Text('Profile')),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          _buildCustomNavigationBar(),

          Positioned(
            top: -45,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () {},
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
                child: Row(
                  children: [
                    const Icon(Icons.add, color: Colors.white),
                    const SizedBox(width: 6),
                    const ManropeFont(
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
          ),
        ],
      ),
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

Widget _buildHomePage() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AutoSlider(),
          const SizedBox(height: 20),
          // Greeting
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari destinasi atau kuliner...',

                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 8),
                  child: Icon(Icons.search_rounded, color: Color(0xFF006399)),
                ),

                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00685F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF00685F),
                      ),
                    ),
                  ),
                ),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 0.5,
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 0.5,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(0, 99, 153, 1),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
          const ManropeFont(
            'Pilihan Kuliner',
            style: TextStyle(color: Color(0xFF00685F), fontSize: 16),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    const NotoFont(
                      'Rekomendasi Terbaik di Batam',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    const ManropeFont('Lihat Semua'),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 350,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDestinationCard(
                    'Jembatan Barelang',
                    'Ikon Batam berupa rangkaian enam jembatan yang menghubungkan kawasan Batam, Rempang, dan Galang dengan panorama laut.',
                    'Kecamatan Sagulung',
                    'Gratis',
                    'assets/images/banner1.jpeg',
                  ),

                  const SizedBox(width: 16),

                  _buildDestinationCard(
                    'Welcome to Batam',
                    'Landmark ikonik di Bukit Clara yang menjadi salah satu simbol Kota Batam dan berada dekat kawasan Batam Centre.',
                    'Kecamatan Batam Kota',
                    'Gratis',
                    'assets/images/banner2.webp',
                  ),

                  const SizedBox(width: 16),

                  _buildDestinationCard(
                    'Maha Vihara Duta Maitreya',
                    'Kompleks vihara besar dengan arsitektur khas dan berbagai area untuk dikunjungi.',
                    'Kecamatan Batam Kota',
                    'Gratis',
                    'assets/images/vihara.jpg',
                  ),

                  const SizedBox(width: 16),

                  _buildDestinationCard(
                    'Mega Wisata Ocarina',
                    'Kawasan wisata tepi laut di Batam Centre dengan berbagai wahana rekreasi, area bermain, dan pemandangan laut.',
                    'Kecamatan Batam Kota',
                    'Rp 5.000',
                    'assets/images/banner3.jpg',
                  ),

                  const SizedBox(width: 16),

                  _buildDestinationCard(
                    'Masjid Muhammad Cheng Hoo',
                    'Masjid dengan arsitektur bernuansa Tionghoa yang berada di kawasan Golden City, Bengkong, Batam.',
                    'Kecamatan Bengkong',
                    'Gratis',
                    'assets/images/chengho.jpg',
                  ),
                ],
              ),
            ),
          ),
          const ManropeFont(
            'Pilihan Kuliner',
            style: TextStyle(color: AppColors.tertiary, fontSize: 16),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    const NotoFont(
                      'Kuliner Ikonik Batam',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    const ManropeFont('Jelajah Rasa'),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ],
          ),

          Column(
            children: [
              _buildFoodCard(
                'Gonggong Rebus Piayu Laut',
                'Kelong Apung',
                'Rp 45.000',
                'Siput laut khas Kepri dengan sambal asam pedas jeruk kesturi.',
                '10:00 - 21:00 WIB',
                'assets/images/makanan/gonggong.jpg',
              ),
              _buildFoodCard(
                'Mie Lendir Harum Manis',
                'Sarapan Favorit',
                'Rp 18.000',
                'Kuah kacang kental rempah ubi manis telur rebus khas Tanjungpinang.',
                '06:30 - 13:00 WIB',
                'assets/images/makanan/mielendir.jpg',
              ),
              _buildFoodCard(
                'Sup Ikan Batam Yong Kee',
                'Legendaris',
                'Rp 45.000',
                'Fillet kakap segar, tomat hijau asam segar dan taburan ebi gurih.',
                '09:00 - 21:30 WIB',
                'assets/images/makanan/supikan.jpg',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const ManropeFont(
            'PALING RAMAI DIKUNJUNGI',
            style: TextStyle(
              color: Color(0xFF006399),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const NotoFont(
            'Destinasi Terpopuler di Batam',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          Column(
            children: [
              _buildPopularDestinationCard(
                0xFFC05400,
                '#1',
                'Jembatan I Barelang (Fisabilillah)',
                '98k+ visit',
                'Spot foto sunset terfavorit se-Kepri',
              ),
              _buildPopularDestinationCard(
                0xFF00685F,
                '#2',
                'Pantai Nongsa & Kawasan Marina',
                '74k+ visit',
                'Pemandangan skyline Singapura dari pantai',
              ),
              _buildPopularDestinationCard(
                0xFF006399,
                '#3',
                'Mega Wisata Ocarina Batam Center',
                '62k+ visit',
                'Bianglala tepi laut, festival musik & kuliner',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildDestinationCard(
  String title,
  String desc,
  String district,
  String price,
  String image,
) {
  return SizedBox(
    width: 340,
    child: Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.bookmark_outline, size: 20),
                ),
              ),

              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(district),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                NotoFont(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ManropeFont(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
                const Divider(thickness: 0.25),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ManropeFont(
                          'Tiket Masuk',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ManropeFont(
                          price,
                          style: const TextStyle(
                            color: Color(0xFF00685F),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildFoodCard(
  String title,
  String location,
  String price,
  String desc,
  String jam,
  String image,
) {
  return SizedBox(
    width: double.infinity,
    child: Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 12,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00685F).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ManropeFont(
                          location,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF00685F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.clock,
                            size: 16,
                            color: AppColors.tertiary,
                          ),
                          ManropeFont(jam),
                        ],
                      ),
                    ],
                  ),
                  ManropeFont(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  ManropeFont(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ManropeFont(
                        price,
                        style: const TextStyle(
                          color: AppColors.tertiary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const ManropeFont(
                        '/ Porsi',
                        style: TextStyle(
                          color: AppColors.tertiary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    ),
  );
}

Widget _buildPopularDestinationCard(
  int color,
  String rank,
  String title,
  String totalVisit,
  String desc,
) {
  return SizedBox(
    width: double.infinity,
    child: Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Color(color),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: ManropeFont(
                  rank,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ManropeFont(
                    title,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  ManropeFont(
                    desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00685F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ManropeFont(
                totalVisit,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF00685F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
