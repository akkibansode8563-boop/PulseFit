import '../../features/nutrition/domain/entities/meal_record.dart';
import 'ai_service.dart';

class OpenAIServiceImpl implements IAIService {
  @override
  Future<MealAnalysisResult> analyzeFoodImage({
    required String imagePath,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const MealAnalysisResult(
      mealTitle: 'Pithla Bhakri with Solkadhi',
      suggestedType: MealType.lunch,
      items: [
        MealItem(name: 'Besan Pithla', weightGrams: 150, calories: 180, proteinGrams: 8, carbsGrams: 24, fatGrams: 6),
        MealItem(name: 'Jowar Bhakri', weightGrams: 100, calories: 180, proteinGrams: 5, carbsGrams: 38, fatGrams: 2),
        MealItem(name: 'Solkadhi', weightGrams: 150, calories: 60, proteinGrams: 1, carbsGrams: 4, fatGrams: 4),
      ],
      confidenceScore: 0.95,
      aiAdvice: 'High-fiber Maharashtrian meal rich in plant protein and gut-friendly probiotics.',
    );
  }

  @override
  Future<MealAnalysisResult> analyzeMealText({
    required String textDescription,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lower = textDescription.toLowerCase();

    if (lower.contains('chicken')) {
      return const MealAnalysisResult(
        mealTitle: 'Grilled Chicken Breast and Rice',
        suggestedType: MealType.lunch,
        items: [
          MealItem(name: 'Grilled Chicken Breast', weightGrams: 200, calories: 330, proteinGrams: 48, carbsGrams: 0, fatGrams: 7),
          MealItem(name: 'Steamed Basmati Rice', weightGrams: 150, calories: 190, proteinGrams: 4, carbsGrams: 42, fatGrams: 1),
        ],
        confidenceScore: 0.96,
        aiAdvice: 'High protein fitness meal optimal for muscle recovery.',
      );
    } else if (lower.contains('egg') || lower.contains('toast')) {
      return const MealAnalysisResult(
        mealTitle: 'Scrambled Eggs and Toast',
        suggestedType: MealType.breakfast,
        items: [
          MealItem(name: 'Scrambled Eggs', weightGrams: 120, calories: 180, proteinGrams: 14, carbsGrams: 2, fatGrams: 12),
          MealItem(name: 'Whole Wheat Toast', weightGrams: 60, calories: 150, proteinGrams: 6, carbsGrams: 26, fatGrams: 2),
        ],
        confidenceScore: 0.94,
        aiAdvice: 'Balanced breakfast providing quality protein and complex carbohydrates.',
      );
    } else if (lower.contains('पोहे') || lower.contains('poha')) {
      return const MealAnalysisResult(
        mealTitle: 'Kanda Poha',
        suggestedType: MealType.breakfast,
        items: [
          MealItem(name: 'Kanda Poha', weightGrams: 200, calories: 260, proteinGrams: 7, carbsGrams: 42, fatGrams: 8),
        ],
        confidenceScore: 0.94,
        aiAdvice: 'Poha is easy to digest and provides sustained morning energy.',
      );
    } else if (lower.contains('थालीपीठ') || lower.contains('thalipeeth')) {
      return const MealAnalysisResult(
        mealTitle: 'Thalipeeth with Curd',
        suggestedType: MealType.breakfast,
        items: [
          MealItem(name: 'Thalipeeth (2 pcs)', weightGrams: 180, calories: 280, proteinGrams: 9, carbsGrams: 42, fatGrams: 8),
          MealItem(name: 'Fresh Curd', weightGrams: 100, calories: 40, proteinGrams: 2, carbsGrams: 3, fatGrams: 2),
        ],
        confidenceScore: 0.96,
        aiAdvice: 'Multi-grain Bhajani Thalipeeth provides complex carbohydrates & fiber.',
      );
    } else if (lower.contains('पिठलं') || lower.contains('pithla') || lower.contains('bhakri')) {
      return const MealAnalysisResult(
        mealTitle: 'Pithla Bhakri',
        suggestedType: MealType.lunch,
        items: [
          MealItem(name: 'Besan Pithla', weightGrams: 150, calories: 200, proteinGrams: 9, carbsGrams: 24, fatGrams: 7),
          MealItem(name: 'Jowar Bhakri', weightGrams: 100, calories: 180, proteinGrams: 5, carbsGrams: 38, fatGrams: 2),
        ],
        confidenceScore: 0.95,
        aiAdvice: 'Gluten-free Jowar Bhakri paired with Pithla supports healthy digestion.',
      );
    }

    return MealAnalysisResult(
      mealTitle: textDescription,
      suggestedType: MealType.lunch,
      items: [
        MealItem(name: textDescription, weightGrams: 200, calories: 350, proteinGrams: 12, carbsGrams: 48, fatGrams: 10),
      ],
      confidenceScore: 0.88,
      aiAdvice: 'Balanced Maharashtrian meal supporting active wellness goals.',
    );
  }
}
