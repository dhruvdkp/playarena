import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamebooking/bloc/auth/auth_bloc.dart';
import 'package:gamebooking/bloc/matchmaker/matchmaker_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/match_request_model.dart';
import 'package:gamebooking/data/models/user_model.dart';
import 'package:gamebooking/data/models/team_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/repositories/team_repository.dart';
import 'package:gamebooking/data/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen view of a match request.
///
/// Subscribes to the match doc so the player list + status update live as
/// other users join or leave. Renders a players section that batch-fetches
/// user profiles via [FirestoreService.getUsersByIds].
class MatchDetailScreen extends StatefulWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final FirestoreService _firestore = FirestoreService();
  // Cache of uid -> UserModel for the players shown in this session.
  final Map<String, UserModel> _playerProfiles = {};
  // Tracks which uid list we last resolved so we don't refetch unchanged sets.
  List<String>? _lastResolvedUids;
  bool _loadingProfiles = false;

  bool _pendingResolve = false;

  /// Schedules a post-frame profile fetch for [uids]. Called from inside the
  /// StreamBuilder's builder on every snapshot; we defer any state mutation
  /// until after the current frame so `setState` is never called during
  /// build (which would throw a framework assertion).
  void _ensureProfiles(List<String> uids) {
    if (_loadingProfiles || _pendingResolve) return;
    if (_isSameUidSet(_lastResolvedUids, uids)) return;
    _pendingResolve = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _pendingResolve = false;
      if (!mounted) return;
      // Re-check after the frame in case a faster snapshot already resolved.
      if (_loadingProfiles) return;
      if (_isSameUidSet(_lastResolvedUids, uids)) return;

      setState(() => _loadingProfiles = true);
      try {
        final missing =
            uids.where((u) => !_playerProfiles.containsKey(u)).toList();
        if (missing.isNotEmpty) {
          final docs = await _firestore.getUsersByIds(missing);
          for (final doc in docs) {
            final user = UserModel.fromJson(doc);
            _playerProfiles[user.id] = user;
          }
        }
        _lastResolvedUids = uids;
      } finally {
        if (mounted) setState(() => _loadingProfiles = false);
      }
    });
  }

  bool _isSameUidSet(List<String>? a, List<String> b) {
    if (a == null) return false;
    if (a.length != b.length) return false;
    return a.toSet().containsAll(b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Match Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocListener<MatchmakerBloc, MatchmakerState>(
        listener: (context, state) {
          if (state is MatchmakerError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: _firestore.matchRequestStream(widget.matchId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.actionGreen),
              );
            }
            if (snapshot.hasError) {
              return _errorBody(snapshot.error.toString());
            }
            final data = snapshot.data;
            if (data == null) {
              return _errorBody('This match no longer exists');
            }
            final match = MatchRequestModel.fromJson(data);
            // Kick off a profile resolve; harmless if already cached.
            _ensureProfiles(match.playersJoined);
            return _buildBody(match);
          },
        ),
      ),
    );
  }

  Widget _errorBody(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                color: AppColors.error.withValues(alpha: 0.8), size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(MatchRequestModel match) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerCard(match),
          const SizedBox(height: 16),
          _statsRow(match),
          const SizedBox(height: 16),
          _playersSection(match),
          if (match.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            _descriptionCard(match.description),
          ],
          const SizedBox(height: 24),
          _actionButton(match),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Header: sport badge, venue, date/time, hosted by ────────────────────

  Widget _headerCard(MatchRequestModel match) {
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chipBadge(
                icon: _sportIcon(match.sportType),
                label: _sportLabel(match.sportType),
                color: _sportColor(match.sportType),
              ),
              _chipBadge(
                label: _skillLabel(match.skillLevel),
                color: AppColors.accentYellow,
              ),
              _statusBadge(match),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            match.venueName,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hosted by ${match.hostName}',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, dd MMM yyyy').format(match.date),
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Icon(Icons.schedule,
                  color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Text(
                match.time,
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(MatchRequestModel match) {
    late final String label;
    late final Color color;
    switch (match.status) {
      case MatchRequestStatus.open:
        label = 'Open';
        color = AppColors.actionGreen;
        break;
      case MatchRequestStatus.full:
        label = 'Full';
        color = AppColors.error;
        break;
      case MatchRequestStatus.cancelled:
        label = 'Cancelled';
        color = AppColors.error;
        break;
      case MatchRequestStatus.completed:
        label = 'Completed';
        color = AppColors.textSecondary;
        break;
    }
    return _chipBadge(label: label, color: color);
  }

  // ── Stats: players filled, progress bar ─────────────────────────────────

  Widget _statsRow(MatchRequestModel match) {
    final progress = match.playersNeeded > 0
        ? (match.playersJoined.length / match.playersNeeded).clamp(0.0, 1.0)
        : 0.0;
    final spotsLeft =
        (match.playersNeeded - match.playersJoined.length).clamp(0, 999);
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${match.playersJoined.length}/${match.playersNeeded} players',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                spotsLeft == 0 ? 'Full' : '$spotsLeft spots left',
                style: TextStyle(
                  color: spotsLeft == 0
                      ? AppColors.error
                      : AppColors.actionGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                spotsLeft == 0
                    ? AppColors.actionGreen
                    : AppColors.accentYellow,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Players list ───────────────────────────────────────────────────────

  Widget _playersSection(MatchRequestModel match) {
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
                'Players',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${match.playersJoined.length})',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (match.playersJoined.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No players yet.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            )
          else
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final viewer =
                    authState is AuthAuthenticated ? authState.user : null;
                return Column(
                  children: match.playersJoined.map((uid) {
                    final profile = _playerProfiles[uid];
                    final isHost = uid == match.hostUserId;
                    final isSelf = viewer != null && viewer.id == uid;
                    return _PlayerRow(
                      uid: uid,
                      profile: profile,
                      isHost: isHost,
                      isSelf: isSelf,
                      viewerId: viewer?.id,
                      loading: _loadingProfiles && profile == null,
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Description ────────────────────────────────────────────────────────

  Widget _descriptionCard(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this game',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action button ──────────────────────────────────────────────────────

  Widget _actionButton(MatchRequestModel match) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user =
            authState is AuthAuthenticated ? authState.user : null;
        return BlocBuilder<MatchmakerBloc, MatchmakerState>(
          buildWhen: (prev, next) =>
              (prev is MatchmakerLoaded ? prev.submittingMatchId : null) !=
              (next is MatchmakerLoaded ? next.submittingMatchId : null),
          builder: (context, mmState) {
            final submitting = mmState is MatchmakerLoaded &&
                mmState.submittingMatchId == match.id;
            return _buildActionBarButton(match, user, submitting);
          },
        );
      },
    );
  }

  Widget _buildActionBarButton(
    MatchRequestModel match,
    UserModel? user,
    bool submitting,
  ) {
    if (user == null) {
      return _bigButton(
        label: 'Sign in to join',
        color: AppColors.surface,
        foreground: AppColors.textDisabled,
        onPressed: null,
      );
    }
    if (user.id == match.hostUserId) {
      return _bigButton(
        icon: Icons.star_outline,
        label: 'You are hosting',
        color: AppColors.surface,
        foreground: AppColors.accentYellow,
        border: BorderSide(
          color: AppColors.accentYellow.withValues(alpha: 0.5),
        ),
        onPressed: null,
      );
    }
    final hasJoined = match.playersJoined.contains(user.id);
    if (hasJoined) {
      return _bigButton(
        label: submitting ? null : 'Leave Match',
        color: AppColors.surface,
        foreground: AppColors.error,
        border: BorderSide(color: AppColors.error),
        busy: submitting,
        onPressed: submitting
            ? null
            : () {
                context.read<MatchmakerBloc>().add(
                      MatchmakerLeaveMatch(
                        matchId: match.id,
                        userId: user.id,
                      ),
                    );
              },
      );
    }
    final isFull = match.status != MatchRequestStatus.open;
    return _bigButton(
      label: submitting ? null : (isFull ? 'Game Full' : 'Join Game'),
      color: isFull ? AppColors.surface : AppColors.actionGreen,
      foreground: isFull ? AppColors.textDisabled : Colors.white,
      busy: submitting,
      onPressed: (isFull || submitting)
          ? null
          : () {
              context.read<MatchmakerBloc>().add(
                    MatchmakerJoinMatch(
                      matchId: match.id,
                      userId: user.id,
                    ),
                  );
            },
    );
  }

  Widget _bigButton({
    IconData? icon,
    String? label,
    required Color color,
    required Color foreground,
    BorderSide? border,
    bool busy = false,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground,
          disabledForegroundColor: foreground,
          disabledBackgroundColor: color,
          side: border ?? BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: busy
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Small helpers ──────────────────────────────────────────────────────

  Widget _chipBadge({IconData? icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

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

  String _skillLabel(SkillLevel s) {
    switch (s) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.any:
        return 'Any';
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════
// Single player row — avatar + name + optional "Host" badge.
// ═════════════════════════════════════════════════════════════════════════

class _PlayerRow extends StatelessWidget {
  final String uid;
  final UserModel? profile;
  final bool isHost;
  final bool isSelf;
  final String? viewerId;
  final bool loading;

  const _PlayerRow({
    required this.uid,
    required this.profile,
    required this.isHost,
    required this.isSelf,
    required this.viewerId,
    required this.loading,
  });

  Future<void> _launch(BuildContext context, Uri uri, String failMsg) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(failMsg),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _addToTeam(BuildContext context) async {
    final p = profile;
    if (p == null) return;
    final repo = context.read<TeamRepository>();
    if (viewerId == null) return;

    // Fetch teams where viewer is captain.
    List<TeamModel> teams;
    try {
      teams = await repo.getTeamsForUser(viewerId!);
      teams = teams.where((t) => t.captainId == viewerId).toList();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load teams: $e')),
      );
      return;
    }
    if (!context.mounted) return;
    if (teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'You have no teams. Create one in Profile → My Teams first.'),
        ),
      );
      return;
    }

    final picked = await showModalBottomSheet<TeamModel>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Add ${p.name} to…',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: teams.length,
                  itemBuilder: (_, i) {
                    final t = teams[i];
                    final already =
                        t.members.any((m) => m.userId == p.id);
                    return ListTile(
                      title: Text(t.name,
                          style:
                              TextStyle(color: AppColors.textPrimary)),
                      subtitle: Text(
                        '${t.members.length} members',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      trailing: already
                          ? Text('Already in',
                              style: TextStyle(
                                  color: AppColors.textDisabled,
                                  fontSize: 12))
                          : Icon(Icons.add_circle_outline,
                              color: AppColors.actionGreen),
                      enabled: !already,
                      onTap: already
                          ? null
                          : () => Navigator.pop(sheetCtx, t),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (picked == null || !context.mounted) return;

    final member = TeamMember(
      userId: p.id,
      name: p.name,
      role: 'Player',
    );
    try {
      await repo.addMember(picked.id, member);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${p.name} added to ${picked.name}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = profile?.name ?? (loading ? 'Loading…' : 'Unknown player');
    final avatarUrl = profile?.avatarUrl;
    final email = profile?.email ?? '';
    final phone = profile?.phone ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                    if (isHost) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppColors.accentYellow.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'HOST',
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
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  _ContactLine(
                    icon: Icons.email_outlined,
                    text: email,
                    onTap: () => _launch(
                      context,
                      Uri(scheme: 'mailto', path: email),
                      'Could not open email app',
                    ),
                  ),
                ],
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  _ContactLine(
                    icon: Icons.phone_outlined,
                    text: phone,
                    onTap: () => _launch(
                      context,
                      Uri(scheme: 'tel', path: phone),
                      'Could not open phone dialer',
                    ),
                  ),
                ],
                if (email.isEmpty && phone.isEmpty && !loading) ...[
                  const SizedBox(height: 2),
                  Text(
                    'No contact info',
                    style: TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Quick action buttons on the right for fast contact.
          if (phone.isNotEmpty)
            IconButton(
              tooltip: 'Call',
              onPressed: () => _launch(
                context,
                Uri(scheme: 'tel', path: phone),
                'Could not open phone dialer',
              ),
              icon: Icon(Icons.call, color: AppColors.actionGreen, size: 20),
              visualDensity: VisualDensity.compact,
            ),
          if (email.isNotEmpty)
            IconButton(
              tooltip: 'Email',
              onPressed: () => _launch(
                context,
                Uri(scheme: 'mailto', path: email),
                'Could not open email app',
              ),
              icon: Icon(Icons.mail_outline,
                  color: AppColors.accentYellow, size: 20),
              visualDensity: VisualDensity.compact,
            ),
          if (!isSelf && viewerId != null && profile != null)
            IconButton(
              tooltip: 'Add to one of my teams',
              onPressed: () => _addToTeam(context),
              icon: Icon(Icons.group_add_outlined,
                  color: AppColors.footballAccent, size: 20),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ContactLine({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
              errorWidget: (_, _, _) => _initialsWidget(initials),
              placeholder: (_, _) => _initialsWidget(initials),
            )
          : _initialsWidget(initials),
    );
  }

  Widget _initialsWidget(String initials) {
    return Center(
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
