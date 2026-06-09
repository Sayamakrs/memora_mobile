import 'dart:convert';

import '../core/api_client.dart';
import '../models/graph_node.dart';

class GraphService {
  final ApiClient apiClient;

  /// Payload mentah terakhir dari endpoint graph tree (untuk debugging di UI).
  dynamic lastRaw;

  GraphService({
    required this.apiClient,
  });

  /// Versi raw JSON terbaca (untuk ditampilkan saat debugging).
  String get lastRawPretty {
    try {
      return const JsonEncoder.withIndent('  ').convert(lastRaw);
    } catch (_) {
      return lastRaw?.toString() ?? '(kosong)';
    }
  }

  Future<GraphNode> getTree(String entryUuid) async {
    final data = await apiClient.get('/graph/tree/$entryUuid');
    lastRaw = data;

    dynamic node = data;

    // Kalau Kaori membungkus tree dalam sebuah key, ambil isinya.
    if (node is Map) {
      for (final key in ['tree', 'graph', 'data', 'root', 'result', 'entry']) {
        final inner = node[key];
        if (inner is Map || inner is List) {
          node = inner;
          break;
        }
      }
    }

    // Kalau respons berupa array node di level atas, bungkus jadi satu root.
    if (node is List) {
      final children = node
          .whereType<Map>()
          .map((e) => GraphNode.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return GraphNode(
        type: 'Entry',
        label: 'Graph',
        uuid: entryUuid,
        children: children,
      );
    }

    if (node is Map) {
      return GraphNode.fromJson(Map<String, dynamic>.from(node));
    }

    return GraphNode(
      type: 'Entry',
      label: 'Graph tidak tersedia',
      uuid: entryUuid,
      children: [],
    );
  }
}
