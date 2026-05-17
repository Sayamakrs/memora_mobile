class ChatMessage {
  final int id;
  final String role;
  final String content;
  final String? createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      role: json['role'] ?? 'assistant',
      content: json['content'] ?? '',
      createdAt: json['created_at'],
    );
  }
}

class Chat {
  final int id;
  final String uuid;
  final String title;
  final List<ChatMessage> messages;

  Chat({
    required this.id,
    required this.uuid,
    required this.title,
    required this.messages,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? 'New Chat',
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((item) => ChatMessage.fromJson(item))
          .toList(),
    );
  }
}