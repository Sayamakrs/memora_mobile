import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../main.dart';
import '../widgets/memora_shell.dart';
import 'home_page.dart';

const String _googleLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#FFC107" d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12s5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24s8.955,20,20,20s20-8.955,20-20c0-1.341-.138-2.65-.389-3.917z"/>
  <path fill="#FF3D00" d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z"/>
  <path fill="#4CAF50" d="M24,44c5.166,0,9.86-1.977,13.409-5.193l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z"/>
  <path fill="#1976D2" d="M43.611,20.083H42V20H24v8h11.303c-.792,2.237-2.231,4.166-4.087,5.571l6.19,5.238C36.971,39.205,44,34,44,24c0-1.341-.138-2.65-.389-3.917z"/>
</svg>
''';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;

  Future<void> beginJourney() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final user = await AppDependencies.of(context).authService.login(
            email: 'mock@memora.app',
            password: 'password',
          );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal masuk ke Memora.')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = width < 390 ? 56.0 : 66.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          const Positioned.fill(child: MeshBackground(opacity: 0.9)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 76,
                      width: 76,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.16),
                            blurRadius: 24,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF4F46E5),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      'Your life,',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleSize,
                        height: 0.9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2.7,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF4F46E5),
                          Color(0xFF9333EA),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'mapped.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          height: 0.92,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2.7,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Reflect, remember, and reconnect with your personal memory graph.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.55,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 54),
                    _BeginJourneyButton(
                      isLoading: isLoading,
                      onTap: beginJourney,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'UI mode aktif. Integrasi Laravel tinggal disambungkan di service layer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeginJourneyButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _BeginJourneyButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_BeginJourneyButton> createState() => _BeginJourneyButtonState();
}

class _BeginJourneyButtonState extends State<_BeginJourneyButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap,
      onTapDown: widget.isLoading
          ? null
          : (_) => setState(() => isPressed = true),
      onTapUp: widget.isLoading
          ? null
          : (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, isPressed ? 5 : 0, 0),
        height: 76,
        constraints: const BoxConstraints(
          minWidth: 270,
          maxWidth: 350,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 26),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(
                alpha: isPressed ? 0.10 : 0.20,
              ),
              blurRadius: isPressed ? 12 : 26,
              offset: Offset(0, isPressed ? 6 : 16),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading)
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            else ...[
              SvgPicture.string(
                _googleLogoSvg,
                width: 28,
                height: 28,
              ),
              const SizedBox(width: 14),
              const Text(
                'Begin Journey',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}