import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_track/core/app_colors.dart';

class AppTextStyles {
  static TextStyle logoText(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.height;

    return GoogleFonts.outfit(
      color: Colors.white,
      fontSize: screenWidth * 0.05625,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle titleText(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.height;

    return GoogleFonts.outfit(
      color: AppColors.black,
      fontSize: screenWidth * 0.035,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle bigText(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.height;

    return GoogleFonts.outfit(
      color: AppColors.black,
      fontSize: screenWidth * 0.035,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle tinyText(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.height;

    return GoogleFonts.outfit(
      color: AppColors.grey,
      fontSize: screenWidth * 0.018,
      fontWeight: FontWeight.w300,
    );
  }

  static TextStyle midText(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.height;

    return GoogleFonts.outfit(
      color: AppColors.grey,
      fontSize: screenWidth * 0.021,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle primaryText(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.height;

    return GoogleFonts.outfit(
      color: AppColors.grey,
      fontSize: screenWidth * 0.025,
      fontWeight: FontWeight.w500,
    );
  }
}
