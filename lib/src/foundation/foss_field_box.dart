import 'package:flutter/widgets.dart';

const double _ringWidth = 3;
const double _minTapTarget = 48;
const double _disabledOpacity = 0.64;

// Focus ring alpha, and the error border and ring alphas: the border deepens
// when the field is focused, the ring stays faint and lifts in dark mode.
const double _focusRingOpacity = 0.24;
const double _errorBorderOpacity = 0.36;
const double _errorBorderFocusedOpacity = 0.64;
const double _errorRingOpacityLight = 0.16;
const double _errorRingOpacityDark = 0.24;

// Inner top-lit rim at rest: a faint dark line in light mode, a faint white
// highlight in dark mode.
const Color _rimLight = Color(0x0A000000);
const Color _rimDark = Color(0x0FFFFFFF);

/// The shared field surface: resting fill, border, focus ring, resting rim and
/// shadow, a minimum height, and a touch target. Every field-shaped control
/// wraps its content in one of these so their chrome stays identical.
///
/// The caller owns the content and its padding, and adds any tap or selection
/// gesture around this box. The border, ring, rim, and shadow are derived from
/// [enabled], [hasError], and [focused]; the box is dimmed when disabled and is
/// centered in a region at least 48 logical pixels tall for the touch target.
class FossFieldBox extends StatelessWidget {
  /// Creates a field surface around [child].
  const FossFieldBox({
    required this.enabled,
    required this.hasError,
    required this.focused,
    required this.background,
    required this.borderColor,
    required this.ringColor,
    required this.destructiveColor,
    required this.borderRadius,
    required this.minHeight,
    required this.shadow,
    required this.isDark,
    required this.child,
    super.key,
  });

  /// Whether the field accepts input. When false the box dims.
  final bool enabled;

  /// Whether the field is invalid, which recolors the border and ring.
  final bool hasError;

  /// Whether the field holds focus, which shows the border and focus ring.
  final bool focused;

  /// The resting fill behind the content.
  final Color background;

  /// The border color while resting and valid.
  final Color borderColor;

  /// The focus accent, used for the border and ring while focused and valid.
  final Color ringColor;

  /// The invalid accent, used for the border and ring while [hasError].
  final Color destructiveColor;

  /// The corner radius of the surface and its ring.
  final double borderRadius;

  /// The minimum content height before the touch-target inflation.
  final double minHeight;

  /// The resting drop shadow, dropped whenever focused, invalid, or disabled.
  final List<BoxShadow> shadow;

  /// Whether the surrounding theme is dark, which tunes the rim and error ring.
  final bool isDark;

  /// The field content. The caller pads it; this box only frames it.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color? ring;
    if (hasError) {
      border = destructiveColor.withValues(
        alpha: focused ? _errorBorderFocusedOpacity : _errorBorderOpacity,
      );
      ring = focused
          ? destructiveColor.withValues(
              alpha: isDark ? _errorRingOpacityDark : _errorRingOpacityLight,
            )
          : null;
    } else if (focused) {
      border = ringColor;
      ring = ringColor.withValues(alpha: _focusRingOpacity);
    } else {
      border = borderColor;
      ring = null;
    }

    final showShadow = enabled && !focused && !hasError;

    Widget content = DecoratedBox(
      decoration: ShapeDecoration(
        color: background,
        shape: RoundedSuperellipseBorder(
          side: BorderSide(color: border),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        shadows: showShadow ? shadow : const [],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: child,
      ),
    );

    if (ring != null) {
      content = CustomPaint(
        foregroundPainter: _RingPainter(color: ring, radius: borderRadius),
        child: content,
      );
    }

    // At rest, a 1px inner rim; dropped under the same states as the shadow.
    // Dark lights the top edge with a white highlight, light darkens the bottom
    // edge. Rim radius is the inner edge (radius - 1).
    if (showShadow) {
      content = CustomPaint(
        foregroundPainter: _RimPainter(
          color: isDark ? _rimDark : _rimLight,
          radius: borderRadius - 1,
          topLit: isDark,
        ),
        child: content,
      );
    }

    if (!enabled) content = Opacity(opacity: _disabledOpacity, child: content);

    // Center the box in a region at least [_minTapTarget] tall so the field
    // meets the minimum touch-target guideline without inflating its height.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minTapTarget),
      child: Center(heightFactor: 1, child: content),
    );
  }
}

/// Paints a 1px rim inside the field: brightest along one edge, fading to
/// nothing by the middle. [topLit] lights the top edge; otherwise the bottom.
class _RimPainter extends CustomPainter {
  const _RimPainter({
    required this.color,
    required this.radius,
    required this.topLit,
  });

  final Color color;
  final double radius;
  final bool topLit;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(0.5);
    final shape = RSuperellipse.fromRectAndRadius(
      rect,
      Radius.circular(radius),
    );
    final shader = LinearGradient(
      begin: topLit ? Alignment.topCenter : Alignment.bottomCenter,
      end: Alignment.center,
      colors: [color, color.withValues(alpha: 0)],
    ).createShader(rect);
    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRSuperellipse(shape, paint);
  }

  @override
  bool shouldRepaint(_RimPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.topLit != topLit;
}

/// Paints the focus ring: a superellipse outset just past the field edge,
/// matching its corner shape so it reads smooth, not circular.
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).inflate(_ringWidth);
    final shape = RSuperellipse.fromRectAndRadius(
      rect,
      Radius.circular(radius + _ringWidth),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _ringWidth;
    canvas.drawRSuperellipse(shape, paint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
