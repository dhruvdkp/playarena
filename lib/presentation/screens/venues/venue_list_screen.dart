import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gamebooking/bloc/venue/venue_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/constants/app_strings.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/presentation/widgets/venue_card.dart';

/// Venue listing screen with search bar, sport filter chips, sort dropdown,
/// and a scrollable list of [VenueCard] widgets. Integrates with [VenueBloc].
class VenueListScreen extends StatefulWidget {
  const VenueListScreen({super.key});

  @override
  State<VenueListScreen> createState() => _VenueListScreenState();
}

enum _SortOption { rating, priceLow, priceHigh, distance }

class _VenueListScreenState extends State<VenueListScreen> {
  final _searchController = TextEditingController();
  int _selectedSportIndex = 0;
  _SortOption _selectedSort = _SortOption.rating;

  static const List<_SportChipData> _sportChips = [
    _SportChipData(label: 'All', icon: Icons.sports, sportType: null),
    _SportChipData(
        label: 'Box Cricket',
        icon: Icons.sports_cricket,
        sportType: SportType.boxCricket),
    _SportChipData(
        label: 'Football',
        icon: Icons.sports_soccer,
        sportType: SportType.football),
    _SportChipData(
        label: 'Pickleball',
        icon: Icons.sports_tennis,
        sportType: SportType.pickleball),
    _SportChipData(
        label: 'Badminton',
        icon: Icons.sports_tennis,
        sportType: SportType.badminton),
    _SportChipData(
        label: 'Tennis',
        icon: Icons.sports_tennis,
        sportType: SportType.tennis),
  ];

  @override
  void initState() {
    super.initState();
    context.read<VenueBloc>().add(const VenueLoadAll());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      context.read<VenueBloc>().add(const VenueLoadAll());
    } else {
      context.read<VenueBloc>().add(VenueSearch(query: query.trim()));
    }
  }

  void _onSportSelected(int index) {
    setState(() => _selectedSportIndex = index);
    final sportType = _sportChips[index].sportType;
    if (sportType == null) {
      context.read<VenueBloc>().add(const VenueLoadAll());
    } else {
      context.read<VenueBloc>().add(VenueFilterBySport(sportType: sportType));
    }
  }

  List<VenueModel> _sortVenues(List<VenueModel> venues) {
    final sorted = List<VenueModel>.from(venues);
    switch (_selectedSort) {
      case _SortOption.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _SortOption.priceLow:
        sorted.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case _SortOption.priceHigh:
        sorted.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
        break;
      case _SortOption.distance:
        // Distance sorting requires user location; fall back to rating
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.venues),
      ),
      body: Column(
        children: [
          // ── Search Bar ───────────────────────────────────────────
          _buildSearchBar(),
          const SizedBox(height: 14),

          // ── Sport Filter Chips ───────────────────────────────────
          _buildSportChips(),
          const SizedBox(height: 14),

          // ── Sort Dropdown ────────────────────────────────────────
          _buildSortRow(),
          const SizedBox(height: 8),

          // ── Venue List ───────────────────────────────────────────
          Expanded(child: _buildVenueList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search venues, locations...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSportChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _sportChips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = _sportChips[index];
          final isSelected = _selectedSportIndex == index;

          return GestureDetector(
            onTap: () => _onSportSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.actionGreen : AppColors.surface,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(
                  color:
                      isSelected ? AppColors.actionGreen : AppColors.divider,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    chip.icon,
                    size: 16,
                    color: isSelected
                        ? AppColors.primaryBackground
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    chip.label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primaryBackground
                          : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<VenueBloc, VenueState>(
            builder: (context, state) {
              final count =
                  state is VenueLoaded ? state.venues.length : 0;
              return Text(
                '$count venues found',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_SortOption>(
                value: _selectedSort,
                isDense: true,
                dropdownColor: AppColors.surface,
                icon: const Icon(Icons.keyboard_arrow_down,
                    size: 18, color: AppColors.textSecondary),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                items: const [
                  DropdownMenuItem(
                    value: _SortOption.rating,
                    child: Text('Rating'),
                  ),
                  DropdownMenuItem(
                    value: _SortOption.priceLow,
                    child: Text('Price: Low-High'),
                  ),
                  DropdownMenuItem(
                    value: _SortOption.priceHigh,
                    child: Text('Price: High-Low'),
                  ),
                  DropdownMenuItem(
                    value: _SortOption.distance,
                    child: Text('Distance'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSort = value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueList() {
    return BlocBuilder<VenueBloc, VenueState>(
      builder: (context, state) {
        if (state is VenueLoading) {
          return _buildShimmerLoading();
        }

        if (state is VenueLoaded) {
          final venues = _sortVenues(state.venues);

          if (venues.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stadium_outlined,
                      size: 56, color: AppColors.textDisabled),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.noResults,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _selectedSportIndex = 0);
                      context.read<VenueBloc>().add(const VenueLoadAll());
                    },
                    child: const Text('Clear Filters'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.actionGreen,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              context.read<VenueBloc>().add(const VenueLoadAll());
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: venues.length,
              itemBuilder: (context, index) {
                return VenueCard(
                  venue: venues[index],
                  onTap: () => context.push('/venues/${venues[index].id}'),
                );
              },
            ),
          );
        }

        if (state is VenueError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<VenueBloc>().add(const VenueLoadAll()),
                  child: const Text(AppStrings.retry),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: 4,
      itemBuilder: (_, __) => const _VenueShimmerCard(),
    );
  }
}

// ── Data Classes ─────────────────────────────────────────────────────────────

class _SportChipData {
  final String label;
  final IconData icon;
  final SportType? sportType;

  const _SportChipData({
    required this.label,
    required this.icon,
    required this.sportType,
  });
}

// ── Shimmer Loading Card ─────────────────────────────────────────────────────

class _VenueShimmerCard extends StatefulWidget {
  const _VenueShimmerCard();

  @override
  State<_VenueShimmerCard> createState() => _VenueShimmerCardState();
}

class _VenueShimmerCardState extends State<_VenueShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(1.0 + 2.0 * _controller.value, 0),
              colors: const [
                AppColors.surface,
                AppColors.card,
                AppColors.surface,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.card.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title placeholder
                    Container(
                      width: 180,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle placeholder
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.divider.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
