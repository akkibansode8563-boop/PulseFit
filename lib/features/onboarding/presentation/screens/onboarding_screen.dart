import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../profile/domain/entities/health_enums.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '25');
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '70');

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(page, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stepTitle(state.currentStep),
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (state.currentStep + 1) / 5,
                      minHeight: 6,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => notifier.nextStep(),
                children: [
                  _buildStep1PersonalInfo(state, notifier),
                  _buildStep2HealthConditions(state, notifier),
                  _buildStep3Lifestyle(state, notifier),
                  _buildStep4GoalSelection(state, notifier),
                  _buildStep5Capabilities(state, notifier),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (state.currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          notifier.previousStep();
                          _goToPage(state.currentStep - 1);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Back', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (state.currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _handleNext(state, notifier),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: Text(
                        state.currentStep == 4 ? 'Generate My Plan ✨' : 'Continue',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepTitle(int step) {
    return switch (step) {
      0 => 'STEP 1/5 — Tell us about yourself',
      1 => 'STEP 2/5 — Health conditions',
      2 => 'STEP 3/5 — Lifestyle & region',
      3 => 'STEP 4/5 — What\'s your goal?',
      4 => 'STEP 5/5 — What can you do?',
      _ => '',
    };
  }

  void _handleNext(state, OnboardingNotifier notifier) async {
    if (state.currentStep < 4) {
      if (state.currentStep == 0) {
        notifier.updateName(_nameController.text.isNotEmpty ? _nameController.text : 'User');
        notifier.updateAge(int.tryParse(_ageController.text) ?? 25);
        notifier.updateHeight(double.tryParse(_heightController.text) ?? 170);
        notifier.updateWeight(double.tryParse(_weightController.text) ?? 70);
      }
      notifier.nextStep();
      _goToPage(state.currentStep + 1);
    } else {
      // Final step — generate personalized plan
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: GlassCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 20),
                Text('AI is analyzing your profile...', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Computing personalized plan', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ),
      );

      await notifier.completeOnboarding();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    }
  }

  // ─── Step 1: Personal Info ───
  Widget _buildStep1PersonalInfo(state, OnboardingNotifier notifier) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('👋 Welcome!', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold))
            .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 4),
        Text('Let\'s personalize your health journey.', style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey))
            .animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 28),
        _buildTextField('Your Name', _nameController, icon: Icons.person_outline),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Age', _ageController, icon: Icons.cake_outlined, isNumber: true)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gender', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SegmentedButton<Gender>(
                    segments: const [
                      ButtonSegment(value: Gender.male, label: Text('M'), icon: Icon(Icons.male, size: 18)),
                      ButtonSegment(value: Gender.female, label: Text('F'), icon: Icon(Icons.female, size: 18)),
                    ],
                    selected: {state.gender},
                    onSelectionChanged: (s) => notifier.updateGender(s.first),
                    style: SegmentedButton.styleFrom(selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Height (cm)', _heightController, icon: Icons.height, isNumber: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Weight (kg)', _weightController, icon: Icons.monitor_weight_outlined, isNumber: true)),
          ],
        ),
      ],
    );
  }

  // ─── Step 2: Health Conditions ───
  Widget _buildStep2HealthConditions(state, OnboardingNotifier notifier) {
    final conditions = <HealthCondition, _ChipData>{
      HealthCondition.none: _ChipData('None / Healthy', '✅', 'कोणताही आजार नाही'),
      HealthCondition.diabetes: _ChipData('Diabetes', '🩸', 'मधुमेह'),
      HealthCondition.highBP: _ChipData('High Blood Pressure', '❤️‍🩹', 'उच्च रक्तदाब'),
      HealthCondition.lowBP: _ChipData('Low Blood Pressure', '💙', 'कमी रक्तदाब'),
      HealthCondition.thyroid: _ChipData('Thyroid', '🦋', 'थायरॉईड'),
      HealthCondition.kneePain: _ChipData('Knee Pain', '🦵', 'गुडघेदुखी'),
      HealthCondition.backPain: _ChipData('Back Pain', '🔙', 'पाठदुखी'),
      HealthCondition.surgeryHistory: _ChipData('Surgery History', '🏥', 'शस्त्रक्रियेचा इतिहास'),
      HealthCondition.allergies: _ChipData('Allergies', '🤧', 'ऍलर्जी'),
      HealthCondition.asthma: _ChipData('Asthma', '🫁', 'दमा'),
    };

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('🏥 Health Conditions', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold))
            .animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text('Select any conditions you have. This ensures safe recommendations.',
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: conditions.entries.map((e) {
            final isSelected = state.healthConditions.contains(e.key);
            return FilterChip(
              label: Text('${e.value.emoji} ${e.value.label}'),
              selected: isSelected,
              onSelected: (_) => notifier.toggleHealthCondition(e.key),
              selectedColor: AppColors.primary.withValues(alpha: 0.25),
              checkmarkColor: AppColors.primary,
              labelStyle: GoogleFonts.outfit(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Step 3: Lifestyle & Region ───
  Widget _buildStep3Lifestyle(state, OnboardingNotifier notifier) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('🏠 Lifestyle & Region', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold))
            .animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),

        // Lifestyle
        Text('What describes your daily routine?', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildSingleSelectChips<LifestyleType>(
          items: {
            LifestyleType.officeJob: '💻 Office Job',
            LifestyleType.student: '📚 Student',
            LifestyleType.businessOwner: '🏢 Business Owner',
            LifestyleType.shiftWorker: '🔄 Shift Worker',
            LifestyleType.housewife: '🏠 Homemaker',
            LifestyleType.driver: '🚗 Driver',
            LifestyleType.retired: '🌅 Retired',
            LifestyleType.freelancer: '💼 Freelancer',
          },
          selected: state.lifestyleType,
          onSelected: notifier.updateLifestyle,
        ),

        const SizedBox(height: 28),

        // Food Preference
        Text('Food Preference', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildSingleSelectChips<FoodPreference>(
          items: {
            FoodPreference.vegetarian: '🥗 Vegetarian (शाकाहारी)',
            FoodPreference.eggetarian: '🥚 Eggetarian (अंडाहारी)',
            FoodPreference.nonVegetarian: '🍗 Non-Vegetarian (मांसाहारी)',
            FoodPreference.vegan: '🌱 Vegan (वीगन)',
          },
          selected: state.foodPreference,
          onSelected: notifier.updateFoodPreference,
        ),

        const SizedBox(height: 28),

        // Region
        Text('Your Region (for food recommendations)', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildSingleSelectChips<IndianRegion>(
          items: {
            IndianRegion.maharashtra: '🏔️ Maharashtra',
            IndianRegion.karnataka: '🌴 Karnataka',
            IndianRegion.gujarat: '🏜️ Gujarat',
            IndianRegion.punjab: '🌾 Punjab',
            IndianRegion.tamilNadu: '🛕 Tamil Nadu',
            IndianRegion.kerala: '🥥 Kerala',
            IndianRegion.bengal: '🐟 Bengal',
            IndianRegion.rajasthan: '🏰 Rajasthan',
            IndianRegion.goa: '🏖️ Goa',
            IndianRegion.other: '🇮🇳 Other',
          },
          selected: state.region,
          onSelected: notifier.updateRegion,
        ),
      ],
    );
  }

  // ─── Step 4: Goal Selection ───
  Widget _buildStep4GoalSelection(state, OnboardingNotifier notifier) {
    final goals = <HealthGoal, _GoalCardData>{
      HealthGoal.buildMuscle: _GoalCardData(
        '💪 Build Muscle', 'स्नायू बांधणे',
        'High Protein • Strength Training • Progressive Overload • Recovery • Sleep',
        Icons.fitness_center, AppColors.primary,
      ),
      HealthGoal.loseFat: _GoalCardData(
        '🔥 Lose Fat', 'चरबी कमी करणे',
        'Calorie Deficit • Walking • Cardio • Moderate Protein • Daily Movement',
        Icons.local_fire_department, AppColors.warning,
      ),
      HealthGoal.stayFit: _GoalCardData(
        '🧘 Stay Fit', 'तंदुरुस्त राहणे',
        'Simple Exercise • Walking • Balanced Diet • Easy Maintenance',
        Icons.self_improvement, AppColors.secondary,
      ),
      HealthGoal.improveHealth: _GoalCardData(
        '❤️ Improve Health', 'आरोग्य सुधारणे',
        'BP Control • Sugar Control • Joint-Friendly Activities • Healthy Eating',
        Icons.favorite, Colors.redAccent,
      ),
      HealthGoal.seniorCitizenMode: _GoalCardData(
        '🌿 Senior Citizen', 'ज्येष्ठ नागरिक',
        'Walking • Stretching • Mobility • Balance • Hydration • Safe Movements',
        Icons.elderly, Colors.teal,
      ),
      HealthGoal.weightGain: _GoalCardData(
        '📈 Weight Gain', 'वजन वाढवणे',
        'Calorie Surplus • High Protein • Healthy Carbs • Strength Training',
        Icons.trending_up, Colors.amber,
      ),
    };

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('🎯 What do you want to achieve?', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold))
            .animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text('Your goal drives everything — calories, protein, workouts, sleep.',
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 20),
        ...goals.entries.map((e) {
          final isSelected = state.primaryGoal == e.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => notifier.updateGoal(e.key),
              child: AnimatedContainer(
                duration: 250.ms,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSelected ? e.value.color.withValues(alpha: 0.15) : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? e.value.color : Colors.transparent,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: e.value.color.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 4))]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(e.value.icon, color: e.value.color, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value.titleEn, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(e.value.titleMr, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(e.value.description, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600), maxLines: 2),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 28),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: (100 * goals.keys.toList().indexOf(e.key)).ms).slideX(begin: 0.05, end: 0);
        }),
      ],
    );
  }

  // ─── Step 5: Capabilities ───
  Widget _buildStep5Capabilities(state, OnboardingNotifier notifier) {
    final hasKneePain = state.healthConditions.contains(HealthCondition.kneePain);

    final caps = <ActivityCapability, String>{
      ActivityCapability.walking: '🚶 Walking (चालणे)',
      ActivityCapability.cycling: '🚴 Cycling (सायकलिंग)',
      ActivityCapability.running: '🏃 Running (धावणे)',
      ActivityCapability.gym: '🏋️ Gym (जिम)',
      ActivityCapability.homeWorkout: '🏠 Home Workout (घरी व्यायाम)',
      ActivityCapability.yoga: '🧘 Yoga (योग)',
      ActivityCapability.swimming: '🏊 Swimming (पोहणे)',
      ActivityCapability.sports: '⚽ Sports (खेळ)',
      ActivityCapability.stretching: '🤸 Stretching (ताणणे)',
      ActivityCapability.dance: '💃 Dance (नृत्य)',
    };

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('🏃 What activities are possible for you?', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold))
            .animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text('Select all that you can realistically do. We\'ll never recommend anything outside this list.',
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey)),
        if (hasKneePain)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ Running has been auto-disabled because of your knee pain. We\'ll recommend joint-friendly alternatives.',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.amber.shade700),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).shake(delay: 300.ms, hz: 2, offset: const Offset(2, 0)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: caps.entries.map((e) {
            final isSelected = state.capabilities.contains(e.key);
            final isDisabled = hasKneePain && e.key == ActivityCapability.running;

            return FilterChip(
              label: Text(e.value),
              selected: isSelected && !isDisabled,
              onSelected: isDisabled ? null : (_) => notifier.toggleCapability(e.key),
              selectedColor: AppColors.primary.withValues(alpha: 0.25),
              disabledColor: Colors.grey.withValues(alpha: 0.1),
              checkmarkColor: AppColors.primary,
              labelStyle: GoogleFonts.outfit(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                color: isDisabled ? Colors.grey : null,
                decoration: isDisabled ? TextDecoration.lineThrough : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Helpers ───
  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.outfit(fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleSelectChips<T>({
    required Map<T, String> items,
    required T selected,
    required ValueChanged<T> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.entries.map((e) {
        final isSelected = selected == e.key;
        return ChoiceChip(
          label: Text(e.value),
          selected: isSelected,
          onSelected: (_) => onSelected(e.key),
          selectedColor: AppColors.primary.withValues(alpha: 0.25),
          checkmarkColor: AppColors.primary,
          labelStyle: GoogleFonts.outfit(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      }).toList(),
    );
  }
}

// ─── Data classes for UI ───
class _ChipData {
  final String label;
  final String emoji;
  final String labelMr;
  const _ChipData(this.label, this.emoji, this.labelMr);
}

class _GoalCardData {
  final String titleEn;
  final String titleMr;
  final String description;
  final IconData icon;
  final Color color;
  const _GoalCardData(this.titleEn, this.titleMr, this.description, this.icon, this.color);
}
