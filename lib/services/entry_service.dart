import '../config/app_config.dart';
import '../core/api_client.dart';
import '../core/mock_data.dart';
import '../models/entry.dart';

class EntryService {
  final ApiClient apiClient;

  EntryService({
    required this.apiClient,
  });

  Future<List<Entry>> getEntries() async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return MockData.getEntries();
    }

    final data = await apiClient.get('/entries');

    return (data['entries'] as List<dynamic>? ?? [])
        .map((item) => Entry.fromJson(item))
        .toList();
  }

  Future<Entry> createEntry({
    required String title,
    required String content,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return MockData.createEntry(title: title, content: content);
    }

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
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return MockData.getEntry(uuid);
    }

    final data = await apiClient.get('/entries/$uuid');
    return Entry.fromJson(data['entry']);
  }

  Future<Entry> updateEntry({
    required String uuid,
    required String title,
    required String content,
  }) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return MockData.updateEntry(
        uuid: uuid,
        title: title,
        content: content,
      );
    }

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
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 150));
      MockData.deleteEntry(uuid);
      return;
    }

    await apiClient.delete('/entries/$uuid');
  }

  Future<Entry> syncGraph(String uuid) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 650));
      return MockData.syncGraph(uuid);
    }

    final data = await apiClient.post('/entries/$uuid/sync-graph');
    return Entry.fromJson(data['entry']);
  }
}