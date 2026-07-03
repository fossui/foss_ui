import 'package:flutter/material.dart' show Theme, ThemeData, ThemeExtension;
import 'package:flutter/widgets.dart';
import 'package:fossui/src/theme/colors/foss_colors.dart';
import 'package:fossui/src/theme/motion/foss_motion.dart';
import 'package:fossui/src/theme/radii/foss_radii.dart';
import 'package:fossui/src/theme/shadows/foss_shadows.dart';
import 'package:fossui/src/theme/spacing/foss_spacing.dart';
import 'package:fossui/src/theme/typography/foss_typography.dart';

/// The root token bundle: the six leaf bundles in one object. Register it once,
/// then read everything through `context.fossTheme`. [FossThemeData.light] and
/// [FossThemeData.dark] are the defaults; build your own to retheme the app.
///
/// ```dart
/// MaterialApp(
///   theme: FossThemeData.light.toThemeData(),
///   darkTheme: FossThemeData.dark.toThemeData(),
/// );
/// ```
@immutable
class FossThemeData extends ThemeExtension<FossThemeData> {
  /// Creates a theme from explicit bundles. Prefer the named defaults.
  const FossThemeData({
    required this.colors,
    required this.radii,
    required this.spacing,
    required this.typography,
    required this.shadows,
    required this.motion,
  });

  /// The default light theme.
  static const light = FossThemeData(
    colors: FossColors.light,
    radii: FossRadii.standard,
    spacing: FossSpacing.standard,
    typography: FossTypography.standard,
    shadows: FossShadows.standard,
    motion: FossMotion.standard,
  );

  /// The default dark theme (light, with the dark color set).
  static const dark = FossThemeData(
    colors: FossColors.dark,
    radii: FossRadii.standard,
    spacing: FossSpacing.standard,
    typography: FossTypography.standard,
    shadows: FossShadows.standard,
    motion: FossMotion.standard,
  );

  /// Semantic color roles.
  final FossColors colors;

  /// Corner radii.
  final FossRadii radii;

  /// Spacing scale.
  final FossSpacing spacing;

  /// Text styles.
  final FossTypography typography;

  /// Elevation shadows.
  final FossShadows shadows;

  /// Animation durations.
  final FossMotion motion;

  @override
  FossThemeData copyWith({
    FossColors? colors,
    FossRadii? radii,
    FossSpacing? spacing,
    FossTypography? typography,
    FossShadows? shadows,
    FossMotion? motion,
  }) => FossThemeData(
    colors: colors ?? this.colors,
    radii: radii ?? this.radii,
    spacing: spacing ?? this.spacing,
    typography: typography ?? this.typography,
    shadows: shadows ?? this.shadows,
    motion: motion ?? this.motion,
  );

  // Hand-written, not generated: each bundle must lerp through its own encoder,
  // so a generated default (which would snap the bundle fields) is not usable.
  @override
  FossThemeData lerp(covariant FossThemeData? other, double t) {
    if (other == null) return this;
    return FossThemeData(
      colors: colors.lerp(other.colors, t),
      radii: radii.lerp(other.radii, t),
      spacing: spacing.lerp(other.spacing, t),
      typography: typography.lerp(other.typography, t),
      shadows: shadows.lerp(other.shadows, t),
      motion: motion.lerp(other.motion, t),
    );
  }

  /// This theme wrapped in a [ThemeData], to register on `MaterialApp.theme`.
  /// Registers the theme as an extension; it does not restyle Material widgets.
  ///
  /// ```dart
  /// MaterialApp(theme: FossThemeData.light.toThemeData());
  /// ```
  ThemeData toThemeData() => ThemeData(extensions: [this]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FossThemeData &&
          colors == other.colors &&
          radii == other.radii &&
          spacing == other.spacing &&
          typography == other.typography &&
          shadows == other.shadows &&
          motion == other.motion;

  @override
  int get hashCode =>
      Object.hash(colors, radii, spacing, typography, shadows, motion);
}

/// Provides a [FossThemeData] to its subtree for non-Material apps. Material
/// apps can instead register the theme in `ThemeData.extensions`; either way
/// `context.fossTheme` resolves it.
///
/// ```dart
/// FossTheme(
///   data: FossThemeData.light,
///   child: const MyApp(),
/// );
/// ```
class FossTheme extends InheritedWidget {
  /// Creates a theme scope.
  const FossTheme({required this.data, required super.child, super.key});

  /// The theme exposed to the subtree.
  final FossThemeData data;

  /// The nearest [FossThemeData] above [context], or null if none.
  static FossThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FossTheme>()?.data;

  @override
  bool updateShouldNotify(FossTheme oldWidget) => data != oldWidget.data;
}

/// The single way to read fossui tokens.
///
/// Resolves the [FossTheme] InheritedWidget first, then a `FossThemeData`
/// registered in `ThemeData.extensions`, and finally the light default, so it
/// works under MaterialApp, CupertinoApp, or a bare WidgetsApp.
///
/// ```dart
/// final t = context.fossTheme;
/// Container(color: t.colors.background, padding: t.spacing.all(4));
/// ```
extension FossThemeContext on BuildContext {
  /// The active fossui theme.
  FossThemeData get fossTheme =>
      FossTheme.maybeOf(this) ??
      Theme.of(this).extension<FossThemeData>() ??
      FossThemeData.light;
}
