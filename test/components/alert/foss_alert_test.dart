import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foss_ui/foss_ui.dart';

void main() {
  Widget host(Widget child, {FossThemeData? theme}) => FossTheme(
    data: theme ?? FossThemeData.light,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 320, child: child),
      ),
    ),
  );

  testWidgets('renders title, description, and an action', (tester) async {
    await tester.pumpWidget(
      host(
        FossAlert(
          variant: FossAlertVariant.warning,
          title: const Text('Storage almost full'),
          description: const Text('Free up space.'),
          actions: [
            GestureDetector(onTap: () {}, child: const Text('Upgrade')),
          ],
        ),
      ),
    );

    expect(find.text('Storage almost full'), findsOneWidget);
    expect(find.text('Free up space.'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every variant builds without overflow', (tester) async {
    for (final variant in FossAlertVariant.values) {
      await tester.pumpWidget(
        host(FossAlert(variant: variant, title: Text(variant.name))),
      );
      expect(find.text(variant.name), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('neutral fill lifts on a dark theme', (tester) async {
    await tester.pumpWidget(
      host(
        const FossAlert(title: Text('Neutral')),
        theme: FossThemeData.dark,
      ),
    );

    expect(find.text('Neutral'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('FossAlertStyle.merge', () {
    test('lays every non-null field of other over this', () {
      const base = FossAlertStyle(
        backgroundColor: Color(0xFF111111),
        borderColor: Color(0xFF222222),
        iconColor: Color(0xFF333333),
        borderRadius: 8,
        titleStyle: TextStyle(fontSize: 10),
        descriptionStyle: TextStyle(fontSize: 11),
      );
      const over = FossAlertStyle(
        borderColor: Color(0xFF444444),
        borderRadius: 12,
      );

      final merged = base.merge(over);

      expect(merged.backgroundColor, const Color(0xFF111111));
      expect(merged.borderColor, const Color(0xFF444444));
      expect(merged.iconColor, const Color(0xFF333333));
      expect(merged.borderRadius, 12);
      expect(merged.titleStyle, const TextStyle(fontSize: 10));
      expect(merged.descriptionStyle, const TextStyle(fontSize: 11));
    });

    test('merge(null) returns this', () {
      const base = FossAlertStyle(borderRadius: 8);
      expect(base.merge(null), same(base));
    });
  });
}
