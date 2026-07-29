import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/theme/app_colors.dart';

class AiErrorSheet extends StatelessWidget {
  final AiAnalysisException exception;
  final VoidCallback onRetry;
  final VoidCallback? onSelectGallery;

  const AiErrorSheet({
    super.key,
    required this.exception,
    required this.onRetry,
    this.onSelectGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  exception.isNetworkError
                      ? Icons.wifi_off_rounded
                      : exception.isApiKeyError
                          ? Icons.key_off_rounded
                          : exception.isQuotaError
                              ? Icons.hourglass_bottom_rounded
                              : exception.isServerError
                                  ? Icons.cloud_off_rounded
                                  : Icons.center_focus_weak_rounded,
                  color: Colors.red.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI could not analyse the image',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      exception.isNetworkError
                          ? 'Network Connectivity Issue'
                          : exception.isApiKeyError
                              ? 'API Configuration Issue'
                              : exception.isQuotaError
                                  ? 'OpenAI Quota Exceeded'
                                  : exception.isServerError
                                      ? 'OpenAI Service Unavailable'
                                      : 'Low Vision Recognition Quality',
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason:',
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exception.message,
                  style: GoogleFonts.sora(
                    fontSize: 12.5,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                if (exception.technicalDetails != null &&
                    exception.technicalDetails!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Details: ${exception.technicalDetails}',
                    style: GoogleFonts.sora(
                      fontSize: 10.5,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (onSelectGallery != null)
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onSelectGallery!();
                    },
                    icon: const Icon(Icons.photo_library_rounded, size: 18, color: Colors.black),
                    label: Text(
                      'Gallery',
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              if (onSelectGallery != null) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onRetry();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                  label: Text(
                    'Retry Scan',
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
