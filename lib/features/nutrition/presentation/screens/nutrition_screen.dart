import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/daily_routine_timeline_dialog.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/maharashtrian_meals.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/voice_logging_sheet.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionAsync = ref.watch(nutritionProvider);
    final isMarathi = ref.watch(localeProvider.notifier).isMarathi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          isMarathi ? 'आहार आणि पोषण' : 'Nutrition AI',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline_rounded, color: Colors.black),
            tooltip: 'Daily Routine Timeline',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const DailyRoutineTimelineDialog(),
            ),
          ),
          ActionChip(
            label: Text(
              isMarathi ? 'मराठी' : 'EN',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
            ),
            backgroundColor: AppColors.primary,
            onPressed: () => ref.read(localeProvider.notifier).toggleLanguage(),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.black),
            tooltip: 'Voice Logging',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const VoiceLoggingSheet(),
            ),
          ),
        ],
      ),
      body: nutritionAsync.when(
        data: (meals) => ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildMaharashtrianSuggestionsSection(context, ref, isMarathi),
            const SizedBox(height: 24),
            Text(
              isMarathi ? "आजचा आहार इतिहास" : "Today's Logged Meals",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12),
            if (meals.isEmpty)
              EmptyStateWidget(
                title: isMarathi ? 'आज कोणताही आहार नोंदवला नाही' : 'No Meals Logged Today',
                message: isMarathi ? 'वरील सुचवलेल्या पदार्थांपैकी निवडा किंवा माईक दाबून सांगा.' : 'Select a Maharashtrian meal suggestion above or log via voice command.',
              )
            else
              ...meals.map((meal) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary,
                          child: const Icon(Icons.restaurant, color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(meal.mealName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                              Text('${meal.totalCalories} kcal • ${meal.totalProtein}g Protein', style: GoogleFonts.outfit(color: const Color(0xFF222222), fontSize: 13, fontWeight: FontWeight.w600)),
                              Text(
                                TimeOfDay.fromDateTime(meal.loggedAt).format(context),
                                style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.black54, size: 20),
                          onPressed: () => ref.read(nutritionProvider.notifier).deleteMeal(meal.id),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
        loading: () => const Padding(padding: EdgeInsets.all(16), child: LoadingShimmer(height: 200)),
        error: (err, stack) => ErrorStateWidget(message: err.toString(), onRetry: () => ref.invalidate(nutritionProvider)),
      ),
    );
  }

  Widget _buildMaharashtrianSuggestionsSection(BuildContext context, WidgetRef ref, bool isMarathi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isMarathi ? 'महाराष्ट्रीयन आहार सुचवणी (६-८ पर्याय)' : 'Maharashtrian Meal Recommendations',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const Icon(Icons.stars, color: Colors.orange, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: MaharashtrianMealData.options.length,
            itemBuilder: (context, index) {
              final item = MaharashtrianMealData.options[index];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMarathi ? item.nameMr : item.nameEn,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.calories} kcal • ${item.proteinGrams}g Protein',
                        style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isMarathi ? item.descriptionMr : item.descriptionEn,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF222222), fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => ref.read(nutritionProvider.notifier).analyzeAndAddMealText(item.nameEn),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isMarathi ? '+ नोंदवा' : '+ Log Meal',
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
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
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }
}
