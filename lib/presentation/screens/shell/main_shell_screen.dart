import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/core/constants/app_colors.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.navigationShell});

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
          indicatorColor: AppColors.actionGreen.withValues(alpha: 0.15),
          surfaceTintColor: Colors.transparent,
          height: 65,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.home, color: AppColors.actionGreen),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.stadium_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.stadium, color: AppColors.actionGreen),
              label: 'Venues',
            ),
            NavigationDestination(
              icon: Icon(Icons.group_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.group, color: AppColors.actionGreen),
              label: 'Matchmaker',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.person, color: AppColors.actionGreen),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
