import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/domain/usecases/observe_messages_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/domain/usecases/send_message_use_case.dart';

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

// --- State Management ---
class ChatState {
  final List<MessageEntity> messages;
  final bool isConnected;

  const ChatState({this.messages = const [], this.isConnected = false});

  ChatState copyWith({List<MessageEntity>? messages, bool? isConnected}) {
    return ChatState(
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  late final ObserveMessagesUseCase _observeMessages;
  late final SendMessageUseCase _sendMessage;

  @override
  ChatState build() {
    _observeMessages = ref.read(observeMessagesUseCaseProvider);
    _sendMessage = ref.read(sendMessageUseCaseProvider);

    // Auto-connect and listen
    _listenToMessages();

    return const ChatState(isConnected: true);
  }

  void _listenToMessages() {
    // In a real app, manage subscription carefully
    _observeMessages().listen((message) {
      state = state.copyWith(messages: [...state.messages, message]);
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    // Optimistic Update: Add my message immediately
    final myMessage = MessageEntity(
      id: DateTime.now().toIso8601String(),
      text: text,
      sender: 'Me',
      timestamp: DateTime.now(),
      isMe: true,
    );

    state = state.copyWith(messages: [...state.messages, myMessage]);

    // Send to server
    await _sendMessage(text);
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
