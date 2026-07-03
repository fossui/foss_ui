import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

void main() {
  Widget host(Widget child) => FossTheme(
    data: FossThemeData.light,
    child: WidgetsApp(
      color: const Color(0xFF000000),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: child,
    ),
  );

  testWidgets('opens, shows the title, and returns the popped value', (
    tester,
  ) async {
    late BuildContext ctx;
    Future<bool?>? pending;

    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      ),
    );

    pending = showFossDialog<bool>(
      context: ctx,
      builder: (context) => FossDialog(
        title: const Text('Delete project'),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delete project'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Delete project'), findsNothing);
    expect(await pending, isTrue);
  });

  testWidgets('scrim tap dismisses when barrierDismissible', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      ),
    );

    unawaited(
      showFossDialog<void>(
        context: ctx,
        builder: (context) => const FossDialog(title: Text('Hi')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hi'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Hi'), findsNothing);
  });

  testWidgets('renders body, description, filled footer, and closes', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    late BuildContext ctx;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      ),
    );

    unawaited(
      showFossDialog<void>(
        context: ctx,
        builder: (context) => FossDialog(
          title: const Text('Details'),
          description: const Text('The full story.'),
          content: const Text('Body copy.'),
          footerVariant: FossDialogFooterVariant.filled,
          style: const FossDialogStyle(maxWidth: 400),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('The full story.'), findsOneWidget);
    expect(find.text('Body copy.'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsNothing);
    handle.dispose();
  });

  group('FossDialogStyle.merge', () {
    test('lays every non-null field of other over this', () {
      const base = FossDialogStyle(
        backgroundColor: Color(0xFF111111),
        borderColor: Color(0xFF222222),
        borderRadius: 8,
        maxWidth: 320,
        titleStyle: TextStyle(fontSize: 10),
        descriptionStyle: TextStyle(fontSize: 11),
      );
      const over = FossDialogStyle(
        maxWidth: 480,
        shadows: [BoxShadow(blurRadius: 4)],
      );

      final merged = base.merge(over);

      expect(merged.backgroundColor, const Color(0xFF111111));
      expect(merged.borderColor, const Color(0xFF222222));
      expect(merged.borderRadius, 8);
      expect(merged.maxWidth, 480);
      expect(merged.shadows, const [BoxShadow(blurRadius: 4)]);
      expect(merged.titleStyle, const TextStyle(fontSize: 10));
      expect(merged.descriptionStyle, const TextStyle(fontSize: 11));
    });

    test('merge(null) returns this', () {
      const base = FossDialogStyle(maxWidth: 320);
      expect(base.merge(null), same(base));
    });
  });
}
