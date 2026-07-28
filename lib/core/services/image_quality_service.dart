import 'dart:io';

enum ImageQualityStatus { valid, tooBlurry, tooDark, invalidFile }

class ImageQualityResult {
  final ImageQualityStatus status;
  final String message;

  const ImageQualityResult({
    required this.status,
    required this.message,
  });

  bool get isValid => status == ImageQualityStatus.valid;
}

class ImageQualityService {
  /// Pre-flight validation for food images before sending to Cloud AI
  static Future<ImageQualityResult> validateImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      return const ImageQualityResult(
        status: ImageQualityStatus.invalidFile,
        message: 'Image file does not exist or was deleted.',
      );
    }

    final length = await file.length();
    if (length < 1024) { // Less than 1 KB
      return const ImageQualityResult(
        status: ImageQualityStatus.tooBlurry,
        message: 'Image is too small or corrupt. Please retake photo.',
      );
    }

    // Basic heuristic validation for file integrity
    return const ImageQualityResult(
      status: ImageQualityStatus.valid,
      message: 'Image quality check passed.',
    );
  }
}
