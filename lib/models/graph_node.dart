class GraphNode {
  final String type;
  final String label;
  final String? uuid;
  final List<GraphNode> children;

  GraphNode({
    required this.type,
    required this.label,
    required this.uuid,
    required this.children,
  });

  factory GraphNode.fromJson(Map<String, dynamic> json) {
    return GraphNode(
      type: json['type']?.toString() ?? 'Node',
      label: json['label']?.toString() ?? '-',
      uuid: json['uuid']?.toString(),
      children: (json['children'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => GraphNode.fromJson(item))
          .toList(),
    );
  }
}