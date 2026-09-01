import 'package:equatable/equatable.dart';

/// A single entry in the in-app notification feed.
class NotificationItemEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool isRead;
  final String? channel;
  final String? action;

  const NotificationItemEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
    this.channel,
    this.action,
  });

  NotificationItemEntity copyWith({bool? isRead}) {
    return NotificationItemEntity(
      id: id,
      title: title,
      body: body,
      receivedAt: receivedAt,
      isRead: isRead ?? this.isRead,
      channel: channel,
      action: action,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    receivedAt,
    isRead,
    channel,
    action,
  ];
}
