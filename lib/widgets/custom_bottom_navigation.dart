import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class NavigationItem {
  final IconData icon;
  final String label;
  final Color color;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final List<NavigationItem> items;
  final Function(int) onItemTapped;
  final VoidCallback? onFABPressed;
  final IconData? fabIcon;
  final Color? fabColor;

  const CustomBottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.items,
    required this.onItemTapped,
    this.onFABPressed,
    this.fabIcon,
    this.fabColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter out home item from bottom navigation
    final filteredItems = items.where((item) => item.label != 'Home').toList();

    return AnimatedBottomNavigationBar.builder(
      itemCount: filteredItems.length,
      tabBuilder: (int index, bool isActive) {
        // Adjust index for filtered items
        final actualIndex = _getActualIndex(index, items, filteredItems);
        final isSelected = selectedIndex == actualIndex;
        final color = isSelected
            ? filteredItems[index].color
            : Colors.grey[600];

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(filteredItems[index].icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              filteredItems[index].label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        );
      },
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      activeIndex: _getFilteredIndex(selectedIndex, items, filteredItems),
      splashColor: selectedIndex < items.length
          ? items[selectedIndex].color
          : Colors.blue,
      notchSmoothness: NotchSmoothness.verySmoothEdge,
      gapLocation: GapLocation.center,
      leftCornerRadius: 16,
      rightCornerRadius: 16,
      onTap: (index) {
        final actualIndex = _getActualIndex(index, items, filteredItems);
        onItemTapped(actualIndex);
      },
      elevation: 8,
      height: 65,
    );
  }

  int _getActualIndex(
    int filteredIndex,
    List<NavigationItem> allItems,
    List<NavigationItem> filteredItems,
  ) {
    final filteredItem = filteredItems[filteredIndex];
    return allItems.indexWhere((item) => item.label == filteredItem.label);
  }

  int _getFilteredIndex(
    int actualIndex,
    List<NavigationItem> allItems,
    List<NavigationItem> filteredItems,
  ) {
    if (actualIndex >= allItems.length) return 0;
    final actualItem = allItems[actualIndex];
    final filteredIndex = filteredItems.indexWhere(
      (item) => item.label == actualItem.label,
    );
    return filteredIndex >= 0 ? filteredIndex : 0;
  }
}

class CenterDockedFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final bool isSelected;

  const CenterDockedFAB({
    Key? key,
    this.onPressed,
    this.icon = Icons.home_rounded,
    this.backgroundColor,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<CenterDockedFAB> createState() => _CenterDockedFABState();
}

class _CenterDockedFABState extends State<CenterDockedFAB>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CenterDockedFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale:
              _scaleAnimation.value *
              (widget.isSelected ? _pulseAnimation.value : 1.0),
          child: GestureDetector(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) => _scaleController.reverse(),
            onTapCancel: () => _scaleController.reverse(),
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onPressed?.call();
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isSelected
                      ? [
                          widget.backgroundColor ??
                              Theme.of(context).primaryColor,
                          (widget.backgroundColor ??
                                  Theme.of(context).primaryColor)
                              .withOpacity(0.8),
                        ]
                      : [Colors.grey[300]!, Colors.grey[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? (widget.backgroundColor ??
                                  Theme.of(context).primaryColor)
                              .withOpacity(0.4)
                        : Colors.grey.withOpacity(0.3),
                    blurRadius: widget.isSelected ? 20 : 10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.isSelected ? Colors.white : Colors.grey[600],
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Enhanced version with custom app bar for additional actions
class CustomAppBarNavigation extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBarNavigation({
    Key? key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor ?? Theme.of(context).primaryColor,
            (backgroundColor ?? Theme.of(context).primaryColor).withOpacity(
              0.8,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? Theme.of(context).primaryColor)
                .withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        actions: actions?.map((action) {
          if (action is IconButton) {
            return IconButton(
              onPressed: action.onPressed,
              icon: Icon((action.icon as Icon).icon, color: Colors.white),
            );
          }
          return action;
        }).toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
