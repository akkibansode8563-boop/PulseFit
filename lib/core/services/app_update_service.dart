import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  /// Current app version embedded at build time — must match pubspec.yaml
  static const String currentVersion = '2.0.0';
  static const int currentBuildNumber = 2;

  /// GitHub repository details for real release checking
  static const String _repoOwner = 'akkibansode8563-boop';
  static const String _repoName = 'PulseFit';

  /// Fetches the latest release from GitHub Releases API
  static Future<AppUpdateInfo?> fetchLatestUpdateInfo({bool simulateDelay = false}) async {
    try {
      final uri = Uri.parse(
        'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest',
      );

      final response = await http.get(uri, headers: {
        'Accept': 'application/vnd.github+json',
      }).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Extract version from tag_name (e.g. "v2.1.0" → "2.1.0")
        final tagName = (data['tag_name'] as String?) ?? '';
        final serverVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;

        if (serverVersion.isEmpty) return null;

        // Compare semantic versions
        final serverBuild = _parseBuildNumber(serverVersion);
        if (serverBuild <= currentBuildNumber && !_isNewerVersion(serverVersion, currentVersion)) {
          return null; // Already on latest or newer
        }

        // Extract APK download URL from release assets
        String downloadUrl = data['html_url'] as String? ?? '';
        final assets = data['assets'] as List<dynamic>? ?? [];
        for (final asset in assets) {
          final name = (asset['name'] as String?) ?? '';
          if (name.endsWith('.apk')) {
            downloadUrl = asset['browser_download_url'] as String? ?? downloadUrl;
            break;
          }
        }

        // Release notes from GitHub release body
        final releaseNotes = data['body'] as String? ?? 'New update available with bug fixes and improvements.';

        return AppUpdateInfo(
          latestVersion: serverVersion,
          buildNumber: serverBuild,
          releaseNotes: releaseNotes,
          downloadUrl: downloadUrl,
        );
      }

      // 404 = no releases yet — not an error
      if (response.statusCode == 404) {
        debugPrint('AppUpdateService: No releases found on GitHub.');
        return null;
      }
    } catch (e) {
      debugPrint('AppUpdateService: Network error checking updates — $e');
    }
    return null;
  }

  /// Compares two semver strings: returns true if [remote] is newer than [local]
  static bool _isNewerVersion(String remote, String local) {
    final rParts = remote.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final lParts = local.split('.').map((s) => int.tryParse(s) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final r = i < rParts.length ? rParts[i] : 0;
      final l = i < lParts.length ? lParts[i] : 0;
      if (r > l) return true;
      if (r < l) return false;
    }
    return false;
  }

  /// Extracts a build number from version string (major*10000 + minor*100 + patch)
  static int _parseBuildNumber(String version) {
    final parts = version.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final major = parts.isNotEmpty ? parts[0] : 0;
    final minor = parts.length > 1 ? parts[1] : 0;
    final patch = parts.length > 2 ? parts[2] : 0;
    return major * 10000 + minor * 100 + patch;
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
