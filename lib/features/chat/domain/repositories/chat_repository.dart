import 'package:flutter_riverpod_clean_architecture/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Stream<MessageEntity> getMessages();
  Future<void> sendMessage(String text);
  void dispose();
}
