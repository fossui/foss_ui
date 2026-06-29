import 'package:flutter/widgets.dart';
import 'package:foss_ui/src/theme/foss_theme.dart';
import 'package:foss_ui/src/theme/motion/foss_motion.dart';

/// The scrim behind a modal overlay: black at 32% opacity (alpha 0x52).
const _scrim = Color(0x52000000);

/// Opens [builder] as a centered modal route, the shared foundation for the
/// dialog and alert dialog.
///
/// Wraps [showGeneralDialog] so the framework supplies the scrim, focus trap,
/// and focus restoration. The active [FossThemeData] is captured here and
/// re-provided inside the route (which mounts above the app's [FossTheme]), so
/// `context.fossTheme` resolves the same tokens. The enter and exit run a fade
/// plus a slight scale over [FossMotion.overlay], zeroed under
/// `MediaQuery.disableAnimations`.
Future<T?> showFossModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useRootNavigator = true,
}) {
  final theme = context.fossTheme;
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ?? (barrierDismissible ? 'Dismiss' : null),
    barrierColor: _scrim,
    transitionDuration: reduceMotion ? Duration.zero : theme.motion.overlay,
    pageBuilder: (context, animation, secondaryAnimation) => FossTheme(
      data: theme,
      // The route mounts outside any Material or DefaultTextStyle, so text
      // would fall back to the framework's debug style. Set a clean base.
      child: DefaultTextStyle(
        style: theme.typography.base.copyWith(
          color: theme.colors.popoverForeground,
          decoration: TextDecoration.none,
        ),
        child: Builder(builder: builder),
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
