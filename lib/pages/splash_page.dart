import 'package:flutter/material.dart';

import '../main.dart';
import 'home_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool hasCheckedSession = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!hasCheckedSession) {
      hasCheckedSession = true;
      checkSession();
    }
  }

  Future<void> checkSession() async {
    final deps = AppDependencies.of(context);
    final token = await deps.tokenStorage.getToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    try {
      final user = await deps.authService.me();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
      );
    } catch (_) {
      await deps.tokenStorage.clearToken();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}