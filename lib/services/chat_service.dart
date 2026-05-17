import '../core/api_client.dart';
import '../models/chat.dart';

class ChatService {
  final ApiClient apiClient;

  ChatService({
    required this.apiClient,
  });

  Future<List<Chat>> getChats() async {
    final data = await apiClient.get('/chats');

    return (data['chats'] as List<dynamic>? ?? [])
        .map((item) => Chat.fromJson(item))
        .toList();
  }

  Future<Chat> createChat(String message) async {
    final data = await apiClient.post(
      '/chats',
      body: {
        'message': message,
      },
    );

    return Chat.fromJson(data['chat']);
  }

  Future<Chat> sendMessage({
    required String chatUuid,
    required String message,
  }) async {
    final data = await apiClient.post(
      '/chats/$chatUuid/messages',
      body: {
        'message': message,
      },
    );

    return Chat.fromJson(data['chat']);
  }
}