import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/entry.dart';
import '../widgets/entry_card.dart';
import '../widgets/memora_shell.dart';
import 'entry_detail_page.dart';

class DailyViewPage extends StatefulWidget {
  final int year;
  final int month;
  final int date;

  const DailyViewPage({
    super.key,
    required this.year,
    required this.month,
    required this.date,
  });

  @override
  State<DailyViewPage> createState() => _DailyViewPageState();
}

class _DailyViewPageState extends State<DailyViewPage> {
  List<Entry> entries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDailyEntries();
    });
  }

  Future<void> loadDailyEntries() async {
    setState(() => isLoading = true);
    try {
      final data = await AppDependencies.of(context)
          .entryService
          .getEntriesByDate(widget.year, widget.month, widget.date);
      setState(() {
        entries = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat journal hari ini')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void openEntry(Entry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EntryDetailPage(entryUuid: entry.uuid),
      ),
    ).then((_) => loadDailyEntries()); // Reload if back from detail
  }

  @override
  Widget build(BuildContext context) {
    final dateObj = DateTime(widget.year, widget.month, widget.date);
    final dateLabel = DateFormat('dd MMMM yyyy').format(dateObj);

    return MemoraShell(
      title: 'Daily Archive',
      // showBackButton: true,
      child: RefreshIndicator(
        onRefresh: loadDailyEntries,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              dateLabel.toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your thoughts captured on this day.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ))
            else if (entries.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      style: BorderStyle.solid,
                      width: 4),
                ),
                child: const Center(
                  child: Text(
                    'No memories found.',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
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
