import '../../features/profile/domain/entities/health_enums.dart';
import '../../features/profile/domain/entities/user_profile.dart';

/// AI-computed personalized health plan based on user's profile, goals,
/// health conditions, and physical capabilities.
class PersonalizedPlan {
  final int dailyCalories;
  final int dailyProteinGrams;
  final int dailyCarbsGrams;
  final int dailyFatGrams;
  final int dailyFiberGrams;
  final int dailyWaterMl;
  final int dailyStepGoal;
  final int sleepGoalMinutes;
  final String idealSleepTime;
  final String idealWakeTime;
  final List<String> exerciseRecommendations;
  final List<String> avoidedExercises;
  final String workoutPlanSummary;
  final String aiExplanation;

  const PersonalizedPlan({
    required this.dailyCalories,
    required this.dailyProteinGrams,
    required this.dailyCarbsGrams,
    required this.dailyFatGrams,
    required this.dailyFiberGrams,
    required this.dailyWaterMl,
    required this.dailyStepGoal,
    required this.sleepGoalMinutes,
    required this.idealSleepTime,
    required this.idealWakeTime,
    required this.exerciseRecommendations,
    required this.avoidedExercises,
    required this.workoutPlanSummary,
    required this.aiExplanation,
  });
}

/// The brain of the application. Computes personalized health plans
/// using Mifflin-St Jeor BMR, TDEE, goal-specific macro splits,
/// and health-condition-aware exercise filtering.
class AIReasoningEngine {
  const AIReasoningEngine._();

  /// Generate a fully personalized plan from user profile.
  static PersonalizedPlan generatePlan(UserProfile profile) {
    // ─── Step 1: Calculate BMR (Mifflin-St Jeor) ───
    final double bmr;
    if (profile.gender == Gender.female) {
      bmr = 10 * profile.weightKg + 6.25 * profile.heightCm - 5 * profile.age - 161;
    } else {
      bmr = 10 * profile.weightKg + 6.25 * profile.heightCm - 5 * profile.age + 5;
    }

    // ─── Step 2: Calculate TDEE ───
    final double activityMultiplier = switch (profile.activityLevel) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.lightlyActive => 1.375,
      ActivityLevel.moderatelyActive => 1.55,
      ActivityLevel.veryActive => 1.725,
    };
    final double tdee = bmr * activityMultiplier;

    // ─── Step 3: Goal-specific calorie adjustment ───
    final int dailyCalories = switch (profile.primaryGoal) {
      HealthGoal.buildMuscle => (tdee + 300).round(),
      HealthGoal.loseFat => (tdee - 500).round(),
      HealthGoal.weightGain => (tdee + 400).round(),
      HealthGoal.stayFit => tdee.round(),
      HealthGoal.improveHealth => tdee.round(),
      HealthGoal.seniorCitizenMode => (tdee - 100).round(),
    };

    // ─── Step 4: Goal-specific protein ───
    final double proteinPerKg = switch (profile.primaryGoal) {
      HealthGoal.buildMuscle => 2.0,
      HealthGoal.weightGain => 1.8,
      HealthGoal.loseFat => 1.6,
      HealthGoal.stayFit => 1.2,
      HealthGoal.improveHealth => 1.0,
      HealthGoal.seniorCitizenMode => 1.2,
    };
    final int dailyProtein = (profile.weightKg * proteinPerKg).round();

    // ─── Step 5: Fat (25-30% of calories) ───
    final int dailyFat = (dailyCalories * 0.27 / 9).round();

    // ─── Step 6: Carbs (remaining) ───
    final int proteinCals = dailyProtein * 4;
    final int fatCals = dailyFat * 9;
    final int dailyCarbs = ((dailyCalories - proteinCals - fatCals) / 4).round().clamp(50, 600);

    // ─── Step 7: Fiber ───
    final int dailyFiber = dailyCalories > 2200 ? 35 : 25;

    // ─── Step 8: Water (35ml/kg, +500 if very active) ───
    int dailyWater = (profile.weightKg * 35).round();
    if (profile.activityLevel == ActivityLevel.veryActive) dailyWater += 500;

    // ─── Step 9: Step goal ───
    final int dailySteps = switch (profile.primaryGoal) {
      HealthGoal.loseFat => 12000,
      HealthGoal.stayFit => 10000,
      HealthGoal.buildMuscle => 8000,
      HealthGoal.weightGain => 7000,
      HealthGoal.improveHealth => 8000,
      HealthGoal.seniorCitizenMode => 5000,
    };

    // ─── Step 10: Sleep ───
    int sleepMinutes;
    if (profile.age >= 65) {
      sleepMinutes = 420; // 7 hrs
    } else if (profile.primaryGoal == HealthGoal.buildMuscle) {
      sleepMinutes = 510; // 8.5 hrs for muscle recovery
    } else {
      sleepMinutes = 480; // 8 hrs
    }

    String wakeTime = profile.idealWakeTime ?? '06:00';
    String sleepTime = _calculateSleepTime(wakeTime, sleepMinutes);

    // ─── Step 11: Exercise recommendations (health-condition-aware) ───
    final exerciseRecs = <String>[];
    final avoidedExercises = <String>[];
    final conditions = profile.healthConditions;
    final caps = profile.capabilities;

    // Start with all capabilities, then filter by health conditions
    if (conditions.contains(HealthCondition.kneePain)) {
      avoidedExercises.add('Running — avoided due to knee pain, high impact stress on joints');
      avoidedExercises.add('Jumping exercises — avoided due to knee condition');
      if (caps.contains(ActivityCapability.walking)) exerciseRecs.add('Brisk Walking (30-45 min)');
      if (caps.contains(ActivityCapability.cycling)) exerciseRecs.add('Cycling (low impact, 30 min)');
      if (caps.contains(ActivityCapability.swimming)) exerciseRecs.add('Swimming (excellent for joint-friendly cardio)');
      if (caps.contains(ActivityCapability.yoga)) exerciseRecs.add('Chair Yoga & Gentle Stretching');
      if (caps.contains(ActivityCapability.gym)) exerciseRecs.add('Upper Body Strength Training (seated)');
    } else if (conditions.contains(HealthCondition.backPain)) {
      avoidedExercises.add('Heavy Deadlifts — avoided due to back pain');
      avoidedExercises.add('Heavy Squats — reduced intensity for back safety');
      if (caps.contains(ActivityCapability.yoga)) exerciseRecs.add('Yoga for Back Health (Cat-Cow, Child Pose)');
      if (caps.contains(ActivityCapability.swimming)) exerciseRecs.add('Swimming (therapeutic for back)');
      if (caps.contains(ActivityCapability.stretching)) exerciseRecs.add('Stretching & Mobility Work');
      if (caps.contains(ActivityCapability.walking)) exerciseRecs.add('Walking (30 min daily)');
      if (caps.contains(ActivityCapability.gym)) exerciseRecs.add('Light Resistance Training (machines)');
    } else if (conditions.contains(HealthCondition.heartCondition)) {
      avoidedExercises.add('HIIT — avoided due to heart condition');
      avoidedExercises.add('Heavy Lifting — avoided for cardiovascular safety');
      if (caps.contains(ActivityCapability.walking)) exerciseRecs.add('Gentle Walking (20-30 min)');
      if (caps.contains(ActivityCapability.yoga)) exerciseRecs.add('Restorative Yoga');
      if (caps.contains(ActivityCapability.stretching)) exerciseRecs.add('Light Stretching');
    } else if (conditions.contains(HealthCondition.highBP)) {
      avoidedExercises.add('Heavy Isometric Holds — may spike blood pressure');
      avoidedExercises.add('Heavy Overhead Presses — risky with high BP');
      if (caps.contains(ActivityCapability.walking)) exerciseRecs.add('Brisk Walking (40 min)');
      if (caps.contains(ActivityCapability.swimming)) exerciseRecs.add('Swimming (excellent for BP management)');
      if (caps.contains(ActivityCapability.yoga)) exerciseRecs.add('Yoga (avoid inversions)');
      if (caps.contains(ActivityCapability.cycling)) exerciseRecs.add('Moderate Cycling');
    } else {
      // No limiting conditions — full recommendations
      if (caps.contains(ActivityCapability.gym)) exerciseRecs.add('Strength Training (Progressive Overload)');
      if (caps.contains(ActivityCapability.running)) exerciseRecs.add('Running / Jogging (30 min)');
      if (caps.contains(ActivityCapability.walking)) exerciseRecs.add('Brisk Walking (45 min)');
      if (caps.contains(ActivityCapability.cycling)) exerciseRecs.add('Cycling (30-45 min)');
      if (caps.contains(ActivityCapability.yoga)) exerciseRecs.add('Yoga & Flexibility');
      if (caps.contains(ActivityCapability.swimming)) exerciseRecs.add('Swimming (30 min)');
      if (caps.contains(ActivityCapability.homeWorkout)) exerciseRecs.add('Home Bodyweight Circuit');
      if (caps.contains(ActivityCapability.sports)) exerciseRecs.add('Sports (Badminton, Cricket, etc.)');
      if (caps.contains(ActivityCapability.dance)) exerciseRecs.add('Dance Fitness (30 min)');
      if (caps.contains(ActivityCapability.stretching)) exerciseRecs.add('Stretching & Cool Down');
    }

    if (exerciseRecs.isEmpty) {
      exerciseRecs.add('Walking (20-30 min daily)');
    }

    // ─── Step 12: Workout plan summary ───
    final workoutPlan = _getWorkoutPlan(profile.primaryGoal, caps, conditions);

    // ─── Step 13: AI explanation ───
    final explanation = _buildExplanation(
      profile: profile,
      dailyCalories: dailyCalories,
      dailyProtein: dailyProtein,
      bmr: bmr,
      tdee: tdee,
      avoidedExercises: avoidedExercises,
    );

    return PersonalizedPlan(
      dailyCalories: dailyCalories,
      dailyProteinGrams: dailyProtein,
      dailyCarbsGrams: dailyCarbs,
      dailyFatGrams: dailyFat,
      dailyFiberGrams: dailyFiber,
      dailyWaterMl: dailyWater,
      dailyStepGoal: dailySteps,
      sleepGoalMinutes: sleepMinutes,
      idealSleepTime: sleepTime,
      idealWakeTime: wakeTime,
      exerciseRecommendations: exerciseRecs,
      avoidedExercises: avoidedExercises,
      workoutPlanSummary: workoutPlan,
      aiExplanation: explanation,
    );
  }

  /// Compute compensatory actions when the user deviates from plan.
  static String rebalanceDay({
    required UserProfile profile,
    required int caloriesConsumed,
    required int calorieTarget,
    required int stepsCompleted,
    required int stepTarget,
    required bool workoutDone,
    required String userMessage,
  }) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('couldn\'t exercise') || lower.contains('missed workout') || lower.contains('no workout')) {
      final extraSteps = ((calorieTarget - caloriesConsumed).abs() / 0.05).round().clamp(3000, 10000);
      return 'No problem! To maintain today\'s calorie balance, you can walk ${extraSteps.toStringAsFixed(0)} extra steps this evening. '
          'Alternatively, reduce dinner calories by ${(calorieTarget * 0.15).round()} kcal.';
    }

    if (lower.contains('walked instead') || lower.contains('walk instead')) {
      return 'That\'s perfectly fine! A 45-minute brisk walk burns approximately 200-250 calories. '
          'Today\'s workout has been replaced by your walk. Keep moving!';
    }

    if (lower.contains('extra') || lower.contains('ate more') || lower.contains('overate') || lower.contains('biryani')) {
      final surplus = 650; // Estimated typical surplus
      return 'You consumed approximately $surplus extra calories. To balance today\'s intake, you can:\n\n'
          '• Walk 8 km (~10,000 steps)\n'
          '• OR Cycle for 50 minutes\n'
          '• OR Reduce dinner calories by ${(surplus * 0.6).round()} kcal\n\n'
          'Remember: one day doesn\'t define your journey. Stay consistent!';
    }

    if (lower.contains('tired') || lower.contains('exhausted') || lower.contains('fatigue') || lower.contains('थकवा')) {
      return 'I understand you\'re feeling tired. Here\'s what I recommend:\n\n'
          '• Reduce today\'s workout intensity by 40%\n'
          '• Focus on stretching and mobility (15 min)\n'
          '• Increase water intake by 500ml\n'
          '• Get to bed 30 minutes earlier tonight\n'
          '• Tomorrow\'s plan will be auto-adjusted for recovery';
    }

    if (lower.contains('what should i eat') || lower.contains('dinner') || lower.contains('lunch') || lower.contains('काय खाऊ')) {
      final remainingCal = calorieTarget - caloriesConsumed;
      final remainingProtein = profile.dailyProteinGoalGrams - (caloriesConsumed ~/ 15); // rough estimate
      return 'Based on your remaining targets:\n\n'
          '• Calories left: $remainingCal kcal\n'
          '• Protein needed: ~${remainingProtein.clamp(0, 200)}g\n\n'
          'I recommend a protein-rich meal within your regional preferences. '
          'Check the Meal Suggestions tab for curated options!';
    }

    // Generic response with awareness
    final calorieGap = calorieTarget - caloriesConsumed;
    final stepGap = stepTarget - stepsCompleted;
    return 'Here\'s your current status:\n\n'
        '• Calories: ${caloriesConsumed}/${calorieTarget} kcal (${calorieGap > 0 ? "$calorieGap remaining" : "target reached!"})\n'
        '• Steps: ${stepsCompleted}/${stepTarget} (${stepGap > 0 ? "$stepGap to go" : "goal met!"})\n'
        '• Workout: ${workoutDone ? "Completed ✅" : "Pending"}\n\n'
        'How can I help adjust your plan?';
  }

  // ─── Private helpers ───

  static String _calculateSleepTime(String wakeTime, int sleepMinutes) {
    final parts = wakeTime.split(':');
    final wakeHour = int.tryParse(parts[0]) ?? 6;
    final wakeMin = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final totalWakeMinutes = wakeHour * 60 + wakeMin;
    var sleepAt = totalWakeMinutes - sleepMinutes;
    if (sleepAt < 0) sleepAt += 1440; // wrap around midnight
    final h = (sleepAt ~/ 60).toString().padLeft(2, '0');
    final m = (sleepAt % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String _getWorkoutPlan(HealthGoal goal, Set<ActivityCapability> caps, Set<HealthCondition> conditions) {
    final hasGym = caps.contains(ActivityCapability.gym);
    final hasHome = caps.contains(ActivityCapability.homeWorkout);

    if (goal == HealthGoal.seniorCitizenMode) {
      return 'Daily: Walking 30 min + Stretching 15 min + Balance Exercises 10 min (5 days/week)';
    }

    return switch (goal) {
      HealthGoal.buildMuscle when hasGym => 'Push/Pull/Legs Split (4-5 days/week) with Progressive Overload',
      HealthGoal.buildMuscle when hasHome => 'Full Body Bodyweight Training (4 days/week) with Progressive Difficulty',
      HealthGoal.buildMuscle => 'Resistance Training 4x/week using available equipment',
      HealthGoal.loseFat => 'Walking 45 min + Light Strength 3x/week + HIIT 2x/week',
      HealthGoal.weightGain when hasGym => 'Compound Lifts 4x/week (Squat, Bench, Deadlift, OHP) + Recovery',
      HealthGoal.weightGain => 'Strength Training 4x/week focusing on compound movements',
      HealthGoal.stayFit => 'Balanced: Walking 30 min daily + Strength 2x/week + Yoga 2x/week',
      HealthGoal.improveHealth => 'Low Impact: Walking 30 min + Yoga 3x/week + Light Cardio 2x/week',
      HealthGoal.seniorCitizenMode => 'Daily: Walking 30 min + Stretching 15 min + Balance Exercises',
    };
  }

  static String _buildExplanation({
    required UserProfile profile,
    required int dailyCalories,
    required int dailyProtein,
    required double bmr,
    required double tdee,
    required List<String> avoidedExercises,
  }) {
    final buf = StringBuffer();

    buf.write('Based on your profile (${profile.age} years, ${profile.gender.name}, '
        '${profile.heightCm} cm, ${profile.weightKg} kg), your Basal Metabolic Rate is '
        '${bmr.round()} kcal and your Total Daily Energy Expenditure is ${tdee.round()} kcal. ');

    buf.write(switch (profile.primaryGoal) {
      HealthGoal.buildMuscle => 'For muscle building, I\'ve added a +300 kcal surplus and set protein at 2.0g per kg body weight to support muscle protein synthesis and recovery. ',
      HealthGoal.loseFat => 'For sustainable fat loss, I\'ve created a -500 kcal deficit with elevated protein (1.6g/kg) to preserve lean muscle while losing body fat. ',
      HealthGoal.weightGain => 'For healthy weight gain, I\'ve added a +400 kcal surplus with high protein (1.8g/kg) to ensure muscle gain over fat storage. ',
      HealthGoal.stayFit => 'For general fitness maintenance, your calories match your TDEE with balanced macros to keep you energized and healthy. ',
      HealthGoal.improveHealth => 'For health improvement, I\'ve prioritized balanced nutrition with adequate protein and fiber, along with joint-friendly activities. ',
      HealthGoal.seniorCitizenMode => 'For senior wellness, I\'ve focused on adequate protein (1.2g/kg) for muscle preservation, gentle activities, and prioritized hydration and mobility. ',
    });

    if (avoidedExercises.isNotEmpty) {
      buf.write('I\'ve excluded certain exercises based on your health conditions: ');
      buf.write(avoidedExercises.map((e) => e.split(' — ').first).join(', '));
      buf.write('. ');
    }

    if (profile.hasDiabetes) {
      buf.write('With diabetes, I recommend balanced meals with low glycemic index foods and avoiding sugar spikes. ');
    }

    buf.write('This plan is designed specifically for YOUR body and lifestyle. Adjust as needed through the AI Chat.');

    return buf.toString();
  }
}
