import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memora_mobile/core/api_client.dart';
import 'package:memora_mobile/core/token_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../services/auth_service.dart';
import 'package:flutter/services.dart';

import '../main.dart';

const String _googleLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#FFC107" d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24s8.955,20,20,20s20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z"/>
  <path fill="#FF3D00" d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z"/>
  <path fill="#4CAF50" d="M24,44c4.039,0,7.828-1.218,11.002-3.3l-6.27-5.232C27.468,36.425,25.776,37,24,37c-5.223,0-9.654-3.343-11.303-8l-6.571,4.819C9.656,39.663,16.318,44,24,44z"/>
  <path fill="#1976D2" d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z"/>
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

    setState(() {
      isLoading = true;
    });

    try {
      final authService = AppDependencies.of(context).authService;

      final user = await authService.loginWithGoogle();

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${user.name}!'),
            behavior: SnackBarBehavior.floating,
          ),
      );

        Navigator.of(context).pushReplacementNamed(
          '/dashboard',
          arguments: user,
      );
    }
    } catch (error) {
      if (mounted) {
        String errorMessage = error.toString();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 10), // Lebih lama agar sempat terbaca
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final double titleSize = width >= 1200
        ? 106
        : width >= 900
            ? 90
            : width >= 600
                ? 74
                : 58;

    final double subtitleSize = width >= 900 ? 20 : 16;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(
            child: _MeshBackground(),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Your life,',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          height: 0.88,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -3,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(0xFF4F46E5),
                              Color(0xFF7C3AED),
                            ],
                          ).createShader(bounds);
                        },
                        child: Text(
                          'mapped.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleSize,
                            height: 0.88,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          'Memora weaves your daily reflections into a living knowledge graph.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            height: 1.45,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 72),
                      LandingGoogleButton(
                        isLoading: isLoading,
                        onTap: beginJourney,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LandingGoogleButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const LandingGoogleButton({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<LandingGoogleButton> createState() => _LandingGoogleButtonState();
}

class _LandingGoogleButtonState extends State<LandingGoogleButton> {
  bool isHovering = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.isLoading;

    final double translateY = isPressed
        ? 4
        : isHovering
            ? -4
            : 0;

    final double bottomBorder = isPressed ? 2 : 8;
    final double shadowOffset = isPressed
        ? 6
        : isHovering
            ? 22
            : 16;

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) {
        if (!disabled) {
          setState(() {
            isHovering = true;
          });
        }
      },
      onExit: (_) {
        setState(() {
          isHovering = false;
          isPressed = false;
        });
      },
      child: GestureDetector(
        onTap: disabled ? null : widget.onTap,
        onTapDown: disabled
            ? null
            : (_) {
                setState(() {
                  isPressed = true;
                });
              },
        onTapUp: disabled
            ? null
            : (_) {
                setState(() {
                  isPressed = false;
                });
              },
        onTapCancel: () {
          setState(() {
            isPressed = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, translateY, 0),
          height: 88,
          constraints: const BoxConstraints(
            minWidth: 280,
            maxWidth: 360,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE2E8F0),
                offset: Offset(0, bottomBorder),
                blurRadius: 0,
              ),
              BoxShadow(
                color: const Color(0x220F172A),
                offset: Offset(0, shadowOffset),
                blurRadius: isHovering ? 30 : 24,
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: Color(0xFF0F172A),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.string(
                        _googleLogoSvg,
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Begin Journey',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
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

class _MeshBackground extends StatelessWidget {
  const _MeshBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
        ),
        _BlurOrb(
          top: -120,
          left: -120,
          size: 430,
          color: Color(0xFFE0E7FF),
        ),
        _BlurOrb(
          top: -110,
          right: -120,
          size: 430,
          color: Color(0xFFF3E8FF),
        ),
        _BlurOrb(
          top: 220,
          left: 0,
          right: 0,
          size: 540,
          color: Color(0xFFEEF2FF),
          center: true,
        ),
      ],
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final double? top;
  final double? left;
  final double? right;
  final double size;
  final Color color;
  final bool center;

  const _BlurOrb({
    this.top,
    this.left,
    this.right,
    required this.size,
    required this.color,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    final orb = IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.70),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.70),
              blurRadius: 140,
              spreadRadius: 40,
            ),
          ],
        ),
      ),
    );

    if (center) {
      return Positioned(
        top: top,
        left: 0,
        right: 0,
        child: Center(child: orb),
      );
    }

    return Positioned(
      top: top,
      left: left,
      right: right,
      child: orb,
    );
  }
}
