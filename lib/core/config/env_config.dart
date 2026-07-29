import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class EnvConfig {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env asset is optional for local dev; secrets are never bundled in production release builds.
    }
  }

  static String get openAiApiKey =>
      dotenv.get('OPENAI_API_KEY', fallback: '');

  static String get envStage =>
      dotenv.get('ENV_STAGE', fallback: 'production');

  static bool get isDevelopment => envStage.toLowerCase() == 'development';
}
