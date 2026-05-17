import '../core/api_client.dart';
import '../models/graph_node.dart';

class GraphService {
  final ApiClient apiClient;

  GraphService({
    required this.apiClient,
  });

  Future<GraphNode> getTree(String entryUuid) async {
    final data = await apiClient.get('/graph/tree/$entryUuid');

    final tree = data['tree'];

    if (tree is Map<String, dynamic>) {
      return GraphNode.fromJson(tree);
    }

    if (tree is Map && tree.isNotEmpty) {
      return GraphNode.fromJson(Map<String, dynamic>.from(tree));
    }

    return GraphNode(
      type: 'Entry',
      label: 'Graph tidak tersedia',
      uuid: entryUuid,
      children: [],
    );
  }
}