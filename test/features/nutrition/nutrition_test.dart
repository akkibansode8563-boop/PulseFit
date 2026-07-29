import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/core/services/openai_service_impl.dart';
import 'package:ai_health_manager/features/nutrition/domain/entities/meal_record.dart';
import 'package:ai_health_manager/features/nutrition/data/repositories/nutrition_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Nutrition Feature Tests', () {
    final aiService = OpenAIServiceImpl();
    final repo = NutritionRepositoryImpl();

    test('analyzeMealText parses chicken and rice into high protein macros', () async {
      final result = await aiService.analyzeMealText(textDescription: 'grilled chicken breast and rice');
      expect(result.mealTitle, contains('Chicken'));
      expect(result.totalProtein, greaterThan(50));
      expect(result.totalCalories, greaterThan(400));
    });

    test('analyzeMealText parses egg toast breakfast successfully', () async {
      final result = await aiService.analyzeMealText(textDescription: 'scrambled eggs and toast');
      expect(result.suggestedType, equals(MealType.breakfast));
      expect(result.items.length, equals(2));
    });

    test('logMeal adds new meal record to repository', () async {
      final initialResult = await repo.getTodayMeals();
      final initialCount = initialResult.data?.length ?? 0;

      final newMeal = MealRecord(
        id: 'test_meal_1',
        title: 'Protein Shake',
        mealType: MealType.snack,
        loggedAt: DateTime.now(),
        items: const [
          MealItem(name: 'Whey Protein', weightGrams: 30, calories: 120, proteinGrams: 24, carbsGrams: 3, fatGrams: 1),
        ],
      );

      final logResult = await repo.logMeal(newMeal);
      expect(logResult.isSuccess, isTrue);

      final updatedResult = await repo.getTodayMeals();
      expect(updatedResult.data?.length, equals(initialCount + 1));
    });

    test('deleteMeal removes meal entry cleanly', () async {
      await repo.deleteMeal('meal_1');
      final mealsResult = await repo.getTodayMeals();
      expect(mealsResult.data?.any((m) => m.id == 'meal_1'), isFalse);
    });
  });
}
