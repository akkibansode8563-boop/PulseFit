import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/ai_reasoning_engine.dart';
import '../../../profile/domain/entities/health_enums.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/ai_entities.dart';
import '../../domain/repositories/i_ai_coach_repository.dart';
import '../models/ai_models.dart';

class AICoachRepositoryImpl implements IAICoachRepository {
  UserProfile? _userProfile = const UserProfile(
    id: 'test_user',
    name: 'Alex',
    age: 28,
    gender: Gender.male,
    heightCm: 175,
    weightKg: 74.5,
    primaryGoal: HealthGoal.buildMuscle,
    dailyCalorieGoal: 2400,
    dailyProteinGoalGrams: 160,
    dailyWaterGoalMl: 3200,
    sleepGoalMinutes: 480,
    isOnboardingComplete: true,
  );

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
  }

  final List<ChatMessageModel> _chatHistory = [
    ChatMessageModel(
      id: 'msg_0',
      text: '⚠️ Disclaimer: AI Health Manager guidance is for general wellness & fitness coaching only. It does not replace professional medical advice, diagnosis, or treatment.',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      isMedicalDisclaimer: true,
    ),
  ];

  List<ProactiveInsight> _insights = [];

  @override
  Future<Result<List<ChatMessage>>> getChatHistory() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return Result.success(List.unmodifiable(_chatHistory));
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<ChatMessage>> sendMessage(String prompt) async {
    try {
      final userMsg = ChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: prompt,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(userMsg);

      await Future.delayed(const Duration(milliseconds: 500));

      final aiResponseText = _generateContextAwareResponse(prompt);
      final aiMsg = ChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch + 1}',
        text: aiResponseText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(aiMsg);

      // Update proactive insights based on conversation
      _updateInsights();

      return Result.success(aiMsg);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ProactiveInsight>>> getProactiveInsights() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      _updateInsights();
      return Result.success(List.unmodifiable(_insights));
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  /// Context-aware AI response that considers user profile, goal, health conditions.
  String _generateContextAwareResponse(String prompt) {
    final profile = _userProfile;
    final lower = prompt.toLowerCase();

    // Use the reasoning engine for dynamic rebalancing
    if (profile != null) {
      // Check for rebalancing scenarios
      if (lower.contains('couldn\'t exercise') || lower.contains('missed workout') || lower.contains('no workout') ||
          lower.contains('व्यायाम नाही')) {
        return AIReasoningEngine.rebalanceDay(
          profile: profile,
          caloriesConsumed: 1200,
          calorieTarget: profile.dailyCalorieGoal,
          stepsCompleted: 3000,
          stepTarget: profile.dailyStepGoal,
          workoutDone: false,
          userMessage: prompt,
        );
      }

      if (lower.contains('extra') || lower.contains('ate more') || lower.contains('biryani') ||
          lower.contains('जास्त खाल्लं')) {
        return AIReasoningEngine.rebalanceDay(
          profile: profile,
          caloriesConsumed: profile.dailyCalorieGoal + 650,
          calorieTarget: profile.dailyCalorieGoal,
          stepsCompleted: 4000,
          stepTarget: profile.dailyStepGoal,
          workoutDone: false,
          userMessage: prompt,
        );
      }

      if (lower.contains('walked instead') || lower.contains('walk instead') || lower.contains('चाललो')) {
        return AIReasoningEngine.rebalanceDay(
          profile: profile,
          caloriesConsumed: 1600,
          calorieTarget: profile.dailyCalorieGoal,
          stepsCompleted: 8000,
          stepTarget: profile.dailyStepGoal,
          workoutDone: false,
          userMessage: prompt,
        );
      }

      if (lower.contains('tired') || lower.contains('exhausted') || lower.contains('थकलो') || lower.contains('थकवा')) {
        return AIReasoningEngine.rebalanceDay(
          profile: profile,
          caloriesConsumed: 1400,
          calorieTarget: profile.dailyCalorieGoal,
          stepsCompleted: 5000,
          stepTarget: profile.dailyStepGoal,
          workoutDone: false,
          userMessage: prompt,
        );
      }

      if (lower.contains('what should i eat') || lower.contains('काय खाऊ') || lower.contains('dinner') || lower.contains('जेवण')) {
        return AIReasoningEngine.rebalanceDay(
          profile: profile,
          caloriesConsumed: 1200,
          calorieTarget: profile.dailyCalorieGoal,
          stepsCompleted: 6000,
          stepTarget: profile.dailyStepGoal,
          workoutDone: true,
          userMessage: prompt,
        );
      }
    }

    // Goal-specific responses
    if (lower.contains('protein') || lower.contains('macro') || lower.contains('food') || lower.contains('प्रोटीन')) {
      final target = profile?.dailyProteinGoalGrams ?? 120;
      return 'Based on your goal, your daily protein target is ${target}g. '
          'For your weight (${profile?.weightKg ?? 70}kg), aim for protein-rich meals throughout the day. '
          'Try including eggs, paneer, dal, chicken, or whey protein in each meal.';
    }

    if (lower.contains('sleep') || lower.contains('recovery') || lower.contains('rest') || lower.contains('झोप')) {
      final sleepTarget = profile?.sleepGoalMinutes ?? 480;
      final bedtime = profile?.idealSleepTime ?? '23:00';
      return 'Your sleep target is ${sleepTarget ~/ 60} hours. '
          'For optimal recovery and ${_goalName(profile?.primaryGoal)}, try to sleep by $bedtime. '
          'Quality sleep directly impacts muscle recovery, fat loss, and overall health.';
    }

    if (lower.contains('workout') || lower.contains('exercise') || lower.contains('training') || lower.contains('व्यायाम')) {
      final plan = profile?.workoutPlanSummary ?? 'Balanced exercise routine';
      return 'Your personalized workout plan: $plan\n\n'
          'This is designed based on your goal (${_goalName(profile?.primaryGoal)}) '
          'and your physical capabilities. Would you like me to adjust it?';
    }

    if (lower.contains('status') || lower.contains('progress') || lower.contains('how am i') || lower.contains('कसं चाललंय')) {
      return 'Here\'s your personalized daily plan summary:\n\n'
          '• Calories: ${profile?.dailyCalorieGoal ?? 2000} kcal\n'
          '• Protein: ${profile?.dailyProteinGoalGrams ?? 60}g\n'
          '• Water: ${(profile?.dailyWaterGoalMl ?? 2500) / 1000}L\n'
          '• Steps: ${profile?.dailyStepGoal ?? 8000}\n'
          '• Sleep: ${(profile?.sleepGoalMinutes ?? 480) ~/ 60} hrs\n\n'
          'Keep tracking your meals and activity to stay on course!';
    }

    // Default contextual greeting
    final name = profile?.name ?? 'there';
    final goal = _goalName(profile?.primaryGoal);
    return 'Hey $name! I\'m monitoring your health metrics, nutrition, hydration, and sleep — '
        'all aligned with your $goal goal. How can I help adjust your plan today?';
  }

  String _goalName(HealthGoal? goal) => switch (goal) {
        HealthGoal.buildMuscle => 'Build Muscle',
        HealthGoal.loseFat => 'Fat Loss',
        HealthGoal.stayFit => 'Stay Fit',
        HealthGoal.improveHealth => 'Health Improvement',
        HealthGoal.seniorCitizenMode => 'Senior Wellness',
        HealthGoal.weightGain => 'Weight Gain',
        null => 'wellness',
      };

  void _updateInsights() {
    final profile = _userProfile;
    if (profile == null) {
      _insights = const [
        ProactiveInsight(id: 'ins_1', title: 'Complete Onboarding', recommendation: 'Set up your profile to get personalized insights.', priority: InsightPriority.high, category: 'Setup'),
      ];
      return;
    }

    _insights = [
      ProactiveInsight(
        id: 'ins_cal',
        title: '🔥 Calorie Target',
        recommendation: 'Your daily target is ${profile.dailyCalorieGoal} kcal for ${_goalName(profile.primaryGoal)}.',
        priority: InsightPriority.high,
        category: 'Nutrition',
      ),
      ProactiveInsight(
        id: 'ins_protein',
        title: '💪 Protein Goal',
        recommendation: 'Aim for ${profile.dailyProteinGoalGrams}g protein (${(profile.dailyProteinGoalGrams / profile.weightKg).toStringAsFixed(1)}g/kg).',
        priority: InsightPriority.medium,
        category: 'Nutrition',
      ),
      ProactiveInsight(
        id: 'ins_water',
        title: '💧 Hydration',
        recommendation: 'Drink ${(profile.dailyWaterGoalMl / 1000).toStringAsFixed(1)}L water today.',
        priority: InsightPriority.medium,
        category: 'Water',
      ),
      if (profile.idealSleepTime != null)
        ProactiveInsight(
          id: 'ins_sleep',
          title: '🌙 Sleep by ${profile.idealSleepTime}',
          recommendation: 'For ${(profile.sleepGoalMinutes / 60).toStringAsFixed(1)} hrs of quality rest.',
          priority: InsightPriority.high,
          category: 'Sleep',
        ),
    ];
  }
}
