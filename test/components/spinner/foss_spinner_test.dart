import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

Widget _host(Widget child, {bool reduceMotion = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Center(child: child),
  ),
);

CustomPainter _painterOf(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(FossSpinner),
      matching: find.byType(CustomPaint),
    ),
  );
  final painter = paint.painter;
  if (painter == null) fail('spinner has no painter');
  return painter;
}

void main() {
  testWidgets('rotates while animating', (tester) async {
    await tester.pumpWidget(_host(const FossSpinner()));
    expect(
      find.descendant(
        of: find.byType(FossSpinner),
        matching: find.byType(RotationTransition),
      ),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 16)); // animation runs
  });

  testWidgets('sizes to the given dimension', (tester) async {
    await tester.pumpWidget(_host(const FossSpinner(size: 40)));
    final box = tester.widget<SizedBox>(
      find
          .descendant(
            of: find.byType(FossSpinner),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(box.width, 40);
    expect(box.height, 40);
  });

  testWidgets('uses the explicit color', (tester) async {
    const pink = Color(0xFFFF00FF);
    await tester.pumpWidget(_host(const FossSpinner(color: pink)));
    expect((_painterOf(tester) as dynamic).color, pink);
  });

  testWidgets('defaults to the foreground token', (tester) async {
    await tester.pumpWidget(_host(const FossSpinner()));
    expect(
      (_painterOf(tester) as dynamic).color,
      FossThemeData.light.colors.foreground,
    );
  });

  testWidgets('repaints when the color changes', (tester) async {
    await tester.pumpWidget(_host(const FossSpinner(color: Color(0xFFFF00FF))));
    await tester.pumpWidget(_host(const FossSpinner(color: Color(0xFF00FFFF))));

    expect((_painterOf(tester) as dynamic).color, const Color(0xFF00FFFF));
  });

  testWidgets('strokes size / 12 with a round cap', (tester) async {
    await tester.pumpWidget(_host(const FossSpinner(size: 36)));
    final canvas = _RecordingCanvas();
    _painterOf(tester).paint(canvas, const Size(36, 36));
    final paint = canvas.arcPaint;
    expect(paint?.strokeWidth, 36 / 12);
    expect(paint?.strokeCap, StrokeCap.round);
    expect(paint?.style, PaintingStyle.stroke);
  });

  testWidgets('rotates on the spinner motion period', (tester) async {
    expect(
      FossThemeData.light.motion.spinner,
      const Duration(milliseconds: 1000),
    );
    await tester.pumpWidget(_host(const FossSpinner()));
    await tester.pump(const Duration(milliseconds: 500));
    final rotation = tester.widget<RotationTransition>(
      find.descendant(
        of: find.byType(FossSpinner),
        matching: find.byType(RotationTransition),
      ),
    );
    // Half the 1000ms token period is half a turn, pinning the controller
    // duration to motion.spinner.
    expect(rotation.turns.value, closeTo(0.5, 0.02));
  });

  testWidgets('keeps a ticker running while animating', (tester) async {
    await tester.pumpWidget(_host(const FossSpinner()));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('reduced motion renders a static arc and stops the ticker', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const FossSpinner(), reduceMotion: true));
    expect(
      find.descendant(
        of: find.byType(FossSpinner),
        matching: find.byType(RotationTransition),
      ),
      findsNothing,
    );
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('announces a default loading label', (tester) async {
    await tester.pumpWidget(_host(const FossSpinner()));
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
  });

  testWidgets('honors a custom semantic label', (tester) async {
    await tester.pumpWidget(
      _host(const FossSpinner(semanticLabel: 'Fetching')),
    );
    expect(find.bySemanticsLabel('Fetching'), findsOneWidget);
  });
}

// Captures the arc Paint so a test can pin stroke geometry without a golden.
class _RecordingCanvas implements Canvas {
  Paint? arcPaint;

  @override
  void drawArc(
    Rect rect,
    double startAngle,
    double sweepAngle,
    bool useCenter,
    Paint paint,
  ) => arcPaint = paint;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
