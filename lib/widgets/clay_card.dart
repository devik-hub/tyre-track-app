import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tyre_management/app/theme/clay_decorations.dart';

/// Claymorphism Card component.
/// Complies with MRF Retreading Franchise specifications:
/// - 24px-32px border radius
/// - 0.92 opacity white background
/// - Dual clay shadows (red glow bottom-right + white highlight top-left)
/// - Subtle translucent white border
class ClayCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool isDark;
  final double elevation;

  const ClayCard({
    super.key,
    required this.child,
    this.borderRadius = 28,
    this.color,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.isDark = false,
    this.elevation = 1.0,
  });

  @override
  State<ClayCard> createState() => _ClayCardState();
}

class _ClayCardState extends State<ClayCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedScale(
      scale: (_isPressed && widget.onTap != null) ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        padding: widget.padding ?? const EdgeInsets.all(16),
        decoration: ClayDecorations.card(
          borderRadius: widget.borderRadius,
          color: widget.color,
          isDark: widget.isDark,
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) {
          HapticFeedback.selectionClick();
          setState(() => _isPressed = true);
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: content,
      );
    }

    return content;
  }
}
