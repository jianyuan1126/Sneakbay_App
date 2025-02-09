import 'package:flutter/material.dart';
import 'package:flutter_application_1/mobile_application/src/utils/constants.dart';

class AppThemes {
  AppThemes._();

  /// Home
  static const TextStyle homeProductName = TextStyle(
    color: AppConstantsColor.lightTextColor,
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle homeProductModel = TextStyle(
      color: AppConstantsColor.lightTextColor,
      fontWeight: FontWeight.bold,
      fontSize: 22);
  static const TextStyle homeProductPrice = TextStyle(
      color: AppConstantsColor.lightTextColor,
      fontWeight: FontWeight.w400,
      fontSize: 16);
}