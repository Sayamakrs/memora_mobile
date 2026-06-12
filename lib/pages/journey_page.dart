import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../main.dart';
import '../models/entry.dart';
import '../widgets/entry_card.dart';
import '../widgets/memora_shell.dart';
import '../widgets/soft_card.dart';
import 'entry_detail_page.dart';

/// "My Journey" — menampilkan semua entri yang dipetakan ke kalender.
/// Tanggal yang punya entri akan diberi titik; ketuk untuk melihat
/// daftar entri pada hari itu.
class JourneyPage extends StatefulWidget {
  const JourneyPage({super.key});

  @override
  State<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  static const _months = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
  ];
  static const _weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  bool isLoading = true;

  /// Map tanggal (tahun-bulan-hari) -> daftar entri di hari itu.
  final Map<String, List<Entry>> _entriesByDay = {};

  late DateTime _visibleMonth; // selalu tanggal 1 dari bulan yang ditampilkan

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) loadEntries();
    });
  }

  String _key(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> loadEntries() async {
    setState(() => isLoading = true);

    try {
      final entries =
          await AppDependencies.of(context).entryService.getEntries();

      _entriesByDay.clear();
      for (final entry in entries) {
        final raw = entry.createdAt;
        if (raw == null || raw.isEmpty) continue;

        final parsed = DateTime.tryParse(raw);
        if (parsed == null) continue;

        final local = parsed.toLocal();
        final key = _key(DateTime(local.year, local.month, local.day));
        _entriesByDay.putIfAbsent(key, () => []).add(entry);
      }
    } on ApiException catch (error) {
      showMessage(error.message);
    } catch (_) {
      showMessage('Gagal memuat data journey.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
    });
  }

  void _changeYear(int delta) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year + delta, _visibleMonth.month, 1);
    });
  }

  void _openDay(DateTime day, List<Entry> entries) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8FAFC),
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Text(
                  '${day.day} ${_capitalize(_months[day.month - 1])} ${day.year}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entries.length} reflection${entries.length > 1 ? 's' : ''} on this day',
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 16),
                ...entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: EntryCard(
                      entry: entry,
                      onTap: () async {
                        Navigator.pop(context); // tutup sheet dulu
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EntryDetailPage(entryUuid: entry.uuid),
                          ),
                        );
                        if (result == true && mounted) loadEntries();
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0] + s.substring(1).toLowerCase();

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MemoraShell(
      title: 'My Journey',
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadEntries,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  SoftCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildWeekdayRow(),
                        const SizedBox(height: 8),
                        _buildGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x336366F1),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.calendar_month_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MAPPED JOURNEY',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6366F1),
                ),
              ),
              Text(
                '${_capitalize(_months[_visibleMonth.month - 1])} ${_visibleMonth.year}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        _navBtn(Icons.keyboard_double_arrow_left_rounded,
            () => _changeYear(-1)),
        const SizedBox(width: 4),
        _navBtn(Icons.chevron_left_rounded, () => _changeMonth(-1)),
        const SizedBox(width: 4),
        _navBtn(Icons.chevron_right_rounded, () => _changeMonth(1)),
        const SizedBox(width: 4),
        _navBtn(
            Icons.keyboard_double_arrow_right_rounded, () => _changeYear(1)),
      ],
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF475569)),
        ),
      ),
    );
  }

  Widget _buildWeekdayRow() {
    return Row(
      children: _weekdays
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildGrid() {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;

    // weekday: Dart -> Mon=1..Sun=7. Kita pakai Sun sebagai kolom pertama.
    final leadingBlanks = firstDay.weekday % 7;
    final totalCells = leadingBlanks + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final today = DateTime.now();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - leadingBlanks + 1;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 54));
              }

              final date =
                  DateTime(_visibleMonth.year, _visibleMonth.month, dayNum);
              final dayEntries = _entriesByDay[_key(date)] ?? const [];
              final hasEntries = dayEntries.isNotEmpty;
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _DayCell(
                    day: dayNum,
                    hasEntries: hasEntries,
                    isToday: isToday,
                    onTap: hasEntries
                        ? () => _openDay(date, List.of(dayEntries))
                        : null,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool hasEntries;
  final bool isToday;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.hasEntries,
    required this.isToday,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = hasEntries
        ? const Color(0xFFEEF2FF)
        : const Color(0xFFF8FAFC);
    final Color textColor = hasEntries
        ? const Color(0xFF4F46E5)
        : const Color(0xFF94A3B8);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday
                ? const Color(0xFF6366F1)
                : const Color(0xFFEDF1F7),
            width: isToday ? 1.6 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontWeight: hasEntries ? FontWeight.w900 : FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasEntries
                    ? const Color(0xFF6366F1)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
