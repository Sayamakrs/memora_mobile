import 'package:flutter/material.dart';

import '../main.dart';
import '../models/entry.dart';
import '../widgets/memora_shell.dart';
import '../widgets/soft_card.dart';
import 'entry_editor_page.dart';
import 'graph_page.dart';

class EntryDetailPage extends StatefulWidget {
  final String entryUuid;

  const EntryDetailPage({
    super.key,
    required this.entryUuid,
  });

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  late Future<Entry> entryFuture;
  bool isSyncing = false;
  bool hasLoadedDependencies = false;
  Entry? currentEntry;

  @override
  void initState() {
    super.initState();
    entryFuture = Future.error('Loading entry...');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!hasLoadedDependencies) {
      entryFuture = loadEntry();
      hasLoadedDependencies = true;
    }
  }

  Future<Entry> loadEntry() async {
    final entry = await AppDependencies.of(context).entryService.getEntry(
          widget.entryUuid,
        );

    currentEntry = entry;
    return entry;
  }

  void refreshEntry() {
    setState(() {
      entryFuture = loadEntry();
    });
  }

  Future<void> syncGraph(Entry entry) async {
    if (isSyncing) return;

    setState(() => isSyncing = true);

    try {
      final synced = await AppDependencies.of(context).entryService.syncGraph(
            entry.uuid,
          );

      if (!mounted) return;

      setState(() {
        currentEntry = synced;
        entryFuture = Future.value(synced);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal berhasil disinkronkan ke graph.')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal sync graph.')),
      );
    } finally {
      if (mounted) setState(() => isSyncing = false);
    }
  }

  Future<void> deleteEntry(Entry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus jurnal?'),
        content: const Text('Jurnal ini akan dihapus dari daftar mobile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;

    await AppDependencies.of(context).entryService.deleteEntry(entry.uuid);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return MemoraShell(
      title: 'Journal Detail',
      subtitle: 'A memory before it becomes a graph',
      actions: [
        IconButton(
          onPressed: () async {
            final entry = currentEntry;
            if (entry == null) return;

            final changed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => EntryEditorPage(entry: entry),
              ),
            );

            if (!mounted) return;

            if (changed == true) {
              refreshEntry();
            }
          },
          icon: const Icon(
            Icons.edit_rounded,
            color: MemoraColors.text,
          ),
        ),
      ],
      child: FutureBuilder<Entry>(
        future: entryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError) {
            return const Center(child: CircularProgressIndicator());
          }

          final entry = snapshot.data;

          if (entry == null) {
            return const Center(child: Text('Entry tidak ditemukan.'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
            children: [
              MemoraContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MemoraPill(
                      label: entry.isSyncedToGraph
                          ? 'SYNCED TO GRAPH'
                          : 'DRAFT JOURNAL',
                      icon: entry.isSyncedToGraph
                          ? Icons.account_tree_rounded
                          : Icons.edit_note_rounded,
                      color: entry.isSyncedToGraph
                          ? MemoraColors.primary
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 36,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                        color: MemoraColors.text,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      entry.isSyncedToGraph
                          ? 'This reflection is already connected to your personal memory graph.'
                          : 'This reflection is still waiting to become part of your memory graph.',
                      style: const TextStyle(
                        color: MemoraColors.body,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (entry.emotions.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.emotions
                            .map(
                              (emotion) => MemoraPill(
                                label: '#$emotion',
                                color: MemoraColors.primary,
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 22),
                    SoftCard(
                      radius: 34,
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        entry.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.72,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    GradientButton(
                      label:
                          entry.isSyncedToGraph ? 'Sync Again' : 'Sync to Graph',
                      icon: Icons.account_tree_rounded,
                      isLoading: isSyncing,
                      onPressed: isSyncing ? null : () => syncGraph(entry),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        foregroundColor: MemoraColors.primary,
                        side: const BorderSide(color: Color(0xFFC7D2FE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GraphPage(entryUuid: entry.uuid),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility_rounded),
                      label: const Text(
                        'View Memory Graph',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => deleteEntry(entry),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete Journal'),
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