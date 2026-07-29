import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ai_health_manager/core/services/ai_service.dart';
import 'package:ai_health_manager/core/services/gemini_service_impl.dart';
import 'package:ai_health_manager/core/services/vision_http_client.dart';

class MockGeminiHttpClient implements VisionHttpClient {
  final int statusCode;
  final String responseBody;

  MockGeminiHttpClient({required this.statusCode, required this.responseBody});

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return http.Response(responseBody, statusCode);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late File tempFile;

  setUpAll(() async {
    tempFile = File('${Directory.systemTemp.path}/test_gemini_food.jpg');
    await tempFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);
  });

  tearDownAll(() async {
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  });

  group('GeminiServiceImpl Tests', () {
    test('HTTP 200 parses Google Gemini Vision JSON correctly', () async {
      const validGeminiResponse = '''
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "{\\"dish\\": \\"Poha\\", \\"confidence\\": 95, \\"cuisine\\": \\"Maharashtrian\\", \\"ingredients\\": [\\"Flattened Rice\\", \\"Peanuts\\", \\"Onion\\"], \\"portion\\": \\"1 Plate\\", \\"estimatedWeight\\": 150, \\"nutrition\\": {\\"calories\\": 250, \\"protein\\": 5.0, \\"carbs\\": 45.0, \\"fat\\": 6.0, \\"fiber\\": 3.0, \\"sugar\\": 2.0}, \\"alternatives\\": [\\"Upma\\"]}"
          }
        ]
      }
    }
  ]
}
''';

      final service = GeminiServiceImpl(
        apiKey: 'AIzaSyTestKey123',
        httpClient: MockGeminiHttpClient(
          statusCode: 200,
          responseBody: validGeminiResponse,
        ),
      );

      final result = await service.analyzeFoodImage(imagePath: tempFile.path);

      expect(result.mealTitle, contains('Poha'));
      expect(result.totalCalories, greaterThan(0));
      expect(result.totalProtein, equals(5));
      expect(result.alternatives, contains('Upma'));
    });

    test('HTTP 429 throws AiAnalysisException with isQuotaError == true', () async {
      final service = GeminiServiceImpl(
        apiKey: 'AIzaSyTestKey123',
        httpClient: MockGeminiHttpClient(
          statusCode: 429,
          responseBody: '{"error": {"message": "Resource has been exhausted"}}',
        ),
      );

      expect(
        () async => await service.analyzeFoodImage(imagePath: tempFile.path),
        throwsA(
          isA<AiAnalysisException>().having((e) => e.isQuotaError, 'isQuotaError', isTrue),
        ),
      );
    });

    test('HTTP 400 invalid key throws AiAnalysisException with isApiKeyError == true', () async {
      final service = GeminiServiceImpl(
        apiKey: 'AIzaSyTestKey123',
        httpClient: MockGeminiHttpClient(
          statusCode: 400,
          responseBody: '{"error": {"message": "API key not valid"}}',
        ),
      );

      expect(
        () async => await service.analyzeFoodImage(imagePath: tempFile.path),
        throwsA(
          isA<AiAnalysisException>().having((e) => e.isApiKeyError, 'isApiKeyError', isTrue),
        ),
      );
    });

    test('Empty/invalid API key throws isApiKeyError == true before HTTP call', () async {
      final service = GeminiServiceImpl(
        apiKey: 'invalid_key',
        httpClient: MockGeminiHttpClient(statusCode: 200, responseBody: '{}'),
      );

      expect(
        () async => await service.analyzeFoodImage(imagePath: tempFile.path),
        throwsA(
          isA<AiAnalysisException>().having((e) => e.isApiKeyError, 'isApiKeyError', isTrue),
        ),
      );
    });
  });
}
