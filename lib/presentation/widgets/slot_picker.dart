import 'package:flutter/material.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/slot_model.dart';

/// A horizontal scrollable list of time-slot chips for a given date.
///
/// Each chip displays the time range, price, and status. Available slots
/// are selectable with a green highlight; booked slots are greyed out;
/// happy-hour slots have a yellow accent; peak-hour slots use a red accent.
class SlotPicker extends StatelessWidget {
  final List<SlotModel> slots;
  final String? selectedSlotId;
  final ValueChanged<SlotModel>? onSlotSelected;

  const SlotPicker({
    super.key,
    required this.slots,
    this.selectedSlotId,
    this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(
          'No slots available for this date',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: slots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final slot = slots[index];
          final isSelected = slot.id == selectedSlotId;
          return _SlotChip(
            slot: slot,
            isSelected: isSelected,
            onTap: slot.isAvailable ? () => onSlotSelected?.call(slot) : null,
          );
        },
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final SlotModel slot;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SlotChip({
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipData = _resolveChipStyle();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.actionGreen.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.actionGreen : chipData.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: chipData.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                chipData.label,
                style: TextStyle(
                  color: chipData.accentColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Time range
            Text(
              '${slot.startTime} - ${slot.endTime}',
              style: TextStyle(
                color: slot.isAvailable
                    ? AppColors.textPrimary
                    : AppColors.textDisabled,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Price
            Text(
              '\u20B9${slot.price.toInt()}',
              style: TextStyle(
                color: slot.isAvailable
                    ? AppColors.actionGreen
                    : AppColors.textDisabled,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ChipStyleData _resolveChipStyle() {
    if (!slot.isAvailable) {
      return _ChipStyleData(
        label: 'BOOKED',
        accentColor: AppColors.textDisabled,
        borderColor: AppColors.divider.withValues(alpha: 0.5),
      );
    }
    if (slot.isHappyHour) {
      return _ChipStyleData(
        label: 'HAPPY HOUR',
        accentColor: AppColors.accentYellow,
        borderColor: AppColors.accentYellow.withValues(alpha: 0.4),
      );
    }
    if (slot.isPeakHour) {
      return _ChipStyleData(
        label: 'PEAK',
        accentColor: AppColors.error,
        borderColor: AppColors.error.withValues(alpha: 0.4),
      );
    }
    return _ChipStyleData(
      label: 'AVAILABLE',
      accentColor: AppColors.actionGreen,
      borderColor: AppColors.divider,
    );
  }
}

class _ChipStyleData {
  final String label;
  final Color accentColor;
  final Color borderColor;

  const _ChipStyleData({
    required this.label,
    required this.accentColor,
    required this.borderColor,
  });
}
