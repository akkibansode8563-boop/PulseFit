import '../../../../core/error/result.dart';
import '../entities/ai_entities.dart';

abstract class IAICoachRepository {
  Future<Result<List<ChatMessage>>> getChatHistory();
  Future<Result<ChatMessage>> sendMessage(String prompt);
  Future<Result<List<ProactiveInsight>>> getProactiveInsights();
}
