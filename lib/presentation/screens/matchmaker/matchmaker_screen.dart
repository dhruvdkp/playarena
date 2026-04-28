import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/bloc/auth/auth_bloc.dart';
import 'package:gamebooking/bloc/matchmaker/matchmaker_bloc.dart';
import 'package:gamebooking/bloc/venue/venue_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/match_request_model.dart';
import 'package:gamebooking/data/models/user_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:intl/intl.dart';

class MatchmakerScreen extends StatefulWidget {
  const MatchmakerScreen({super.key});

  @override
  State<MatchmakerScreen> createState() => _MatchmakerScreenState();
}

class _MatchmakerScreenState extends State<MatchmakerScreen> {
  // Skill chip is pure client-side filter — kept in widget state.
  // Sport filter lives in MatchmakerLoaded so it survives refreshes.
  SkillLevel? _selectedSkill;

  static const List<SkillLevel> _skillLevels = [
    SkillLevel.beginner,
    SkillLevel.intermediate,
    SkillLevel.advanced,
  ];

  @override
  void initState() {
    super.initState();
    context.read<MatchmakerBloc>().add(const MatchmakerSubscribe());
    // Pre-warm the venue list so the host-game sheet's dropdown is ready.
    final venueState = context.read<VenueBloc>().state;
    if (venueState is! VenueLoaded) {
      context.read<VenueBloc>().add(const VenueLoadAll());
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
          'Find a Game',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
        child: Column(
          children: [
            _buildSportFilterChips(),
            _buildSkillLevelFilter(),
            Divider(color: AppColors.divider, height: 1),
            Expanded(child: _buildMatchList()),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isAuthed = authState is AuthAuthenticated;
          return FloatingActionButton.extended(
            onPressed: isAuthed
                ? () => _showHostGameSheet(context, authState.user)
                : () => _promptSignIn(context),
            backgroundColor: AppColors.actionGreen,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Host a Game',
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

  void _promptSignIn(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Please sign in to host or join a game'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ── Sport filter (now state-driven) ─────────────────────────────────────

  Widget _buildSportFilterChips() {
    return BlocBuilder<MatchmakerBloc, MatchmakerState>(
      buildWhen: (prev, next) =>
          (prev is MatchmakerLoaded ? prev.sportFilter : null) !=
          (next is MatchmakerLoaded ? next.sportFilter : null),
      builder: (context, state) {
        final selectedSport =
            state is MatchmakerLoaded ? state.sportFilter : null;
        return Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _sportChip(null, 'All Sports', Icons.sports, selectedSport),
                const SizedBox(width: 8),
                ...SportType.values.map((sport) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _sportChip(
                      sport,
                      _sportLabel(sport),
                      _sportIcon(sport),
                      selectedSport,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sportChip(
    SportType? sport,
    String label,
    IconData icon,
    SportType? selectedSport,
  ) {
    final isSelected = selectedSport == sport;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: AppColors.card,
      selectedColor: AppColors.actionGreen,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.actionGreen : AppColors.divider,
        ),
      ),
      onSelected: (_) {
        context
            .read<MatchmakerBloc>()
            .add(MatchmakerFilterBySport(sportType: sport));
      },
    );
  }

  Widget _buildSkillLevelFilter() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'Skill: ',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            _skillChip(null, 'Any'),
            const SizedBox(width: 8),
            ..._skillLevels.map((level) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _skillChip(level, _skillLabel(level)),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _skillChip(SkillLevel? level, String label) {
    final isSelected = _selectedSkill == level;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: AppColors.card,
      selectedColor: AppColors.footballAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.footballAccent : AppColors.divider,
        ),
      ),
      onSelected: (_) {
        setState(() => _selectedSkill = level);
      },
    );
  }

  // ── Match list ──────────────────────────────────────────────────────────

  Widget _buildMatchList() {
    return BlocBuilder<MatchmakerBloc, MatchmakerState>(
      builder: (context, state) {
        if (state is MatchmakerLoading || state is MatchmakerInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.actionGreen),
          );
        }

        if (state is MatchmakerError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 48),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context
                      .read<MatchmakerBloc>()
                      .add(const MatchmakerSubscribe()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.actionGreen),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        if (state is MatchmakerLoaded) {
          var matches = state.matches;

          if (state.sportFilter != null) {
            matches = matches
                .where((m) => m.sportType == state.sportFilter)
                .toList();
          }
          if (_selectedSkill != null) {
            matches = matches
                .where((m) => m.skillLevel.name == _selectedSkill!.name)
                .toList();
          }

          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_outlined,
                      color: AppColors.textDisabled.withValues(alpha: 0.5),
                      size: 72),
                  const SizedBox(height: 16),
                  Text(
                    'No open games found',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to host a game!',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.actionGreen,
            // Stream is already live; this re-subscribes for users who
            // expect pull-to-refresh as a recovery action after a network blip.
            onRefresh: () async {
              context
                  .read<MatchmakerBloc>()
                  .add(const MatchmakerSubscribe());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              itemBuilder: (context, index) =>
                  _buildMatchCard(matches[index], state.submittingMatchId),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMatchCard(MatchRequestModel match, String? submittingMatchId) {
    final spotsLeft = match.playersNeeded - match.playersJoined.length;
    final isFull = spotsLeft <= 0;
    final progress = match.playersNeeded > 0
        ? (match.playersJoined.length / match.playersNeeded).clamp(0.0, 1.0)
        : 0.0;
    final isSubmitting = submittingMatchId == match.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFull
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/matchmaker/match/${match.id}'),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _badge(
                  icon: _sportIcon(match.sportType),
                  label: _sportLabel(match.sportType),
                  color: _sportColor(match.sportType),
                  bgColor:
                      _sportColor(match.sportType).withValues(alpha: 0.15),
                ),
                _badge(
                  label: _skillLabel(match.skillLevel),
                  color: AppColors.accentYellow,
                  bgColor: AppColors.surface,
                ),
                _badge(
                  label: isFull ? 'Full' : '$spotsLeft spots left',
                  color: isFull ? AppColors.error : AppColors.actionGreen,
                  bgColor: isFull
                      ? AppColors.error.withValues(alpha: 0.15)
                      : AppColors.actionGreen.withValues(alpha: 0.15),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              match.venueName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Hosted by ${match.hostName}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today,
                        color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEE, dd MMM').format(match.date),
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule,
                        color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      match.time,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Icon(Icons.group,
                    color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${match.playersJoined.length}/${match.playersNeeded} players',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color:
                        isFull ? AppColors.actionGreen : AppColors.accentYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isFull ? AppColors.actionGreen : AppColors.accentYellow,
                ),
                minHeight: 5,
              ),
            ),

            if (match.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                match.description,
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (match.playersJoined.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.touch_app_outlined,
                      color: AppColors.textDisabled, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to view players',
                    style: TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),
            _buildActionButton(match, isFull, isSubmitting),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    MatchRequestModel match,
    bool isFull,
    bool isSubmitting,
  ) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user =
            authState is AuthAuthenticated ? authState.user : null;
        final isHost = user != null && user.id == match.hostUserId;
        final hasJoined =
            user != null && match.playersJoined.contains(user.id);

        // Hosts: show a non-interactive "You are hosting" pill.
        if (isHost) {
          return SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.star_outline, size: 18),
              label: const Text('You are hosting'),
              style: OutlinedButton.styleFrom(
                disabledForegroundColor: AppColors.accentYellow,
                side: BorderSide(
                  color: AppColors.accentYellow.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          );
        }

        // Joined non-hosts: show Leave Match.
        if (hasJoined) {
          return SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      context.read<MatchmakerBloc>().add(
                            MatchmakerLeaveMatch(
                              matchId: match.id,
                              userId: user.id,
                            ),
                          );
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    )
                  : const Text('Leave Match',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      )),
            ),
          );
        }

        // Default: Join (or signed-out / full disabled state).
        final canJoin = user != null && !isFull;
        return SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: !canJoin || isSubmitting
                ? null
                : () {
                    context.read<MatchmakerBloc>().add(
                          MatchmakerJoinMatch(
                            matchId: match.id,
                            userId: user.id,
                          ),
                        );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.actionGreen,
              disabledBackgroundColor: AppColors.surface,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.textDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    user == null
                        ? 'Sign in to join'
                        : (isFull ? 'Game Full' : 'Join Game'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _badge({
    IconData? icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Host-game bottom sheet ──────────────────────────────────────────────

  void _showHostGameSheet(BuildContext context, UserModel user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _HostGameSheet(user: user),
    );
  }

  // ── Sport / skill labels & icons ────────────────────────────────────────

  String _sportLabel(SportType type) {
    switch (type) {
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

  IconData _sportIcon(SportType type) {
    switch (type) {
      case SportType.boxCricket:
        return Icons.sports_cricket;
      case SportType.football:
        return Icons.sports_soccer;
      case SportType.pickleball:
        return Icons.sports_tennis;
      case SportType.badminton:
        return Icons.sports_tennis;
      case SportType.tennis:
        return Icons.sports_tennis;
    }
  }

  Color _sportColor(SportType type) {
    switch (type) {
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

  String _skillLabel(SkillLevel level) {
    switch (level) {
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
// Host-game bottom sheet — extracted as its own StatefulWidget so its form
// state survives BLoC rebuilds and stays out of the parent screen's state.
// ═════════════════════════════════════════════════════════════════════════

class _HostGameSheet extends StatefulWidget {
  final UserModel user;
  const _HostGameSheet({required this.user});

  @override
  State<_HostGameSheet> createState() => _HostGameSheetState();
}

class _HostGameSheetState extends State<_HostGameSheet> {
  final _formKey = GlobalKey<FormState>();
  VenueModel? _venue;
  SportType _sport = SportType.boxCricket;
  SkillLevel _skill = SkillLevel.beginner;
  DateTime? _date;
  TimeOfDay? _time;
  final _playersController = TextEditingController(text: '10');
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _playersController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.accentYellow,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.accentYellow,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_venue == null) {
      _toast('Please pick a venue');
      return;
    }
    if (_date == null) {
      _toast('Please pick a date');
      return;
    }
    if (_time == null) {
      _toast('Please pick a time');
      return;
    }
    final players = int.tryParse(_playersController.text.trim());
    if (players == null || players < 2) {
      _toast('Players needed must be a number ≥ 2');
      return;
    }

    final timeStr =
        '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

    final match = MatchRequestModel(
      id: '', // Firestore generates the doc id; repository strips this.
      hostUserId: widget.user.id,
      hostName: widget.user.name,
      venueId: _venue!.id,
      venueName: _venue!.name,
      sportType: _sport,
      date: _date!,
      time: timeStr,
      playersNeeded: players,
      playersJoined: [widget.user.id],
      skillLevel: _skill,
      description: _descriptionController.text.trim(),
      status: MatchRequestStatus.open,
    );
    context
        .read<MatchmakerBloc>()
        .add(MatchmakerCreateRequest(request: match));
    Navigator.pop(context);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                'Host a Game',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              _label('Venue'),
              _buildVenueDropdown(),
              const SizedBox(height: 16),

              _label('Sport'),
              _dropdownContainer(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SportType>(
                    value: _sport,
                    dropdownColor: AppColors.card,
                    isExpanded: true,
                    items: SportType.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          _sportLabel(s),
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _sport = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _pickerField(
                      label: 'Date',
                      hint: 'Pick a date',
                      value: _date == null
                          ? null
                          : DateFormat('EEE, dd MMM yyyy').format(_date!),
                      onTap: _pickDate,
                      icon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pickerField(
                      label: 'Time',
                      hint: 'Pick a time',
                      value: _time?.format(context),
                      onTap: _pickTime,
                      icon: Icons.schedule,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _label('Players Needed'),
              TextFormField(
                controller: _playersController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.textPrimary),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null) return 'Must be a number';
                  if (n < 2) return 'At least 2 players';
                  if (n > 50) return 'At most 50 players';
                  return null;
                },
                decoration: _inputDecoration('e.g. 10'),
              ),
              const SizedBox(height: 16),

              _label('Skill Level'),
              _dropdownContainer(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SkillLevel>(
                    value: _skill,
                    dropdownColor: AppColors.card,
                    isExpanded: true,
                    items: SkillLevel.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          _skillLabel(s),
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _skill = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _label('Description (optional)'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('Describe the game...'),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.actionGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Create Game',
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
        ),
      ),
    );
  }

  Widget _buildVenueDropdown() {
    return BlocBuilder<VenueBloc, VenueState>(
      builder: (context, state) {
        if (state is VenueLoading || state is VenueInitial) {
          return _dropdownContainer(
            child: const SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accentYellow,
                  ),
                ),
              ),
            ),
          );
        }
        if (state is VenueLoaded) {
          if (state.venues.isEmpty) {
            return _dropdownContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No venues available — ask an admin to add one.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }
          return _dropdownContainer(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<VenueModel>(
                value: _venue,
                dropdownColor: AppColors.card,
                isExpanded: true,
                hint: Text(
                  'Pick a venue',
                  style: TextStyle(color: AppColors.textDisabled),
                ),
                items: state.venues.map((v) {
                  return DropdownMenuItem(
                    value: v,
                    child: Text(
                      '${v.name}  •  ${v.city}',
                      style: TextStyle(color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _venue = v;
                    // Auto-pick the first sport this venue supports if the
                    // current sport isn't in its list.
                    if (v.sportTypes.isNotEmpty &&
                        !v.sportTypes.contains(_sport)) {
                      _sport = v.sportTypes.first;
                    }
                  });
                },
              ),
            ),
          );
        }
        // VenueError or unknown — let user retry.
        return _dropdownContainer(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Could not load venues',
                  style:
                      TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: () => context
                    .read<VenueBloc>()
                    .add(const VenueLoadAll()),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }

  Widget _dropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }

  Widget _pickerField({
    required String label,
    required String hint,
    required String? value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      color: value == null
                          ? AppColors.textDisabled
                          : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  String _sportLabel(SportType type) {
    switch (type) {
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

  String _skillLabel(SkillLevel level) {
    switch (level) {
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
