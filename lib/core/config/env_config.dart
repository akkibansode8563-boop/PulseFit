import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class EnvConfig {
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  static String get supabaseUrl =>
      dotenv.get('SUPABASE_URL', fallback: 'https://placeholder.supabase.co');

  static String get supabaseAnonKey =>
      dotenv.get('SUPABASE_ANON_KEY', fallback: 'placeholder-anon-key');

  static String get openAiApiKey =>
      dotenv.get('OPENAI_API_KEY', fallback: 'placeholder-openai-key');

  static String get envStage =>
      dotenv.get('ENV_STAGE', fallback: 'development');

  static bool get isDevelopment => envStage.toLowerCase() == 'development';
}
