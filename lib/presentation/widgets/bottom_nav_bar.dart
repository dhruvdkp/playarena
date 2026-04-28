import 'package:flutter/material.dart';
import 'package:gamebooking/core/constants/app_colors.dart';

/// Custom bottom navigation bar with 4 tabs styled in the stadium dark theme.
///
/// Tabs: Home, Venues, Matchmaker, Profile.
/// The active tab is indicated by a green accent color and a small
/// indicator dot above the icon.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(
      icon: Icons.stadium_outlined,
      activeIcon: Icons.stadium,
      label: 'Venues',
    ),
    _NavItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group,
      label: 'Matchmaker',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: _NavBarTab(
                    item: item,
                    isActive: isActive,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarTab extends StatelessWidget {
  final _NavItem item;
  final bool isActive;

  const _NavBarTab({
    required this.item,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Active indicator dot
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 20 : 0,
          height: 3,
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.actionGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Icon
        Icon(
          isActive ? item.activeIcon : item.icon,
          size: 24,
          color: isActive ? AppColors.actionGreen : AppColors.textDisabled,
        ),
        const SizedBox(height: 3),

        // Label
        Text(
          item.label,
          style: TextStyle(
            color: isActive ? AppColors.actionGreen : AppColors.textDisabled,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
