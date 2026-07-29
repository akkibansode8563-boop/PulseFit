import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../features/nutrition/data/mappers/food_analysis_mapper.dart';
import 'ai_service.dart';
import 'api_key_storage_service.dart';
import 'network_checker_service.dart';
import 'vision_http_client.dart';

class GeminiServiceImpl implements IAIService {
  final String? apiKey;
  final VisionHttpClient httpClient;

  GeminiServiceImpl({
    this.apiKey,
    VisionHttpClient? httpClient,
  }) : httpClient = httpClient ?? DefaultVisionHttpClient();

  Future<String> _getEffectiveKey() async {
    if (apiKey != null && apiKey!.isNotEmpty) return apiKey!;

    final savedKey = await ApiKeyStorageService.getGeminiKey();
    if (savedKey != null && savedKey.isNotEmpty) return savedKey;

    final envKey = Platform.environment['GEMINI_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) return envKey;

    if (dotenv.isInitialized) {
      final dotenvKey = dotenv.env['GEMINI_API_KEY'];
      if (dotenvKey != null && dotenvKey.isNotEmpty) return dotenvKey;
    }

    return '';
  }

  @override
  Future<MealAnalysisResult> analyzeFoodImage({
    required String imagePath,
    String? note,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();

    // STAGE 1: File Check
    final file = File(imagePath);
    if (!await file.exists()) {
      throw const AiAnalysisException('Unable to locate image file on device.');
    }

    // STAGE 2: Network Connectivity Check
    final bool isOnline = await NetworkCheckerService.isConnected();
    if (!isOnline) {
      throw const AiAnalysisException(
        'Internet connection required for Cloud AI Vision Analysis.',
        isNetworkError: true,
      );
    }

    // STAGE 3: API Key Verification
    final String key = await _getEffectiveKey();
    if (key.isEmpty || !key.startsWith('AIza')) {
      throw const AiAnalysisException(
        'No Google Gemini API key configured. Add your key in Settings → AI Vision.',
        isApiKeyError: true,
      );
    }

    // STAGE 4: Base64 Encoding & Request Preparation
    const String systemPrompt =
        'You are an expert nutritionist, chef, dietitian, food scientist, and computer vision model. Your task is to identify food from a single image with very high accuracy. Recognize Indian food (Maharashtrian, North Indian, South Indian, Gujarati, Punjabi, Street Food, Snacks) as well as Chinese, Italian, Japanese, Mexican, Healthy/Gym Meals, Fast Food, Desserts, and Beverages. Never invent fake food names or return generic placeholders. If confidence is lower than 90%, return top 3 dish alternatives in the alternatives array. Return JSON strictly matching this schema:\n'
        '{\n'
        '  "dish": "Batata Bhaji",\n'
        '  "confidence": 94,\n'
        '  "cuisine": "Maharashtrian",\n'
        '  "ingredients": ["Potato", "Turmeric", "Mustard Seeds", "Curry Leaves", "Coriander"],\n'
        '  "portion": "Medium Bowl",\n'
        '  "estimatedWeight": 180,\n'
        '  "nutrition": {\n'
        '    "calories": 218,\n'
        '    "protein": 3.8,\n'
        '    "carbs": 31.5,\n'
        '    "fat": 9.0,\n'
        '    "fiber": 4.2,\n'
        '    "sugar": 2.0\n'
        '  },\n'
        '  "alternatives": ["Aloo Sabzi", "Jeera Aloo"]\n'
        '}';

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    final Stopwatch netStopwatch = Stopwatch()..start();
    http.Response response;

    final Uri url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$key',
    );

    try {
      response = await httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': systemPrompt},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'response_mime_type': 'application/json',
          }
        }),
      );
      netStopwatch.stop();
    } catch (e) {
      throw AiAnalysisException(
        'Google Gemini Vision API network error: $e',
        isNetworkError: true,
      );
    }

    // STAGE 5: Status Code Verification
    if (response.statusCode != 200) {
      debugPrint('Google Gemini Vision HTTP ${response.statusCode}: ${response.body}');

      if (response.statusCode == 429) {
        throw const AiAnalysisException(
          'Your Google Gemini API account has run out of quota. Check your plan at aistudio.google.com, or add a different key in Settings.',
          isQuotaError: true,
        );
      }
      if (response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 403) {
        throw const AiAnalysisException(
          'Your Google Gemini API key was rejected. Check it in Settings → AI Vision.',
          isApiKeyError: true,
        );
      }
      if (response.statusCode >= 500) {
        throw const AiAnalysisException(
          'Google Gemini Vision service is temporarily unavailable. Please try again shortly.',
          isServerError: true,
        );
      }

      throw AiAnalysisException(
        'Google Gemini Vision request failed (HTTP ${response.statusCode}).',
        technicalDetails: response.body,
      );
    }

    // STAGE 6: JSON Parsing
    Map<String, dynamic> jsonResult;
    String rawContent = '';
    try {
      final data = jsonDecode(response.body);
      rawContent = data['candidates'][0]['content']['parts'][0]['text'];
      jsonResult = jsonDecode(rawContent);
    } catch (e) {
      throw AiAnalysisException(
        'Failed to parse JSON response from Google Gemini Vision model.',
        technicalDetails: response.body,
      );
    }

    stopwatch.stop();

    return FoodAnalysisMapper.fromOpenAiJson(
      jsonResult,
      rawJsonResponse: rawContent,
      totalLatencyMs: stopwatch.elapsedMilliseconds,
      networkLatencyMs: netStopwatch.elapsedMilliseconds,
    );
  }

  @override
  Future<MealAnalysisResult> analyzeMealText({
    required String textDescription,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    final bool isOnline = await NetworkCheckerService.isConnected();
    final String key = await _getEffectiveKey();

    if (isOnline && key.startsWith('AIza')) {
      try {
        final Uri url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$key',
        );

        final response = await httpClient.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text':
                        'You are an expert nutritionist. Analyze this meal description: "$textDescription". Return strictly JSON matching keys: dish, cuisine, estimatedWeight, calories, protein, carbs, fat, fiber, sugar, confidenceScore, aiAdvice.'
                  }
                ]
              }
            ],
            'generationConfig': {
              'response_mime_type': 'application/json',
            }
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final rawContent = data['candidates'][0]['content']['parts'][0]['text'];
          final jsonResult = jsonDecode(rawContent);

          stopwatch.stop();

          return FoodAnalysisMapper.fromOpenAiJson(
            jsonResult,
            rawJsonResponse: rawContent,
            totalLatencyMs: stopwatch.elapsedMilliseconds,
            networkLatencyMs: 150,
          );
        }
      } catch (_) {}
    }

    throw const AiAnalysisException(
      'Unable to analyze text meal description via Google Gemini API.',
      isApiKeyError: true,
    );
  }
}
