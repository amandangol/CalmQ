import 'package:flutter/material.dart';
import '../app_theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double height;
  final double? width;
  final List<Color>? gradientColors;
  final double borderRadius;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.width,
    this.gradientColors,
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: gradientColors ?? [AppColors.primary, AppColors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.surface,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.surface),
              ),
      ),
    );
  }
}
