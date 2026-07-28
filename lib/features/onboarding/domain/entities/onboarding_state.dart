import 'package:flutter/foundation.dart';
import '../../../profile/domain/entities/health_enums.dart';

/// Intermediate state accumulated across the 5-step onboarding flow.
@immutable
class OnboardingState {
  // Step 1: Personal Info
  final String name;
  final int age;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final double? bodyFatPercent;
  final double? waistSizeCm;

  // Step 2: Health Conditions
  final Set<HealthCondition> healthConditions;
  final List<String> allergies;
  final List<String> currentMedications;

  // Step 3: Lifestyle & Region
  final LifestyleType lifestyleType;
  final FoodPreference foodPreference;
  final IndianRegion region;

  // Step 4: Goal
  final HealthGoal? primaryGoal;

  // Step 5: Capabilities
  final Set<ActivityCapability> capabilities;

  // Flow control
  final int currentStep;

  const OnboardingState({
    this.name = '',
    this.age = 25,
    this.gender = Gender.male,
    this.heightCm = 170.0,
    this.weightKg = 70.0,
    this.bodyFatPercent,
    this.waistSizeCm,
    this.healthConditions = const {HealthCondition.none},
    this.allergies = const [],
    this.currentMedications = const [],
    this.lifestyleType = LifestyleType.officeJob,
    this.foodPreference = FoodPreference.vegetarian,
    this.region = IndianRegion.maharashtra,
    this.primaryGoal,
    this.capabilities = const {ActivityCapability.walking},
    this.currentStep = 0,
  });

  bool get isStep1Valid => name.isNotEmpty && age > 0 && heightCm > 0 && weightKg > 0;
  bool get isStep4Valid => primaryGoal != null;
  bool get isStep5Valid => capabilities.isNotEmpty;

  OnboardingState copyWith({
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
    FoodPreference? foodPreference,
    IndianRegion? region,
    HealthGoal? primaryGoal,
    Set<ActivityCapability>? capabilities,
    int? currentStep,
  }) {
    return OnboardingState(
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
      foodPreference: foodPreference ?? this.foodPreference,
      region: region ?? this.region,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      capabilities: capabilities ?? this.capabilities,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}
