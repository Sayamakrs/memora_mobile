import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // Sesuaikan untuk ambil AppDependencies
import '../widgets/memora_shell.dart';
import 'daily_view_page.dart';

class MonthlyViewPage extends StatefulWidget {
  final int initialYear;
  final int initialMonth;

  const MonthlyViewPage({
    super.key,
    required this.initialYear,
    required this.initialMonth,
  });

  @override
  State<MonthlyViewPage> createState() => _MonthlyViewPageState();
}

class _MonthlyViewPageState extends State<MonthlyViewPage> {
  late int year;
  late int month;
  List<int> markedDates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    year = widget.initialYear;
    month = widget.initialMonth;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadMarkedDates();
    });
  }

  Future<void> loadMarkedDates() async {
    setState(() => isLoading = true);
    try {
      // Sesuaikan dengan nama fungsi service kamu
      final dates = await AppDependencies.of(context)
          .entryService
          .getMarkedDates(year, month);
      setState(() {
        markedDates = dates;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data kalender')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void changeMonth(int step) {
    setState(() {
      month += step;
      if (month > 12) {
        month = 1;
        year++;
      } else if (month < 1) {
        month = 12;
        year--;
      }
    });
    loadMarkedDates();
  }

  @override
  Widget build(BuildContext context) {
    // Logic untuk menghitung hari dalam bulan ini
    final dateObj = DateTime(year, month);
    final monthLabel = DateFormat('MMMM yyyy').format(dateObj);

    // Hitung offset hari pertama (agar sesuai dengan grid kalender)
    int daysInMonth = DateTime(year, month + 1, 0).day;
    int firstWeekday = DateTime(year, month, 1).weekday; // 1 = Mon, 7 = Sun
    int offset = firstWeekday == 7 ? 0 : firstWeekday;

    return MemoraShell(
      title: 'Journey',
      // showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Navigasi Bulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 32),
                onPressed: () => changeMonth(-1),
              ),
              Text(
                monthLabel.toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 32),
                onPressed: () => changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            _buildCalendarGrid(daysInMonth, offset),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(int daysInMonth, int offset) {
    const daysOfWeek = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: const Border(
            bottom: BorderSide(color: Color(0xFFE2E8F0), width: 8)),
      ),
      child: Column(
        children: [
          // Header Hari
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek
                .map((d) => SizedBox(
                      width: 36,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          // Grid Tanggal
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + offset,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox.shrink();

              int day = index - offset + 1;
              bool hasEntry = markedDates.contains(day);

              return GestureDetector(
                onTap: hasEntry
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DailyViewPage(
                              year: year,
                              month: month,
                              date: day,
                            ),
                          ),
                        );
                      }
                    : null, // Disable tap jika tidak ada entri
                child: Container(
                  decoration: BoxDecoration(
                    color: hasEntry
                        ? const Color(0xFFEEF2FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: hasEntry
                        ? Border.all(color: const Color(0xFFC7D2FE), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: hasEntry
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
