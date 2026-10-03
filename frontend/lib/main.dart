import 'package:flutter/material.dart';
import 'package:frontend/pages/loading_page.dart';
import 'package:frontend/core/theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartTrip',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.tertiary,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const LoadingPage(),
    );
  }
}
