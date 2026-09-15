import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});
  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Smart',
                  style: GoogleFonts.montserrat(
                    color: Color(0xFF0284C7),
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Trip',
                  style: GoogleFonts.montserrat(
                    color: Color(0xFFF97316),
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            SizedBox(
              width: 180,
              child: LinearProgressIndicator(color: Color(0xFF0284C7)),
            ),
          ],
        ),
      ),
    );
  }
}
