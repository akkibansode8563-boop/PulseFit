import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../../core/services/live_ota_sync_engine.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_counter_text.dart';
import '../../../../core/widgets/daily_routine_timeline_dialog.dart';
import '../../../../core/widgets/glowing_vitality_ring.dart';
import '../../../../core/widgets/horizontal_calendar_strip.dart';
import '../../../../core/widgets/pulsefit_logo.dart';
import '../../../reminders/presentation/screens/reminders_screen.dart';
import '../../../ai/presentation/screens/ai_coach_screen.dart';
import '../../../nutrition/presentation/providers/nutrition_provider.dart';
import '../../../nutrition/presentation/screens/food_scanner_screen.dart';
import '../../../nutrition/presentation/screens/nutrition_screen.dart';
import '../../../nutrition/presentation/widgets/food_details_sheet.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../reminders/presentation/widgets/full_screen_alarm_overlay.dart';
import '../../../water/presentation/screens/water_screen.dart';
import '../../../workout/presentation/screens/workout_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LiveOtaSyncEngine.syncOnStartup(context);
      AppUpdateService.checkOnStartup(context);
    });
  }

  final List<Widget> _screens = const [
    DashboardHomeTab(),
    NutritionScreen(),
    WaterScreen(),
    WorkoutScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          const FullScreenAlarmOverlay(),
        ],
      ),

      // Design System Floating Button (Circle FAB with 0 12px 30px rgba(143,211,107,.30) Shadow)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: AppColors.primary,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FoodScannerScreen()),
          ),
          child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textPrimary, size: 28),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.surfaceMint,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined, color: AppColors.textPrimary), selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryDark), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined, color: AppColors.textPrimary), selectedIcon: Icon(Icons.fitness_center_rounded, color: AppColors.primaryDark), label: 'Workout'),
          NavigationDestination(icon: Icon(Icons.eco_outlined, color: AppColors.textPrimary), selectedIcon: Icon(Icons.eco_rounded, color: AppColors.primaryDark), label: 'Nutrition'),
          NavigationDestination(icon: Icon(Icons.trending_up_rounded, color: AppColors.textPrimary), selectedIcon: Icon(Icons.trending_up_rounded, color: AppColors.primaryDark), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded, color: AppColors.textPrimary), selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryDark), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardHomeTab extends ConsumerWidget {
  const DashboardHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final mealsAsync = ref.watch(nutritionProvider);
    final profile = profileAsync.valueOrNull;

    final targetCalories = profile?.dailyCalorieGoal ?? 2400;
    final meals = mealsAsync.valueOrNull ?? [];
    final currentCalories = meals.fold(0, (sum, m) => sum + m.totalCalories);
    final calRatio = targetCalories > 0 ? (currentCalories / targetCalories) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const PulseFitLogo(iconSize: 24, fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline_rounded, color: AppColors.textPrimary),
            tooltip: 'Daily Routine Timeline',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const DailyRoutineTimelineDialog(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.alarm_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen())),
            tooltip: 'Reminders & Alarms',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.secondary,
              child: Text(
                profile?.name.isNotEmpty == true ? profile!.name[0] : 'P',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AICoachScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Hero Card Gradient (#F6FFF1 -> #DDF8D8 -> #C3F1B7) with 28px Radius
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroCardGradient,
              borderRadius: BorderRadius.circular(AppColors.radiusCard), // 28px
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HorizontalCalendarStrip(),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.name.isNotEmpty == true
                                ? 'Hello, ${profile!.name}! 👋'
                                : 'Welcome to PulseFit! 👋',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            "You're on your way to a healthy week!",
                            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryDark,
                      child: Text(
                        profile?.name.isNotEmpty == true
                            ? profile!.name[0].toUpperCase()
                            : 'P',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pill Tabs (50px Radius)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppColors.radiusChip), // 50px
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPillTab('Last week', false),
                      _buildPillTab('This week', true),
                      _buildPillTab('All time', false),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Ticker Card with Ring Gauge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppColors.radiusCard),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Calories', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              AnimatedCounterText(
                                value: currentCalories > 0 ? currentCalories : 1960,
                                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 4),
                              Text('/ $targetCalories kcal', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      GlowingVitalityRing(
                        progress: calRatio > 0 ? calRatio : 0.72,
                        centerValue: currentCalories > 0 ? currentCalories : 1960,
                        centerUnit: 'Kcal',
                        label: '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

          const SizedBox(height: 24),

          // Eating History Section (Design System Cards)
          Text('Eating history', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 14),

          _buildHistoryRow(
            title: 'Kanda Poha & Salad',
            color: AppColors.secondary,
            icon: Icons.eco_rounded,
            kcal: '260 kcal',
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const FoodDetailsSheet(
                title: 'Kanda Poha with Peanuts',
                category: 'BREAKFAST',
                grams: 200,
                calories: 260,
                proteinGrams: 7,
                fatGrams: 8,
                carbsGrams: 42,
              ),
            ),
          ),
          const SizedBox(height: 10),

          _buildHistoryRow(
            title: 'Pithla Bhakri & Solkadhi',
            color: AppColors.surface,
            icon: Icons.lunch_dining_rounded,
            kcal: '420 kcal',
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const FoodDetailsSheet(
                title: 'Pithla Bhakri & Solkadhi',
                category: 'LUNCH',
                grams: 250,
                calories: 420,
                proteinGrams: 16,
                fatGrams: 11,
                carbsGrams: 64,
              ),
            ),
          ),
          const SizedBox(height: 10),

          _buildHistoryRow(
            title: 'Thalipeeth & Curd',
            color: AppColors.surface,
            icon: Icons.flatware_rounded,
            kcal: '320 kcal',
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const FoodDetailsSheet(
                title: 'Thalipeeth with Curd',
                category: 'SNACK',
                grams: 180,
                calories: 320,
                proteinGrams: 11,
                fatGrams: 10,
                carbsGrams: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTab(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(AppColors.radiusChip),
        boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHistoryRow({
    required String title,
    required Color color,
    required IconData icon,
    required String kcal,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      kcal,
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
