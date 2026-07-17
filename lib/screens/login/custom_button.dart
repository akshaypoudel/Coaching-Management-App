import 'package:flutter/material.dart';
import 'package:stdent_management_system/screens/login/app_textstyles.dart';
import 'package:stdent_management_system/screens/login/colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const CustomButton({super.key, required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        child: Text(title, style: AppTextStyles.button),
      ),
    );
  }
}
