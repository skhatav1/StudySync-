import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(8);
    final decoration = BoxDecoration(
      gradient: gradient,
      color: gradient == null ? theme.cardTheme.color : null,
      borderRadius: borderRadius,
      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.14)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.18 : 0.04),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );

    if (onTap == null) {
      return Container(padding: padding, decoration: decoration, child: child);
    }

    // Use Ink so the ripple renders on top of the decoration correctly.
    return Semantics(
      label: semanticLabel,
      button: semanticLabel != null,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: Ink(
          decoration: decoration,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
