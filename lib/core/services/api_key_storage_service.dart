import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's own OpenAI API key on-device.
/// NOTE: shared_preferences is NOT encrypted storage. For production,
/// swap this for `flutter_secure_storage` (Keychain/Keystore-backed) —
/// this class's public API is written so that swap only touches this file.
abstract class ApiKeyStorageService {
  static const _key = 'user_openai_api_key';

  static Future<void> saveKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, key.trim());
    } catch (_) {}
  }

  static Future<String?> getKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_key);
      return (value == null || value.isEmpty) ? null : value;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
