import '../../domain/entities/ai_entities.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.isUser,
    required super.timestamp,
    super.isMedicalDisclaimer,
  });

  factory ChatMessageModel.fromDomain(ChatMessage msg) {
    return ChatMessageModel(
      id: msg.id,
      text: msg.text,
      isUser: msg.isUser,
      timestamp: msg.timestamp,
      isMedicalDisclaimer: msg.isMedicalDisclaimer,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      isMedicalDisclaimer: json['isMedicalDisclaimer'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'isMedicalDisclaimer': isMedicalDisclaimer,
      };
}
