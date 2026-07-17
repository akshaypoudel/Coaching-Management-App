import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const subtitle = TextStyle(fontSize: 16, color: AppColors.grey);

  static const button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
