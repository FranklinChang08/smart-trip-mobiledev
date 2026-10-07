import 'dart:async';

import 'package:flutter/material.dart';

class AutoSlider extends StatefulWidget {
  const AutoSlider({super.key});

  @override
  State<AutoSlider> createState() => _AutoSliderState();
}

class _AutoSliderState extends State<AutoSlider> {
  final PageController _controller = PageController();
  Timer? _timer;

  int currentPage = 0;

  final List<String> images = [
    'assets/images/banner1.jpeg',
    'assets/images/banner2.webp',
    'assets/images/banner3.jpg',
    'assets/images/chengho.jpg',
    'assets/images/vihara.jpg',
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      currentPage++;

      if (currentPage >= images.length) {
        currentPage = 0;
      }

      _controller.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Dot indicator
        SizedBox(
          height: 8,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(images.length, (index) {
                final bool isSelected = currentPage == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isSelected ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF006399)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
