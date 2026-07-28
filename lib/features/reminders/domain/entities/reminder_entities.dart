import 'package:flutter/foundation.dart';

enum ReminderType { water, wakeUp, sleep, medicine }

@immutable
class PersistentReminder {
  final String id;
  final ReminderType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isDismissed;
  final String actionLabel;

  const PersistentReminder({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isDismissed = false,
    required this.actionLabel,
  });

  PersistentReminder copyWith({
    bool? isDismissed,
  }) {
    return PersistentReminder(
      id: id,
      type: type,
      title: title,
      message: message,
      timestamp: timestamp,
      isDismissed: isDismissed ?? this.isDismissed,
      actionLabel: actionLabel,
    );
  }
}
