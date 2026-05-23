import '../models/app_user.dart';
import '../models/chat.dart';
import '../models/entry.dart';
import '../models/graph_node.dart';

class MockData {
  static final AppUser user = AppUser(
    id: 1,
    name: 'Aulia',
    email: 'm.auliakhairurizqy.s2018@gmail.com',
    avatar: null,
    aliases: const ['Aulia', 'Aku', 'Saya'],
  );

  static final List<Entry> entries = [
    Entry(
      id: 1,
      uuid: 'entry-memora-001',
      title: 'Diskusi project Memora',
      content:
          'Hari ini kami membahas pembagian tugas Memora. Bagian web dan AI masih menyiapkan API, sementara mobile perlu fokus membuat UI native Flutter yang siap terhubung ke Laravel nanti.',
      excerpt:
          'Hari ini kami membahas pembagian tugas Memora dan integrasi mobile ke Laravel.',
      emotions: const ['focused', 'curious'],
      isSyncedToGraph: true,
      graphSyncedAt: '2026-05-23T10:20:00Z',
      createdAt: '2026-05-23T10:00:00Z',
      updatedAt: '2026-05-23T10:20:00Z',
    ),
    Entry(
      id: 2,
      uuid: 'entry-memora-002',
      title: 'Rencana UI mobile',
      content:
          'Aku ingin tampilan mobile tetap mirip dengan web Memora: clean, soft, rounded, ada gradient halus, dan tombol seperti kartu yang terasa interaktif.',
      excerpt:
          'Aku ingin tampilan mobile tetap mirip dengan web Memora: clean dan soft.',
      emotions: const ['calm', 'motivated'],
      isSyncedToGraph: false,
      graphSyncedAt: null,
      createdAt: '2026-05-22T14:00:00Z',
      updatedAt: '2026-05-22T14:00:00Z',
    ),
  ];

  static int _entryId = 3;
  static int _chatId = 3;

  static List<Entry> getEntries() => List<Entry>.from(entries);

  static Entry getEntry(String uuid) {
    return entries.firstWhere(
      (entry) => entry.uuid == uuid,
      orElse: () => entries.first,
    );
  }

  static Entry createEntry({
    required String title,
    required String content,
  }) {
    final now = DateTime.now().toIso8601String();

    final entry = Entry(
      id: _entryId,
      uuid: 'entry-mock-${_entryId.toString().padLeft(3, '0')}',
      title: title.isEmpty ? 'Untitled Entry' : title,
      content: content,
      excerpt: content.length > 90 ? '${content.substring(0, 90)}...' : content,
      emotions: const ['reflective'],
      isSyncedToGraph: false,
      graphSyncedAt: null,
      createdAt: now,
      updatedAt: now,
    );

    _entryId++;
    entries.insert(0, entry);

    return entry;
  }

  static Entry updateEntry({
    required String uuid,
    required String title,
    required String content,
  }) {
    final index = entries.indexWhere((entry) => entry.uuid == uuid);

    if (index == -1) {
      return createEntry(title: title, content: content);
    }

    final old = entries[index];

    final updated = Entry(
      id: old.id,
      uuid: old.uuid,
      title: title.isEmpty ? 'Untitled Entry' : title,
      content: content,
      excerpt: content.length > 90 ? '${content.substring(0, 90)}...' : content,
      emotions: old.emotions,
      isSyncedToGraph: old.isSyncedToGraph,
      graphSyncedAt: old.graphSyncedAt,
      createdAt: old.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );

    entries[index] = updated;

    return updated;
  }

  static void deleteEntry(String uuid) {
    entries.removeWhere((entry) => entry.uuid == uuid);
  }

  static Entry syncGraph(String uuid) {
    final old = getEntry(uuid);
    final index = entries.indexWhere((entry) => entry.uuid == uuid);

    final synced = Entry(
      id: old.id,
      uuid: old.uuid,
      title: old.title,
      content: old.content,
      excerpt: old.excerpt,
      emotions: old.emotions,
      isSyncedToGraph: true,
      graphSyncedAt: DateTime.now().toIso8601String(),
      createdAt: old.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );

    if (index != -1) {
      entries[index] = synced;
    }

    return synced;
  }

  static Chat createChat(String message) {
    final chat = Chat(
      id: _chatId,
      uuid: 'chat-mock-${_chatId.toString().padLeft(3, '0')}',
      title: 'Reflection with Kaori',
      messages: [
        ChatMessage(
          id: 1,
          role: 'user',
          content: message,
          createdAt: DateTime.now().toIso8601String(),
        ),
        ChatMessage(
          id: 2,
          role: 'assistant',
          content:
              'Aku menangkap beberapa konteks dari ceritamu. Untuk sementara ini masih dummy response, nanti bagian ini akan mengambil jawaban dari Laravel API yang meneruskan konteks ke Kaori.',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ],
    );

    _chatId++;

    return chat;
  }

  static Chat sendMessage({
    required Chat chat,
    required String message,
  }) {
    final messages = List<ChatMessage>.from(chat.messages)
      ..add(
        ChatMessage(
          id: chat.messages.length + 1,
          role: 'user',
          content: message,
          createdAt: DateTime.now().toIso8601String(),
        ),
      )
      ..add(
        ChatMessage(
          id: chat.messages.length + 2,
          role: 'assistant',
          content:
              'Noted. Nanti saat API siap, pesan ini akan dikirim ke endpoint chat Laravel dan dijawab berdasarkan journal serta graph personal user.',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

    return Chat(
      id: chat.id,
      uuid: chat.uuid,
      title: chat.title,
      messages: messages,
    );
  }

  static GraphNode graphTree(String entryUuid) {
    final entry = getEntry(entryUuid);

    return GraphNode(
      type: 'Entry',
      label: entry.title,
      uuid: entry.uuid,
      children: [
        GraphNode(
          type: 'Event',
          label: 'Mengerjakan mobile Memora',
          uuid: null,
          children: [
            GraphNode(
              type: 'EmotionState',
              label: entry.emotions.isNotEmpty ? entry.emotions.first : 'focused',
              uuid: null,
              children: const [],
            ),
            GraphNode(
              type: 'Person',
              label: 'Tim Memora',
              uuid: null,
              children: const [],
            ),
          ],
        ),
      ],
    );
  }
}