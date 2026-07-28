import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_reasoning_engine.dart';
import '../../../profile/domain/entities/health_enums.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/onboarding_state.dart';

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(const OnboardingState());

  // ─── Step Navigation ───
  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void previousStep() {
    if (state.currentStep > 0) state = state.copyWith(currentStep: state.currentStep - 1);
  }

  // ─── Step 1: Personal Info ───
  void updateName(String name) => state = state.copyWith(name: name);
  void updateAge(int age) => state = state.copyWith(age: age);
  void updateGender(Gender gender) => state = state.copyWith(gender: gender);
  void updateHeight(double cm) => state = state.copyWith(heightCm: cm);
  void updateWeight(double kg) => state = state.copyWith(weightKg: kg);
  void updateBodyFat(double? pct) => state = state.copyWith(bodyFatPercent: pct);
  void updateWaistSize(double? cm) => state = state.copyWith(waistSizeCm: cm);

  // ─── Step 2: Health Conditions ───
  void toggleHealthCondition(HealthCondition condition) {
    final current = Set<HealthCondition>.from(state.healthConditions);
    if (condition == HealthCondition.none) {
      state = state.copyWith(healthConditions: {HealthCondition.none});
      return;
    }
    current.remove(HealthCondition.none);
    if (current.contains(condition)) {
      current.remove(condition);
    } else {
      current.add(condition);
    }
    if (current.isEmpty) current.add(HealthCondition.none);
    state = state.copyWith(healthConditions: current);
  }

  // ─── Step 3: Lifestyle ───
  void updateLifestyle(LifestyleType type) => state = state.copyWith(lifestyleType: type);
  void updateFoodPreference(FoodPreference pref) => state = state.copyWith(foodPreference: pref);
  void updateRegion(IndianRegion region) => state = state.copyWith(region: region);

  // ─── Step 4: Goal ───
  void updateGoal(HealthGoal goal) => state = state.copyWith(primaryGoal: goal);

  // ─── Step 5: Capabilities ───
  void toggleCapability(ActivityCapability cap) {
    final current = Set<ActivityCapability>.from(state.capabilities);
    if (current.contains(cap)) {
      current.remove(cap);
    } else {
      current.add(cap);
    }
    // Auto-remove running if knee pain exists
    if (state.healthConditions.contains(HealthCondition.kneePain)) {
      current.remove(ActivityCapability.running);
    }
    if (current.isEmpty) current.add(ActivityCapability.walking);
    state = state.copyWith(capabilities: current);
  }

  // ─── Complete Onboarding ───
  Future<void> completeOnboarding() async {
    // Build a temporary profile to feed the reasoning engine
    final tempProfile = UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: state.name,
      age: state.age,
      gender: state.gender,
      heightCm: state.heightCm,
      weightKg: state.weightKg,
      bodyFatPercent: state.bodyFatPercent,
      waistSizeCm: state.waistSizeCm,
      healthConditions: state.healthConditions,
      lifestyleType: state.lifestyleType,
      foodPreference: state.foodPreference,
      region: state.region,
      primaryGoal: state.primaryGoal ?? HealthGoal.stayFit,
      capabilities: state.capabilities,
      activityLevel: _inferActivityLevel(),
    );

    // Let the AI Reasoning Engine compute the personalized plan
    final plan = AIReasoningEngine.generatePlan(tempProfile);

    // Create the final profile with AI-computed targets
    final finalProfile = tempProfile.copyWith(
      dailyCalorieGoal: plan.dailyCalories,
      dailyProteinGoalGrams: plan.dailyProteinGrams,
      dailyCarbsGoalGrams: plan.dailyCarbsGrams,
      dailyFatGoalGrams: plan.dailyFatGrams,
      dailyFiberGoalGrams: plan.dailyFiberGrams,
      dailyWaterGoalMl: plan.dailyWaterMl,
      dailyStepGoal: plan.dailyStepGoal,
      sleepGoalMinutes: plan.sleepGoalMinutes,
      idealWakeTime: plan.idealWakeTime,
      idealSleepTime: plan.idealSleepTime,
      workoutPlanSummary: plan.workoutPlanSummary,
      aiExplanation: plan.aiExplanation,
      isOnboardingComplete: true,
    );

    // Save to profile provider
    await _ref.read(profileProvider.notifier).updateProfile(finalProfile);
  }

  ActivityLevel _inferActivityLevel() {
    final caps = state.capabilities;
    if (caps.contains(ActivityCapability.gym) && caps.length >= 4) {
      return ActivityLevel.veryActive;
    } else if (caps.length >= 3) {
      return ActivityLevel.moderatelyActive;
    } else if (caps.length >= 2) {
      return ActivityLevel.lightlyActive;
    }
    return ActivityLevel.sedentary;
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});
