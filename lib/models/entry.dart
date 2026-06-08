class Entry {
  final int id;
  final String uuid;
  final String title;
  final String content;
  final String excerpt;
  final List<String> emotions;
  final bool isSyncedToGraph;
  final String? graphSyncedAt;
  final String? syncStatus;
  final String? createdAt;
  final String? updatedAt;

  Entry({
    required this.id,
    required this.uuid,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.emotions,
    required this.isSyncedToGraph,
    required this.graphSyncedAt,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    String stripHtml(String value) {
      return value
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .trim();
    }

    final rawContent = json['content']?.toString() ?? '';
    final rawExcerpt = json['excerpt']?.toString() ?? '';

    return Entry(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? 'Untitled Entry',
      content: stripHtml(rawContent),
      excerpt: stripHtml(rawExcerpt.isNotEmpty ? rawExcerpt : rawContent),
      emotions: (json['emotions'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      isSyncedToGraph: json['is_synced_to_graph'] ?? false,
      graphSyncedAt: json['graph_synced_at'],
      syncStatus: json['sync_status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
