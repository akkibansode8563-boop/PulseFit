import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../profile/domain/entities/health_enums.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../../../settings/presentation/screens/api_key_settings_screen.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.mintBackground,
      appBar: AppBar(
        title: Text('Profile & Goals', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.lightTextPrimary),
            tooltip: 'Re-do Onboarding',
            onPressed: () {
              final profile = profileAsync.valueOrNull;
              if (profile != null) {
                ref.read(profileProvider.notifier).updateProfile(
                  profile.copyWith(isOnboardingComplete: false),
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) => _buildProfileContent(context, ref, profile),
        loading: () => const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              LoadingShimmer(height: 100),
              SizedBox(height: 16),
              LoadingShimmer(height: 180),
            ],
          ),
        ),
        error: (err, stack) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(profileProvider),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, UserProfile profile) {
    final goalName = switch (profile.primaryGoal) {
      HealthGoal.buildMuscle => '💪 Build Muscle',
      HealthGoal.loseFat => '🔥 Lose Fat',
      HealthGoal.stayFit => '🧘 Stay Fit',
      HealthGoal.improveHealth => '❤️ Improve Health',
      HealthGoal.seniorCitizenMode => '🌿 Senior Citizen',
      HealthGoal.weightGain => '📈 Weight Gain',
    };

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Profile Header Container (Soft Pistachio Mint Card)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFC7F09D),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                      style: GoogleFonts.outfit(fontSize: 26, color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.age} yrs • ${profile.gender.name} • ${profile.heightCm.toStringAsFixed(0)} cm • ${profile.weightKg.toStringAsFixed(1)} kg',
                          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.lightTextSecondary, fontWeight: FontWeight.w600),
                        ),
                        Text('BMI: ${profile.bmi.toStringAsFixed(1)} (${profile.bmiCategory})',
                            style: GoogleFonts.outfit(fontSize: 12, color: AppColors.lightTextSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Chip(
                label: Text(goalName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // AI-Computed Targets
        Text('AI-Computed Daily Targets', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
        const SizedBox(height: 12),
        _buildTargetTile(context, Icons.local_fire_department, 'Calories', '${profile.dailyCalorieGoal} kcal', const Color(0xFFFF6B00)),
        _buildTargetTile(context, Icons.fitness_center, 'Protein', '${profile.dailyProteinGoalGrams}g', AppColors.lightTextPrimary),
        _buildTargetTile(context, Icons.grain, 'Carbs', '${profile.dailyCarbsGoalGrams}g', Colors.deepOrange),
        _buildTargetTile(context, Icons.water_drop, 'Water', '${(profile.dailyWaterGoalMl / 1000).toStringAsFixed(1)}L', AppColors.secondary),
        _buildTargetTile(context, Icons.directions_walk, 'Steps', '${profile.dailyStepGoal}', Colors.green.shade800),
        _buildTargetTile(context, Icons.bedtime, 'Sleep', '${profile.sleepGoalMinutes ~/ 60} hrs', Colors.indigo.shade800),
        if (profile.idealSleepTime != null)
          _buildTargetTile(context, Icons.nightlight, 'Bedtime', profile.idealSleepTime!, Colors.purple.shade800),

        const SizedBox(height: 20),

        // Health Conditions
        if (profile.healthConditions.isNotEmpty && !profile.healthConditions.contains(HealthCondition.none)) ...[
          Text('Health Conditions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.healthConditions.map((c) => Chip(
              label: Text(c.name, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
              backgroundColor: const Color(0xFFFEDCB6),
            )).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Workout Plan
        if (profile.workoutPlanSummary != null) ...[
          Text('Workout Plan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(profile.workoutPlanSummary!, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.lightTextPrimary, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 20),
        ],

        // AI Explanation
        if (profile.aiExplanation != null) ...[
          Text('AI Reasoning', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(profile.aiExplanation!, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.lightTextSecondary, height: 1.5, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 16),
        ],

        // Settings Entry
        Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0x1A10B981), child: Icon(Icons.vpn_key_rounded, color: Color(0xFF10B981))),
            title: Text('AI Vision Key Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
            subtitle: Text('Configure your own OpenAI API key', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.lightTextSecondary)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ApiKeySettingsScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetTile(BuildContext context, IconData icon, String title, String value, Color color) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
        trailing: Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ),
    );
  }
}
