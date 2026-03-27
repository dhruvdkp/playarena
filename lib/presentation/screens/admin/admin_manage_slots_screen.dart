import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/slot_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class AdminManageSlotsScreen extends StatefulWidget {
  final String venueId;
  const AdminManageSlotsScreen({super.key, required this.venueId});

  @override
  State<AdminManageSlotsScreen> createState() => _AdminManageSlotsScreenState();
}

class _AdminManageSlotsScreenState extends State<AdminManageSlotsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  VenueModel? _venue;
  List<SlotModel> _slots = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final venueData = await _firestoreService.getVenueById(widget.venueId);
      if (venueData != null) {
        _venue = VenueModel.fromJson(venueData);
      }
      await _loadSlots();
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _loadSlots() async {
    try {
      final data =
          await _firestoreService.getVenueSlots(widget.venueId, _selectedDate);
      setState(() {
        _slots = data.map((j) => SlotModel.fromJson(j)).toList();
      });
    } catch (_) {}
  }

  Future<void> _generateSlots() async {
    if (_venue == null) return;

    final daysController = TextEditingController(text: '7');
    final durationController = TextEditingController(text: '60');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Generate Slots',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Auto-generate time slots based on venue operating hours.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of days',
                hintText: '7',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Slot duration (minutes)',
                hintText: '60',
                prefixIcon: Icon(Icons.timer),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionGreen),
            child:
                const Text('Generate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final days = int.tryParse(daysController.text) ?? 7;
    final duration = int.tryParse(durationController.text) ?? 60;
    final openParts = _venue!.openTime.split(':');
    final closeParts = _venue!.closeTime.split(':');
    final openHour = int.parse(openParts[0]);
    final closeHour = int.parse(closeParts[0]);

    for (int d = 0; d < days; d++) {
      final date = DateTime.now().add(Duration(days: d));
      final dayStart = DateTime(date.year, date.month, date.day);

      for (int hour = openHour; hour < closeHour; hour++) {
        for (int min = 0; min < 60; min += duration) {
          if (hour + (min + duration) / 60 > closeHour) break;

          final startHour = hour;
          final startMin = min;
          final endMin = min + duration;
          final endHour = hour + endMin ~/ 60;
          final endMinute = endMin % 60;

          final isPeak = hour >= 17 && hour <= 21;
          final isHappy = hour >= 6 && hour < 9;
          final price = isPeak
              ? _venue!.peakPricePerHour
              : isHappy
                  ? _venue!.happyHourPrice
                  : _venue!.pricePerHour;

          await _firestoreService.createSlot(widget.venueId, {
            'venueId': widget.venueId,
            'date': Timestamp.fromDate(dayStart),
            'startTime':
                '${startHour.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')}',
            'endTime':
                '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}',
            'duration': duration,
            'price': price,
            'isAvailable': true,
            'isHappyHour': isHappy,
            'isPeakHour': isPeak,
          });
        }
      }
    }

    await _loadSlots();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Slots generated for $days days!'),
          backgroundColor: AppColors.actionGreen,
        ),
      );
    }
  }

  Future<void> _deleteSlot(SlotModel slot) async {
    await _firestoreService.deleteSlot(widget.venueId, slot.id);
    _loadSlots();
  }

  Future<void> _toggleSlotAvailability(SlotModel slot) async {
    await _firestoreService.updateSlotAvailability(
      widget.venueId,
      slot.id,
      !slot.isAvailable,
    );
    _loadSlots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage Slots',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            if (_venue != null)
              Text(_venue!.name,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _generateSlots,
            icon: const Icon(Icons.auto_fix_high, color: AppColors.accentYellow),
            tooltip: 'Auto-generate slots',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentYellow))
          : Column(
              children: [
                // Date selector
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 14,
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final isSelected = date.day == _selectedDate.day &&
                          date.month == _selectedDate.month &&
                          date.year == _selectedDate.year;
                      final dayNames = [
                        'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
                      ];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedDate = date);
                          _loadSlots();
                        },
                        child: Container(
                          width: 52,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentYellow
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentYellow
                                  : AppColors.divider.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayNames[date.weekday - 1],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
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
                                      ? Colors.black
                                      : AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Slot count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_slots.length} slots',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                      Row(
                        children: [
                          _LegendDot(
                              color: AppColors.available, label: 'Available'),
                          const SizedBox(width: 12),
                          _LegendDot(
                              color: AppColors.fullyBooked, label: 'Booked'),
                          const SizedBox(width: 12),
                          _LegendDot(
                              color: AppColors.textDisabled, label: 'Disabled'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Slots list
                Expanded(
                  child: _slots.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event_busy,
                                  size: 48, color: AppColors.textDisabled),
                              const SizedBox(height: 12),
                              const Text('No slots for this date',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _generateSlots,
                                icon: const Icon(Icons.auto_fix_high, size: 18),
                                label: const Text('Generate Slots'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentYellow,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _slots.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final slot = _slots[index];
                            return _SlotTile(
                              slot: slot,
                              onToggle: () => _toggleSlotAvailability(slot),
                              onDelete: () => _deleteSlot(slot),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  final SlotModel slot;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SlotTile({
    required this.slot,
    required this.onToggle,
    required this.onDelete,
  });

  Color get _statusColor {
    if (slot.bookedBy != null) return AppColors.fullyBooked;
    if (!slot.isAvailable) return AppColors.textDisabled;
    return AppColors.available;
  }

  String get _statusLabel {
    if (slot.bookedBy != null) return 'BOOKED';
    if (!slot.isAvailable) return 'DISABLED';
    return 'AVAILABLE';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot.startTime} – ${slot.endTime}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '\u20B9${slot.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: AppColors.actionGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                    if (slot.isPeakHour) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('PEAK',
                            style: TextStyle(
                                color: AppColors.error,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                    if (slot.isHappyHour) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.actionGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('HAPPY HR',
                            style: TextStyle(
                                color: AppColors.actionGreen,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                  color: _statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          if (slot.bookedBy == null) ...[
            IconButton(
              onPressed: onToggle,
              icon: Icon(
                slot.isAvailable
                    ? Icons.toggle_on
                    : Icons.toggle_off,
                color: slot.isAvailable
                    ? AppColors.actionGreen
                    : AppColors.textDisabled,
                size: 28,
              ),
              tooltip: slot.isAvailable ? 'Disable' : 'Enable',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32),
            ),
          ],
        ],
      ),
    );
  }
}
