import 'package:flutter/material.dart';

import '../core/api_client.dart';
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
  Entry? entry;
  bool isLoading = true;
  bool isSyncing = false;

  @override
  void initState() {
    super.initState();
    loadEntry();
  }

  Future<void> loadEntry() async {
    setState(() => isLoading = true);

    try {
      entry = await AppDependencies.of(context)
          .entryService
          .getEntry(widget.entryUuid);
    } on ApiException catch (error) {
      showMessage(error.message);
    } catch (_) {
      showMessage('Gagal mengambil detail journal.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus journal?'),
        content: const Text('Journal ini akan dihapus dari database.'),
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

    if (confirmed != true || entry == null) return;

    try {
      await AppDependencies.of(context).entryService.deleteEntry(entry!.uuid);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (_) {
      showMessage('Gagal menghapus journal.');
    }
  }

  Future<void> syncGraph() async {
    if (entry == null) return;

    setState(() => isSyncing = true);

    try {
      entry = await AppDependencies.of(context).entryService.syncGraph(entry!.uuid);

      if (!mounted) return;

      showMessage('Journal berhasil disinkronkan ke graph.');
      setState(() {});
    } on ApiException catch (error) {
      showMessage(error.message);
    } catch (_) {
      showMessage('Gagal sync graph. Pastikan Kaori berjalan.');
    } finally {
      if (mounted) {
        setState(() => isSyncing = false);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> editEntry() async {
    if (entry == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EntryEditorPage(entry: entry),
      ),
    );

    if (result == true) {
      await loadEntry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MemoraShell(
      title: 'Journal Detail',
      actions: [
        IconButton(
          onPressed: editEntry,
          icon: const Icon(Icons.edit_rounded),
        ),
        IconButton(
          onPressed: deleteEntry,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : entry == null
              ? const Center(child: Text('Journal tidak ditemukan.'))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      entry!.title,
                      style: const TextStyle(
                        fontSize: 32,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: entry!.emotions
                          .map(
                            (emotion) => Chip(
                              label: Text('#$emotion'),
                              backgroundColor: const Color(0xFFEEF2FF),
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    SoftCard(
                      child: Text(
                        entry!.content,
                        style: const TextStyle(
                          height: 1.6,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: isSyncing ? null : syncGraph,
                        icon: const Icon(Icons.account_tree_rounded),
                        label: Text(
                          isSyncing
                              ? 'Syncing...'
                              : entry!.isSyncedToGraph
                                  ? 'Sync Again to Graph'
                                  : 'Sync to Graph',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GraphPage(entryUuid: entry!.uuid),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_rounded),
                        label: const Text(
                          'View Graph Tree',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}