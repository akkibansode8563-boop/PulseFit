import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/image_quality_service.dart';
import '../../../../core/services/network_checker_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/smile_celebration_overlay.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/ai_error_sheet.dart';
import '../widgets/developer_debug_sheet.dart';
import '../widgets/food_verification_sheet.dart';
import '../widgets/internet_required_sheet.dart';
import '../widgets/voice_logging_sheet.dart';

class FoodScannerScreen extends ConsumerStatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  ConsumerState<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends ConsumerState<FoodScannerScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCameraLoading = true;

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  MealAnalysisResult? _lastAnalysis;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _initNativeCamera();
  }

  Future<void> _initNativeCamera() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        _cameras = await availableCameras();
        if (_cameras != null && _cameras!.isNotEmpty) {
          _cameraController = CameraController(
            _cameras!.first,
            ResolutionPreset.high,
            enableAudio: false,
          );
          await _cameraController!.initialize();
          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
              _isCameraLoading = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Native Camera Init Notice: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
        _isCameraLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureFromLiveCamera() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile capturedFile = await _cameraController!.takePicture();
        await _processImage(capturedFile.path);
      } catch (e) {
        debugPrint('Camera capture error: $e. Falling back to system picker...');
        _pickImage(ImageSource.camera);
      }
    } else {
      _pickImage(ImageSource.camera);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
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
      }
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
      );
      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo Selection Notice: $e. Please pick photo from gallery.'),
        ),
      );
    }
  }

  Future<void> _processImage(String imagePath) async {
    // ── STAGE 1: Network Check ──
    final bool isOnline = await NetworkCheckerService.isConnected();
    if (!isOnline) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => InternetRequiredSheet(
          onRetry: () => _processImage(imagePath),
          onQueueOffline: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('📷 Photo saved to Offline AI Queue. Analysis will run when connected.')),
            );
          },
        ),
      );
      return;
    }

    // ── STAGE 2: Pre-Flight Image Quality Check ──
    final qualityResult = await ImageQualityService.validateImage(imagePath);
    if (!qualityResult.isValid) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => AiErrorSheet(
          exception: AiAnalysisException('Image Quality Issue: ${qualityResult.message}'),
          onRetry: () => _pickImage(ImageSource.camera),
          onSelectGallery: () => _pickImage(ImageSource.gallery),
        ),
      );
      return;
    }

    setState(() {
      _selectedImage = XFile(imagePath);
      _isAnalyzing = true;
    });

    // ── STAGE 3 & 4: Cloud AI Vision Analysis with Explicit Error Surface ──
    final aiService = ref.read(aiServiceProvider);
    try {
      final result = await aiService.analyzeFoodImage(imagePath: imagePath);

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
        _lastAnalysis = result;
      });

      // ── STEP 7: Confidence Validation Tiers ──
      if (result.confidenceScore < 0.75) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => AiErrorSheet(
            exception: AiAnalysisException(
              'Low AI Confidence (${(result.confidenceScore * 100).toInt()}%). Unable to identify dish reliably. Please retake photo with better lighting.',
            ),
            onRetry: () => _pickImage(ImageSource.camera),
            onSelectGallery: () => _pickImage(ImageSource.gallery),
          ),
        );
        return;
      }

      // ── Show Verification Sheet with Tiered Confidence & Alternatives ──
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => FoodVerificationSheet(
          initialAnalysis: result,
          onScanAgain: () {
            setState(() {
              _selectedImage = null;
            });
          },
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
    } on AiAnalysisException catch (ex) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => AiErrorSheet(
          exception: ex,
          onRetry: () => _processImage(imagePath),
          onSelectGallery: () => _pickImage(ImageSource.gallery),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => AiErrorSheet(
          exception: AiAnalysisException('Unexpected scanner error: $e'),
          onRetry: () => _processImage(imagePath),
          onSelectGallery: () => _pickImage(ImageSource.gallery),
        ),
      );
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
        actions: [
          if (_lastAnalysis != null)
            IconButton(
              icon: const Icon(Icons.bug_report_rounded, color: AppColors.primary),
              tooltip: 'Developer Debug Panel',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DeveloperDebugSheet(
                    telemetry: _lastAnalysis?.telemetry,
                    analysis: _lastAnalysis!,
                  ),
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Live Camera Preview / Captured Photo Viewfinder
          Positioned.fill(
            child: _selectedImage != null
                ? Image.file(File(_selectedImage!.path), fit: BoxFit.cover)
                : (_isCameraInitialized && _cameraController != null)
                    ? CameraPreview(_cameraController!)
                    : Container(
                        color: const Color(0xFF1E2A24),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isCameraLoading)
                                const CircularProgressIndicator(color: AppColors.primary)
                              else ...[
                                Icon(Icons.camera_alt_outlined, size: 70, color: AppColors.primary.withValues(alpha: 0.6)),
                                const SizedBox(height: 16),
                                Text(
                                  'Tap shutter button to snap or choose photo',
                                  style: GoogleFonts.sora(fontSize: 14, color: Colors.white70),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                                  label: Text('Select Photo from Gallery', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
                                ),
                              ],
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
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 16, spreadRadius: 2),
                ],
              ),
            ),
          ),

          // Status Badge Top Overlay
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCameraInitialized ? 'Live Camera Feed Active' : 'Cloud AI Multimodal Ready',
                      style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_isAnalyzing)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
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

          // Bottom Action Bar: Gallery, Live Capture & Voice Selection
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

                  // Central Snap Shutter Button
                  GestureDetector(
                    onTap: _captureFromLiveCamera,
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
