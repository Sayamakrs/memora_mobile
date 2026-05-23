import 'package:flutter/material.dart';

import '../main.dart';
import '../models/entry.dart';
import '../models/graph_node.dart';
import '../widgets/memora_shell.dart';
import '../widgets/soft_card.dart';
import 'entry_detail_page.dart';

class GraphPage extends StatefulWidget {
  final String? entryUuid;

  const GraphPage({
    super.key,
    this.entryUuid,
  });

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  late Future<_GraphPageData> dataFuture;
  bool hasLoadedDependencies = false;

  @override
  void initState() {
    super.initState();

    dataFuture = Future.value(
      const _GraphPageData(
        entries: [],
        selectedEntry: null,
        graph: null,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!hasLoadedDependencies) {
      dataFuture = loadData();
      hasLoadedDependencies = true;
    }
  }

  Future<_GraphPageData> loadData() async {
    final deps = AppDependencies.of(context);

    final entries = await deps.entryService.getEntries();

    final targetEntry = widget.entryUuid != null
        ? entries.where((entry) => entry.uuid == widget.entryUuid).firstOrNull
        : entries.where((entry) => entry.isSyncedToGraph).firstOrNull;

    if (targetEntry == null) {
      return _GraphPageData(
        entries: entries,
        selectedEntry: null,
        graph: null,
      );
    }

    final graph = await deps.graphService.getTree(targetEntry.uuid);

    return _GraphPageData(
      entries: entries,
      selectedEntry: targetEntry,
      graph: graph,
    );
  }

  void reload() {
    setState(() {
      dataFuture = loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MemoraShell(
      title: 'Memory Graph',
      subtitle: 'A soft map of your reflections',
      actions: [
        IconButton(
          onPressed: reload,
          icon: const Icon(
            Icons.refresh_rounded,
            color: MemoraColors.text,
          ),
        ),
      ],
      child: FutureBuilder<_GraphPageData>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;

          if (data == null || data.graph == null || data.selectedEntry == null) {
            return _EmptyGraphState(onRefresh: reload);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
            children: [
              MemoraContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MemoraPill(
                      label: 'KNOWLEDGE GRAPH',
                      icon: Icons.account_tree_rounded,
                      color: MemoraColors.primary,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Your memories,\nconnected.',
                      style: TextStyle(
                        fontSize: 38,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.7,
                        color: MemoraColors.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Currently showing a mock graph projection from "${data.selectedEntry!.title}". Later, this will be loaded from Laravel and Kaori.',
                      style: const TextStyle(
                        color: MemoraColors.body,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 26),
                    _MemoryMap(root: data.graph!),
                    const SizedBox(height: 34),
                    const Text(
                      'Synced Journals',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        color: MemoraColors.text,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...data.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SoftCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EntryDetailPage(
                                  entryUuid: entry.uuid,
                                ),
                              ),
                            ).then((_) => reload());
                          },
                          padding: const EdgeInsets.all(18),
                          radius: 30,
                          elevated: true,
                          child: Row(
                            children: [
                              Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: entry.isSyncedToGraph
                                      ? MemoraColors.primary
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: MemoraColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.isSyncedToGraph
                                          ? 'Synced to memory graph'
                                          : 'Not synced yet',
                                      style: const TextStyle(
                                        color: MemoraColors.muted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFFCBD5E1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MemoryMap extends StatelessWidget {
  final GraphNode root;

  const _MemoryMap({
    required this.root,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: 36,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          _GraphNodePill(
            label: root.label,
            type: root.type,
            isRoot: true,
          ),
          if (root.children.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: 2,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFC7D2FE),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 8),
            ...root.children.map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GraphBranch(node: child),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GraphBranch extends StatelessWidget {
  final GraphNode node;

  const _GraphBranch({
    required this.node,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GraphNodePill(
          label: node.label,
          type: node.type,
        ),
        if (node.children.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: node.children
                .map(
                  (child) => _GraphNodePill(
                    label: child.label,
                    type: child.type,
                    compact: true,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _GraphNodePill extends StatelessWidget {
  final String label;
  final String type;
  final bool isRoot;
  final bool compact;

  const _GraphNodePill({
    required this.label,
    required this.type,
    this.isRoot = false,
    this.compact = false,
  });

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'entry':
        return Icons.article_rounded;
      case 'event':
        return Icons.bolt_rounded;
      case 'person':
        return Icons.person_rounded;
      case 'emotionstate':
      case 'emotion':
        return Icons.favorite_rounded;
      default:
        return Icons.circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = isRoot ? MemoraColors.dark : Colors.white;
    final foreground = isRoot ? Colors.white : MemoraColors.text;
    final muted = isRoot ? Colors.white.withValues(alpha: 0.68) : MemoraColors.muted;

    return Container(
      constraints: BoxConstraints(
        maxWidth: compact ? 170 : 310,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(compact ? 18 : 23),
        border: isRoot ? null : Border.all(color: const Color(0xFFE0E7FF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isRoot ? Colors.white : MemoraColors.primary,
            size: compact ? 16 : 19,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    fontSize: compact ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGraphState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyGraphState({
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
      children: [
        MemoraContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MemoraPill(
                label: 'KNOWLEDGE GRAPH',
                icon: Icons.account_tree_rounded,
                color: MemoraColors.primary,
              ),
              const SizedBox(height: 18),
              const Text(
                'No memory\ngraph yet.',
                style: TextStyle(
                  fontSize: 38,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.7,
                  color: MemoraColors.text,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sync one of your journals first. For now, mock graph data will appear after pressing Sync to Graph on a journal detail page.',
                style: TextStyle(
                  color: MemoraColors.body,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 26),
              SoftCard(
                padding: const EdgeInsets.all(26),
                radius: 34,
                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: MemoraColors.softPurple,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.account_tree_rounded,
                        color: MemoraColors.primary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Your graph will appear here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                        color: MemoraColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Once the journal is synced, Memora will map entries, events, emotions, and people.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: MemoraColors.body,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    GradientButton(
                      label: 'Refresh Graph',
                      icon: Icons.refresh_rounded,
                      onPressed: onRefresh,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GraphPageData {
  final List<Entry> entries;
  final Entry? selectedEntry;
  final GraphNode? graph;

  const _GraphPageData({
    required this.entries,
    required this.selectedEntry,
    required this.graph,
  });
}

extension _FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}