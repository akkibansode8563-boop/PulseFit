import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/features/nutrition/data/mappers/food_analysis_mapper.dart';

void main() {
  group('FoodAnalysisMapper Unit Tests', () {
    test('fromOpenAiJson maps valid JSON payload to MealAnalysisResult', () {
      final jsonPayload = {
        'dish': 'Batata Bhaji',
        'confidence': 94,
        'cuisine': 'Maharashtrian',
        'ingredients': ['Potato', 'Turmeric'],
        'portion': 'Medium Bowl',
        'estimatedWeight': 180,
        'nutrition': {
          'calories': 218,
          'protein': 3.8,
          'carbs': 31.5,
          'fat': 9.0,
          'fiber': 4.2,
          'sugar': 2.0
        },
        'alternatives': ['Aloo Sabzi']
      };

      final result = FoodAnalysisMapper.fromOpenAiJson(
        jsonPayload,
        rawJsonResponse: '{}',
        totalLatencyMs: 250,
        networkLatencyMs: 200,
      );

      expect(result.mealTitle, contains('Batata Bhaji'));
      expect(result.confidenceScore, equals(0.94));
      expect(result.cuisine, equals('Maharashtrian'));
      expect(result.ingredients, contains('Potato'));
      expect(result.alternatives, contains('Aloo Sabzi'));
    });
  });
}
