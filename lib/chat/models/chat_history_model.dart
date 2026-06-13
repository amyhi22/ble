import 'package:flutter/material.dart';

enum MessageRole { user, assistant }

class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLiked;
  final bool isDisliked;
  final List<String>? attachments;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLiked = false,
    this.isDisliked = false,
    this.attachments,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isLiked,
    bool? isDisliked,
    List<String>? attachments,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
      attachments: attachments ?? this.attachments,
    );
  }
}

class ChatConversation {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  DateTime lastModified;
  final bool isPinned;

  ChatConversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.lastModified,
    this.isPinned = false,
  });

  ChatConversation copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastModified,
    bool? isPinned,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

enum ConversationGroup { today, yesterday, previous7Days, older }

extension ConversationGroupExtension on ConversationGroup {
  String get displayName {
    switch (this) {
      case ConversationGroup.today:
        return 'اليوم';
      case ConversationGroup.yesterday:
        return 'أمس';
      case ConversationGroup.previous7Days:
        return 'آخر 7 أيام';
      case ConversationGroup.older:
        return 'محادثات أقدم';
    }
  }
}