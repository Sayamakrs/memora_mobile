import '../core/api_client.dart';
import '../models/graph_node.dart';

class GraphService {
  final ApiClient apiClient;

  GraphService({
    required this.apiClient,
  });

  Future<GraphNode> getTree(String entryUuid) async {
    final data = await apiClient.get('/graph/tree/$entryUuid');

    if (data is Map<String, dynamic>) {
      return GraphNode.fromJson(data);
    }

    if (data is Map && data.isNotEmpty) {
      return GraphNode.fromJson(Map<String, dynamic>.from(data));
    }

    return GraphNode(
      type: 'Entry',
      label: 'Graph tidak tersedia',
      uuid: entryUuid,
      children: [],
    );
  }
}