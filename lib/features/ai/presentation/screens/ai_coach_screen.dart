import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/ai_entities.dart';
import '../providers/ai_coach_provider.dart';

class AICoachScreen extends ConsumerWidget {
  const AICoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiStateAsync = ref.watch(aiCoachProvider);
    final textController = TextEditingController();
    final profile = ref.watch(profileProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.mintBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mintBackground,
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.lightTextPrimary),
            const SizedBox(width: 8),
            Text('AI Health Coach', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
          ],
        ),
      ),
      body: aiStateAsync.when(
        data: (state) => Column(
          children: [
            if (state.insights.isNotEmpty) _buildInsightCarousel(state.insights),
            Expanded(child: _buildChatTimeline(state.messages, state.isThinking)),
            _buildQuickPromptChips(ref, profile?.primaryGoal),
            _buildInputArea(context, ref, textController),
          ],
        ),
        loading: () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: const [
              LoadingShimmer(height: 100),
              SizedBox(height: 16),
              LoadingShimmer(height: 150),
              SizedBox(height: 16),
              LoadingShimmer(height: 200),
            ],
          ),
        ),
        error: (err, stack) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(aiCoachProvider),
        ),
      ),
    );
  }

  Widget _buildInsightCarousel(List<ProactiveInsight> insights) {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: insights.length,
        itemBuilder: (context, index) {
          final item = insights[index];
          return Card(
            color: const Color(0xFFC7F09D),
            margin: const EdgeInsets.only(right: 12),
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: AppColors.lightTextPrimary, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.outfit(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.recommendation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(color: AppColors.lightTextSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatTimeline(List<ChatMessage> messages, bool isThinking) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (isThinking ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isThinking) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: AppColors.mintPrimary, radius: 14, child: const Icon(Icons.auto_awesome, size: 14, color: AppColors.lightTextPrimary)),
                const SizedBox(width: 8),
                Text('AI is thinking...', style: GoogleFonts.outfit(color: AppColors.lightTextSecondary, fontStyle: FontStyle.italic)),
              ],
            ),
          );
        }

        final msg = messages[index];
        if (msg.isMedicalDisclaimer) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEDCB6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
            ),
            child: Text(msg.text, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600)),
          );
        }

        return Align(
          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: msg.isUser ? AppColors.mintPrimary : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              msg.text,
              style: GoogleFonts.outfit(
                color: AppColors.lightTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickPromptChips(WidgetRef ref, dynamic goal) {
    final prompts = getGoalAwarePrompts(goal);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: prompts.map((prompt) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ActionChip(
            label: Text(prompt, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
            backgroundColor: const Color(0xFFEAF7E2),
            onPressed: () => ref.read(aiCoachProvider.notifier).sendUserPrompt(prompt),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, WidgetRef ref, TextEditingController controller) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        color: AppColors.mintBackground,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: GoogleFonts.outfit(color: AppColors.lightTextPrimary),
                decoration: InputDecoration(
                  hintText: 'Ask AI Health Coach...',
                  hintStyle: GoogleFonts.outfit(color: AppColors.lightTextSecondary),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: AppColors.mintPrimary),
              icon: const Icon(Icons.send, color: AppColors.lightTextPrimary),
              onPressed: () {
                final text = controller.text;
                controller.clear();
                ref.read(aiCoachProvider.notifier).sendUserPrompt(text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
