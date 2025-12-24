import 'package:flutter_riverpod_clean_architecture/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/domain/repositories/chat_repository.dart';

class ObserveMessagesUseCase {
  final ChatRepository _repository;

  ObserveMessagesUseCase(this._repository);

  Stream<MessageEntity> call() {
    return _repository.getMessages();
  }
}
