import '../../domain/entities/user_profile.dart';
import '../../domain/entities/health_enums.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.age,
    required super.gender,
    required super.heightCm,
    required super.weightKg,
    super.bodyFatPercent,
    super.waistSizeCm,
    super.healthConditions,
    super.allergies,
    super.currentMedications,
    super.lifestyleType,
    super.activityLevel,
    super.foodPreference,
    super.region,
    required super.primaryGoal,
    super.capabilities,
    super.dailyCalorieGoal,
    super.dailyProteinGoalGrams,
    super.dailyCarbsGoalGrams,
    super.dailyFatGoalGrams,
    super.dailyFiberGoalGrams,
    super.dailyWaterGoalMl,
    super.dailyStepGoal,
    super.sleepGoalMinutes,
    super.idealWakeTime,
    super.idealSleepTime,
    super.workoutPlanSummary,
    super.aiExplanation,
    super.isOnboardingComplete,
  });

  factory UserProfileModel.fromDomain(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      age: profile.age,
      gender: profile.gender,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      bodyFatPercent: profile.bodyFatPercent,
      waistSizeCm: profile.waistSizeCm,
      healthConditions: profile.healthConditions,
      allergies: profile.allergies,
      currentMedications: profile.currentMedications,
      lifestyleType: profile.lifestyleType,
      activityLevel: profile.activityLevel,
      foodPreference: profile.foodPreference,
      region: profile.region,
      primaryGoal: profile.primaryGoal,
      capabilities: profile.capabilities,
      dailyCalorieGoal: profile.dailyCalorieGoal,
      dailyProteinGoalGrams: profile.dailyProteinGoalGrams,
      dailyCarbsGoalGrams: profile.dailyCarbsGoalGrams,
      dailyFatGoalGrams: profile.dailyFatGoalGrams,
      dailyFiberGoalGrams: profile.dailyFiberGoalGrams,
      dailyWaterGoalMl: profile.dailyWaterGoalMl,
      dailyStepGoal: profile.dailyStepGoal,
      sleepGoalMinutes: profile.sleepGoalMinutes,
      idealWakeTime: profile.idealWakeTime,
      idealSleepTime: profile.idealSleepTime,
      workoutPlanSummary: profile.workoutPlanSummary,
      aiExplanation: profile.aiExplanation,
      isOnboardingComplete: profile.isOnboardingComplete,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? 'user_local_1',
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 25,
      gender: Gender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => Gender.male,
      ),
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 170.0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 70.0,
      primaryGoal: HealthGoal.values.firstWhere(
        (e) => e.name == json['primaryGoal'],
        orElse: () => HealthGoal.stayFit,
      ),
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == json['activityLevel'],
        orElse: () => ActivityLevel.moderatelyActive,
      ),
      dailyCalorieGoal: json['dailyCalorieGoal'] as int? ?? 2000,
      dailyProteinGoalGrams: json['dailyProteinGoalGrams'] as int? ?? 60,
      dailyWaterGoalMl: json['dailyWaterGoalMl'] as int? ?? 2500,
      sleepGoalMinutes: json['sleepGoalMinutes'] as int? ?? 480,
      isOnboardingComplete: json['isOnboardingComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender.name,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'primaryGoal': primaryGoal.name,
      'activityLevel': activityLevel.name,
      'dailyCalorieGoal': dailyCalorieGoal,
      'dailyProteinGoalGrams': dailyProteinGoalGrams,
      'dailyWaterGoalMl': dailyWaterGoalMl,
      'sleepGoalMinutes': sleepGoalMinutes,
      'isOnboardingComplete': isOnboardingComplete,
    };
  }
}
