import 'package:flutter/material.dart';
import '../app_theme.dart';

class SnackbarUtils {
  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, AppColors.error, Icons.error_outline);
  }

  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      AppColors.success,
      Icons.check_circle_outline,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackbar(context, message, AppColors.info, Icons.info_outline);
  }

  static void _showSnackbar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.surface),
            SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: AppColors.surface)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
