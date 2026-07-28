import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/nutrition_provider.dart';

class FoodDetailsSheet extends ConsumerWidget {
  final String title;
  final String category;
  final int grams;
  final int calories;
  final int proteinGrams;
  final int fatGrams;
  final int carbsGrams;
  final String? imagePath;

  const FoodDetailsSheet({
    super.key,
    required this.title,
    this.category = 'MAHARASHTRIAN',
    this.grams = 200,
    required this.calories,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbsGrams,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppColors.radiusBottomSheet)), // 34px
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hero Food Banner Container
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppColors.radiusBottomSheet)),
                  gradient: AppColors.heroCardGradient,
                ),
                child: const Icon(Icons.restaurant_menu, color: AppColors.primaryDark, size: 72),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Portion Chips (50px Radius)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppColors.radiusChip), // 50px
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppColors.radiusChip),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        '${grams} G',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),

                // Calorie pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppColors.radiusChip),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total $calories kcal',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3 Macro Circular Ring Cards (Design System Tokens)
                Row(
                  children: [
                    Expanded(child: _buildMacroRingCard('Protein', '${proteinGrams}g', AppColors.macroProtein)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMacroRingCard('Fat', '${fatGrams}g', AppColors.macroFat)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMacroRingCard('Carbs', '${carbsGrams}g', AppColors.macroCarbs)),
                  ],
                ),
                const SizedBox(height: 28),

                // Action Buttons (18px Radius)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusButton)), // 18px
                          side: const BorderSide(color: AppColors.divider),
                        ),
                        child: Text(
                          'Update Details',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(nutritionProvider.notifier).analyzeAndAddMealText(title);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusButton)), // 18px
                        ),
                        child: Text(
                          'Add Meal',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
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

  Widget _buildMacroRingCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              child: Center(
                child: Text(
                  value,
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
