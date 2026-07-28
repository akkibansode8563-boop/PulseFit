import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/meal_record.dart';
import '../../domain/repositories/i_nutrition_repository.dart';
import '../models/meal_record_model.dart';

class NutritionRepositoryImpl implements INutritionRepository {
  final List<MealRecordModel> _localMeals = [
    MealRecordModel(
      id: 'meal_1',
      title: 'Scrambled Eggs & Toast',
      mealType: MealType.breakfast,
      loggedAt: DateTime.now().subtract(const Duration(hours: 4)),
      items: const [
        MealItem(name: 'Scrambled Eggs (3 whole)', weightGrams: 150, calories: 210, proteinGrams: 18, carbsGrams: 2, fatGrams: 15),
        MealItem(name: 'Whole Wheat Toast (2 slices)', weightGrams: 60, calories: 160, proteinGrams: 8, carbsGrams: 28, fatGrams: 2),
      ],
    ),
  ];

  @override
  Future<Result<List<MealRecord>>> getTodayMeals() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return Result.success(List.unmodifiable(_localMeals));
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<MealRecord>> logMeal(MealRecord meal) async {
    try {
      final model = MealRecordModel.fromDomain(meal);
      _localMeals.insert(0, model);
      await Future.delayed(const Duration(milliseconds: 200));
      return Result.success(model);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteMeal(String mealId) async {
    try {
      _localMeals.removeWhere((m) => m.id == mealId);
      await Future.delayed(const Duration(milliseconds: 200));
      return Result.success(null);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }
}
