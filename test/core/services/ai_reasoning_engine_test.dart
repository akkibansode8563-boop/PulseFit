import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/core/services/ai_reasoning_engine.dart';
import 'package:ai_health_manager/features/profile/domain/entities/user_profile.dart';
import 'package:ai_health_manager/features/profile/domain/entities/health_enums.dart';

void main() {
  group('AI Reasoning Engine Tests', () {
    test('generatePlan computes high protein for muscle building', () {
      const profile = UserProfile(
        id: 'u1',
        name: 'Rahul',
        age: 28,
        gender: Gender.male,
        heightCm: 175.0,
        weightKg: 75.0,
        primaryGoal: HealthGoal.buildMuscle,
        capabilities: {ActivityCapability.gym, ActivityCapability.walking},
      );

      final plan = AIReasoningEngine.generatePlan(profile);
      expect(plan.dailyProteinGrams, equals(150)); // 75kg * 2.0g/kg
      expect(plan.dailyCalories, greaterThan(2000));
      expect(plan.exerciseRecommendations, contains(contains('Strength Training')));
    });

    test('generatePlan excludes running when knee pain is present', () {
      const profile = UserProfile(
        id: 'u2',
        name: 'Priya',
        age: 32,
        gender: Gender.female,
        heightCm: 162.0,
        weightKg: 60.0,
        primaryGoal: HealthGoal.loseFat,
        healthConditions: {HealthCondition.kneePain},
        capabilities: {ActivityCapability.walking, ActivityCapability.running, ActivityCapability.cycling},
      );

      final plan = AIReasoningEngine.generatePlan(profile);
      expect(plan.avoidedExercises.any((e) => e.contains('Running')), isTrue);
      expect(plan.exerciseRecommendations.any((e) => e.contains('Walking') || e.contains('Cycling')), isTrue);
    });

    test('rebalanceDay responds intelligently to overeating prompt', () {
      const profile = UserProfile(
        id: 'u3',
        name: 'Amit',
        age: 30,
        gender: Gender.male,
        heightCm: 178.0,
        weightKg: 80.0,
        primaryGoal: HealthGoal.loseFat,
      );

      final response = AIReasoningEngine.rebalanceDay(
        profile: profile,
        caloriesConsumed: 2600,
        calorieTarget: 2000,
        stepsCompleted: 4000,
        stepTarget: 10000,
        workoutDone: false,
        userMessage: 'I ate extra biryani today',
      );

      expect(response, contains('650 extra calories'));
      expect(response, contains('Walk 8 km'));
    });
  });
}
