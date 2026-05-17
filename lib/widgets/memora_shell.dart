import 'package:flutter/material.dart';

class MemoraShell extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;

  const MemoraShell({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: actions,
      ),
      body: child,
    );
  }
}