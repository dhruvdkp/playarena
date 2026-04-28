import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamebooking/bloc/auth/auth_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/team_model.dart';
import 'package:gamebooking/data/models/user_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/repositories/team_repository.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

/// Detail view of a single team. Captain can remove members + delete team.
class TeamDetailScreen extends StatefulWidget {
  final String teamId;

  const TeamDetailScreen({super.key, required this.teamId});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  final FirestoreService _firestore = FirestoreService();
  TeamModel? _team;
  final Map<String, UserModel> _profiles = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final team = await context.read<TeamRepository>().getTeamById(widget.teamId);
      if (team == null) {
        setState(() {
          _error = 'Team not found';
          _loading = false;
        });
        return;
      }
      final ids = team.members.map((m) => m.userId).toList();
      final docs = await _firestore.getUsersByIds(ids);
      _profiles.clear();
      for (final d in docs) {
        final u = UserModel.fromJson(d);
        _profiles[u.id] = u;
      }
      if (!mounted) return;
      setState(() {
        _team = team;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _removeMember(TeamMember m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Remove ${m.name}?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'They will no longer be part of this team.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await context.read<TeamRepository>().removeMember(widget.teamId, m);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not remove: $e')),
      );
    }
  }

  Future<void> _deleteTeam() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete team?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This permanently deletes the team for everyone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await context.read<TeamRepository>().deleteTeam(widget.teamId);
      if (!mounted) return;
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          _team?.name ?? 'Team',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final user = authState is AuthAuthenticated ? authState.user : null;
              final isCaptain =
                  user != null && _team != null && _team!.captainId == user.id;
              if (!isCaptain) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Delete team',
                icon: Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: _deleteTeam,
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.actionGreen),
      );
    }
    if (_error != null) {
      return _msgBody(_error!);
    }
    final team = _team;
    if (team == null) return _msgBody('Team not found');

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final isCaptain = user != null && team.captainId == user.id;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerCard(team),
              const SizedBox(height: 16),
              _membersSection(team, isCaptain),
            ],
          ),
        );
      },
    );
  }

  Widget _msgBody(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _headerCard(TeamModel team) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _sportColor(team.sportType).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_sportIcon(team.sportType),
                color: _sportColor(team.sportType), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_sportLabel(team.sportType)}  •  Captained by ${team.captainName}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _membersSection(TeamModel team, bool isCaptain) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups_outlined,
                  color: AppColors.accentYellow, size: 20),
              const SizedBox(width: 8),
              Text(
                'Members',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${team.members.length})',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...team.members.map((m) {
            final profile = _profiles[m.userId];
            final isCapMember = m.userId == team.captainId;
            return _MemberRow(
              member: m,
              profile: profile,
              isCaptain: isCapMember,
              showRemove: isCaptain && !isCapMember,
              onRemove: () => _removeMember(m),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────

class _MemberRow extends StatelessWidget {
  final TeamMember member;
  final UserModel? profile;
  final bool isCaptain;
  final bool showRemove;
  final VoidCallback onRemove;

  const _MemberRow({
    required this.member,
    required this.profile,
    required this.isCaptain,
    required this.showRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final name = profile?.name ?? member.name;
    final avatarUrl = profile?.avatarUrl;
    final email = profile?.email ?? '';
    final phone = profile?.phone ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _Avatar(name: name, imageUrl: avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCaptain) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CAPTAIN',
                          style: TextStyle(
                            color: AppColors.accentYellow,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (email.isNotEmpty)
                  Text(email,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                if (phone.isNotEmpty)
                  Text(phone,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          if (showRemove)
            IconButton(
              tooltip: 'Remove',
              icon: Icon(Icons.person_remove_outlined,
                  color: AppColors.error, size: 20),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  const _Avatar({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _initials(initials),
              placeholder: (_, _) => _initials(initials),
            )
          : _initials(initials),
    );
  }

  Widget _initials(String s) => Center(
        child: Text(
          s.isEmpty ? '?' : s,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

// shared
String _sportLabel(SportType t) {
  switch (t) {
    case SportType.boxCricket:
      return 'Box Cricket';
    case SportType.football:
      return 'Football';
    case SportType.pickleball:
      return 'Pickleball';
    case SportType.badminton:
      return 'Badminton';
    case SportType.tennis:
      return 'Tennis';
  }
}

IconData _sportIcon(SportType t) {
  switch (t) {
    case SportType.boxCricket:
      return Icons.sports_cricket;
    case SportType.football:
      return Icons.sports_soccer;
    case SportType.pickleball:
    case SportType.badminton:
    case SportType.tennis:
      return Icons.sports_tennis;
  }
}

Color _sportColor(SportType t) {
  switch (t) {
    case SportType.boxCricket:
      return AppColors.cricketAccent;
    case SportType.football:
      return AppColors.footballAccent;
    case SportType.pickleball:
      return AppColors.pickleballAccent;
    case SportType.badminton:
      return AppColors.accentYellow;
    case SportType.tennis:
      return AppColors.actionGreen;
  }
}
