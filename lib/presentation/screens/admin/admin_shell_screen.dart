import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/core/constants/app_colors.dart';

class AdminShellScreen extends StatelessWidget {
  const AdminShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.accentYellow.withValues(alpha: 0.15),
          surfaceTintColor: Colors.transparent,
          height: 65,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.accentYellow),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.stadium_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.stadium, color: AppColors.accentYellow),
              label: 'Venues',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.calendar_month, color: AppColors.accentYellow),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.person, color: AppColors.accentYellow),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
