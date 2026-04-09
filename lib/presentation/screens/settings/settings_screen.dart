import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gamebooking/bloc/auth/auth_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/routes/app_router.dart';
import 'package:gamebooking/data/models/user_model.dart';

/// Fully dynamic Settings screen.
///
/// Every value comes from a real source — never hardcoded:
/// - Account section reads the live `UserModel` from `AuthBloc`
/// - Saving name / phone goes through `AuthProfileUpdateRequested`
/// - Notification toggles persist in `SharedPreferences` and survive restarts
/// - Logout uses the standard `AuthLogoutRequested` event
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // SharedPreferences keys for notification settings.
  static const _kBookingReminders = 'pref_notif_booking_reminders';
  static const _kPromoEmails = 'pref_notif_promo_emails';
  static const _kMatchInvites = 'pref_notif_match_invites';

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Loaded once on init from SharedPreferences. UI mutations write back
  // immediately so the values are always live.
  bool _bookingReminders = true;
  bool _promoEmails = false;
  bool _matchInvites = true;
  bool _prefsLoaded = false;

  bool _editingProfile = false;
  bool _savingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _nameController.text = state.user.name;
      _phoneController.text = state.user.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _bookingReminders = prefs.getBool(_kBookingReminders) ?? true;
      _promoEmails = prefs.getBool(_kPromoEmails) ?? false;
      _matchInvites = prefs.getBool(_kMatchInvites) ?? true;
      _prefsLoaded = true;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveProfile(UserModel currentUser) async {
    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (newName == currentUser.name && newPhone == currentUser.phone) {
      setState(() => _editingProfile = false);
      return;
    }

    setState(() => _savingProfile = true);
    final updated = currentUser.copyWith(name: newName, phone: newPhone);
    context.read<AuthBloc>().add(AuthProfileUpdateRequested(user: updated));
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'You will need to sign in again to access your bookings.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated && _savingProfile) {
            setState(() {
              _savingProfile = false;
              _editingProfile = false;
              _nameController.text = state.user.name;
              _phoneController.text = state.user.phone;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated'),
                backgroundColor: AppColors.actionGreen,
              ),
            );
          } else if (state is AuthError && _savingProfile) {
            setState(() => _savingProfile = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Update failed: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AuthUnauthenticated) {
            // After logout — bounce back to login.
            context.go(AppRoutes.login);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading && !_savingProfile) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionGreen),
            );
          }

          if (state is! AuthAuthenticated) {
            return _buildSignedOutState();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('Account'),
              const SizedBox(height: 10),
              _buildAccountCard(state.user),
              const SizedBox(height: 24),
              _sectionTitle('Notifications'),
              const SizedBox(height: 10),
              _buildNotificationsCard(),
              const SizedBox(height: 24),
              _sectionTitle('Account actions'),
              const SizedBox(height: 10),
              _buildLogoutCard(),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  // ── Sections ────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.accentYellow,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _cardContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }

  Widget _buildSignedOutState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline,
              color: AppColors.textDisabled, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Please sign in to manage settings',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.actionGreen,
            ),
            child:
                const Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Account card ────────────────────────────────────────────────────────

  Widget _buildAccountCard(UserModel user) {
    return _cardContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      AppColors.actionGreen.withValues(alpha: 0.2),
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: AppColors.actionGreen,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _savingProfile
                      ? null
                      : () => setState(
                            () => _editingProfile = !_editingProfile,
                          ),
                  icon: Icon(
                    _editingProfile ? Icons.close : Icons.edit_outlined,
                    color: AppColors.actionGreen,
                    size: 20,
                  ),
                ),
              ],
            ),
            if (_editingProfile) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _savingProfile ? null : () => _saveProfile(user),
                  icon: _savingProfile
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: Text(_savingProfile ? 'Saving…' : 'Save changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.actionGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 14),
              _readOnlyRow(Icons.phone_outlined, 'Phone',
                  user.phone.isEmpty ? '—' : user.phone),
              const SizedBox(height: 8),
              _readOnlyRow(
                Icons.calendar_today_outlined,
                'Member since',
                '${user.createdAt.day.toString().padLeft(2, '0')}/'
                    '${user.createdAt.month.toString().padLeft(2, '0')}/'
                    '${user.createdAt.year}',
              ),
              const SizedBox(height: 8),
              _readOnlyRow(
                Icons.workspace_premium_outlined,
                'Membership',
                _membershipLabel(user.membershipType),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _readOnlyRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textDisabled),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _membershipLabel(MembershipType type) {
    switch (type) {
      case MembershipType.free:
        return 'Free';
      case MembershipType.silver:
        return 'Silver';
      case MembershipType.gold:
        return 'Gold';
      case MembershipType.platinum:
        return 'Platinum';
    }
  }

  // ── Notifications card ──────────────────────────────────────────────────

  Widget _buildNotificationsCard() {
    if (!_prefsLoaded) {
      return _cardContainer(
        child: const SizedBox(
          height: 120,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.actionGreen,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    return _cardContainer(
      child: Column(
        children: [
          _switchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Booking reminders',
            subtitle: 'Get notified before your slot starts',
            value: _bookingReminders,
            onChanged: (v) {
              setState(() => _bookingReminders = v);
              _setPref(_kBookingReminders, v);
            },
          ),
          const Divider(color: AppColors.divider, height: 1, indent: 56),
          _switchTile(
            icon: Icons.local_offer_outlined,
            title: 'Promotional emails',
            subtitle: 'Discounts, offers and venue news',
            value: _promoEmails,
            onChanged: (v) {
              setState(() => _promoEmails = v);
              _setPref(_kPromoEmails, v);
            },
          ),
          const Divider(color: AppColors.divider, height: 1, indent: 56),
          _switchTile(
            icon: Icons.group_add_outlined,
            title: 'Match invites',
            subtitle: 'Players inviting you to open games',
            value: _matchInvites,
            onChanged: (v) {
              setState(() => _matchInvites = v);
              _setPref(_kMatchInvites, v);
            },
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.actionGreen,
          ),
        ],
      ),
    );
  }

  // ── Logout card ─────────────────────────────────────────────────────────

  Widget _buildLogoutCard() {
    return _cardContainer(
      child: InkWell(
        onTap: _confirmLogout,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout,
                    color: AppColors.error, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.error.withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
