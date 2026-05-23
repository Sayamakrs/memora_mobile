import 'package:flutter/material.dart';

import 'memora_shell.dart';

class SoftCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final double radius;
  final bool outlined;
  final bool elevated;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.color = Colors.white,
    this.radius = 30,
    this.outlined = false,
    this.elevated = true,
  });

  @override
  State<SoftCard> createState() => _SoftCardState();
}

class _SoftCardState extends State<SoftCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, isPressed ? 3 : 0, 0),
      width: double.infinity,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: widget.outlined ? MemoraColors.border : Colors.white,
          width: 1.2,
        ),
        boxShadow: widget.elevated
            ? [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(
                    alpha: isPressed ? 0.035 : 0.075,
                  ),
                  blurRadius: isPressed ? 10 : 24,
                  offset: Offset(0, isPressed ? 5 : 14),
                ),
              ]
            : [],
      ),
      child: widget.child,
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: card,
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? null
              : const LinearGradient(
                  colors: [
                    MemoraColors.primary,
                    MemoraColors.primary2,
                  ],
                ),
          color: onPressed == null ? const Color(0xFFCBD5E1) : null,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            if (onPressed != null)
              BoxShadow(
                color: MemoraColors.primary.withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          onPressed: onPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon),
          label: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class MemoraPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const MemoraPill({
    super.key,
    required this.label,
    this.icon,
    this.color = MemoraColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon == null ? 12 : 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}