import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String text;
  final String sender;
  final DateTime timestamp;
  final bool isMe;

  const MessageEntity({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.isMe,
  });

  @override
  List<Object?> get props => [id, text, sender, timestamp, isMe];
}
