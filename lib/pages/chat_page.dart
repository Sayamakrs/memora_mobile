import 'package:flutter/material.dart';

import '../main.dart';
import '../models/chat.dart';
import '../widgets/memora_shell.dart';
import '../widgets/soft_card.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Chat? activeChat;
  bool isSending = false;

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    final message = messageController.text.trim();

    if (message.isEmpty || isSending) return;

    messageController.clear();
    setState(() => isSending = true);

    try {
      final service = AppDependencies.of(context).chatService;

      final chat = activeChat == null
          ? await service.createChat(message)
          : await service.sendMessage(
              chatUuid: activeChat!.uuid,
              message: message,
            );

      if (!mounted) return;

      setState(() {
        activeChat = chat;
      });

      await Future.delayed(const Duration(milliseconds: 80));

      if (!mounted) return;

      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim pesan.')),
      );
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = activeChat?.messages ?? [];

    return MemoraShell(
      title: 'Kaori',
      subtitle: 'Your AI memory companion',
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 2),
          child: MemoraPill(
            label: 'Mock',
            icon: Icons.circle,
            color: Color(0xFF10B981),
          ),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _EmptyChat(
                    onPromptTap: (text) {
                      messageController.text = text;
                      sendMessage();
                    },
                  )
                : MemoraContent(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return _ChatBubble(message: messages[index]);
                      },
                    ),
                  ),
          ),
          _ChatInput(
            controller: messageController,
            isSending: isSending,
            onSend: sendMessage,
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final ValueChanged<String> onPromptTap;

  const _EmptyChat({
    required this.onPromptTap,
  });

  @override
  Widget build(BuildContext context) {
    final prompts = [
      'Bantu aku merefleksikan jurnal hari ini.',
      'Apa pola emosi yang sering muncul?',
      'Ringkas memori penting minggu ini.',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
      children: [
        MemoraContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MemoraPill(
                label: 'KAORI AI',
                icon: Icons.auto_awesome_rounded,
                color: MemoraColors.primary,
              ),
              const SizedBox(height: 18),
              const Text(
                "What's on your mind?",
                style: TextStyle(
                  fontSize: 38,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.7,
                  color: MemoraColors.text,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kaori is ready to listen and help you map your thoughts. Later, the response will use Laravel API and your memory graph.',
                style: TextStyle(
                  color: MemoraColors.body,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Try asking',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                  color: MemoraColors.text,
                ),
              ),
              const SizedBox(height: 14),
              ...prompts.map(
                (prompt) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SoftCard(
                    onTap: () => onPromptTap(prompt),
                    padding: const EdgeInsets.all(18),
                    radius: 30,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: MemoraColors.softPurple,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: MemoraColors.primary,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            prompt,
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w800,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFCBD5E1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({
    required this.message,
  });

  bool get isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 14,
        left: isUser ? 52 : 0,
        right: isUser ? 0 : 52,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: MemoraColors.softPurple,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: MemoraColors.primary,
                size: 19,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: isUser ? MemoraColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: Radius.circular(isUser ? 22 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 22),
                ),
                border: isUser ? null : Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.065),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF334155),
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
          ),
        ),
      ),
      child: MemoraContent(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: MemoraColors.background,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Ask Kaori...',
                    hintStyle: TextStyle(
                      color: MemoraColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: isSending ? null : onSend,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: MemoraColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: MemoraColors.primary.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: isSending
                    ? const Padding(
                        padding: EdgeInsets.all(15),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}