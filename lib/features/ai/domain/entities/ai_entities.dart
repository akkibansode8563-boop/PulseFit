import 'package:flutter/foundation.dart';

@immutable
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isMedicalDisclaimer;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isMedicalDisclaimer = false,
  });
}

enum InsightPriority { high, medium, low }

@immutable
class ProactiveInsight {
  final String id;
  final String title;
  final String recommendation;
  final InsightPriority priority;
  final String category;

  const ProactiveInsight({
    required this.id,
    required this.title,
    required this.recommendation,
    required this.priority,
    required this.category,
  });
}
