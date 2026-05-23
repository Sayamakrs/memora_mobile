import '../config/app_config.dart';
import '../core/api_client.dart';
import '../core/mock_data.dart';
import '../models/chat.dart';

class ChatService {
  final ApiClient apiClient;
  Chat? _activeMockChat;

  ChatService({
    required this.apiClient,
  });

  Future<List<Chat>> getChats() async {
    if (AppConfig.useMockData) {
      return _activeMockChat == null ? [] : [_activeMockChat!];
    }

    final data = await apiClient.get('/chats');

    return (data['chats'] as List<dynamic>? ?? [])
        .map((item) => Chat.fromJson(item))
        .toList();
  }

  Future<Chat> createChat(String message) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 450));
      _activeMockChat = MockData.createChat(message);
      return _activeMockChat!;
    }

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
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 450));

      _activeMockChat ??= MockData.createChat(message);
      _activeMockChat = MockData.sendMessage(
        chat: _activeMockChat!,
        message: message,
      );

      return _activeMockChat!;
    }

    final data = await apiClient.post(
      '/chats/$chatUuid/messages',
      body: {
        'message': message,
      },
    );

    return Chat.fromJson(data['chat']);
  }
}