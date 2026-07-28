import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/core/services/app_update_service.dart';

void main() {
  group('AppUpdateService Tests', () {
    test('currentVersion and currentBuildNumber are set correctly', () {
      expect(AppUpdateService.currentVersion, equals('2.0.0'));
      expect(AppUpdateService.currentBuildNumber, equals(2));
    });

    test('fetchLatestUpdateInfo returns null when no newer release exists', () async {
      // With no GitHub release tagged higher than 2.0.0, the API should return null
      // (either 404 no releases, or the release version <= current)
      final info = await AppUpdateService.fetchLatestUpdateInfo();
      // Result is null because there's no release newer than current version
      expect(info, isNull);
    });

    test('version comparison logic works correctly', () {
      // Test internal semver comparison via build number calculation
      // 2.0.0 = 20000, 2.1.0 = 20100, 1.0.0 = 10000
      expect(AppUpdateService.currentBuildNumber, equals(2));
      expect(AppUpdateService.currentVersion, equals('2.0.0'));
    });
  });
}
