import '../../domain/entities/reminder_entities.dart';

class PersistentReminderModel extends PersistentReminder {
  const PersistentReminderModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    required super.timestamp,
    super.isDismissed,
    required super.actionLabel,
  });

  factory PersistentReminderModel.fromDomain(PersistentReminder domain) {
    return PersistentReminderModel(
      id: domain.id,
      type: domain.type,
      title: domain.title,
      message: domain.message,
      timestamp: domain.timestamp,
      isDismissed: domain.isDismissed,
      actionLabel: domain.actionLabel,
    );
  }

  factory PersistentReminderModel.fromJson(Map<String, dynamic> json) {
    return PersistentReminderModel(
      id: json['id'] as String,
      type: ReminderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReminderType.water,
      ),
      title: json['title'] as String? ?? 'Reminder',
      message: json['message'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      isDismissed: json['isDismissed'] as bool? ?? false,
      actionLabel: json['actionLabel'] as String? ?? 'Log Now',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'isDismissed': isDismissed,
        'actionLabel': actionLabel,
      };
}
