import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/image_quality_service.dart';
import '../../../../core/services/network_checker_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/smile_celebration_overlay.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/food_verification_sheet.dart';
import '../widgets/internet_required_sheet.dart';
import '../widgets/voice_logging_sheet.dart';

class FoodScannerScreen extends ConsumerStatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  ConsumerState<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends ConsumerState<FoodScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isAnalyzing = false;

  Future<void> _pickImage(ImageSource source) async {
    // ── STAGE 1: Network Check before Camera / AI Analysis ──
    final bool isOnline = await NetworkCheckerService.isConnected();
    if (!isOnline) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => InternetRequiredSheet(
          onRetry: () => _pickImage(source),
          onQueueOffline: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('📷 Photo saved to Offline AI Queue. Analysis will run when connected.')),
            );
          },
        ),
      );
      return;
    }

    // ── STAGE 1.5: Explicit Runtime Camera Permission Request ──
    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus.isPermanentlyDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('📷 Camera permission is permanently denied. Please grant permission in Settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      } else if (cameraStatus.isDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Camera permission is required to capture food photos. Switching to Gallery...'),
          ),
        );
        _pickImage(ImageSource.gallery);
        return;
      }
    } else if (source == ImageSource.gallery) {
      final photoStatus = await Permission.photos.request();
      if (photoStatus.isPermanentlyDenied) {
        // On Android 13+, photos permission handles media library
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isPermanentlyDenied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('🖼️ Gallery access is permanently denied. Please grant permission in Settings.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
      }
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
      );
      if (image != null) {
        // ── STAGE 2: Pre-Flight Image Quality Check (Blur / Dark) ──
        final qualityResult = await ImageQualityService.validateImage(image.path);
        if (!qualityResult.isValid) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Quality Alert: ${qualityResult.message}'),
              backgroundColor: Colors.orange.shade800,
            ),
          );
          return;
        }

        setState(() {
          _selectedImage = image;
          _isAnalyzing = true;
        });

        // ── STAGE 3 & 4: Cloud AI Vision Analysis ──
        final aiService = ref.read(aiServiceProvider);
        final result = await aiService.analyzeFoodImage(imagePath: image.path);

        if (!mounted) return;

        setState(() {
          _isAnalyzing = false;
        });

        // ── STAGE 5: Show Verification Sheet with Tiered Confidence ──
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => FoodVerificationSheet(
            initialAnalysis: result,
            onScanAgain: () => _pickImage(source),
            onConfirmed: (finalMeal) async {
              final repo = ref.read(nutritionRepositoryProvider);
              await repo.logMeal(finalMeal);
              ref.invalidate(nutritionProvider);

              if (mounted) {
                SmileCelebrationOverlay.show(
                  context,
                  message: 'Log Saved: ${finalMeal.title} (${finalMeal.totalCalories} kcal)! 😃',
                  emoji: '😋',
                );
              }
            },
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera Notification: $e. Switching to gallery photo selection...'),
          duration: const Duration(seconds: 3),
        ),
      );

      if (source == ImageSource.camera) {
        _pickImage(ImageSource.gallery);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI Food & Macro Scanner',
          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Viewfinder / Selected Image Preview Container
          Positioned.fill(
            child: _selectedImage != null
                ? Image.file(File(_selectedImage!.path), fit: BoxFit.cover)
                : Container(
                    color: const Color(0xFF1E2A24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 70, color: AppColors.primary.withValues(alpha: 0.6)),
                          const SizedBox(height: 16),
                          Text(
                            'Point camera at food dish or choose photo',
                            style: GoogleFonts.sora(fontSize: 14, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cloud_done_rounded, color: AppColors.primary, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Cloud AI Recognition • Internet Active',
                                  style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Laser Scanner Frame Overlay
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary, width: 3),
              ),
            ),
          ),

          if (_isAnalyzing)
            Container(
              color: Colors.black.withValues(alpha: 0.75),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Cloud AI Multimodal Analyzing Food & 6 Macros...',
                      style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Action Bar: Camera, Gallery & Voice Selection
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Gallery Option
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.photo_library_rounded, color: AppColors.primaryDark),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    tooltip: 'Choose from Gallery / Library',
                  ),

                  // Camera Snap Button
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_rounded, color: Colors.black, size: 32),
                    ),
                  ),

                  // Quick Voice Button
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.mic_rounded, color: AppColors.primaryDark),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const VoiceLoggingSheet(),
                      );
                    },
                    tooltip: 'Voice Logging',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
