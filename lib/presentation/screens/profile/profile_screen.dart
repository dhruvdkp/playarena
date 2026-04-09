import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/bloc/auth/auth_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/routes/app_router.dart';
import 'package:gamebooking/data/models/booking_model.dart';
import 'package:gamebooking/data/models/user_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionGreen),
            );
          }

          if (state is AuthAuthenticated) {
            return _buildProfileContent(context, state.user);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_off_outlined,
                    color: AppColors.textDisabled, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Not logged in',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.actionGreen),
                  child: const Text('Log In',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildAvatarSection(user),
          const SizedBox(height: 24),
          _buildStatsRow(user),
          const SizedBox(height: 12),
          _buildMemberSinceRow(user),
          const SizedBox(height: 24),
          _buildMenuSection(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(UserModel user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.actionGreen.withValues(alpha: 0.2),
              backgroundImage:
                  user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: AppColors.actionGreen,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.primaryBackground,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.actionGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        _buildMembershipBadge(user.membershipType),
      ],
    );
  }

  Widget _buildMembershipBadge(MembershipType type) {
    Color badgeColor;
    String label;
    IconData icon;

    switch (type) {
      case MembershipType.free:
        badgeColor = AppColors.textSecondary;
        label = 'Free Member';
        icon = Icons.person;
        break;
      case MembershipType.silver:
        badgeColor = const Color(0xFFC0C0C0);
        label = 'Silver Member';
        icon = Icons.workspace_premium;
        break;
      case MembershipType.gold:
        badgeColor = AppColors.accentYellow;
        label = 'Gold Member';
        icon = Icons.workspace_premium;
        break;
      case MembershipType.platinum:
        badgeColor = const Color(0xFF00CED1);
        label = 'Platinum Member';
        icon = Icons.diamond;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserModel user) {
    // Live-counts bookings from Firestore so the numbers reflect actual
    // state instead of the stale `user.totalBookings` field (which is only
    // set once at sign-in and never updated when a booking is created).
    final firestoreService = FirestoreService();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: firestoreService.userBookingsStream(user.id),
          builder: (context, snapshot) {
            final bookings = (snapshot.data ?? [])
                .map((j) {
                  try {
                    return BookingModel.fromJson(j);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<BookingModel>()
                .toList();

            final total = bookings.length;
            final upcoming = bookings
                .where((b) => b.bookingStatus == BookingStatus.upcoming)
                .length;
            final completed = bookings
                .where((b) => b.bookingStatus == BookingStatus.completed)
                .length;

            // Show a subtle loading state for the very first frame so the
            // user doesn't see a flash of "0".
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem(
                  isLoading ? '—' : '$total',
                  'Total Bookings',
                  Icons.calendar_month,
                ),
                Container(width: 1, height: 44, color: AppColors.divider),
                _statItem(
                  isLoading ? '—' : '$upcoming',
                  'Upcoming',
                  Icons.event_available,
                ),
                Container(width: 1, height: 44, color: AppColors.divider),
                _statItem(
                  isLoading ? '—' : '$completed',
                  'Completed',
                  Icons.check_circle_outline,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMemberSinceRow(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.card_membership,
                color: AppColors.actionGreen, size: 20),
            const SizedBox(width: 12),
            const Text(
              'Member since',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const Spacer(),
            Text(
              DateFormat('MMM yyyy').format(user.createdAt),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.actionGreen, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textDisabled, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            _menuItem(
              icon: Icons.book_outlined,
              label: 'My Bookings',
              onTap: () => context.push(AppRoutes.myBookings),
            ),
            const Divider(color: AppColors.divider, height: 1, indent: 56),
            _menuItem(
              icon: Icons.groups_outlined,
              label: 'My Teams',
              onTap: () {
                // TODO: Add my teams route
              },
            ),
            const Divider(color: AppColors.divider, height: 1, indent: 56),
            _menuItem(
              icon: Icons.payment_outlined,
              label: 'Payment Methods',
              onTap: () {
                // TODO: Add payment methods route
              },
            ),
            const Divider(color: AppColors.divider, height: 1, indent: 56),
            _menuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => context.push(AppRoutes.settings),
            ),
            const Divider(color: AppColors.divider, height: 1, indent: 56),
            _menuItem(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {
                // TODO: Add help route
              },
            ),
            const Divider(color: AppColors.divider, height: 1, indent: 56),
            _menuItem(
              icon: Icons.logout,
              label: 'Logout',
              isDestructive: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    content: const Text(
                      'Are you sure you want to logout?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Cancel',
                          style:
                              TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context
                              .read<AuthBloc>()
                              .add(const AuthLogoutRequested());
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error),
                        child: const Text('Logout',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? AppColors.error
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDestructive
                      ? AppColors.error
                      : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.5)
                  : AppColors.textDisabled,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
