import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/core/services/app_update_service.dart';

void main() {
  group('AppUpdateService Tests', () {
    test('fetchLatestUpdateInfo returns valid update information', () async {
      final info = await AppUpdateService.fetchLatestUpdateInfo(simulateDelay: false);

      expect(info, isNotNull);
      expect(info!.latestVersion, equals('1.1.0'));
      expect(info.buildNumber, greaterThan(AppUpdateService.currentBuildNumber));
      expect(info.releaseNotes, contains('Maharashtrian'));
    });
  });
}
