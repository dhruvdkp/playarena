import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/bloc/auth/auth_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/team_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/repositories/team_repository.dart';

/// Lists teams the signed-in user owns (captain) or has joined (member).
/// Tap a team to open detail; tap FAB to create a new team.
class MyTeamsScreen extends StatefulWidget {
  const MyTeamsScreen({super.key});

  @override
  State<MyTeamsScreen> createState() => _MyTeamsScreenState();
}

class _MyTeamsScreenState extends State<MyTeamsScreen> {
  late Future<List<TeamModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<TeamModel>> _load() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return [];
    return context.read<TeamRepository>().getTeamsForUser(auth.user.id);
  }

  void _refresh() {
    final next = _load();
    setState(() {
      _future = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'My Teams',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return _emptyState('Please sign in to manage teams');
          }
          return RefreshIndicator(
            color: AppColors.actionGreen,
            onRefresh: () async => _refresh(),
            child: FutureBuilder<List<TeamModel>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.actionGreen,
                    ),
                  );
                }
                if (snap.hasError) {
                  return _emptyState('Could not load teams\n${snap.error}');
                }
                final teams = snap.data ?? [];
                if (teams.isEmpty) {
                  return _emptyState(
                    'No teams yet.\nTap the + button to create one.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: teams.length,
                  itemBuilder: (_, i) => _TeamCard(
                    team: teams[i],
                    isCaptain: teams[i].captainId == authState.user.id,
                    onTap: () async {
                      await context.push('/profile/teams/${teams[i].id}');
                      _refresh();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () async {
              final created = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => _CreateTeamSheet(user: state.user),
              );
              if (created == true) _refresh();
            },
            backgroundColor: AppColors.actionGreen,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'New Team',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(String msg) {
    return ListView(
      // ListView so RefreshIndicator works on empty state
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      children: [
        Icon(
          Icons.groups_outlined,
          color: AppColors.textDisabled.withValues(alpha: 0.5),
          size: 72,
        ),
        const SizedBox(height: 16),
        Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────

class _TeamCard extends StatelessWidget {
  final TeamModel team;
  final bool isCaptain;
  final VoidCallback onTap;

  const _TeamCard({
    required this.team,
    required this.isCaptain,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _sportColor(team.sportType).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _sportIcon(team.sportType),
                  color: _sportColor(team.sportType),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            team.name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCaptain) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentYellow.withValues(
                                alpha: 0.15,
                              ),
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
                    const SizedBox(height: 4),
                    Text(
                      '${team.members.length} member${team.members.length == 1 ? '' : 's'}  •  ${_sportLabel(team.sportType)}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────

class _CreateTeamSheet extends StatefulWidget {
  final dynamic user;
  const _CreateTeamSheet({required this.user});

  @override
  State<_CreateTeamSheet> createState() => _CreateTeamSheetState();
}

class _CreateTeamSheetState extends State<_CreateTeamSheet> {
  final _name = TextEditingController();
  SportType _sport = SportType.boxCricket;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Team name required')));
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<TeamRepository>().createTeam(
        name: name,
        captainId: widget.user.id,
        captainName: widget.user.name,
        sportType: _sport,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not create team: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'New Team',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Team name',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Thunder Strikers',
              hintStyle: TextStyle(color: AppColors.textDisabled),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.actionGreen),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sport',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SportType>(
                value: _sport,
                isExpanded: true,
                dropdownColor: AppColors.card,
                items: SportType.values
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          _sportLabel(s),
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _sport = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _busy ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Create Team',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── shared helpers ──────────────────────────────────────────────────────

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
