import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { english, marathi }

class LocaleNotifier extends StateNotifier<AppLanguage> {
  LocaleNotifier() : super(AppLanguage.english);

  void toggleLanguage() {
    state = state == AppLanguage.english ? AppLanguage.marathi : AppLanguage.english;
  }

  void setLanguage(AppLanguage lang) {
    state = lang;
  }

  bool get isMarathi => state == AppLanguage.marathi;

  String tr(String keyEn, String keyMr) {
    return state == AppLanguage.marathi ? keyMr : keyEn;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLanguage>((ref) {
  return LocaleNotifier();
});
