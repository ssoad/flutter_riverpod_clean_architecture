import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/domain/entities/message_entity.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final MessageEntity message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe) ...[
              Text(
                message.sender,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeFormat.format(message.timestamp),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isMe
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                      : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
