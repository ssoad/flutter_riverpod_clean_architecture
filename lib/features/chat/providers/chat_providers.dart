import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/domain/usecases/observe_messages_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/domain/usecases/send_message_use_case.dart';

/// Data layer dependency injection providers
/// These providers are responsible for creating and managing data layer instances

// --- Data Source ---
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSourceImpl();
});

// --- Repository ---
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(chatRemoteDataSourceProvider));
});

// --- Use Cases ---
final observeMessagesUseCaseProvider = Provider<ObserveMessagesUseCase>((ref) {
  return ObserveMessagesUseCase(ref.watch(chatRepositoryProvider));
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});
