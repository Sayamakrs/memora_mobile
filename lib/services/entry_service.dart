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

  Future<List<int>> getMarkedDates(int year, int month) async {
    try {
      print('➡️ Manggil endpoint: /entries/$year/$month');
      final response = await apiClient.get('/entries/$year/$month');
      print('📥 Raw response: $response');

      final responseData = response['data'] as Map<String, dynamic>? ?? {};
      print('📦 responseData: $responseData');

      final markedDates = responseData['marked_dates'] as List<dynamic>? ?? [];
      print('🗓 markedDates (raw): $markedDates');

      final result = markedDates.map((item) {
        if (item is int) return item;
        return int.tryParse(item.toString()) ?? 0;
      }).toList();

      print('✅ markedDates (parsed): $result');
      return result;
    } catch (e, stackTrace) {
      print('❌ Error getMarkedDates: $e');
      print('🔍 StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<Entry>> getEntriesByDate(int year, int month, int date) async {
    try {
      print('➡️ Manggil endpoint: /entries/$year/$month/$date');
      final response = await apiClient.get('/entries/$year/$month/$date');
      print('📥 Raw response: $response');

      final responseData = response['data'] as Map<String, dynamic>? ?? {};
      print('📦 responseData: $responseData');

      final entriesList = responseData['entries'] as List<dynamic>? ?? [];
      print('📝 entriesList (raw): $entriesList');

      final result = entriesList
          .map((item) => Entry.fromJson(item as Map<String, dynamic>))
          .toList();

      print('✅ entriesList (parsed): $result');
      return result;
    } catch (e, stackTrace) {
      print('❌ Error getEntriesByDate: $e');
      print('🔍 StackTrace: $stackTrace');
      return [];
    }
  }
}
