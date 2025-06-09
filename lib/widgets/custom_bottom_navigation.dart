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

class CurvedNavigationBar extends StatefulWidget {
  const CurvedNavigationBar({
    Key? key,
    required this.items,
    required this.selectedIndex,
    this.onItemTapped,
    this.onFABPressed,
    this.fabIcon = Icons.home_rounded,
    this.fabColor = const Color(0xFF6B73FF),
    this.backgroundColor = const Color(0xFFF8F9FF),
    this.unselectedColor = Colors.black54,
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
  State<CurvedNavigationBar> createState() => _CurvedNavigationBarState();
}

class _CurvedNavigationBarState extends State<CurvedNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation if FAB is selected
    if (widget.selectedIndex == -1) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == -1 && oldWidget.selectedIndex != -1) {
      _animationController.forward();
    } else if (widget.selectedIndex != -1 && oldWidget.selectedIndex == -1) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: Stack(
        children: [
          // Curved background
          ClipPath(
            clipper: _CurvedClipper(),
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF), // Light blue-white background
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
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
                children: _buildNavigationItems(context),
              ),
            ),
          ),

          // Floating Action Button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.fabColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: FloatingActionButton(
                          onPressed: widget.onFABPressed,
                          backgroundColor: widget.fabColor,
                          elevation: 0,
                          child: Icon(
                            widget.fabIcon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavigationItems(BuildContext context) {
    List<Widget> navigationItems = [];
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth =
        screenWidth - 32 - 90; // Subtract padding and FAB space
    final itemWidth = availableWidth / 4; // Divide by 4 items

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final isSelected = i == widget.selectedIndex;

      navigationItems.add(
        SizedBox(
          width: itemWidth,
          child: GestureDetector(
            onTap: () => widget.onItemTapped?.call(i),
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
                      color: isSelected ? item.color : widget.unselectedColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected ? item.color : widget.unselectedColor,
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

      // Add space for FAB after second item
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
