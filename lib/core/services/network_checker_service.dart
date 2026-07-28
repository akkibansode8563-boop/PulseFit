import 'dart:io';

class NetworkCheckerService {
  /// Checks active internet connectivity before attempting cloud AI analysis
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}
