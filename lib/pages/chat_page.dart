import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../main.dart';
import '../models/chat.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  /// Daftar session chat (riwayat) di drawer.
  List<Chat> sessions = [];

  /// Session yang sedang dibuka beserta messages-nya.
  Chat? activeChat;

  bool isLoadingSessions = true;
  bool isLoadingChat = false;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) loadSessions();
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DATA
  // ---------------------------------------------------------------------------

  Future<void> loadSessions() async {
    setState(() => isLoadingSessions = true);

    try {
      sessions = await AppDependencies.of(context).chatService.getChats();
    } on ApiException catch (error) {
      showMessage(error.message);
    } catch (_) {
      showMessage('Gagal memuat riwayat chat.');
    } finally {
      if (mounted) setState(() => isLoadingSessions = false);
    }
  }

  Future<void> openSession(Chat session) async {
    Navigator.of(context).maybePop(); // tutup drawer

    setState(() {
      isLoadingChat = true;
      activeChat = session; // tampilkan judul dulu
    });

    try {
      final full =
          await AppDependencies.of(context).chatService.getChat(session.uuid);
      if (!mounted) return;
      setState(() => activeChat = full);
      scrollToBottom();
    } on ApiException catch (error) {
      showMessage(error.message);
    } catch (_) {
      showMessage('Gagal membuka percakapan.');
    } finally {
      if (mounted) setState(() => isLoadingChat = false);
    }
  }

  void startNewChat() {
    Navigator.of(context).maybePop();
    setState(() {
      activeChat = null;
      messageController.clear();
    });
  }

  Future<void> sendMessage() async {
    if (isSending) return;

    final message = messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => isSending = true);

    try {
      final chatService = AppDependencies.of(context).chatService;

      if (activeChat == null) {
        activeChat = await chatService.createChat(message);
        await loadSessions(); // session baru -> refresh riwayat
      } else {
        activeChat = await chatService.sendMessage(
          chatUuid: activeChat!.uuid,
          message: message,
        );
      }

      messageController.clear();
      if (mounted) setState(() {});
      scrollToBottom();
    } on ApiException catch (error) {
      showMessage(error.message);
    } catch (_) {
      showMessage('Gagal mengirim pesan. Pastikan backend berjalan.');
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: _buildHistoryDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Text(
          activeChat?.title ?? 'Kaori',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'New Chat',
            onPressed: startNewChat,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildConversation()),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildConversation() {
    if (isLoadingChat) {
      return const Center(child: CircularProgressIndicator());
    }

    final messages = activeChat?.messages ?? [];

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🧠', style: TextStyle(fontSize: 34)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "WHAT'S ON YOUR MIND?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kaori is ready to listen and map your thoughts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: messages.length,
      itemBuilder: (_, index) => ChatBubble(message: messages[index]),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
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
                  hintText: 'Type your reflection here...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
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
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'KAORI AI',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Material(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: startNewChat,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.add_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: isLoadingSessions
                  ? const Center(child: CircularProgressIndicator())
                  : sessions.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Belum ada riwayat chat.\nMulai percakapan baru.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF94A3B8)),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: sessions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, index) {
                            final session = sessions[index];
                            final isActive =
                                session.uuid == activeChat?.uuid;
                            return _SessionTile(
                              title: session.title,
                              isActive: isActive,
                              onTap: () => openSession(session),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _SessionTile({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFEEF2FF) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: isActive
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ),
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
