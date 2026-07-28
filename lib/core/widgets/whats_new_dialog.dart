import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/live_ota_sync_engine.dart';
import '../theme/app_colors.dart';

class WhatsNewDialog extends StatelessWidget {
  final OtaPayloadInfo payload;

  const WhatsNewDialog({
    super.key,
    required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8FD36B), Color(0xFF5B9A54)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Features Synced! 🚀',
                        style: GoogleFonts.sora(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Version ${payload.syncVersion} • Live OTA Auto-Sync',
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5B9A54),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              "What's New in PulseFit:",
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // Feature Highlights Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMint,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: payload.newFeatures.map((feat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      feat,
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Got It Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Got It! Enjoy Features ⚡',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
