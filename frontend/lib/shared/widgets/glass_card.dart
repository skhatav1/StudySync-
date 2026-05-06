import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoration = BoxDecoration(
      gradient: gradient,
      color: gradient == null ? theme.cardTheme.color : null,
      borderRadius: BorderRadius.circular(8),
      border:
          Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.14)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.18 : 0.04),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
    final content = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      ),
    );
  }
}
