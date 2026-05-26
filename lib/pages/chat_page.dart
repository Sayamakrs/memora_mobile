import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../main.dart';
import '../models/chat.dart';
import '../widgets/memora_shell.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageController = TextEditingController();

  Chat? activeChat;
  bool isSending = false;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
  if (isSending) return;

  final message = messageController.text.trim();

  if (message.isEmpty) return;

  setState(() => isSending = true);

  try {
    if (activeChat == null) {
      activeChat = await AppDependencies.of(context)
          .chatService
          .createChat(message);
    } else {
      activeChat = await AppDependencies.of(context).chatService.sendMessage(
            chatUuid: activeChat!.uuid,
            message: message,
          );
    }

    messageController.clear();

    if (mounted) {
      setState(() {});
    }
  } on ApiException catch (error) {
    showMessage(error.message);
  } catch (_) {
    showMessage('Gagal mengirim pesan. Pastikan backend berjalan.');
  } finally {
    if (mounted) {
      setState(() => isSending = false);
    }
  }
}

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = activeChat?.messages ?? [];

    return MemoraShell(
      title: 'Kaori',
      child: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Tanyakan sesuatu ke Kaori. Response akan dikirim melalui API Laravel.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      final message = messages[index];
                      return ChatBubble(message: message);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'What is on your mind?',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: isSending ? null : sendMessage,
                    icon: isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_upward_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF6366F1) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF0F172A),
            height: 1.45,
          ),
        ),
      ),
    );
  }
}