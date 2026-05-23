import 'package:flutter/material.dart';

import '../main.dart';
import '../models/app_user.dart';
import '../models/entry.dart';
import '../widgets/entry_card.dart';
import '../widgets/memora_shell.dart';
import '../widgets/soft_card.dart';
import 'chat_page.dart';
import 'entry_detail_page.dart';
import 'entry_editor_page.dart';
import 'graph_page.dart';
import 'profile_page.dart';

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
  int selectedIndex = 0;
  late Future<List<Entry>> entriesFuture;
  bool hasLoadedDependencies = false;

  @override
  void initState() {
    super.initState();
    entriesFuture = Future.value([]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!hasLoadedDependencies) {
      entriesFuture = loadEntries();
      hasLoadedDependencies = true;
    }
  }

  Future<List<Entry>> loadEntries() {
    return AppDependencies.of(context).entryService.getEntries();
  }

  void refreshEntries() {
    setState(() {
      entriesFuture = loadEntries();
    });
  }

  Future<void> openEditor() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EntryEditorPage()),
    );

    if (!mounted) return;

    if (created == true) {
      refreshEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeDashboard(
        user: widget.user,
        entriesFuture: entriesFuture,
        onRefresh: refreshEntries,
        onCreateEntry: openEditor,
      ),
      const ChatPage(),
      const GraphPage(),
      ProfilePage(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: MemoraColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: MeshBackground(opacity: 0.72)),

          Positioned.fill(
            child: SafeArea(
              child: IndexedStack(
                index: selectedIndex,
                children: pages,
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: _MemoraBottomNav(
                selectedIndex: selectedIndex,
                onChanged: (index) {
                  setState(() => selectedIndex = index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  final AppUser user;
  final Future<List<Entry>> entriesFuture;
  final VoidCallback onRefresh;
  final VoidCallback onCreateEntry;

  const _HomeDashboard({
    required this.user,
    required this.entriesFuture,
    required this.onRefresh,
    required this.onCreateEntry,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 120),
        children: [
          MemoraContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(user: user),
                const SizedBox(height: 34),

                Row(
                  children: [
                    Expanded(
                      child: _PrimaryActionCard(
                        icon: Icons.edit_rounded,
                        title: 'New Journal',
                        subtitle: 'Capture a moment',
                        onTap: onCreateEntry,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _PrimaryActionCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Talk to Kaori',
                        subtitle: 'Explore your mindset',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChatPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _WideActionCard(
                  icon: Icons.account_tree_rounded,
                  title: 'Memory Graph',
                  subtitle: 'Explore connected memories from your journal',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GraphPage()),
                    );
                  },
                ),

                const SizedBox(height: 42),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Recent Reflections',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: MemoraColors.text,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onRefresh,
                      child: const Text(
                        'Refresh',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: MemoraColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                FutureBuilder<List<Entry>>(
                  future: entriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _LoadingEntries();
                    }

                    final entries = snapshot.data ?? [];

                    if (entries.isEmpty) {
                      return SoftCard(
                        padding: const EdgeInsets.all(26),
                        child: Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: MemoraColors.softPurple,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: const Icon(
                                Icons.edit_note_rounded,
                                size: 34,
                                color: MemoraColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada jurnal.',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: MemoraColors.text,
                              ),
                            ),
                            const SizedBox(height: 7),
                            const Text(
                              'Mulai tulis refleksi pertamamu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: MemoraColors.body,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 18),
                            GradientButton(
                              label: 'Create Journal',
                              icon: Icons.add_rounded,
                              onPressed: onCreateEntry,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: EntryCard(
                                entry: entry,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EntryDetailPage(
                                        entryUuid: entry.uuid,
                                      ),
                                    ),
                                  );

                                  onRefresh();
                                },
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppUser user;

  const _Header({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = user.name.split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MemoraPill(
          label: '2026 MAY 23',
          color: MemoraColors.primary,
        ),
        const SizedBox(height: 18),
        Text(
          'Good afternoon,\n$firstName.',
          style: const TextStyle(
            fontSize: 38,
            height: 0.98,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.7,
            color: MemoraColors.text,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ready to map out your thoughts?',
          style: TextStyle(
            fontSize: 16,
            height: 1.45,
            fontWeight: FontWeight.w700,
            color: MemoraColors.body,
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      radius: 30,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: MemoraColors.softPurple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: MemoraColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: MemoraColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MemoraColors.muted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
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
    );
  }
}

class _WideActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _WideActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      radius: 30,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: MemoraColors.softPurple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: MemoraColors.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: MemoraColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: MemoraColors.muted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
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
    );
  }
}

class _LoadingEntries extends StatelessWidget {
  const _LoadingEntries();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SoftCard(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCBD5E1),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonLine(width: 190),
                      SizedBox(height: 10),
                      _SkeletonLine(width: 250),
                      SizedBox(height: 10),
                      _SkeletonLine(width: 140),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;

  const _SkeletonLine({
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _MemoraBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _MemoraBottomNav({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.chat_bubble_rounded, 'Kaori'),
      (Icons.account_tree_rounded, 'Graph'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: MemoraContent(
        maxWidth: 820,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.09),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = selectedIndex == index;
              final item = items[index];

              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(index),
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? MemoraColors.softPurple
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.$1,
                          color: selected
                              ? MemoraColors.primary
                              : const Color(0xFF94A3B8),
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$2,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: selected
                                ? MemoraColors.primary
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}