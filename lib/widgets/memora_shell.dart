import 'package:flutter/material.dart';

const double kMemoraMaxWidth = 820;

class MemoraShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;

  const MemoraShell({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MemoraColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: MeshBackground(opacity: 0.7)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                  child: MemoraContent(
                    child: Row(
                      children: [
                        if (Navigator.canPop(context))
                          MemoraIconButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                        if (Navigator.canPop(context)) const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 25,
                                  height: 1.05,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.0,
                                  color: MemoraColors.text,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 5),
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: MemoraColors.muted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        ...actions,
                      ],
                    ),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MemoraContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const MemoraContent({
    super.key,
    required this.child,
    this.maxWidth = kMemoraMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class MemoraColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF0F172A);
  static const Color muted = Color(0xFF94A3B8);
  static const Color body = Color(0xFF64748B);
  static const Color border = Color(0xFFE5E7EB);
  static const Color softPurple = Color(0xFFEEF2FF);
  static const Color primary = Color(0xFF4F46E5);
  static const Color primary2 = Color(0xFF7C3AED);
  static const Color dark = Color(0xFF111827);
}

class MeshBackground extends StatelessWidget {
  final double opacity;

  const MeshBackground({
    super.key,
    this.opacity = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFF7F8FF),
              Color(0xFFFBF8FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -150,
              left: -130,
              child: _Blob(
                size: 300,
                color: const Color(0xFF6366F1).withValues(alpha: 0.11),
              ),
            ),
            Positioned(
              top: 95,
              right: -145,
              child: _Blob(
                size: 300,
                color: const Color(0xFF9333EA).withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: -160,
              left: 30,
              child: _Blob(
                size: 310,
                color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 90,
            spreadRadius: 32,
          ),
        ],
      ),
    );
  }
}

class MemoraIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const MemoraIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = MemoraColors.text,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: color,
        ),
      ),
    );
  }
}