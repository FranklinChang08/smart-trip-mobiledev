import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManropeFont extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const ManropeFont(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.manrope(textStyle: style),
    );
  }
}
