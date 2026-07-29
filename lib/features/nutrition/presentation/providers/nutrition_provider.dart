import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/ai_vision_factory.dart';
import '../../../../core/services/openai_service_impl.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../../domain/entities/meal_record.dart';
import '../../domain/repositories/i_nutrition_repository.dart';

final aiServiceProvider = Provider<IAIService>((ref) {
  // Synchronous fallback service; dynamic methods fetch effective service via AiVisionFactory
  return OpenAIServiceImpl();
});

final nutritionRepositoryProvider = Provider<INutritionRepository>((ref) {
  return NutritionRepositoryImpl();
});

class NutritionNotifier extends AsyncNotifier<List<MealRecord>> {
  @override
  FutureOr<List<MealRecord>> build() async {
    final repo = ref.watch(nutritionRepositoryProvider);
    final result = await repo.getTodayMeals();
    return result.fold(
      onSuccess: (meals) => meals,
      onError: (failure) => throw Exception(failure.message),
    );
  }

  Future<MealAnalysisResult> analyzeMealDescription(String text) async {
    final aiService = await AiVisionFactory.getService();
    return await aiService.analyzeMealText(textDescription: text);
  }

  Future<void> analyzeAndAddMealText(String text) async {
    final aiService = await AiVisionFactory.getService();
    final res = await aiService.analyzeMealText(textDescription: text);
    await saveAnalyzedMeal(res);
  }

  Future<void> saveAnalyzedMeal(MealAnalysisResult analysis) async {
    final newMeal = MealRecord(
      id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
      title: analysis.mealTitle,
      mealType: analysis.suggestedType,
      items: analysis.items,
      loggedAt: DateTime.now(),
    );

    final repo = ref.read(nutritionRepositoryProvider);
    final result = await repo.logMeal(newMeal);
    result.fold(
      onSuccess: (_) async {
        final updatedMeals = await repo.getTodayMeals();
        state = AsyncValue.data(updatedMeals.data ?? []);
      },
      onError: (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
    );
  }

  Future<void> deleteMeal(String mealId) async {
    final repo = ref.read(nutritionRepositoryProvider);
    await repo.deleteMeal(mealId);
    final updatedMeals = await repo.getTodayMeals();
    state = AsyncValue.data(updatedMeals.data ?? []);
  }
}

final nutritionProvider = AsyncNotifierProvider<NutritionNotifier, List<MealRecord>>(
  NutritionNotifier.new,
);
