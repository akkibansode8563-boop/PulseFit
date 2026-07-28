import 'package:flutter/foundation.dart';

enum MealType { breakfast, lunch, dinner, snack }

@immutable
class MealItem {
  final String name;
  final int weightGrams;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;

  const MealItem({
    required this.name,
    required this.weightGrams,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  MealItem copyWith({
    String? name,
    int? weightGrams,
    int? calories,
    int? proteinGrams,
    int? carbsGrams,
    int? fatGrams,
  }) {
    return MealItem(
      name: name ?? this.name,
      weightGrams: weightGrams ?? this.weightGrams,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
    );
  }
}

@immutable
class MealRecord {
  final String id;
  final String title;
  final MealType mealType;
  final List<MealItem> items;
  final DateTime loggedAt;
  final String? imagePath;

  const MealRecord({
    required this.id,
    required this.title,
    required this.mealType,
    required this.items,
    required this.loggedAt,
    this.imagePath,
  });

  String get mealName => title;
  int get totalCalories => items.fold(0, (sum, item) => sum + item.calories);
  int get totalProtein => items.fold(0, (sum, item) => sum + item.proteinGrams);
  int get totalCarbs => items.fold(0, (sum, item) => sum + item.carbsGrams);
  int get totalFat => items.fold(0, (sum, item) => sum + item.fatGrams);
}
