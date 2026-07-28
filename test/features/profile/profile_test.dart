import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/features/profile/domain/entities/user_profile.dart';
import 'package:ai_health_manager/features/profile/domain/entities/health_enums.dart';
import 'package:ai_health_manager/features/profile/data/models/user_profile_model.dart';
import 'package:ai_health_manager/features/profile/data/repositories/profile_repository_impl.dart';

void main() {
  group('Profile Feature Tests', () {
    final repo = ProfileRepositoryImpl();

    test('getUserProfile returns profile successfully', () async {
      final result = await repo.getUserProfile();
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.id, equals('user_local_1'));
    });

    test('updateUserProfile updates target goals cleanly', () async {
      final initialResult = await repo.getUserProfile();
      final initialProfile = initialResult.data!;

      final updatedProfile = initialProfile.copyWith(
        name: 'Alex Mercer',
        dailyCalorieGoal: 2600,
        dailyProteinGoalGrams: 180,
      );

      final updateResult = await repo.updateUserProfile(updatedProfile);
      expect(updateResult.isSuccess, isTrue);
      expect(updateResult.data?.name, equals('Alex Mercer'));
      expect(updateResult.data?.dailyCalorieGoal, equals(2600));
      expect(updateResult.data?.dailyProteinGoalGrams, equals(180));
    });

    test('UserProfileModel json serialization works roundtrip', () {
      const model = UserProfileModel(
        id: 'test_123',
        name: 'Jane Doe',
        age: 30,
        gender: Gender.female,
        heightCm: 168.0,
        weightKg: 62.0,
        primaryGoal: HealthGoal.loseFat,
        activityLevel: ActivityLevel.veryActive,
        dailyCalorieGoal: 1800,
        dailyProteinGoalGrams: 130,
        dailyWaterGoalMl: 2800,
        sleepGoalMinutes: 510,
      );

      final json = model.toJson();
      final deserialized = UserProfileModel.fromJson(json);

      expect(deserialized.id, equals('test_123'));
      expect(deserialized.primaryGoal, equals(HealthGoal.loseFat));
      expect(deserialized.dailyCalorieGoal, equals(1800));
    });
  });
}
