class GraphNode {
  final String type;
  final String label;
  final String? uuid;
  final List<GraphNode> children;

  GraphNode({
    required this.type,
    required this.label,
    this.uuid,
    required this.children,
  });

  factory GraphNode.fromJson(Map<String, dynamic> json) {
    final children = <GraphNode>[];

    void addChildrenFrom(String key) {
      final value = json[key];

      if (value is List) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            children.add(GraphNode.fromJson(item));
          } else if (item is Map) {
            children.add(GraphNode.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
    }

    addChildrenFrom('children');
    addChildrenFrom('events');
    addChildrenFrom('people');
    addChildrenFrom('emotions');

    final emotionType = json['emotion_type'];
    if (emotionType is Map<String, dynamic>) {
      children.add(GraphNode.fromJson(emotionType));
    } else if (emotionType is Map) {
      children.add(GraphNode.fromJson(Map<String, dynamic>.from(emotionType)));
    }

    return GraphNode(
      type: json['type']?.toString() ?? 'Node',
      label: json['label']?.toString() ??
          json['name']?.toString() ??
          json['summary']?.toString() ??
          'Untitled Node',
      uuid: json['uuid']?.toString() ?? json['uid']?.toString(),
      children: children,
    );
  }
}