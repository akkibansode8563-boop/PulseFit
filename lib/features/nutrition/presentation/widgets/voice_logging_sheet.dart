import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/nutrition_provider.dart';

class VoiceLoggingSheet extends ConsumerStatefulWidget {
  const VoiceLoggingSheet({super.key});

  @override
  ConsumerState<VoiceLoggingSheet> createState() => _VoiceLoggingSheetState();
}

class _VoiceLoggingSheetState extends ConsumerState<VoiceLoggingSheet> {
  bool _isListening = false;
  String _recognizedText = '';
  Timer? _simulatedListeningTimer;

  final List<String> _samplePromptsMr = [
    'मी १ प्लेट कांदा पोहे खाल्ले',
    '२ थालीपीठ आणि १ कप ताजे दही',
    '१ वाटी पिठलं भाकरी आणि सोलकढी',
    '१ वाटी मटकी उसळ आणि २ चपाती',
  ];

  final List<String> _samplePromptsEn = [
    'I ate 1 plate Kanda Poha',
    '2 Thalipeeth with 1 cup Curd',
    '1 bowl Pithla Bhakri with Solkadhi',
    '1 bowl Matki Usal and 2 Chapatis',
  ];

  void _startListening(String initialText) {
    setState(() {
      _isListening = true;
      _recognizedText = initialText;
    });

    _simulatedListeningTimer?.cancel();
    _simulatedListeningTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isListening = false);
      }
    });
  }

  @override
  void dispose() {
    _simulatedListeningTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = ref.watch(localeProvider.notifier).isMarathi;
    final prompts = isMarathi ? _samplePromptsMr : _samplePromptsEn;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppColors.radiusBottomSheet)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Text(
            isMarathi ? '🎙️ आवाज संदेशातून अन्न नोंदवा' : '🎙️ Log Meal via Voice Command',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            isMarathi ? 'माईकवर क्लिक करा किंवा खालीलपैकी एक पर्याय निवडा' : 'Tap mic to speak or pick a Maharashtrian dish prompt below',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: const Color(0xFF222222), fontSize: 13),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _startListening(prompts[0]),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: _isListening ? AppColors.accent : AppColors.primary,
              child: const Icon(Icons.mic, color: Colors.black, size: 36),
            ).animate(target: _isListening ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 400.ms).shimmer(color: Colors.black12),
          ),
          const SizedBox(height: 16),
          Text(
            _isListening
                ? (isMarathi ? 'ऐकत आहे...' : 'Listening...')
                : (_recognizedText.isEmpty ? (isMarathi ? 'माईक दाबा...' : 'Tap Mic to start...') : _recognizedText),
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prompts
                .map((p) => ActionChip(
                      label: Text(p, style: GoogleFonts.outfit(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600)),
                      backgroundColor: AppColors.surface,
                      onPressed: () => _startListening(p),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _recognizedText.isEmpty
                  ? null
                  : () async {
                      await ref.read(nutritionProvider.notifier).analyzeAndAddMealText(_recognizedText);
                      if (context.mounted) Navigator.pop(context);
                    },
              child: Text(
                isMarathi ? 'अन्न नोंदवा' : 'Log Voice Meal',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
