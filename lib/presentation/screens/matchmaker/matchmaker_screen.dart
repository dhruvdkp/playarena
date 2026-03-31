import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamebooking/bloc/matchmaker/matchmaker_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/match_request_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:intl/intl.dart';

class MatchmakerScreen extends StatefulWidget {
  const MatchmakerScreen({super.key});

  @override
  State<MatchmakerScreen> createState() => _MatchmakerScreenState();
}

class _MatchmakerScreenState extends State<MatchmakerScreen> {
  SportType? _selectedSport;
  SkillLevel? _selectedSkill;

  final List<SkillLevel> _skillLevels = [
    SkillLevel.beginner,
    SkillLevel.intermediate,
    SkillLevel.advanced,
  ];

  @override
  void initState() {
    super.initState();
    context.read<MatchmakerBloc>().add(const MatchmakerLoadMatches());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Find a Game',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          _buildSportFilterChips(),
          _buildSkillLevelFilter(),
          const Divider(color: AppColors.divider, height: 1),
          Expanded(child: _buildMatchList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showHostGameSheet(context),
        backgroundColor: AppColors.actionGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Host a Game',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSportFilterChips() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _sportChip(null, 'All Sports', Icons.sports),
            const SizedBox(width: 8),
            ...SportType.values.map((sport) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _sportChip(
                  sport,
                  _sportLabel(sport),
                  _sportIcon(sport),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _sportChip(SportType? sport, String label, IconData icon) {
    final isSelected = _selectedSport == sport;
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
        setState(() => _selectedSport = sport);
        if (sport != null) {
          context
              .read<MatchmakerBloc>()
              .add(MatchmakerFilterBySport(sportType: sport));
        } else {
          context
              .read<MatchmakerBloc>()
              .add(const MatchmakerLoadMatches());
        }
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
            const Text(
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

  Widget _buildMatchList() {
    return BlocBuilder<MatchmakerBloc, MatchmakerState>(
      builder: (context, state) {
        if (state is MatchmakerLoading) {
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
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context
                      .read<MatchmakerBloc>()
                      .add(const MatchmakerLoadMatches()),
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

          if (_selectedSkill != null) {
            matches = matches
                .where((m) =>
                    m.skillLevel.name == _selectedSkill!.name)
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
                  const Text(
                    'No open games found',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Be the first to host a game!',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, index) =>
                _buildMatchCard(matches[index]),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMatchCard(MatchRequestModel match) {
    final spotsLeft = match.playersNeeded - match.playersJoined.length;
    final isFull = spotsLeft <= 0;
    final progress = match.playersNeeded > 0
        ? (match.playersJoined.length / match.playersNeeded).clamp(0.0, 1.0)
        : 0.0;

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Badges row: wrap to prevent overflow ──
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

            // ── Venue name ──
            Text(
              match.venueName,
              style: const TextStyle(
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
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // ── Date & Time row: wrap for small screens ──
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEE, dd MMM').format(match.date),
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule,
                        color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      match.time,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Player progress ──
            Row(
              children: [
                const Icon(Icons.group,
                    color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${match.playersJoined.length}/${match.playersNeeded} players',
                  style: const TextStyle(
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

            // ── Description ──
            if (match.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                match.description,
                style: const TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // ── Join button ──
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: isFull
                    ? null
                    : () {
                        context.read<MatchmakerBloc>().add(
                              MatchmakerJoinMatch(
                                matchId: match.id,
                                userId: 'current_user',
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
                child: Text(
                  isFull ? 'Game Full' : 'Join Game',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

  void _showHostGameSheet(BuildContext context) {
    final sportController = ValueNotifier<SportType>(SportType.boxCricket);
    final skillController = ValueNotifier<SkillLevel>(SkillLevel.beginner);
    final venueController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final playersController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
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
                const Text(
                  'Host a Game',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Sport',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                ValueListenableBuilder<SportType>(
                  valueListenable: sportController,
                  builder: (_, sport, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<SportType>(
                          value: sport,
                          dropdownColor: AppColors.card,
                          isExpanded: true,
                          items: SportType.values.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                _sportLabel(s),
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) sportController.value = v;
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _sheetTextField(venueController, 'Venue', 'Enter venue name'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _sheetTextField(
                            dateController, 'Date', 'DD/MM/YYYY')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _sheetTextField(
                            timeController, 'Time', 'HH:MM')),
                  ],
                ),
                const SizedBox(height: 16),
                _sheetTextField(
                    playersController, 'Players Needed', 'e.g. 10'),
                const SizedBox(height: 16),
                const Text('Skill Level',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                ValueListenableBuilder<SkillLevel>(
                  valueListenable: skillController,
                  builder: (_, skill, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<SkillLevel>(
                          value: skill,
                          dropdownColor: AppColors.card,
                          isExpanded: true,
                          items: SkillLevel.values.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                _skillLabel(s),
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) skillController.value = v;
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _sheetTextField(descriptionController, 'Description',
                    'Describe the game...'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final match = MatchRequestModel(
                        id: 'MR${DateTime.now().millisecondsSinceEpoch}',
                        hostUserId: 'current_user',
                        hostName: 'You',
                        venueId: 'venue_1',
                        venueName: venueController.text.isNotEmpty
                            ? venueController.text
                            : 'TBD Venue',
                        sportType: sportController.value,
                        date: DateTime.now().add(const Duration(days: 1)),
                        time: timeController.text.isNotEmpty
                            ? timeController.text
                            : '18:00',
                        playersNeeded:
                            int.tryParse(playersController.text) ?? 10,
                        playersJoined: const ['current_user'],
                        skillLevel: skillController.value,
                        description: descriptionController.text.isNotEmpty
                            ? descriptionController.text
                            : '',
                        status: MatchRequestStatus.open,
                      );
                      context.read<MatchmakerBloc>().add(
                            MatchmakerCreateRequest(request: match),
                          );
                      Navigator.pop(ctx);
                    },
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
        );
      },
    );
  }

  Widget _sheetTextField(
      TextEditingController controller, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textDisabled),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.actionGreen),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
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
