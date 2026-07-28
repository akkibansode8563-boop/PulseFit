import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/domain/entities/health_enums.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../data/repositories/ai_coach_repository_impl.dart';
import '../../domain/entities/ai_entities.dart';

final aiCoachRepositoryProvider = Provider<AICoachRepositoryImpl>((ref) {
  return AICoachRepositoryImpl();
});

class AICoachState {
  final List<ChatMessage> messages;
  final List<ProactiveInsight> insights;
  final bool isThinking;

  const AICoachState({
    required this.messages,
    required this.insights,
    this.isThinking = false,
  });

  AICoachState copyWith({
    List<ChatMessage>? messages,
    List<ProactiveInsight>? insights,
    bool? isThinking,
  }) {
    return AICoachState(
      messages: messages ?? this.messages,
      insights: insights ?? this.insights,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}

class AICoachNotifier extends AsyncNotifier<AICoachState> {
  @override
  FutureOr<AICoachState> build() async {
    final repo = ref.watch(aiCoachRepositoryProvider);

    // Inject user profile into the AI coach for context-aware responses
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.valueOrNull;
    if (profile != null) {
      repo.setUserProfile(profile);
    }

    final historyRes = await repo.getChatHistory();
    final insightsRes = await repo.getProactiveInsights();

    // Add personalized greeting if onboarding is complete
    final messages = historyRes.data ?? [];

    return AICoachState(
      messages: messages,
      insights: insightsRes.data ?? [],
    );
  }

  Future<void> sendUserPrompt(String prompt) async {
    if (prompt.trim().isEmpty) return;
    final repo = ref.read(aiCoachRepositoryProvider);

    // Ensure profile is injected
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile != null) {
      repo.setUserProfile(profile);
    }

    final currentVal = state.valueOrNull;
    if (currentVal != null) {
      state = AsyncValue.data(currentVal.copyWith(isThinking: true));
    }

    await repo.sendMessage(prompt);
    final updatedHistory = await repo.getChatHistory();
    final updatedInsights = await repo.getProactiveInsights();

    state = AsyncValue.data(
      AICoachState(
        messages: updatedHistory.data ?? [],
        insights: updatedInsights.data ?? [],
        isThinking: false,
      ),
    );
  }
}

final aiCoachProvider = AsyncNotifierProvider<AICoachNotifier, AICoachState>(
  AICoachNotifier.new,
);

/// Goal-aware quick prompt suggestions
List<String> getGoalAwarePrompts(HealthGoal? goal) {
  return switch (goal) {
    HealthGoal.buildMuscle => ['Am I eating enough protein?', 'Adjust my macros', 'Recommend workout', 'I missed my workout'],
    HealthGoal.loseFat => ['How many steps left?', 'I ate extra today', 'Can I eat this?', 'Reduce today\'s target'],
    HealthGoal.stayFit => ['Show my status', 'What should I eat?', 'Recommend light exercise', 'Adjust my plan'],
    HealthGoal.improveHealth => ['Is my BP diet correct?', 'Safe exercises for today', 'Sugar-friendly snacks', 'How\'s my progress?'],
    HealthGoal.seniorCitizenMode => ['Easy exercises today', 'Am I drinking enough water?', 'Safe walking duration', 'Sleep advice'],
    HealthGoal.weightGain => ['Am I eating enough?', 'Calorie surplus check', 'Best muscle foods', 'When to eat more?'],
    null => ['Analyze my sleep', 'Adjust my macros', 'Recommend workout'],
  };
}
