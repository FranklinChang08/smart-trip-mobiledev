import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AutoSlider extends StatefulWidget {
  const AutoSlider({super.key});

  @override
  State<AutoSlider> createState() => _AutoSliderState();
}

class _AutoSliderState extends State<AutoSlider> {
  final PageController _controller = PageController();
  Timer? _timer;
  int currentPage = 0;

  bool _isLoading = true;
  List<String> images = [];

  // Konfigurasi Base URL Backend (menyesuaikan platform web / android emulator / device)
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSliderImages();
  }

  // Fungsi helper untuk memetakan URL foto dari API backend
  String _resolveImageUrl(dynamic linkFoto) {
    if (linkFoto == null || linkFoto.toString().isEmpty) {
      return 'http://127.0.0.1:8000/storage/placeholder.jpg';
    }
    final String fotoStr = linkFoto.toString();
    if (fotoStr.startsWith('http://') || fotoStr.startsWith('https://')) {
      return fotoStr;
    }
    return '$_baseUrl/wisata/foto/$fotoStr';
  }

  Future<void> _fetchSliderImages() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/wisata'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> items = jsonResponse is List
            ? jsonResponse
            : (jsonResponse['data'] as List<dynamic>? ?? []);

        // Ambil maksimal 5 data saja
        final limitedItems = items.take(5).toList();

        final List<String> fetchedImages = [];

        for (var item in limitedItems) {
          final destination = Map<String, dynamic>.from(item);
          final fotoDestinasis =
              destination['foto_destinasis'] as List<dynamic>? ?? [];

          final linkFoto = fotoDestinasis.isNotEmpty
              ? fotoDestinasis[0]['link_photo']
              : null;
          final fallbackImage = destination['image_url'] ?? destination['foto'];

          final imageUrl = linkFoto != null
              ? _resolveImageUrl(linkFoto)
              : (fallbackImage != null
                    ? _resolveImageUrl(fallbackImage)
                    : 'http://127.0.0.1:8000/storage/placeholder.jpg');

          fetchedImages.add(imageUrl);
        }

        if (!mounted) return;

        setState(() {
          if (fetchedImages.isNotEmpty) {
            images = fetchedImages;
          } else {
            // Fallback default jika data kosong
            images = ['http://127.0.0.1:8000/storage/placeholder.jpg'];
          }
          _isLoading = false;
        });

        // Mulai timer slider setelah data berhasil dimuat
        _startAutoSlide();
      } else {
        _handleFallbackImages();
      }
    } catch (e) {
      _handleFallbackImages();
    }
  }

  void _handleFallbackImages() {
    if (!mounted) return;
    setState(() {
      images = ['http://127.0.0.1:8000/storage/placeholder.jpg'];
      _isLoading = false;
    });
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (images.isEmpty) return;

      currentPage++;
      if (currentPage >= images.length) {
        currentPage = 0;
      }

      if (_controller.hasClients) {
        _controller.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }

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
    if (_isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

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
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(images[index]),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
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
