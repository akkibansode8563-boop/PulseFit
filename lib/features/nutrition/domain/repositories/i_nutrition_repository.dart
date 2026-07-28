import '../../../../core/error/result.dart';
import '../entities/meal_record.dart';

abstract class INutritionRepository {
  Future<Result<List<MealRecord>>> getTodayMeals();
  Future<Result<MealRecord>> logMeal(MealRecord meal);
  Future<Result<void>> deleteMeal(String mealId);
}
