import '../../domain/entities/meal_record.dart';

class MealItemModel extends MealItem {
  const MealItemModel({
    required super.name,
    required super.weightGrams,
    required super.calories,
    required super.proteinGrams,
    required super.carbsGrams,
    required super.fatGrams,
  });

  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
      name: json['name'] as String? ?? 'Food item',
      weightGrams: json['weightGrams'] as int? ?? 100,
      calories: json['calories'] as int? ?? 0,
      proteinGrams: json['proteinGrams'] as int? ?? 0,
      carbsGrams: json['carbsGrams'] as int? ?? 0,
      fatGrams: json['fatGrams'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weightGrams': weightGrams,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
    };
  }
}

class MealRecordModel extends MealRecord {
  const MealRecordModel({
    required super.id,
    required super.title,
    required super.mealType,
    required super.items,
    required super.loggedAt,
    super.imagePath,
  });

  factory MealRecordModel.fromDomain(MealRecord record) {
    return MealRecordModel(
      id: record.id,
      title: record.title,
      mealType: record.mealType,
      items: record.items,
      loggedAt: record.loggedAt,
      imagePath: record.imagePath,
    );
  }

  factory MealRecordModel.fromJson(Map<String, dynamic> json) {
    return MealRecordModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Meal Log',
      mealType: MealType.values.firstWhere(
        (e) => e.name == json['mealType'],
        orElse: () => MealType.lunch,
      ),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => MealItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      loggedAt: DateTime.tryParse(json['loggedAt'] as String? ?? '') ?? DateTime.now(),
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'mealType': mealType.name,
      'items': items.map((i) => MealItemModel(
        name: i.name,
        weightGrams: i.weightGrams,
        calories: i.calories,
        proteinGrams: i.proteinGrams,
        carbsGrams: i.carbsGrams,
        fatGrams: i.fatGrams,
      ).toJson()).toList(),
      'loggedAt': loggedAt.toIso8601String(),
      'imagePath': imagePath,
    };
  }
}
