import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foss_ui/foss_ui.dart';

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

  testWidgets('scrim tap does not dismiss; the action returns a value', (
    tester,
  ) async {
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

    final pending = showFossAlertDialog<bool>(
      context: ctx,
      builder: (context) => FossAlertDialog(
        title: const Text('Delete account'),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Delete account'), findsOneWidget);

    // Tapping the scrim must not close a non-dismissible alert dialog.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Delete account'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete account'), findsNothing);
    expect(await pending, isTrue);
  });

  testWidgets('renders body, description, and honors a style width', (
    tester,
  ) async {
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
      showFossAlertDialog<void>(
        context: ctx,
        builder: (context) => FossAlertDialog(
          title: const Text('Session expired'),
          description: const Text('Sign in again to continue.'),
          content: const Text('Your token lapsed.'),
          style: const FossAlertDialogStyle(maxWidth: 360),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Session expired'), findsOneWidget);
    expect(find.text('Sign in again to continue.'), findsOneWidget);
    expect(find.text('Your token lapsed.'), findsOneWidget);
  });

  testWidgets('asserts on empty actions', (tester) async {
    expect(
      () => FossAlertDialog(actions: const [], title: const Text('x')),
      throwsAssertionError,
    );
  });

  group('FossAlertDialogStyle.merge', () {
    test('lays every non-null field of other over this', () {
      const base = FossAlertDialogStyle(
        backgroundColor: Color(0xFF111111),
        borderColor: Color(0xFF222222),
        borderRadius: 8,
        maxWidth: 320,
        titleStyle: TextStyle(fontSize: 10),
        descriptionStyle: TextStyle(fontSize: 11),
      );
      const over = FossAlertDialogStyle(
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
      const base = FossAlertDialogStyle(maxWidth: 320);
      expect(base.merge(null), same(base));
    });
  });
}
