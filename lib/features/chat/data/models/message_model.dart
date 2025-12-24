import 'package:flutter_riverpod_clean_architecture/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.text,
    required super.sender,
    required super.timestamp,
    required super.isMe,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? DateTime.now().toIso8601String(),
      text: json['text'] as String,
      sender: json['sender'] as String? ?? 'Server',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isMe: false,
    );
  }

  factory MessageModel.fromText(String text) {
    return MessageModel(
      id: DateTime.now().toIso8601String(),
      text: text,
      sender: 'Server',
      timestamp: DateTime.now(),
      isMe: false,
    );
  }
}
