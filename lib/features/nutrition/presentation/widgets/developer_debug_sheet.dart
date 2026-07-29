import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/theme/app_colors.dart';

class DeveloperDebugSheet extends StatelessWidget {
  final AiAnalysisTelemetry? telemetry;
  final MealAnalysisResult analysis;

  const DeveloperDebugSheet({
    super.key,
    required this.telemetry,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final tel = telemetry;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF141E18),
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
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.bug_report_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              Text(
                'Developer Pipeline Debug Panel',
                style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _debugRow('API Key Loaded', tel?.apiKeyLoaded == true ? 'Yes (Verified)' : 'No'),
                _debugRow('Internet Connection', tel?.isOnline == true ? 'Connected' : 'Offline'),
                _debugRow('Image Resolution', tel?.imageResolution ?? '1080p JPEG'),
                _debugRow('Image File Size', tel != null ? '${(tel.imageSizeBytes / 1024).round()} KB' : 'Unknown'),
                _debugRow('Vision Model Used', tel?.visionModel ?? 'gpt-4o-mini'),
                _debugRow('Confidence Score', '${(analysis.confidenceScore * 100).toInt()}%'),
                _debugRow('Nutrition Source', tel?.nutritionSource ?? 'OpenAI Vision'),
                _debugRow('Database Calibration', tel?.fallbackUsed == true ? 'Calibrated from Database' : 'Direct AI Estimation'),
                _debugRow('Total Latency', tel != null ? '${tel.totalLatencyMs} ms' : 'N/A'),
                _debugRow('Network Response Time', tel != null ? '${tel.networkLatencyMs} ms' : 'N/A'),
                const SizedBox(height: 14),
                Text(
                  'Raw OpenAI JSON Payload:',
                  style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      tel?.rawJsonResponse ?? 'No raw payload available',
                      style: GoogleFonts.firaCode(fontSize: 10.5, color: Colors.greenAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Close Debug Panel', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _debugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.sora(fontSize: 12, color: Colors.white70),
          ),
          Text(
            value,
            style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
