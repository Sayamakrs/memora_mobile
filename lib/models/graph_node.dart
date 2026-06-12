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

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

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

    // Beragam kemungkinan nama key anak dari Kaori.
    for (final key in [
      'children',
      'events',
      'people',
      'emotions',
      'nodes',
      'links',
      'relationships',
      'relations',
      'related',
      'items',
    ]) {
      addChildrenFrom(key);
    }

    final emotionType = json['emotion_type'];
    if (emotionType is Map<String, dynamic>) {
      children.add(GraphNode.fromJson(emotionType));
    } else if (emotionType is Map) {
      children.add(GraphNode.fromJson(Map<String, dynamic>.from(emotionType)));
    }

    final type = json['type']?.toString() ??
        json['label_type']?.toString() ??
        'Node';

    var label = json['label']?.toString() ??
        json['name']?.toString() ??
        json['summary']?.toString() ??
        json['title']?.toString() ??
        json['text']?.toString() ??
        json['value']?.toString() ??
        'Untitled Node';

    // Root Entry biasanya ber-label UUID mentah -> tampilkan lebih ramah.
    if (type.toLowerCase() == 'entry' && _uuidPattern.hasMatch(label)) {
      label = 'Journal Entry';
    }

    return GraphNode(
      type: type,
      label: label,
      uuid: json['uuid']?.toString() ?? json['uid']?.toString(),
      children: children,
    );
  }
}
