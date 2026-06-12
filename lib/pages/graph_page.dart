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

  String? errorMessage;
  int? errorStatus;
  String? rawDump;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) loadGraph();
    });
  }

  Future<void> loadGraph() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      errorStatus = null;
      rawDump = null;
    });

    final graphService = AppDependencies.of(context).graphService;

    try {
      final result = await graphService.getTree(widget.entryUuid);
      if (!mounted) return;

      setState(() {
        root = result;
        rawDump = graphService.lastRawPretty;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        root = null;
        errorStatus = error.statusCode;
        errorMessage = error.message;
        rawDump = error.body;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        root = null;
        errorMessage = 'Gagal mengambil graph tree: $error';
        rawDump = graphService.lastRawPretty;
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  bool get _treeIsEmpty =>
      root != null && root!.children.isEmpty && errorMessage == null;

  @override
  Widget build(BuildContext context) {
    return MemoraShell(
      title: 'Graph Tree',
      actions: [
        IconButton(
          tooltip: 'Muat ulang',
          onPressed: isLoading ? null : loadGraph,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                  'Visualisasi struktur tree yang dikirim backend Laravel/Kaori.',
                  style: TextStyle(color: Color(0xFF64748B), height: 1.5),
                ),
                const SizedBox(height: 20),

                if (errorMessage != null) _buildError(),

                if (errorMessage == null && _treeIsEmpty) _buildEmpty(),

                if (errorMessage == null && root != null && !_treeIsEmpty)
                  GraphNodeWidget(node: root!, level: 0),

                if (rawDump != null && rawDump!.trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildRaw(),
                ],
              ],
            ),
    );
  }

  Widget _buildError() {
    final isNotFound = errorStatus == 404;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorStatus != null
                      ? 'Gagal mengambil graph (HTTP $errorStatus)'
                      : 'Gagal mengambil graph',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? '',
            style: const TextStyle(color: Color(0xFF475569), height: 1.5),
          ),
          if (isNotFound) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Text(
                'Kemungkinan penyebab:\n'
                '• Journal ini belum di-"Sync to Graph" (lakukan sync dulu di halaman detail).\n'
                '• Layanan Kaori (FastAPI :8001) sedang tidak berjalan / tidak terjangkau dari server Laravel.',
                style: TextStyle(
                  color: Color(0xFF92400E),
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: FilledButton.icon(
              onPressed: loadGraph,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Graph berhasil diambil, tapi tidak ada node turunan.',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bentuk data dari Kaori mungkin berbeda dari yang dikenali. '
            'Lihat "Raw response" di bawah untuk struktur aslinya.',
            style: TextStyle(color: Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRaw() {
    return SoftCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: const Text(
            'Raw response (debug)',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: const Text(
            'Tap untuk lihat payload mentah dari server',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                rawDump ?? '',
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
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
