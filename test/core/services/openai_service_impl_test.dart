import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ai_health_manager/core/services/ai_service.dart';
import 'package:ai_health_manager/core/services/openai_service_impl.dart';
import 'package:ai_health_manager/core/services/vision_http_client.dart';

class FakeVisionHttpClient implements VisionHttpClient {
  final int statusCode;
  final String body;
  int callCount = 0;

  FakeVisionHttpClient({required this.statusCode, required this.body});

  @override
  Future<http.Response> post(
    Uri uri, {
    required Map<String, String> headers,
    required Object body,
  }) async {
    callCount++;
    return http.Response(this.body, statusCode);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late File tempImage;

  setUpAll(() async {
    tempImage = File('${Directory.systemTemp.path}/test_food_image.jpg');
    await tempImage.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46]);
  });

  tearDownAll(() async {
    if (await tempImage.exists()) {
      await tempImage.delete();
    }
  });

  group('OpenAIServiceImpl HTTP Status Code Branch Tests', () {
    test('HTTP 200 with valid JSON returns populated MealAnalysisResult', () async {
      final fakeJson = jsonEncode({
        'choices': [
          {
            'message': {
              'content': jsonEncode({
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
              })
            }
          }
        ]
      });

      final fakeClient = FakeVisionHttpClient(statusCode: 200, body: fakeJson);
      final service = OpenAIServiceImpl(apiKey: 'sk-test-key-12345', httpClient: fakeClient);

      final result = await service.analyzeFoodImage(imagePath: tempImage.path);

      expect(result.mealTitle, contains('Batata Bhaji'));
      expect(result.totalCalories, greaterThan(0));
      expect(fakeClient.callCount, equals(1));
    });

    test('HTTP 429 throws AiAnalysisException with isQuotaError == true', () async {
      final fakeClient = FakeVisionHttpClient(statusCode: 429, body: '{"error": "Quota exceeded"}');
      final service = OpenAIServiceImpl(apiKey: 'sk-test-key-12345', httpClient: fakeClient);

      expect(
        () => service.analyzeFoodImage(imagePath: tempImage.path),
        throwsA(isA<AiAnalysisException>().having((e) => e.isQuotaError, 'isQuotaError', isTrue)),
      );
    });

    test('HTTP 401 throws AiAnalysisException with isApiKeyError == true', () async {
      final fakeClient = FakeVisionHttpClient(statusCode: 401, body: '{"error": "Unauthorized key"}');
      final service = OpenAIServiceImpl(apiKey: 'sk-test-key-12345', httpClient: fakeClient);

      expect(
        () => service.analyzeFoodImage(imagePath: tempImage.path),
        throwsA(isA<AiAnalysisException>().having((e) => e.isApiKeyError, 'isApiKeyError', isTrue)),
      );
    });

    test('HTTP 500 throws AiAnalysisException with isServerError == true', () async {
      final fakeClient = FakeVisionHttpClient(statusCode: 500, body: '{"error": "Internal Server Error"}');
      final service = OpenAIServiceImpl(apiKey: 'sk-test-key-12345', httpClient: fakeClient);

      expect(
        () => service.analyzeFoodImage(imagePath: tempImage.path),
        throwsA(isA<AiAnalysisException>().having((e) => e.isServerError, 'isServerError', isTrue)),
      );
    });

    test('Malformed JSON response on HTTP 200 throws parse error exception', () async {
      final fakeClient = FakeVisionHttpClient(statusCode: 200, body: 'INVALID_NOT_JSON');
      final service = OpenAIServiceImpl(apiKey: 'sk-test-key-12345', httpClient: fakeClient);

      expect(
        () => service.analyzeFoodImage(imagePath: tempImage.path),
        throwsA(isA<AiAnalysisException>().having((e) => e.message, 'message', contains('Failed to parse JSON'))),
      );
    });

    test('Empty/invalid API key throws isApiKeyError == true before HTTP call', () async {
      final fakeClient = FakeVisionHttpClient(statusCode: 200, body: '{}');
      final service = OpenAIServiceImpl(apiKey: 'invalid-key-no-sk-prefix', httpClient: fakeClient);

      expect(
        () => service.analyzeFoodImage(imagePath: tempImage.path),
        throwsA(isA<AiAnalysisException>().having((e) => e.isApiKeyError, 'isApiKeyError', isTrue)),
      );
      expect(fakeClient.callCount, equals(0));
    });
  });
}
