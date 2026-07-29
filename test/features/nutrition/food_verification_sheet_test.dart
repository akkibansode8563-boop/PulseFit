import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/core/services/ai_service.dart';
import 'package:ai_health_manager/features/nutrition/domain/entities/meal_record.dart';
import 'package:ai_health_manager/features/nutrition/presentation/widgets/food_verification_sheet.dart';

void main() {
  testWidgets('FoodVerificationSheet renders alternatives ActionChips and updates title on tap', (WidgetTester tester) async {
    const analysis = MealAnalysisResult(
      mealTitle: 'Batata Bhaji',
      suggestedType: MealType.lunch,
      items: [
        MealItem(
          name: 'Batata Bhaji',
          weightGrams: 180,
          calories: 218,
          proteinGrams: 4,
          carbsGrams: 31,
          fatGrams: 9,
        ),
      ],
      confidenceScore: 0.85,
      aiAdvice: 'Spiced potato fry.',
      alternatives: ['Aloo Sabzi', 'Jeera Aloo'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FoodVerificationSheet(
            initialAnalysis: analysis,
            onConfirmed: (_) {},
          ),
        ),
      ),
    );

    // Verify ActionChips display
    expect(find.text('Did you mean:'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Aloo Sabzi'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Jeera Aloo'), findsOneWidget);

    // Tap 'Aloo Sabzi' ActionChip
    await tester.tap(find.widgetWithText(ActionChip, 'Aloo Sabzi'));
    await tester.pumpAndSettle();

    // Verify title updated
    expect(find.text('Aloo Sabzi'), findsWidgets);
  });
}
