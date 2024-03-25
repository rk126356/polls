import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppFonts {
  static TextStyle headingTextStyle = GoogleFonts.kanit(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.headingText,
  );

  static TextStyle bodyTextStyle = GoogleFonts.kanit(
    fontSize: 16.0,
    color: Colors.black,
  );

  static TextStyle buttonTextStyle = GoogleFonts.kanit(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}
