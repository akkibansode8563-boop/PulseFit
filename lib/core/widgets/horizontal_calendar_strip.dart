import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/dashboard/presentation/providers/selected_date_provider.dart';
import '../theme/app_colors.dart';

class HorizontalCalendarStrip extends ConsumerWidget {
  const HorizontalCalendarStrip({super.key});

  String _formatHeaderDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    final weekdayName = weekdays[date.weekday - 1];
    final monthName = months[date.month - 1];
    final dayNum = date.day;

    String suffix = 'th';
    if (dayNum % 10 == 1 && dayNum != 11) suffix = 'st';
    if (dayNum % 10 == 2 && dayNum != 12) suffix = 'nd';
    if (dayNum % 10 == 3 && dayNum != 13) suffix = 'rd';

    return '$weekdayName, $monthName $dayNum$suffix';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    // Compute start of current week (Monday)
    final monday = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header with Interactive Calendar Picker Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatHeaderDate(selectedDate),
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primaryDark,
                          onPrimary: Colors.white,
                          surface: AppColors.card,
                          onSurface: AppColors.textPrimary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  ref.read(selectedDateProvider.notifier).state = picked;
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primaryDark),
                    const SizedBox(width: 4),
                    Text(
                      'Calendar',
                      style: GoogleFonts.sora(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Horizontal 7-Day Calendar Strip
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final date = weekDays[index];
            final isSelected =
                date.year == selectedDate.year &&
                date.month == selectedDate.month &&
                date.day == selectedDate.day;

            return GestureDetector(
              onTap: () => ref.read(selectedDateProvider.notifier).state = date,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryDark : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      dayLabels[index],
                      style: GoogleFonts.sora(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.black : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
