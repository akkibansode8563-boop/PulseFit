import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  double _progress = 0.0;
  bool _isCompleted = false;

  void _startInAppDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.1;
    });

    // Simulate in-app OTA download & installation
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (mounted) {
        setState(() => _progress = i / 10.0);
      }
    }

    if (mounted) {
      setState(() {
        _isDownloading = false;
        _isCompleted = true;
      });
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
                        'Version ${widget.updateInfo.latestVersion} (Build ${widget.updateInfo.buildNumber})',
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
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                widget.updateInfo.releaseNotes,
                style: GoogleFonts.outfit(fontSize: 12, height: 1.4, color: const Color(0xFF222222), fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),

            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppColors.surface,
                color: AppColors.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Downloading & Installing Update... ${(_progress * 100).toInt()}%',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              const SizedBox(height: 12),
            ] else if (_isCompleted) ...[
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Update Installed Successfully!',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusButton)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Restart App Now', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusButton)),
                      ),
                      onPressed: _startInAppDownload,
                      child: Text('Update Now', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
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
