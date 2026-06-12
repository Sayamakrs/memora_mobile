import '../core/api_client.dart';
import '../models/chat.dart';

class ChatService {
  final ApiClient apiClient;

  ChatService({
    required this.apiClient,
  });

  /// Daftar SESSION chat (riwayat). Endpoint GET /chats sudah mengembalikan
  /// chat lengkap dengan messages-nya, latest first.
  Future<List<Chat>> getChats() async {
    final data = await apiClient.get('/chats');

    return (data['chats'] as List<dynamic>? ?? [])
        .map((item) => Chat.fromJson(item))
        .toList();
  }

  /// Ambil 1 session chat lengkap (GET /chats/{uuid}).
  Future<Chat> getChat(String chatUuid) async {
    final data = await apiClient.get('/chats/$chatUuid');
    return Chat.fromJson(data['chat']);
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
