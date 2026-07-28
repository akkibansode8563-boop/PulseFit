import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/smile_celebration_overlay.dart';
import '../providers/nutrition_provider.dart';

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
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _isAnalyzing = true;
        });

        // Simulate AI Nutrition Scanner & Regional Dish Analysis
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        setState(() {
          _isAnalyzing = false;
        });

        // Trigger Smile Celebration Toast!
        SmileCelebrationOverlay.show(
          context,
          message: 'Scanned Kanda Poha & Salad (260 kcal, 7g Protein)! 😃',
          emoji: '😋',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to access camera/gallery: $e')),
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
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'AI Analyzing Food Dish & Macros...',
                      style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Action Bar: Camera & Gallery / Library Selection
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
                      SmileCelebrationOverlay.show(
                        context,
                        message: 'Voice Logging Activated! 😃',
                        emoji: '🎙️',
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
