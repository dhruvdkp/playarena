import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gamebooking/bloc/venue/venue_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/constants/app_strings.dart';
import 'package:gamebooking/core/utils/helpers.dart';
import 'package:gamebooking/data/models/review_model.dart';
import 'package:gamebooking/data/models/slot_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/presentation/widgets/slot_picker.dart';

/// Venue detail screen displaying an image carousel, venue info, amenities,
/// pricing, date/slot picker, reviews, and a "Book Now" floating button.
///
/// Receives [venueId] from the route parameter and uses [VenueBloc] to
/// load venue details, slots, and reviews.
class VenueDetailScreen extends StatefulWidget {
  final String venueId;

  const VenueDetailScreen({super.key, required this.venueId});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlotId;
  int _currentImageIndex = 0;
  final PageController _imagePageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<VenueBloc>().add(VenueLoadDetail(venueId: widget.venueId));
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedSlotId = null;
    });
    context.read<VenueBloc>().add(
          VenueLoadSlots(venueId: widget.venueId, date: date),
        );
  }

  void _onSlotSelected(SlotModel slot) {
    setState(() => _selectedSlotId = slot.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VenueBloc, VenueState>(
      builder: (context, state) {
        if (state is VenueLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.actionGreen),
            ),
          );
        }

        if (state is VenueError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<VenueBloc>()
                        .add(VenueLoadDetail(venueId: widget.venueId)),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is VenueDetailLoaded) {
          return _buildContent(state.venue, state.slots, state.reviews);
        }

        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }

  Widget _buildContent(
    VenueModel venue,
    List<SlotModel> slots,
    List<ReviewModel> reviews,
  ) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Image Carousel / Header ────────────────────────────────
          _buildImageHeader(venue),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── Venue Name & Rating ────────────────────────────
                  _buildVenueHeader(venue),
                  const SizedBox(height: 12),

                  // ── Address ────────────────────────────────────────
                  _buildAddress(venue),
                  const SizedBox(height: 20),

                  // ── Sport Type Chips ───────────────────────────────
                  _buildSportChips(venue),
                  const SizedBox(height: 24),

                  // ── Amenities Grid ────────────────────────────────
                  _buildAmenitiesSection(venue),
                  const SizedBox(height: 24),

                  // ── Pricing Section ───────────────────────────────
                  _buildPricingSection(venue),
                  const SizedBox(height: 24),

                  // ── Rules Section ───────────────────────────────────
                  if (venue.rules.isNotEmpty) ...[
                    _buildRulesSection(venue),
                    const SizedBox(height: 24),
                  ],

                  // ── Date Picker ───────────────────────────────────
                  _buildDatePicker(),
                  const SizedBox(height: 16),

                  // ── Slot Picker ───────────────────────────────────
                  _buildSlotSection(slots),
                  const SizedBox(height: 24),

                  // ── Reviews Section ───────────────────────────────
                  _buildReviewsSection(reviews),
                  const SizedBox(height: 24),

                  // ── Contact Button ────────────────────────────────
                  _buildContactButton(venue),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Floating Book Now Button ──────────────────────────────────────
      floatingActionButton: _buildBookNowButton(venue),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── Image Carousel Header ────────────────────────────────────────────────

  Widget _buildImageHeader(VenueModel venue) {
    final images = venue.imageUrls;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primaryBackground,
      leading: _buildCircularBackButton(),
      actions: [
        _buildCircularIconButton(Icons.favorite_border, () {}),
        const SizedBox(width: 8),
        _buildCircularIconButton(Icons.share_outlined, () {}),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image carousel
            if (images.isNotEmpty)
              PageView.builder(
                controller: _imagePageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() => _currentImageIndex = index);
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Icon(Icons.stadium_outlined,
                            size: 56, color: AppColors.textDisabled),
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                color: AppColors.surface,
                child: const Center(
                  child: Icon(Icons.stadium_outlined,
                      size: 56, color: AppColors.textDisabled),
                ),
              ),

            // Gradient overlay
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x800F172A),
                      AppColors.primaryBackground,
                    ],
                    stops: [0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // Page indicator dots
            if (images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentImageIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? AppColors.actionGreen
                            : AppColors.textDisabled.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: AppColors.primaryBackground.withValues(alpha: 0.6),
        radius: 18,
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          color: AppColors.textPrimary,
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
        ),
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onTap) {
    return CircleAvatar(
      backgroundColor: AppColors.primaryBackground.withValues(alpha: 0.6),
      radius: 18,
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: AppColors.textPrimary,
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }

  // ── Venue Header ─────────────────────────────────────────────────────────

  Widget _buildVenueHeader(VenueModel venue) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      venue.name,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ),
                  if (venue.isVerified) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.verified,
                        color: AppColors.actionGreen, size: 22),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${venue.openTime} - ${venue.closeTime}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        // Rating badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentYellow.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.accentYellow, size: 20),
              const SizedBox(width: 4),
              Text(
                venue.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.accentYellow,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${venue.totalReviews})',
                style: TextStyle(
                  color: AppColors.accentYellow.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Address ──────────────────────────────────────────────────────────────

  Widget _buildAddress(VenueModel venue) {
    return GestureDetector(
      onTap: () {
        // TODO: Open in maps
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on_outlined,
                color: AppColors.actionGreen, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.address,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  venue.city,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.open_in_new,
              size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  // ── Sport Chips ──────────────────────────────────────────────────────────

  Widget _buildSportChips(VenueModel venue) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: venue.sportTypes.map((sport) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.actionGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.actionGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Helpers.getSportIcon(sport.name),
                size: 16,
                color: AppColors.actionGreen,
              ),
              const SizedBox(width: 6),
              Text(
                sport.name
                    .replaceAllMapped(
                      RegExp(r'([A-Z])'),
                      (m) => ' ${m.group(0)}',
                    )
                    .trim(),
                style: const TextStyle(
                  color: AppColors.actionGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Amenities Grid ───────────────────────────────────────────────────────

  Widget _buildAmenitiesSection(VenueModel venue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.amenities,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: venue.amenities.map((amenity) {
            return _AmenityIcon(amenity: amenity);
          }).toList(),
        ),
      ],
    );
  }

  // ── Rules Section ───────────────────────────────────────────────────────

  Widget _buildRulesSection(VenueModel venue) {
    final ruleLines = venue.rules
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rules & Guidelines',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accentYellow.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ruleLines.map((rule) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.check_circle,
                          color: AppColors.accentYellow, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule.trim(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Pricing Section ──────────────────────────────────────────────────────

  Widget _buildPricingSection(VenueModel venue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _PriceCard(
                label: 'Regular',
                price: venue.pricePerHour,
                color: AppColors.actionGreen,
                icon: Icons.access_time,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PriceCard(
                label: 'Peak Hour',
                price: venue.peakPricePerHour,
                color: AppColors.error,
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PriceCard(
                label: 'Happy Hour',
                price: venue.happyHourPrice,
                color: AppColors.accentYellow,
                icon: Icons.local_offer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Date Picker ──────────────────────────────────────────────────────────

  Widget _buildDatePicker() {
    final today = DateTime.now();
    final dates = List.generate(14, (i) => today.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectDate,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, today);

              return GestureDetector(
                onTap: () => _onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.actionGreen
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.actionGreen
                          : AppColors.divider,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekdayShort(date.weekday),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryBackground
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryBackground
                              : AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _monthShort(date.month),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryBackground
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isToday && !isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.actionGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _weekdayShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _monthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  // ── Slot Section ─────────────────────────────────────────────────────────

  Widget _buildSlotSection(List<SlotModel> slots) {
    final todaySlots = slots
        .where((s) => _isSameDay(s.date, _selectedDate))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.availableSlots,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '${todaySlots.where((s) => s.isAvailable).length} available',
              style: const TextStyle(
                color: AppColors.actionGreen,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SlotPicker(
          slots: todaySlots,
          selectedSlotId: _selectedSlotId,
          onSlotSelected: _onSlotSelected,
        ),
      ],
    );
  }

  // ── Reviews Section ──────────────────────────────────────────────────────

  Widget _buildReviewsSection(List<ReviewModel> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppStrings.reviews} (${reviews.length})',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all reviews
              },
              child: const Text(AppStrings.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No reviews yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...reviews.take(3).map((review) => _ReviewCard(review: review)),
      ],
    );
  }

  // ── Contact Button ───────────────────────────────────────────────────────

  Widget _buildContactButton(VenueModel venue) {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: Open phone dialer
      },
      icon: const Icon(Icons.phone_outlined),
      label: Text('Contact Venue (${venue.contactPhone})'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Book Now FAB ─────────────────────────────────────────────────────────

  Widget _buildBookNowButton(VenueModel venue) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedSlotId != null
            ? () => context.push('/booking/${venue.id}')
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.divider,
          disabledForegroundColor: AppColors.textDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: AppColors.actionGreen.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flash_on, size: 20),
            const SizedBox(width: 8),
            Text(
              _selectedSlotId != null
                  ? AppStrings.bookNow
                  : 'Select a Slot to Book',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Amenity Icon Widget ──────────────────────────────────────────────────────

class _AmenityIcon extends StatelessWidget {
  final Amenity amenity;

  const _AmenityIcon({required this.amenity});

  @override
  Widget build(BuildContext context) {
    final data = _resolveAmenity();

    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(data.icon, size: 22, color: AppColors.actionGreen),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  _AmenityData _resolveAmenity() {
    switch (amenity) {
      case Amenity.parking:
        return const _AmenityData(icon: Icons.local_parking, label: 'Parking');
      case Amenity.cctv:
        return const _AmenityData(icon: Icons.videocam_outlined, label: 'CCTV');
      case Amenity.shower:
        return const _AmenityData(icon: Icons.shower_outlined, label: 'Shower');
      case Amenity.drinkingWater:
        return const _AmenityData(
            icon: Icons.water_drop_outlined, label: 'Water');
      case Amenity.changingRoom:
        return const _AmenityData(
            icon: Icons.checkroom, label: 'Changing\nRoom');
      case Amenity.cafeteria:
        return const _AmenityData(
            icon: Icons.restaurant_outlined, label: 'Cafeteria');
      case Amenity.firstAid:
        return const _AmenityData(
            icon: Icons.medical_services_outlined, label: 'First Aid');
      case Amenity.wifi:
        return const _AmenityData(icon: Icons.wifi, label: 'WiFi');
      case Amenity.floodlights:
        return const _AmenityData(
            icon: Icons.flashlight_on_outlined, label: 'Floodlights');
      case Amenity.scoreboard:
        return const _AmenityData(
            icon: Icons.scoreboard_outlined, label: 'Scoreboard');
    }
  }
}

class _AmenityData {
  final IconData icon;
  final String label;

  const _AmenityData({required this.icon, required this.label});
}

// ── Price Card ───────────────────────────────────────────────────────────────

class _PriceCard extends StatelessWidget {
  final String label;
  final double price;
  final Color color;
  final IconData icon;

  const _PriceCard({
    required this.label,
    required this.price,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            Helpers.formatPrice(price),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Review Card ──────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info + rating
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.card,
                backgroundImage: review.userAvatarUrl != null
                    ? NetworkImage(review.userAvatarUrl!)
                    : null,
                child: review.userAvatarUrl == null
                    ? Text(
                        Helpers.getInitials(review.userName),
                        style: const TextStyle(
                          color: AppColors.actionGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      Helpers.formatDateRelative(review.createdAt),
                      style: const TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.accentYellow,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Comment
          Text(
            review.comment,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          // Helpful count
          if (review.helpfulCount > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.thumb_up_alt_outlined,
                    size: 14, color: AppColors.textDisabled),
                const SizedBox(width: 4),
                Text(
                  '${review.helpfulCount} found helpful',
                  style: const TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
