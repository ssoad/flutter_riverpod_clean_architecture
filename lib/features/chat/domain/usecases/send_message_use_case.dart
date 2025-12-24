import 'package:flutter_riverpod_clean_architecture/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<void> call(String text) {
    return _repository.sendMessage(text);
  }
}
