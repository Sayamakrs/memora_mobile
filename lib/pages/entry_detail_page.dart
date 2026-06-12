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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        loadEntry();
      }
    });
  }

  Future<void> loadEntry() async {
    setState(() => isLoading = true);

    try {
      entry = await AppDependencies.of(context)
          .entryService
          .getEntry(widget.entryUuid);
    } on ApiException catch (error) {
      entry = null;
      if (mounted) {
        showMessage(error.message);
      }
    } catch (_) {
      entry = null;
      if (mounted) {
        showMessage('Gagal mengambil detail journal.');
      }
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

  // Widget helper murni untuk nampilin status murni tanpa interaksi tombol retry
  Widget _buildSyncBadge() {
    final status = entry!.syncStatus;

    if (status == 'pending') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          border: Border.all(color: Colors.amber.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
            ),
            const Text(
              '⏳ SYNCING / PENDING',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFFB45309),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      );
    } else if (status == 'success') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const Text(
              '✅ GRAPH SYNCED',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF059669),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      );
    } else if (status == 'failed') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const Text(
              '⚠️ SYNC FAILED',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFFE11D48),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
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

                    // Emotions List Tags
                    if (entry!.emotions.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: entry!.emotions
                            .map(
                              (emotion) => Chip(
                                label: Text(
                                  '#${emotion.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                                backgroundColor: const Color(0xFFEEF2FF),
                                side:
                                    const BorderSide(color: Color(0xFFE0E7FF)),
                              ),
                            )
                            .toList(),
                      ),

                    const SizedBox(height: 14),

                    // Sync Status di atas Textarea/SoftCard
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildSyncBadge(),
                    ),

                    const SizedBox(height: 18),

                    // Textarea Content
                    SoftCard(
                      child: Text(
                        entry!.content,
                        style: const TextStyle(
                          height: 1.6,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Button View Graph Tree
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
