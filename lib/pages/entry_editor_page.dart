import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../main.dart';
import '../models/entry.dart';
import '../widgets/memora_shell.dart';
import '../widgets/soft_card.dart';

class EntryEditorPage extends StatefulWidget {
  final Entry? entry;

  const EntryEditorPage({
    super.key,
    this.entry,
  });

  @override
  State<EntryEditorPage> createState() => _EntryEditorPageState();
}

class _EntryEditorPageState extends State<EntryEditorPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  bool isSaving = false;

  bool get isEditMode => widget.entry != null;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.entry?.title ?? '',
    );

    contentController = TextEditingController(
      text: widget.entry?.content ?? '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> saveEntry() async {
    setState(() => isSaving = true);

    try {
      if (isEditMode) {
        await AppDependencies.of(context).entryService.updateEntry(
              uuid: widget.entry!.uuid,
              title: titleController.text.trim(),
              content: contentController.text.trim(),
            );
      } else {
        await AppDependencies.of(context).entryService.createEntry(
              title: titleController.text.trim(),
              content: contentController.text.trim(),
            );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } on ApiException catch (error) {
      showMessage(error.message);
    } catch (_) {
      showMessage('Gagal menyimpan journal.');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
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
      title: isEditMode ? 'Edit Journal' : 'New Journal',
      actions: [
        IconButton(
          onPressed: isSaving ? null : saveEntry,
          icon: const Icon(Icons.save_rounded),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
            decoration: const InputDecoration(
              hintText: 'Untitled Entry',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 12),
          SoftCard(
            child: TextField(
              controller: contentController,
              minLines: 14,
              maxLines: 24,
              decoration: const InputDecoration(
                hintText: 'Write what is on your mind...',
                border: InputBorder.none,
              ),
              style: const TextStyle(
                height: 1.55,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: isSaving ? null : saveEntry,
              icon: const Icon(Icons.check_rounded),
              label: Text(
                isSaving ? 'Saving...' : 'Save Journal',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}