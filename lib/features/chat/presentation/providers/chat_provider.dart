import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/providers/chat_providers.dart';

/// Presentation layer state management
/// This file contains only UI-related state providers

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
  @override
  ChatState build() {
    // Auto-connect and listen
    _listenToMessages();

    return const ChatState(isConnected: true);
  }

  void _listenToMessages() {
    // In a real app, manage subscription carefully
    final observeMessages = ref.read(observeMessagesUseCaseProvider);
    observeMessages().listen((message) {
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
    final sendMessageUseCase = ref.read(sendMessageUseCaseProvider);
    await sendMessageUseCase(text);
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
