import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BebasNeueFont extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const BebasNeueFont(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.bebasNeue(textStyle: style));
  }
}
