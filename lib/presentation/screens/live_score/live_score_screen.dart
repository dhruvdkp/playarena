import 'package:flutter/material.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/venue_model.dart';

class LiveScoreScreen extends StatefulWidget {
  const LiveScoreScreen({super.key});

  @override
  State<LiveScoreScreen> createState() => _LiveScoreScreenState();
}

class _LiveScoreScreenState extends State<LiveScoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Mock live match data for demonstration
  final List<_LiveMatch> _liveMatches = [
    _LiveMatch(
      id: 'live_1',
      team1: 'Thunder Strikers',
      team2: 'Royal Challengers',
      score1: 45,
      score2: 38,
      sportType: SportType.boxCricket,
      venue: 'Arena Sports Complex',
      status: 'Innings 2 - Over 8.3',
    ),
    _LiveMatch(
      id: 'live_2',
      team1: 'FC Warriors',
      team2: 'United XI',
      score1: 2,
      score2: 1,
      sportType: SportType.football,
      venue: 'Green Field Stadium',
      status: '72nd min',
    ),
    _LiveMatch(
      id: 'live_3',
      team1: 'Smash Kings',
      team2: 'Net Ninjas',
      score1: 11,
      score2: 9,
      sportType: SportType.badminton,
      venue: 'City Badminton Hall',
      status: 'Set 2 - Game Point',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withValues(
                        alpha: _pulseAnimation.value),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(
                            alpha: _pulseAnimation.value * 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'Live Now',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _liveMatches.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _liveMatches.length,
              itemBuilder: (context, index) =>
                  _buildLiveMatchCard(_liveMatches[index]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_score_outlined,
            color: AppColors.textDisabled.withValues(alpha: 0.5),
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            'No Live Matches',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'There are no matches being played right now.\nCheck back later!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMatchCard(_LiveMatch match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          // Header with sport and venue
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _sportColor(match.sportType).withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _sportIcon(match.sportType),
                      size: 16,
                      color: _sportColor(match.sportType),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _sportLabel(match.sportType),
                      style: TextStyle(
                        color: _sportColor(match.sportType),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.error.withValues(
                                alpha: _pulseAnimation.value),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Score section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                // Team 1
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            match.team1.substring(0, 2).toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.team1,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Scores
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${match.score1}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          ':',
                          style: TextStyle(
                            color: AppColors.textDisabled,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${match.score2}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Team 2
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            match.team2.substring(0, 2).toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.team2,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer with status and venue
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer,
                        color: AppColors.accentYellow, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      match.status,
                      style: const TextStyle(
                        color: AppColors.accentYellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.textDisabled, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      match.venue,
                      style: const TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
}

class _LiveMatch {
  final String id;
  final String team1;
  final String team2;
  final int score1;
  final int score2;
  final SportType sportType;
  final String venue;
  final String status;

  const _LiveMatch({
    required this.id,
    required this.team1,
    required this.team2,
    required this.score1,
    required this.score2,
    required this.sportType,
    required this.venue,
    required this.status,
  });
}
