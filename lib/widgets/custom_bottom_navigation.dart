import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NavigationItem {
  final IconData icon;
  final String label;
  final Color color;
  final IconData? selectedIcon;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.color,
    this.selectedIcon,
  });
}

class CurvedNavigationBar extends StatelessWidget {
  const CurvedNavigationBar({
    Key? key,
    required this.items,
    required this.selectedIndex,
    this.onItemTapped,
    this.onFABPressed,
    this.fabIcon = Icons.home_rounded,
    this.fabColor = const Color(0xFF6B73FF),
    this.backgroundColor = Colors.white,
    this.unselectedColor = Colors.grey,
    this.height = 80.0,
  }) : super(key: key);

  final List<NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onItemTapped;
  final VoidCallback? onFABPressed;
  final IconData fabIcon;
  final Color fabColor;
  final Color backgroundColor;
  final Color unselectedColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Stack(
        children: [
          // Curved background
          ClipPath(
            clipper: _CurvedClipper(),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
            ),
          ),

          // Navigation items
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildNavigationItems(),
              ),
            ),
          ),

          // Floating Action Button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: fabColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: onFABPressed,
                  backgroundColor: fabColor,
                  elevation: 0,
                  child: Icon(fabIcon, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavigationItems() {
    List<Widget> navigationItems = [];
    final screenWidth = MediaQuery.of(navigatorKey.currentContext!).size.width;
    final availableWidth =
        screenWidth - 32 - 90; // Subtract padding and FAB space
    final itemWidth = availableWidth / 4; // Divide by 4 items

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isSelected = i == selectedIndex;

      navigationItems.add(
        SizedBox(
          width: itemWidth,
          child: GestureDetector(
            onTap: () => onItemTapped?.call(i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? item.color.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                      color: isSelected ? item.color : unselectedColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected ? item.color : unselectedColor,
                      fontSize: isSelected ? 14 : 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      //  space for FAB after second item
      if (i == 1) {
        navigationItems.add(const SizedBox(width: 90));
      }
    }

    return navigationItems;
  }
}

class _CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from top-left
    path.lineTo(0, 0);

    // Create the curve for the FAB
    final centerX = size.width / 2;
    final curveHeight = 35.0;

    // Left side of the curve
    path.lineTo(centerX - 60, 0);
    path.quadraticBezierTo(centerX - 40, 0, centerX - 40, 20);

    // Bottom of the curve (where FAB sits)
    path.quadraticBezierTo(centerX, curveHeight, centerX + 40, 20);

    // Right side of the curve
    path.quadraticBezierTo(centerX + 40, 0, centerX + 60, 0);

    // Complete the rectangle
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
