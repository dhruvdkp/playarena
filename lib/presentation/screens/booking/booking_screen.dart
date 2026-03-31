import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/bloc/auth/auth_bloc.dart';
import 'package:gamebooking/bloc/booking/booking_bloc.dart';
import 'package:gamebooking/bloc/venue/venue_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/routes/app_router.dart';
import 'package:gamebooking/data/models/add_on_model.dart';
import 'package:gamebooking/data/models/booking_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final String venueId;

  const BookingScreen({super.key, required this.venueId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final List<AddOnModel> _availableAddOns = const [
    AddOnModel(id: 'addon_bat', name: 'Bat Rental', price: 100, description: 'Premium cricket bat'),
    AddOnModel(id: 'addon_ball', name: 'Ball', price: 50, description: 'Match-quality ball'),
    AddOnModel(id: 'addon_shoes', name: 'Shoes', price: 150, description: 'Sports shoes rental'),
    AddOnModel(id: 'addon_refreshments', name: 'Refreshments', price: 200, description: 'Water & energy drinks'),
  ];

  final Set<String> _selectedAddOnIds = {};
  final List<_SplitFriend> _splitFriends = [];
  final TextEditingController _friendNameController = TextEditingController();

  @override
  void dispose() {
    _friendNameController.dispose();
    super.dispose();
  }

  double get _addOnsTotal => _availableAddOns
      .where((a) => _selectedAddOnIds.contains(a.id))
      .fold(0.0, (sum, a) => sum + a.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Complete Booking',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingCreated) {
            context.go(AppRoutes.bookingConfirmation);
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionGreen),
            );
          }

          final selectedSlot =
              state is BookingInProgress ? state.selectedSlot : null;
          final slotPrice = selectedSlot?.price ?? 0.0;
          final discount = 0.0;
          final total = slotPrice + _addOnsTotal - discount;
          final perPersonAmount = _splitFriends.isNotEmpty
              ? total / (_splitFriends.length + 1)
              : total;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVenueInfoHeader(context),
                const SizedBox(height: 20),
                _buildSelectedSlotCard(selectedSlot),
                const SizedBox(height: 24),
                _buildAddOnsSection(),
                const SizedBox(height: 24),
                _buildSplitPaymentSection(perPersonAmount),
                const SizedBox(height: 24),
                _buildPriceBreakdown(slotPrice, _addOnsTotal, discount, total),
                const SizedBox(height: 32),
                _buildConfirmButton(context, state, total),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenueInfoHeader(BuildContext context) {
    return BlocBuilder<VenueBloc, VenueState>(
      builder: (context, venueState) {
        String venueName = 'Loading venue...';
        String sportLabel = '';

        if (venueState is VenueDetailLoaded) {
          venueName = venueState.venue.name;
          sportLabel =
              venueState.venue.sportTypes.map(_sportTypeLabel).join(', ');
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.stadiumGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.actionGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stadium_outlined,
                  color: AppColors.actionGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venueName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sportLabel,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
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

  Widget _buildSelectedSlotCard(dynamic selectedSlot) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.actionGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, color: AppColors.actionGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Selected Slot',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedSlot != null) ...[
            _slotDetailRow(
              Icons.calendar_today,
              'Date',
              DateFormat('EEE, dd MMM yyyy').format(selectedSlot.date),
            ),
            const SizedBox(height: 8),
            _slotDetailRow(
              Icons.schedule,
              'Time',
              '${selectedSlot.startTime} - ${selectedSlot.endTime}',
            ),
            const SizedBox(height: 8),
            _slotDetailRow(
              Icons.timer_outlined,
              'Duration',
              '${selectedSlot.duration} mins',
            ),
            const SizedBox(height: 8),
            _slotDetailRow(
              Icons.currency_rupee,
              'Slot Price',
              '${selectedSlot.price.toStringAsFixed(0)}',
            ),
            if (selectedSlot.isHappyHour) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department,
                        color: AppColors.accentYellow, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Happy Hour Rate',
                      style: TextStyle(
                          color: AppColors.accentYellow,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ] else
            const Text(
              'No slot selected. Please go back and select a time slot.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _slotDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAddOnsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.add_shopping_cart,
                color: AppColors.accentYellow, size: 22),
            SizedBox(width: 8),
            Text(
              'Add-ons',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._availableAddOns.map((addOn) {
          final isSelected = _selectedAddOnIds.contains(addOn.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedAddOnIds.remove(addOn.id);
                    context
                        .read<BookingBloc>()
                        .add(BookingRemoveAddOn(addOnId: addOn.id));
                  } else {
                    _selectedAddOnIds.add(addOn.id);
                    context
                        .read<BookingBloc>()
                        .add(BookingAddAddOn(addOn: addOn));
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.actionGreen.withValues(alpha: 0.1)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.actionGreen
                        : AppColors.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.actionGreen.withValues(alpha: 0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _addOnIcon(addOn.id),
                        color: isSelected
                            ? AppColors.actionGreen
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addOn.name,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (addOn.description != null)
                            Text(
                              addOn.description!,
                              style: const TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '\u20B9${addOn.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.actionGreen
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.actionGreen
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.actionGreen
                              : AppColors.divider,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSplitPaymentSection(double perPersonAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.group, color: AppColors.footballAccent, size: 22),
                SizedBox(width: 8),
                Text(
                  'Split Payment',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => _showAddFriendDialog(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.footballAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color:
                          AppColors.footballAccent.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add,
                        color: AppColors.footballAccent, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Add Friend',
                      style: TextStyle(
                        color: AppColors.footballAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_splitFriends.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Column(
              children: [
                Icon(Icons.people_outline,
                    color: AppColors.textDisabled, size: 40),
                SizedBox(height: 8),
                Text(
                  'Add friends to split the total cost equally',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _splitPersonTile('You', perPersonAmount, isYou: true),
                const Divider(color: AppColors.divider, height: 1),
                ..._splitFriends.map((friend) {
                  return Column(
                    children: [
                      _splitPersonTile(friend.name, perPersonAmount),
                      if (friend != _splitFriends.last)
                        const Divider(
                            color: AppColors.divider, height: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _splitPersonTile(String name, double amount,
      {bool isYou = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isYou
                ? AppColors.actionGreen.withValues(alpha: 0.2)
                : AppColors.footballAccent.withValues(alpha: 0.2),
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                color: isYou
                    ? AppColors.actionGreen
                    : AppColors.footballAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: isYou ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            '\u20B9${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isYou) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                setState(() {
                  _splitFriends.removeWhere((f) => f.name == name);
                });
              },
              child:
                  const Icon(Icons.close, color: AppColors.error, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    _friendNameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Friend',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: _friendNameController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter friend\'s name',
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
          ),
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
              final name = _friendNameController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _splitFriends.add(_SplitFriend(name: name));
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.actionGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child:
                const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(
      double slotPrice, double addOnsTotal, double discount, double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Breakdown',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _priceRow('Slot Price', slotPrice),
          if (addOnsTotal > 0) ...[
            const SizedBox(height: 8),
            _priceRow('Add-ons', addOnsTotal),
          ],
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _priceRow('Discount', -discount, isDiscount: true),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.divider, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\u20B9${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.actionGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          '${isDiscount ? "- " : ""}\u20B9${amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            color:
                isDiscount ? AppColors.actionGreen : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(
      BuildContext context, BookingState state, double total) {
    final isLoading = state is BookingLoading;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.actionGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.actionGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  final bookingState =
                      context.read<BookingBloc>().state;
                  if (bookingState is BookingInProgress &&
                      bookingState.selectedSlot != null) {
                    final slot = bookingState.selectedSlot!;
                    final selectedAddOns = _availableAddOns
                        .where(
                            (a) => _selectedAddOnIds.contains(a.id))
                        .map((a) => AddOn(
                              id: a.id,
                              name: a.name,
                              price: a.price,
                              quantity: 1,
                            ))
                        .toList();

                    final splitPayments = _splitFriends
                        .map((f) => SplitPaymentModel(
                              userId: f.name
                                  .toLowerCase()
                                  .replaceAll(' ', '_'),
                              userName: f.name,
                              amount:
                                  total / (_splitFriends.length + 1),
                              isPaid: false,
                            ))
                        .toList();

                    // Get real user data from AuthBloc
                    final authState = context.read<AuthBloc>().state;
                    final userId = authState is AuthAuthenticated
                        ? authState.user.id
                        : 'guest';
                    final userName = authState is AuthAuthenticated
                        ? authState.user.name
                        : 'Guest';

                    // Get real venue data from VenueBloc
                    final venueState = context.read<VenueBloc>().state;
                    String venueName = 'Venue';
                    SportType sportType = SportType.boxCricket;
                    if (venueState is VenueDetailLoaded) {
                      venueName = venueState.venue.name;
                      sportType = venueState.venue.sportTypes.isNotEmpty
                          ? venueState.venue.sportTypes.first
                          : SportType.boxCricket;
                    }

                    final booking = BookingModel(
                      id: 'BK${DateTime.now().millisecondsSinceEpoch}',
                      venueId: widget.venueId,
                      venueName: venueName,
                      userId: userId,
                      userName: userName,
                      sportType: sportType,
                      slot: slot,
                      addOns: selectedAddOns,
                      totalAmount: total,
                      paymentStatus: PaymentStatus.pending,
                      bookingStatus: BookingStatus.upcoming,
                      splitPayment: splitPayments,
                      createdAt: DateTime.now(),
                    );

                    context
                        .read<BookingBloc>()
                        .add(BookingCreate(booking: booking));
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Confirm & Pay \u20B9${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  IconData _addOnIcon(String id) {
    switch (id) {
      case 'addon_bat':
        return Icons.sports_cricket;
      case 'addon_ball':
        return Icons.sports_soccer;
      case 'addon_shoes':
        return Icons.ice_skating;
      case 'addon_refreshments':
        return Icons.local_cafe;
      default:
        return Icons.add_circle_outline;
    }
  }

  String _sportTypeLabel(SportType type) {
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
}

class _SplitFriend {
  final String name;
  const _SplitFriend({required this.name});
}
