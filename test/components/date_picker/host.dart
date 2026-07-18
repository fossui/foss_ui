import 'package:flutter/widgets.dart';
import 'package:fossui/fossui.dart';

/// Wraps [child] in a themed [WidgetsApp] so the calendar dialog has a
/// Navigator to push its modal route onto. Mirrors the dialog test harness.
Widget host(
  Widget child, {
  FossThemeData? theme,
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  bool reduceMotion = false,
}) => FossTheme(
  data: theme ?? FossThemeData.light,
  child: WidgetsApp(
    color: const Color(0xFF000000),
    pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, _, _) => builder(context),
    ),
    home: Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: MediaQueryData(
          size: const Size(800, 600),
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reduceMotion,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  ),
);
