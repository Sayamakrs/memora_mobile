import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../main.dart';
import '../models/graph_node.dart';
import '../widgets/memora_shell.dart';
import '../widgets/soft_card.dart';

class GraphPage extends StatefulWidget {
  final String entryUuid;

  const GraphPage({
    super.key,
    required this.entryUuid,
  });

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  GraphNode? root;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGraph();
  }

  Future<void> loadGraph() async {
    setState(() => isLoading = true);

    try {
      root = await AppDependencies.of(context)
          .graphService
          .getTree(widget.entryUuid);
    } on ApiException catch (error) {
      showMessage(error.message);
    } catch (_) {
      showMessage('Gagal mengambil graph tree.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MemoraShell(
      title: 'Graph Tree',
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : root == null
              ? const Center(child: Text('Graph tidak tersedia.'))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Personal Knowledge Graph',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Visualisasi sederhana dari struktur tree yang dikirim oleh backend Laravel/Kaori.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GraphNodeWidget(node: root!, level: 0),
                  ],
                ),
    );
  }
}

class GraphNodeWidget extends StatelessWidget {
  final GraphNode node;
  final int level;

  const GraphNodeWidget({
    super.key,
    required this.node,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: level * 16.0, bottom: 12),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              node.type.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              node.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (node.children.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...node.children.map(
                (child) => GraphNodeWidget(
                  node: child,
                  level: level + 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}