import 'package:flutter/semantics.dart' show SemanticsRole;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

import 'host.dart';

const List<FossSelectItem<String>> _items = [
  FossSelectItem(value: 'a', label: 'Apple'),
  FossSelectItem(value: 'b', label: 'Banana'),
];

Finder _byRole(SemanticsRole role) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.role == role,
);

void main() {
  group('FossSelect a11y', () {
    testWidgets('popup is a menu and rows are menu items', (tester) async {
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      expect(_byRole(SemanticsRole.menu), findsOneWidget);
      expect(_byRole(SemanticsRole.menuItem), findsNWidgets(2));
    });

    testWidgets('multi rows carry the menuItemCheckbox role', (tester) async {
      await tester.pumpWidget(
        host(
          FossMultiSelect<String>(
            placeholder: 'Tags',
            items: _items,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Tags'));
      await tester.pumpAndSettle();

      expect(_byRole(SemanticsRole.menuItemCheckbox), findsNWidgets(2));
    });

    testWidgets('the closed trigger meets the Android tap target guideline', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (_) {},
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('focus returns to the trigger after close', (tester) async {
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(
        tester.binding.focusManager.primaryFocus?.debugLabel,
        'FossSelect trigger',
      );
    });

    testWidgets('the Android back button dismisses the popup', (tester) async {
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);

      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(handled, isTrue);
      expect(find.text('Banana'), findsNothing);
    });
  });
}
