import 'package:shared_preferences/shared_preferences.dart';

enum AiVisionProvider { openai, gemini, none }

class ConfiguredAiKey {
  final String key;
  final AiVisionProvider provider;

  const ConfiguredAiKey({required this.key, required this.provider});
}

abstract class ApiKeyStorageService {
  static const _openAiKey = 'user_openai_api_key';
  static const _geminiKey = 'user_gemini_api_key';

  static Future<void> saveOpenAiKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_openAiKey, key.trim());
    } catch (_) {}
  }

  static Future<void> saveGeminiKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_geminiKey, key.trim());
    } catch (_) {}
  }

  static Future<String?> getKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_openAiKey);
      return (value == null || value.isEmpty) ? null : value;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getGeminiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_geminiKey);
      return (value == null || value.isEmpty) ? null : value;
    } catch (_) {
      return null;
    }
  }

  static Future<ConfiguredAiKey> getEffectiveProviderKey() async {
    // 1. Check Gemini key
    final gemini = await getGeminiKey();
    if (gemini != null && gemini.startsWith('AIza')) {
      return ConfiguredAiKey(key: gemini, provider: AiVisionProvider.gemini);
    }

    // 2. Check OpenAI key
    final openAi = await getKey();
    if (openAi != null && openAi.startsWith('sk-')) {
      return ConfiguredAiKey(key: openAi, provider: AiVisionProvider.openai);
    }

    return const ConfiguredAiKey(key: '', provider: AiVisionProvider.none);
  }

  static Future<void> clearKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_openAiKey);
      await prefs.remove(_geminiKey);
    } catch (_) {}
  }

  // Backward compatibility alias
  static Future<void> saveKey(String key) async {
    if (key.trim().startsWith('AIza')) {
      await saveGeminiKey(key);
    } else {
      await saveOpenAiKey(key);
    }
  }

  static Future<void> clearKey() async {
    await clearKeys();
  }
}
