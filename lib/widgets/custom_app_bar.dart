import 'package:flutter/material.dart';
import '../app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData leadingIcon;
  final List<Widget>? actions;
  final Widget? trailingWidget;
  final bool showBackButton;
  final VoidCallback? onLeadingPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.leadingIcon,
    this.actions,
    this.trailingWidget,
    this.showBackButton = false,
    this.onLeadingPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(),
      flexibleSpace: Container(
        decoration: BoxDecoration(color: AppColors.primary),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (showBackButton)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed:
                          onLeadingPressed ?? () => Navigator.pop(context),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(leadingIcon, color: Colors.white, size: 24),
                  ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (trailingWidget != null) trailingWidget!,
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
