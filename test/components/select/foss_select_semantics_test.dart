import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

import 'host.dart';

const List<FossSelectItem<String>> _items = [
  FossSelectItem(value: 'a', label: 'Apple'),
  FossSelectItem(value: 'b', label: 'Banana'),
];

void main() {
  group('FossSelect sizing', () {
    bool hasMinHeight(WidgetTester tester, double height) => tester
        .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
        .any((b) => b.constraints.minHeight == height);

    testWidgets('sm resolves the trigger to a 32 minimum height', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const FossSelect<String>(
            placeholder: 'Pick',
            size: FossSelectSize.sm,
            items: _items,
          ),
        ),
      );
      expect(hasMinHeight(tester, 32), isTrue);
    });

    testWidgets('md resolves the trigger to a 36 minimum height', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const FossSelect<String>(placeholder: 'Pick', items: _items)),
      );
      expect(hasMinHeight(tester, 36), isTrue);
    });

    testWidgets('lg resolves the trigger to a 40 minimum height', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const FossSelect<String>(
            placeholder: 'Pick',
            size: FossSelectSize.lg,
            items: _items,
          ),
        ),
      );
      expect(hasMinHeight(tester, 40), isTrue);
    });
  });

  group('FossSelect semantics', () {
    Finder triggerOf(String text) => find.ancestor(
      of: find.text(text),
      matching: find.byType(FocusableActionDetector),
    );

    testWidgets('the trigger is a button that reports its expanded state', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        tester.getSemantics(triggerOf('Pick')),
        isSemantics(
          isButton: true,
          hasExpandedState: true,
          isExpanded: false,
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(triggerOf('Pick')),
        isSemantics(isExpanded: true),
      );
    });

    testWidgets('errorText is announced as a hint on the trigger', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const FossSelect<String>(
            placeholder: 'Pick',
            errorText: 'Required',
            items: _items,
          ),
        ),
      );

      expect(
        tester.getSemantics(triggerOf('Pick')),
        isSemantics(hint: 'Required'),
      );
    });

    testWidgets('a picked row reports itself as selected', (tester) async {
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            value: 'b',
            items: _items,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      final row = find.ancestor(
        of: find.text('Banana'),
        matching: find.byType(MergeSemantics),
      );
      expect(
        tester.getSemantics(row),
        isSemantics(isSelected: true, label: 'Banana'),
      );
    });
  });
}
