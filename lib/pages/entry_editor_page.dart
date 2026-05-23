import 'package:flutter/material.dart';

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
  late final TextEditingController titleController;
  late final TextEditingController contentController;
  bool isSaving = false;

  bool get isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.entry?.title ?? '');
    contentController = TextEditingController(text: widget.entry?.content ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> saveEntry() async {
    if (isSaving) return;

    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi judul atau konten jurnal dulu.')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final service = AppDependencies.of(context).entryService;

      if (isEditing) {
        await service.updateEntry(
          uuid: widget.entry!.uuid,
          title: title,
          content: content,
        );
      } else {
        await service.createEntry(
          title: title,
          content: content,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan jurnal.')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MemoraShell(
      title: isEditing ? 'Edit Journal' : 'New Journal',
      subtitle: 'Capture the moment before it fades',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
        children: [
          MemoraContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MemoraPill(
                  label: 'WRITE MODE',
                  icon: Icons.edit_note_rounded,
                  color: MemoraColors.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  isEditing
                      ? 'Refine this memory.'
                      : 'Write freely.\nMemora will organize the meaning later.',
                  style: const TextStyle(
                    fontSize: 34,
                    height: 1.02,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.4,
                    color: MemoraColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'The UI is currently using mock data. Later this form will send journal entries to Laravel API.',
                  style: TextStyle(
                    color: MemoraColors.body,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 26),
                SoftCard(
                  radius: 34,
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 25,
                          letterSpacing: -0.8,
                          color: MemoraColors.text,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Journal title',
                          hintStyle: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontWeight: FontWeight.w900,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      const Divider(height: 26, color: Color(0xFFE5E7EB)),
                      TextField(
                        controller: contentController,
                        minLines: 13,
                        maxLines: 24,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.65,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'What happened today? How did it make you feel?',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w700,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: isEditing ? 'Save Changes' : 'Save Journal',
                        icon: Icons.check_rounded,
                        isLoading: isSaving,
                        onPressed: isSaving ? null : saveEntry,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}