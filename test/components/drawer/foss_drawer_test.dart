import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foss_ui/foss_ui.dart';

void main() {
  Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
      FossTheme(
        data: FossThemeData.light,
        child: Directionality(
          textDirection: direction,
          child: WidgetsApp(
            color: const Color(0xFF000000),
            pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
              settings: settings,
              pageBuilder: (context, _, _) => builder(context),
            ),
            home: child,
          ),
        ),
      );

  Future<BuildContext> pumpHost(
    WidgetTester tester, {
    TextDirection direction = TextDirection.ltr,
  }) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
        direction: direction,
      ),
    );
    return ctx;
  }

  group('FossDrawerStyle.merge', () {
    test('other wins per field, null inherits', () {
      const base = FossDrawerStyle(
        backgroundColor: Color(0xFF111111),
        borderRadius: 8,
      );
      final merged = base.merge(
        const FossDrawerStyle(borderRadius: 20, borderColor: Color(0xFF222222)),
      );
      expect(merged.backgroundColor, const Color(0xFF111111));
      expect(merged.borderRadius, 20);
      expect(merged.borderColor, const Color(0xFF222222));
    });

    test('merge null returns this', () {
      const base = FossDrawerStyle(borderRadius: 12);
      expect(identical(base.merge(null), base), isTrue);
    });
  });

  testWidgets('opens, shows the title, and returns the popped value', (
    tester,
  ) async {
    final ctx = await pumpHost(tester);

    final pending = showFossDrawer<bool>(
      context: ctx,
      builder: (context) => FossDrawer(
        title: const Text('Filters'),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsOneWidget);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsNothing);
    expect(await pending, isTrue);
  });

  for (final side in FossDrawerSide.values) {
    testWidgets('opens from the $side edge', (tester) async {
      final ctx = await pumpHost(tester);
      unawaited(
        showFossDrawer<void>(
          context: ctx,
          side: side,
          builder: (context) => const FossDrawer(title: Text('Panel')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Panel'), findsOneWidget);
    });
  }

  testWidgets('scrim tap dismisses when barrierDismissible', (tester) async {
    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        builder: (context) => const FossDrawer(title: Text('Hi')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hi'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Hi'), findsNothing);
  });

  testWidgets('scrim tap is blocked when barrierDismissible is false', (
    tester,
  ) async {
    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        barrierDismissible: false,
        builder: (context) => const FossDrawer(title: Text('Stuck')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Stuck'), findsOneWidget);
  });

  testWidgets('close button shows on flag, dismisses, and is labelled', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        builder: (context) =>
            const FossDrawer(title: Text('Sheet'), showCloseButton: true),
      ),
    );
    await tester.pumpAndSettle();

    final closeFinder = find.bySemanticsLabel('Close');
    expect(closeFinder, findsOneWidget);
    expect(
      tester.getSemantics(closeFinder),
      matchesSemantics(label: 'Close', isButton: true, hasTapAction: true),
    );

    await tester.tap(closeFinder);
    await tester.pumpAndSettle();
    expect(find.text('Sheet'), findsNothing);
    handle.dispose();
  });

  testWidgets('renders with a drag handle', (tester) async {
    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        builder: (context) =>
            const FossDrawer(title: Text('Grab'), showHandle: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Grab'), findsOneWidget);
    expect(find.byType(FossDrawer), findsOneWidget);
  });

  testWidgets('header-absent renders content only', (tester) async {
    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        builder: (context) => const FossDrawer(content: Text('Body only')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Body only'), findsOneWidget);
  });

  testWidgets('drag past the threshold dismisses', (tester) async {
    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        builder: (context) => const FossDrawer(title: Text('Dragme')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dragme'), findsOneWidget);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Dragme')),
    );
    await gesture.moveBy(const Offset(0, 500));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Dragme'), findsNothing);
  });

  testWidgets('a short drag springs back', (tester) async {
    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        builder: (context) => const FossDrawer(title: Text('Springy')),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Springy')),
    );
    await gesture.moveBy(const Offset(0, 8));
    // Pause so the release carries no fling velocity.
    await tester.pump(const Duration(milliseconds: 400));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Springy'), findsOneWidget);
  });

  testWidgets('left drawer anchors to the start edge', (tester) async {
    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        side: FossDrawerSide.left,
        builder: (context) => const FossDrawer(title: Text('Side')),
      ),
    );
    await tester.pumpAndSettle();
    final left = tester.getTopLeft(find.text('Side')).dx;
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(left, lessThan(width / 2));
  });

  testWidgets('reduced motion still opens and closes', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: host(
          Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    unawaited(
      showFossDrawer<void>(
        context: ctx,
        builder: (context) => const FossDrawer(title: Text('Instant')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Instant'), findsOneWidget);
  });

  testWidgets('renders a description in the header', (tester) async {
    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        builder: (context) => const FossDrawer(
          title: Text('Titled'),
          description: Text('A supporting line.'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('A supporting line.'), findsOneWidget);
  });

  testWidgets('drag off the top edge dismisses', (tester) async {
    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        side: FossDrawerSide.top,
        builder: (context) => const FossDrawer(title: Text('Topper')),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Topper')),
    );
    await gesture.moveBy(const Offset(0, -500));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Topper'), findsNothing);
  });

  for (final (side, delta) in <(FossDrawerSide, Offset)>[
    (FossDrawerSide.left, Offset(-500, 0)),
    (FossDrawerSide.right, Offset(500, 0)),
  ]) {
    testWidgets('drag off the $side edge dismisses', (tester) async {
      final ctx = await pumpHost(tester);
      unawaited(
        showFossDrawer<void>(
          context: ctx,
          side: side,
          builder: (context) => const FossDrawer(title: Text('Panel')),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Panel')),
      );
      await gesture.moveBy(delta);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Panel'), findsNothing);
    });
  }

  testWidgets('a side panel shows its handle on the exposed edge', (
    tester,
  ) async {
    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        side: FossDrawerSide.right,
        builder: (context) =>
            const FossDrawer(title: Text('Rail'), showHandle: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rail'), findsOneWidget);
  });

  testWidgets('bottom drawer without actions pads the safe area', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(bottom: 40);
    addTearDown(tester.view.resetPadding);

    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        builder: (context) => const FossDrawer(content: Text('No footer')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No footer'), findsOneWidget);
  });

  testWidgets('survives an external rebuild while open', (tester) async {
    final ctx = await pumpHost(tester);
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        builder: (context) => const FossDrawer(title: Text('Persist')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Persist'), findsOneWidget);

    // Re-pump the whole tree: the route's page rebuilds, updating the side
    // scope in place.
    await pumpHost(tester);
    await tester.pumpAndSettle();
    expect(find.text('Persist'), findsOneWidget);
  });

  testWidgets('renders on a dark theme', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      FossTheme(
        data: FossThemeData.dark,
        child: WidgetsApp(
          color: const Color(0xFF000000),
          pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, _, _) => builder(context),
          ),
          home: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    unawaited(
      showFossDrawer<void>(
        context: ctx,
        builder: (context) => const FossDrawer(
          title: Text('Dark'),
          footerVariant: FossDrawerFooterVariant.filled,
          actions: [Text('OK')],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dark'), findsOneWidget);
  });
}
