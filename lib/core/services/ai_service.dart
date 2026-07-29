import 'package:flutter/foundation.dart';
import '../../features/nutrition/domain/entities/meal_record.dart';

class AiAnalysisException implements Exception {
  final String message;
  final String? technicalDetails;
  final bool isNetworkError;
  final bool isApiKeyError;

  const AiAnalysisException(
    this.message, {
    this.technicalDetails,
    this.isNetworkError = false,
    this.isApiKeyError = false,
  });

  @override
  String toString() => message;
}

@immutable
class AiAnalysisTelemetry {
  final bool apiKeyLoaded;
  final bool isOnline;
  final String imageResolution;
  final int imageSizeBytes;
  final String visionModel;
  final String promptSent;
  final String rawJsonResponse;
  final double confidenceScore;
  final String nutritionSource;
  final bool fallbackUsed;
  final int totalLatencyMs;
  final int networkLatencyMs;

  const AiAnalysisTelemetry({
    required this.apiKeyLoaded,
    required this.isOnline,
    required this.imageResolution,
    required this.imageSizeBytes,
    required this.visionModel,
    required this.promptSent,
    required this.rawJsonResponse,
    required this.confidenceScore,
    required this.nutritionSource,
    required this.fallbackUsed,
    required this.totalLatencyMs,
    required this.networkLatencyMs,
  });
}

@immutable
class MealAnalysisResult {
  final String mealTitle;
  final MealType suggestedType;
  final List<MealItem> items;
  final double confidenceScore;
  final String aiAdvice;
  final String cuisine;
  final List<String> ingredients;
  final String portion;
  final int estimatedWeightGrams;
  final int totalFiberGrams;
  final int totalSugarGrams;
  final List<String> alternatives;
  final AiAnalysisTelemetry? telemetry;

  const MealAnalysisResult({
    required this.mealTitle,
    required this.suggestedType,
    required this.items,
    required this.confidenceScore,
    required this.aiAdvice,
    this.cuisine = 'Indian',
    this.ingredients = const [],
    this.portion = '1 Serving',
    this.estimatedWeightGrams = 200,
    this.totalFiberGrams = 4,
    this.totalSugarGrams = 2,
    this.alternatives = const [],
    this.telemetry,
  });

  int get totalCalories => items.fold(0, (sum, i) => sum + i.calories);
  int get totalProtein => items.fold(0, (sum, i) => sum + i.proteinGrams);
  int get totalCarbs => items.fold(0, (sum, i) => sum + i.carbsGrams);
  int get totalFat => items.fold(0, (sum, i) => sum + i.fatGrams);

  MealAnalysisResult copyWith({
    String? mealTitle,
    MealType? suggestedType,
    List<MealItem>? items,
    double? confidenceScore,
    String? aiAdvice,
    String? cuisine,
    List<String>? ingredients,
    String? portion,
    int? estimatedWeightGrams,
    int? totalFiberGrams,
    int? totalSugarGrams,
    List<String>? alternatives,
    AiAnalysisTelemetry? telemetry,
  }) {
    return MealAnalysisResult(
      mealTitle: mealTitle ?? this.mealTitle,
      suggestedType: suggestedType ?? this.suggestedType,
      items: items ?? this.items,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      aiAdvice: aiAdvice ?? this.aiAdvice,
      cuisine: cuisine ?? this.cuisine,
      ingredients: ingredients ?? this.ingredients,
      portion: portion ?? this.portion,
      estimatedWeightGrams: estimatedWeightGrams ?? this.estimatedWeightGrams,
      totalFiberGrams: totalFiberGrams ?? this.totalFiberGrams,
      totalSugarGrams: totalSugarGrams ?? this.totalSugarGrams,
      alternatives: alternatives ?? this.alternatives,
      telemetry: telemetry ?? this.telemetry,
    );
  }
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
