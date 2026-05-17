import '../core/api_client.dart';
import '../models/entry.dart';

class EntryService {
  final ApiClient apiClient;

  EntryService({
    required this.apiClient,
  });

  Future<List<Entry>> getEntries() async {
    final data = await apiClient.get('/entries');

    return (data['entries'] as List<dynamic>? ?? [])
        .map((item) => Entry.fromJson(item))
        .toList();
  }

  Future<Entry> createEntry({
    required String title,
    required String content,
  }) async {
    final data = await apiClient.post(
      '/entries',
      body: {
        'title': title,
        'content': content,
      },
    );

    return Entry.fromJson(data['entry']);
  }

  Future<Entry> getEntry(String uuid) async {
    final data = await apiClient.get('/entries/$uuid');
    return Entry.fromJson(data['entry']);
  }

  Future<Entry> updateEntry({
    required String uuid,
    required String title,
    required String content,
  }) async {
    final data = await apiClient.patch(
      '/entries/$uuid',
      body: {
        'title': title,
        'content': content,
      },
    );

    return Entry.fromJson(data['entry']);
  }

  Future<void> deleteEntry(String uuid) async {
    await apiClient.delete('/entries/$uuid');
  }

  Future<Entry> syncGraph(String uuid) async {
    final data = await apiClient.post('/entries/$uuid/sync-graph');
    return Entry.fromJson(data['entry']);
  }
}