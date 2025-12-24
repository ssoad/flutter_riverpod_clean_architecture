import 'dart:async';
import 'package:flutter_riverpod_clean_architecture/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Stream<MessageEntity> getMessages() {
    // Ensure we are connected when asking for messages
    _remoteDataSource.connect();
    return _remoteDataSource.messages; // MessageModel extends MessageEntity
  }

  @override
  Future<void> sendMessage(String text) async {
    await _remoteDataSource.sendMessage(text);
  }

  @override
  void dispose() {
    _remoteDataSource.disconnect();
  }
}
