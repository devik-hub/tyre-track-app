import 'package:flutter/material.dart';
import 'package:tyre_management/app/theme/clay_decorations.dart';

/// The universal Claymorphism card widget.
/// Replaces every Card() and Container() that acts as a surface in the app.
/// Use [isDark] = true in admin portal screens.
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isDark;
  final bool redAccent;
  final double blurStrength; // Kept for API compat, unused in clay
  final VoidCallback? onTap;
  final double elevation; // Kept for API compat

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 28,
    this.isDark = false,
    this.redAccent = false,
    this.blurStrength = 0,
    this.onTap,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = ClayDecorations.card(
      borderRadius: borderRadius,
      isDark: isDark,
      color: redAccent
          ? (isDark ? const Color(0xFF2A1818) : const Color(0xFFFFF0F0)).withOpacity(0.92)
          : null,
    );

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      card = _ClayTapWrapper(onTap: onTap!, child: card);
    }

    return Container(margin: margin, child: card);
  }
}

/// Press-down animation wrapper for tappable clay surfaces.
class _ClayTapWrapper extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _ClayTapWrapper({required this.onTap, required this.child});

  @override
  State<_ClayTapWrapper> createState() => _ClayTapWrapperState();
}

class _ClayTapWrapperState extends State<_ClayTapWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
