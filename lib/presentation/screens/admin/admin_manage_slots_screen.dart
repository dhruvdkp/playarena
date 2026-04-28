import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/routes/app_router.dart';
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

    final cfg = await showDialog<_GenSlotsConfig>(
      context: context,
      builder: (ctx) => _GenerateSlotsDialog(venue: _venue!),
    );

    if (cfg == null) return;

    setState(() => _isLoading = true);

    final duration = cfg.duration;
    final openHour = cfg.startTime.hour;
    final openMinTotal = cfg.startTime.minute;
    final closeHour = cfg.endTime.hour;
    final closeMinTotal = cfg.endTime.minute;
    // Convert to absolute minutes since midnight for cleaner comparisons.
    final windowStartMin = openHour * 60 + openMinTotal;
    final windowEndMin = closeHour * 60 + closeMinTotal;

    if (windowEndMin <= windowStartMin) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final dateStart = DateTime(
      cfg.dateRange.start.year,
      cfg.dateRange.start.month,
      cfg.dateRange.start.day,
    );
    final dateEnd = DateTime(
      cfg.dateRange.end.year,
      cfg.dateRange.end.month,
      cfg.dateRange.end.day,
    );
    final days = dateEnd.difference(dateStart).inDays + 1;

    // Skip slots starting within the next hour so users always have a buffer
    // to book + arrive.
    final earliestStart = DateTime.now().add(const Duration(hours: 1));

    // Build a Set of existing slot keys "yyyy-MM-dd|HH:mm" so we never
    // create a duplicate when admin re-runs generate.
    final existing = <String>{};
    for (final s in _slots) {
      final d = s.date;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}|${s.startTime}';
      existing.add(key);
    }

    int created = 0;
    int skippedDup = 0;

    for (int d = 0; d < days; d++) {
      final dayStart = dateStart.add(Duration(days: d));

      for (int curMin = windowStartMin;
          curMin + duration <= windowEndMin;
          curMin += duration) {
        final startHour = curMin ~/ 60;
        final startMinPart = curMin % 60;
        final endTotal = curMin + duration;
        final endHour = endTotal ~/ 60;
        final endMinute = endTotal % 60;

        final slotStart = DateTime(
          dayStart.year,
          dayStart.month,
          dayStart.day,
          startHour,
          startMinPart,
        );
        if (slotStart.isBefore(earliestStart)) continue;

        final startStr =
            '${startHour.toString().padLeft(2, '0')}:${startMinPart.toString().padLeft(2, '0')}';
        final dateKey =
            '${dayStart.year}-${dayStart.month.toString().padLeft(2, '0')}-${dayStart.day.toString().padLeft(2, '0')}';
        final key = '$dateKey|$startStr';
        if (existing.contains(key)) {
          skippedDup++;
          continue;
        }
        existing.add(key);

        final isPeak = startHour >= 17 && startHour <= 21;
        final isHappy = startHour >= 6 && startHour < 9;
        final price = isPeak
            ? _venue!.peakPricePerHour
            : isHappy
                ? _venue!.happyHourPrice
                : _venue!.pricePerHour;

        await _firestoreService.createSlot(widget.venueId, {
          'venueId': widget.venueId,
          'date': Timestamp.fromDate(dayStart),
          'startTime': startStr,
          'endTime':
              '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}',
          'duration': duration,
          'price': price,
          'isAvailable': true,
          'isHappyHour': isHappy,
          'isPeakHour': isPeak,
        });
        created++;
      }
    }

    await _loadSlots();
    setState(() => _isLoading = false);

    if (mounted) {
      final msg = skippedDup > 0
          ? 'Created $created new slot${created == 1 ? '' : 's'}. '
              'Skipped $skippedDup duplicate${skippedDup == 1 ? '' : 's'}.'
          : 'Created $created slot${created == 1 ? '' : 's'} for $days day${days == 1 ? '' : 's'}.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: created > 0
              ? AppColors.actionGreen
              : AppColors.accentYellow,
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.adminVenues);
            }
          },
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage Slots',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            if (_venue != null)
              Text(_venue!.name,
                  style: TextStyle(
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
                        style: TextStyle(
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
                              Icon(Icons.event_busy,
                                  size: 48, color: AppColors.textDisabled),
                              const SizedBox(height: 12),
                              Text('No slots for this date',
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
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
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
                  style: TextStyle(
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

// ═════════════════════════════════════════════════════════════════════════
// Generate Slots dialog — date range + start/end time + duration
// ═════════════════════════════════════════════════════════════════════════

class _GenSlotsConfig {
  final DateTimeRange dateRange;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int duration;
  const _GenSlotsConfig({
    required this.dateRange,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });
}

class _GenerateSlotsDialog extends StatefulWidget {
  final VenueModel venue;
  const _GenerateSlotsDialog({required this.venue});

  @override
  State<_GenerateSlotsDialog> createState() => _GenerateSlotsDialogState();
}

class _GenerateSlotsDialogState extends State<_GenerateSlotsDialog> {
  DateTimeRange? _range;
  TimeOfDay? _start;
  TimeOfDay? _end;
  int _duration = 60;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _range = DateTimeRange(
      start: DateTime(today.year, today.month, today.day),
      end: DateTime(today.year, today.month, today.day)
          .add(const Duration(days: 6)),
    );
    _start = _parseTimeOfDay(widget.venue.openTime) ??
        const TimeOfDay(hour: 9, minute: 0);
    _end = _parseTimeOfDay(widget.venue.closeTime) ??
        const TimeOfDay(hour: 21, minute: 0);
  }

  TimeOfDay? _parseTimeOfDay(String s) {
    final parts = s.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _pickRange() async {
    final today = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: today.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.accentYellow,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart
        ? (_start ?? const TimeOfDay(hour: 9, minute: 0))
        : (_end ?? const TimeOfDay(hour: 21, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.accentYellow,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  String _fmtRange(DateTimeRange r) {
    String d(DateTime x) =>
        '${x.day.toString().padLeft(2, '0')}/${x.month.toString().padLeft(2, '0')}/${x.year}';
    return '${d(r.start)} → ${d(r.end)}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Generate Slots',
          style: TextStyle(color: AppColors.textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pick date range and operating window.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            _pickerTile(
              label: 'Date range',
              value: _range == null ? 'Pick dates' : _fmtRange(_range!),
              icon: Icons.date_range,
              onTap: _pickRange,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _pickerTile(
                    label: 'Start',
                    value: _start?.format(context) ?? '—',
                    icon: Icons.schedule,
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _pickerTile(
                    label: 'End',
                    value: _end?.format(context) ?? '—',
                    icon: Icons.schedule,
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _duration,
              decoration: InputDecoration(
                labelText: 'Slot duration (minutes)',
                labelStyle:
                    TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.timer),
              ),
              dropdownColor: AppColors.surface,
              style: TextStyle(color: AppColors.textPrimary),
              items: const [30, 45, 60, 90, 120]
                  .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text('$v min'),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _duration = v);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: (_range == null || _start == null || _end == null)
              ? null
              : () {
                  Navigator.pop(
                    context,
                    _GenSlotsConfig(
                      dateRange: _range!,
                      startTime: _start!,
                      endTime: _end!,
                      duration: _duration,
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.actionGreen),
          child: const Text('Generate',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _pickerTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
