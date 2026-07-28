import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/update_notification_dialog.dart';

@immutable
class AppUpdateInfo {
  final String latestVersion;
  final int buildNumber;
  final String releaseNotes;
  final String downloadUrl;
  final bool isMandatory;

  const AppUpdateInfo({
    required this.latestVersion,
    required this.buildNumber,
    required this.releaseNotes,
    required this.downloadUrl,
    this.isMandatory = false,
  });
}

class AppUpdateService {
  static const String currentVersion = '1.0.0';
  static const int currentBuildNumber = 1;

  /// Checks server/remote manifest for new updates on launch
  static Future<AppUpdateInfo?> fetchLatestUpdateInfo({bool simulateDelay = true}) async {
    try {
      // Simulate remote version check against Supabase / backend API
      if (simulateDelay) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // In production, this parses JSON from your remote endpoint:
      // e.g. https://api.healthmanager.app/v1/update_manifest.json
      const serverVersion = '1.1.0';
      const serverBuild = 2;

      if (serverBuild > currentBuildNumber) {
        return const AppUpdateInfo(
          latestVersion: serverVersion,
          buildNumber: serverBuild,
          releaseNotes:
              '• Added Maharashtrian Regional Food Voice Command Engine\n'
              '• Enhanced Pitch Black High-Contrast Design System\n'
              '• Added Goal-First AI Reasoning Engine & Injury Filter\n'
              '• Performance & Offline Sync Improvements',
          downloadUrl: 'https://github.com/aihealthmanager/app/releases/latest/download/app-release.apk',
          isMandatory: false,
        );
      }
    } catch (e) {
      debugPrint('AppUpdateService error: $e');
    }
    return null;
  }

  /// Automatically triggers update notification banner on startup if update is available
  static Future<void> checkOnStartup(BuildContext context) async {
    final updateInfo = await fetchLatestUpdateInfo();
    if (updateInfo != null && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: !updateInfo.isMandatory,
        builder: (_) => UpdateNotificationDialog(updateInfo: updateInfo),
      );
    }
  }
}
