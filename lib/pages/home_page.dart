import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../main.dart';
import '../models/app_user.dart';
import '../models/entry.dart';
import '../widgets/entry_card.dart';
import '../widgets/memora_shell.dart';
import '../widgets/soft_card.dart';
import 'chat_page.dart';
import 'entry_detail_page.dart';
import 'entry_editor_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'monthly_view_page.dart';

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({
    super.key,
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Entry> entries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future<void> loadEntries() async {
    setState(() => isLoading = true);

    try {
      entries = await AppDependencies.of(context).entryService.getEntries();
    } on ApiException catch (error) {
      showMessage(error.message);
    } catch (_) {
      showMessage('Gagal mengambil data journal.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> logout() async {
    await AppDependencies.of(context).authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> openCreateEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EntryEditorPage()),
    );

    if (result == true) {
      loadEntries();
    }
  }

  Future<void> openEntry(Entry entry) async {
    debugPrint('OPEN ENTRY ID: ${entry.id}');
    debugPrint('OPEN ENTRY UUID: ${entry.uuid}');
    debugPrint('OPEN ENTRY TITLE: ${entry.title}');

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EntryDetailPage(entryUuid: entry.uuid),
      ),
    );

    if (result == true) {
      loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MemoraShell(
      title: 'Memora',
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(user: widget.user),
              ),
            );
          },
          icon: const Icon(Icons.person_rounded),
        ),
        IconButton(
          onPressed: logout,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: loadEntries,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Good afternoon,\n${widget.user.name}.',
              style: const TextStyle(
                fontSize: 34,
                height: 1.08,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ready to map out your thoughts?',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SoftCard(
                    onTap: openCreateEntry,
                    child: const _HomeAction(
                      icon: Icons.edit_note_rounded,
                      title: 'New Journal',
                      subtitle: 'Capture a moment',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SoftCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatPage()),
                      );
                    },
                    child: const _HomeAction(
                      icon: Icons.chat_rounded,
                      title: 'Talk to Kaori',
                      subtitle: 'Ask companion',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Recent Reflections',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final now = DateTime.now();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MonthlyViewPage(
                          initialYear: now.year,
                          initialMonth: now.month,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1), // Warna Indigo
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (entries.isEmpty)
              const SoftCard(
                child: Text('Belum ada journal. Buat journal baru dulu.'),
              )
            else
              ...entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: EntryCard(
                    entry: entry,
                    onTap: () => openEntry(entry),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HomeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 34),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
