import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_item_entity.dart';

class NotificationItemModel extends NotificationItemEntity {
  const NotificationItemModel({
    required super.id,
    required super.title,
    required super.body,
    required super.receivedAt,
    super.isRead,
    super.channel,
    super.action,
  });

  factory NotificationItemModel.fromEntity(NotificationItemEntity entity) {
    return NotificationItemModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      receivedAt: entity.receivedAt,
      isRead: entity.isRead,
      channel: entity.channel,
      action: entity.action,
    );
  }

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      channel: json['channel'] as String?,
      action: json['action'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'receivedAt': receivedAt.toIso8601String(),
      'isRead': isRead,
      'channel': channel,
      'action': action,
    };
  }

  NotificationItemEntity toEntity() => this;
}
