import 'ai_service.dart';
import 'api_key_storage_service.dart';
import 'gemini_service_impl.dart';
import 'openai_service_impl.dart';

abstract class AiVisionFactory {
  static Future<IAIService> getService() async {
    final configuredKey = await ApiKeyStorageService.getEffectiveProviderKey();
    if (configuredKey.provider == AiVisionProvider.gemini) {
      return GeminiServiceImpl(apiKey: configuredKey.key);
    }
    return OpenAIServiceImpl(apiKey: configuredKey.key);
  }
}
