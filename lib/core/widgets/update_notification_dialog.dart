import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_update_service.dart';
import '../theme/app_colors.dart';

class UpdateNotificationDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;

  const UpdateNotificationDialog({
    super.key,
    required this.updateInfo,
  });

  @override
  State<UpdateNotificationDialog> createState() => _UpdateNotificationDialogState();
}

class _UpdateNotificationDialogState extends State<UpdateNotificationDialog> {
  bool _isDownloading = false;

  Future<void> _downloadUpdate() async {
    final url = widget.updateInfo.downloadUrl;
    if (url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No download URL available for this release.')),
        );
      }
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try with external non-browser application
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open download link: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => _isDownloading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusCard)),
      backgroundColor: Colors.white,
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.system_update_rounded, color: Colors.black, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Update Available! 🎉',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        'Version ${widget.updateInfo.latestVersion}',
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              "What's New:",
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: SingleChildScrollView(
                child: Text(
                  widget.updateInfo.releaseNotes,
                  style: GoogleFonts.outfit(fontSize: 12, height: 1.4, color: const Color(0xFF222222), fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Source badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 4),
                    Text(
                      'Verified from GitHub Releases',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF2E7D32)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_isDownloading) ...[
              const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Opening download link...',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  if (!widget.updateInfo.isMandatory)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusButton)),
                          side: const BorderSide(color: AppColors.divider),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text('Later', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                  if (!widget.updateInfo.isMandatory) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusButton)),
                      ),
                      onPressed: _downloadUpdate,
                      icon: const Icon(Icons.download_rounded, color: Colors.black, size: 18),
                      label: Text('Download APK', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
