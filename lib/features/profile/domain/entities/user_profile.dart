import 'package:flutter/foundation.dart';
import 'health_enums.dart';

// Keep legacy enums as aliases for backward compatibility during migration
typedef OldHealthGoal = HealthGoal;
typedef OldActivityLevel = ActivityLevel;

enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive }

@immutable
class UserProfile {
  // ─── Identity ───
  final String id;
  final String name;
  final int age;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final double? bodyFatPercent;
  final double? waistSizeCm;

  // ─── Health Conditions ───
  final Set<HealthCondition> healthConditions;
  final List<String> allergies;
  final List<String> currentMedications;

  // ─── Lifestyle ───
  final LifestyleType lifestyleType;
  final ActivityLevel activityLevel;

  // ─── Food & Region ───
  final FoodPreference foodPreference;
  final IndianRegion region;

  // ─── Goal ───
  final HealthGoal primaryGoal;

  // ─── Physical Capabilities ───
  final Set<ActivityCapability> capabilities;

  // ─── AI-Computed Daily Targets ───
  final int dailyCalorieGoal;
  final int dailyProteinGoalGrams;
  final int dailyCarbsGoalGrams;
  final int dailyFatGoalGrams;
  final int dailyFiberGoalGrams;
  final int dailyWaterGoalMl;
  final int dailyStepGoal;
  final int sleepGoalMinutes;
  final String? idealWakeTime;  // e.g. "06:00"
  final String? idealSleepTime; // e.g. "23:00"
  final String? workoutPlanSummary;
  final String? aiExplanation;

  // ─── Onboarding ───
  final bool isOnboardingComplete;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    this.bodyFatPercent,
    this.waistSizeCm,
    this.healthConditions = const {HealthCondition.none},
    this.allergies = const [],
    this.currentMedications = const [],
    this.lifestyleType = LifestyleType.officeJob,
    this.activityLevel = ActivityLevel.moderatelyActive,
    this.foodPreference = FoodPreference.vegetarian,
    this.region = IndianRegion.maharashtra,
    required this.primaryGoal,
    this.capabilities = const {ActivityCapability.walking},
    this.dailyCalorieGoal = 2000,
    this.dailyProteinGoalGrams = 60,
    this.dailyCarbsGoalGrams = 250,
    this.dailyFatGoalGrams = 65,
    this.dailyFiberGoalGrams = 25,
    this.dailyWaterGoalMl = 2500,
    this.dailyStepGoal = 8000,
    this.sleepGoalMinutes = 480,
    this.idealWakeTime,
    this.idealSleepTime,
    this.workoutPlanSummary,
    this.aiExplanation,
    this.isOnboardingComplete = false,
  });

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  bool get hasKneePain => healthConditions.contains(HealthCondition.kneePain);
  bool get hasBackPain => healthConditions.contains(HealthCondition.backPain);
  bool get hasDiabetes => healthConditions.contains(HealthCondition.diabetes);
  bool get hasHighBP => healthConditions.contains(HealthCondition.highBP);

  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    double? bodyFatPercent,
    double? waistSizeCm,
    Set<HealthCondition>? healthConditions,
    List<String>? allergies,
    List<String>? currentMedications,
    LifestyleType? lifestyleType,
    ActivityLevel? activityLevel,
    FoodPreference? foodPreference,
    IndianRegion? region,
    HealthGoal? primaryGoal,
    Set<ActivityCapability>? capabilities,
    int? dailyCalorieGoal,
    int? dailyProteinGoalGrams,
    int? dailyCarbsGoalGrams,
    int? dailyFatGoalGrams,
    int? dailyFiberGoalGrams,
    int? dailyWaterGoalMl,
    int? dailyStepGoal,
    int? sleepGoalMinutes,
    String? idealWakeTime,
    String? idealSleepTime,
    String? workoutPlanSummary,
    String? aiExplanation,
    bool? isOnboardingComplete,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      waistSizeCm: waistSizeCm ?? this.waistSizeCm,
      healthConditions: healthConditions ?? this.healthConditions,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      lifestyleType: lifestyleType ?? this.lifestyleType,
      activityLevel: activityLevel ?? this.activityLevel,
      foodPreference: foodPreference ?? this.foodPreference,
      region: region ?? this.region,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      capabilities: capabilities ?? this.capabilities,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyProteinGoalGrams: dailyProteinGoalGrams ?? this.dailyProteinGoalGrams,
      dailyCarbsGoalGrams: dailyCarbsGoalGrams ?? this.dailyCarbsGoalGrams,
      dailyFatGoalGrams: dailyFatGoalGrams ?? this.dailyFatGoalGrams,
      dailyFiberGoalGrams: dailyFiberGoalGrams ?? this.dailyFiberGoalGrams,
      dailyWaterGoalMl: dailyWaterGoalMl ?? this.dailyWaterGoalMl,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      sleepGoalMinutes: sleepGoalMinutes ?? this.sleepGoalMinutes,
      idealWakeTime: idealWakeTime ?? this.idealWakeTime,
      idealSleepTime: idealSleepTime ?? this.idealSleepTime,
      workoutPlanSummary: workoutPlanSummary ?? this.workoutPlanSummary,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
    );
  }
}
