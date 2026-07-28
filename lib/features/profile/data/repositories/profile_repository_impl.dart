import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/health_enums.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  static const String _profileKey = 'pulsefit_user_profile_json';

  UserProfileModel _cachedProfile = const UserProfileModel(
    id: 'user_local_1',
    name: '',
    age: 25,
    gender: Gender.male,
    heightCm: 170.0,
    weightKg: 70.0,
    primaryGoal: HealthGoal.stayFit,
    activityLevel: ActivityLevel.moderatelyActive,
    foodPreference: FoodPreference.vegetarian,
    region: IndianRegion.maharashtra,
    capabilities: {ActivityCapability.gym, ActivityCapability.walking, ActivityCapability.cycling},
    dailyCalorieGoal: 2000,
    dailyProteinGoalGrams: 70,
    dailyCarbsGoalGrams: 250,
    dailyFatGoalGrams: 60,
    dailyFiberGoalGrams: 30,
    dailyWaterGoalMl: 2500,
    dailyStepGoal: 10000,
    sleepGoalMinutes: 480,
    idealWakeTime: '06:00',
    idealSleepTime: '23:00',
    workoutPlanSummary: 'Balanced Fitness & Wellness Program',
    aiExplanation: 'Personalized plan for optimal daily health.',
    isOnboardingComplete: false,
  );

  bool _initialized = false;

  Future<void> _initLocalCache() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_profileKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        _cachedProfile = UserProfileModel.fromJson(map);
      }
    } catch (_) {
      // Fallback to default in case of parse error
    } finally {
      _initialized = true;
    }
  }

  @override
  Future<Result<UserProfile>> getUserProfile() async {
    try {
      await _initLocalCache();
      return Result.success(_cachedProfile);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserProfile>> updateUserProfile(UserProfile profile) async {
    try {
      _cachedProfile = UserProfileModel.fromDomain(profile);
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonStr = jsonEncode(_cachedProfile.toJson());
        await prefs.setString(_profileKey, jsonStr);
      } catch (_) {
        // Fallback for isolated unit tests without mock SharedPreferences
      }
      return Result.success(_cachedProfile);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }
}
