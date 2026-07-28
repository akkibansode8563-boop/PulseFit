import 'package:flutter/material.dart';

@immutable
class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final double progress; // 0.0 to 1.0
  final DateTime? unlockedAt;

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.progress = 0.0,
    this.unlockedAt,
  });

  static List<AchievementBadge> get defaultBadges => const [
        AchievementBadge(
          id: 'hydration_hero',
          title: 'Hydration Hero',
          description: 'Log 2,000ml water for 7 days in a row',
          icon: '💧',
          isUnlocked: true,
          progress: 1.0,
        ),
        AchievementBadge(
          id: 'meal_master',
          title: 'Meal Master',
          description: 'Scan & log 20 regional Maharashtrian & Indian meals',
          icon: '🥗',
          isUnlocked: true,
          progress: 1.0,
        ),
        AchievementBadge(
          id: 'protein_pro',
          title: 'Protein Pro',
          description: 'Hit 100g daily protein target',
          icon: '🥩',
          isUnlocked: false,
          progress: 0.75,
        ),
        AchievementBadge(
          id: '7_day_streak',
          title: '7 Day Streak',
          description: 'Active Health Tracking for 7 consecutive days',
          icon: '🔥',
          isUnlocked: true,
          progress: 1.0,
        ),
        AchievementBadge(
          id: '30_day_streak',
          title: '30 Day Streak',
          description: 'Active Health Tracking for 30 consecutive days',
          icon: '🏆',
          isUnlocked: false,
          progress: 0.40,
        ),
        AchievementBadge(
          id: 'morning_warrior',
          title: 'Morning Warrior',
          description: 'Complete workout before 8:00 AM',
          icon: '🌅',
          isUnlocked: true,
          progress: 1.0,
        ),
        AchievementBadge(
          id: 'fitness_explorer',
          title: 'Fitness Explorer',
          description: 'Use Nutrition, Water, Sleep, Workout & AI Coach',
          icon: '🚀',
          isUnlocked: true,
          progress: 1.0,
        ),
        AchievementBadge(
          id: 'pulsefit_champion',
          title: 'PulseFit Champion',
          description: 'Achieve 100% daily vitality ring score',
          icon: '👑',
          isUnlocked: false,
          progress: 0.85,
        ),
      ];
}
