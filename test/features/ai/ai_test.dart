import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/features/ai/data/repositories/ai_coach_repository_impl.dart';

void main() {
  group('AI Coach Feature Tests', () {
    final repo = AICoachRepositoryImpl();

    test('getChatHistory includes medical disclaimer initial message', () async {
      final historyRes = await repo.getChatHistory();
      expect(historyRes.isSuccess, isTrue);
      expect(historyRes.data, isNotNull);
      expect(historyRes.data?.first.isMedicalDisclaimer, isTrue);
      expect(historyRes.data?.first.text, contains('Disclaimer'));
    });

    test('sendMessage generates contextual AI response correctly', () async {
      final sendRes = await repo.sendMessage('Tell me about my protein goal');
      expect(sendRes.isSuccess, isTrue);
      expect(sendRes.data?.text, contains('protein'));

      final updatedHistory = await repo.getChatHistory();
      expect(updatedHistory.data?.length, greaterThanOrEqualTo(3));
    });

    test('getProactiveInsights returns active health recommendations', () async {
      final insightsRes = await repo.getProactiveInsights();
      expect(insightsRes.isSuccess, isTrue);
      expect(insightsRes.data?.isNotEmpty, isTrue);
      expect(insightsRes.data?.first.title, contains('Calorie Target'));
    });
  });
}
