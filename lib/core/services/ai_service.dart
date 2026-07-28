import 'package:flutter/foundation.dart';
import '../../features/nutrition/domain/entities/meal_record.dart';

@immutable
class MealAnalysisResult {
  final String mealTitle;
  final MealType suggestedType;
  final List<MealItem> items;
  final double confidenceScore;
  final String aiAdvice;

  const MealAnalysisResult({
    required this.mealTitle,
    required this.suggestedType,
    required this.items,
    required this.confidenceScore,
    required this.aiAdvice,
  });

  int get totalCalories => items.fold(0, (sum, i) => sum + i.calories);
  int get totalProtein => items.fold(0, (sum, i) => sum + i.proteinGrams);
  int get totalCarbs => items.fold(0, (sum, i) => sum + i.carbsGrams);
  int get totalFat => items.fold(0, (sum, i) => sum + i.fatGrams);
}

abstract class IAIService {
  Future<MealAnalysisResult> analyzeFoodImage({
    required String imagePath,
    String? note,
  });

  Future<MealAnalysisResult> analyzeMealText({
    required String textDescription,
  });
}
