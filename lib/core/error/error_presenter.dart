import '../services/ai_service.dart';
import 'app_exception.dart';

abstract class ErrorPresenter {
  static String userMessage(Object error) {
    if (error is AiAnalysisException) {
      return error.message;
    }
    if (error is AppException) {
      return error.message;
    }
    final str = error.toString().replaceAll('Exception: ', '').trim();
    if (str.isEmpty || str == 'null' || str.contains('Instance of')) {
      return 'Something went wrong. Please try again.';
    }
    return str;
  }
}
