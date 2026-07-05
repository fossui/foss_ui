import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

import 'host.dart';

const List<FossComboboxItem<String>> _items = [
  FossComboboxItem(value: 'a', label: 'Design'),
  FossComboboxItem(value: 'b', label: 'Engineering'),
];

String _text(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText)).controller.text;

/// True when any semantics node carries [label]. Robust against the node
/// merging that trips `find.bySemanticsLabel`.
bool _hasLabel(WidgetTester tester, String label) =>
    _any(tester, (n) => n.label.contains(label));

/// True when any semantics node reports the expanded state.
bool _anyExpanded(WidgetTester tester) => _any(tester, (n) {
  // hasFlag is deprecated but the flag-collection replacement has no stable
  // public getter across SDKs; the flag read stays correct.
  // ignore: deprecated_member_use
  return n.hasFlag(SemanticsFlag.isExpanded);
});

bool _any(WidgetTester tester, bool Function(SemanticsNode) test) {
  var found = false;
  void visit(SemanticsNode node) {
    if (test(node)) found = true;
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  // pipelineOwner is deprecated but remains the simplest whole-tree semantics
  // walk; the per-view replacement adds no coverage here.
  // ignore: deprecated_member_use
  visit(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return found;
}

/// Themed host that places [child] inside a scrollable, so an ancestor scroll
/// can be exercised.
Widget _scrollHost(Widget child) => FossTheme(
  data: FossThemeData.light,
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (_) => ListView(
              children: [
                const SizedBox(height: 80),
                Padding(padding: const EdgeInsets.all(16), child: child),
                const SizedBox(height: 1200),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  group('FossCombobox controlled value', () {
    testWidgets('reflects an external value change into the field', (
      tester,
    ) async {
      var value = 'a';
      late StateSetter setOuter;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return FossCombobox<String>(
                items: _items,
                value: value,
                onSelected: (_) {},
              );
            },
          ),
        ),
      );
      expect(_text(tester), 'Design');

      setOuter(() => value = 'b');
      await tester.pumpAndSettle();
      expect(_text(tester), 'Engineering');
    });

    testWidgets('clears the field when the value goes null', (tester) async {
      String? value = 'a';
      late StateSetter setOuter;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return FossCombobox<String>(
                items: _items,
                value: value,
                onSelected: (_) {},
              );
            },
          ),
        ),
      );
      expect(_text(tester), 'Design');

      setOuter(() => value = null);
      await tester.pumpAndSettle();
      expect(_text(tester), isEmpty);
    });
  });

  group('FossCombobox blur', () {
    testWidgets('restores the selected label when blurred without a pick', (
      tester,
    ) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        host(
          FossCombobox<String>(
            items: _items,
            value: 'a',
            focusNode: focus,
            onSelected: (_) {},
          ),
        ),
      );
      expect(_text(tester), 'Design');

      focus.requestFocus();
      await tester.enterText(find.byType(EditableText), 'zzz');
      await tester.pump();
      expect(_text(tester), 'zzz');

      focus.unfocus();
      await tester.pumpAndSettle();
      expect(_text(tester), 'Design');
    });
  });

  group('FossCombobox empty state', () {
    testWidgets('shows a custom emptyText', (tester) async {
      await tester.pumpWidget(
        host(
          FossCombobox<String>(
            items: _items,
            emptyText: 'Nothing here',
            onSelected: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('Nothing here'), findsOneWidget);
    });
  });

  group('FossCombobox style', () {
    testWidgets('forwards the override to the embedded field box', (
      tester,
    ) async {
      const fill = Color(0xFF123456);
      await tester.pumpWidget(
        host(
          FossCombobox<String>(
            items: _items,
            style: const FossComboboxStyle(backgroundColor: fill),
            onSelected: (_) {},
          ),
        ),
      );

      final field = tester.widget<FossTextField>(find.byType(FossTextField));
      expect(field.style?.backgroundColor, fill);
    });
  });

  group('FossCombobox semantics', () {
    testWidgets('the trigger button carries a label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(FossCombobox<String>(items: _items, onSelected: (_) {})),
      );

      expect(_hasLabel(tester, 'Show options'), isTrue);
      handle.dispose();
    });

    testWidgets('the clear button carries a label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          FossCombobox<String>(
            items: _items,
            value: 'a',
            showClear: true,
            onSelected: (_) {},
          ),
        ),
      );

      expect(_hasLabel(tester, 'Clear'), isTrue);
      handle.dispose();
    });

    testWidgets('the field reports its expanded state only while open', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        host(
          FossCombobox<String>(
            items: _items,
            focusNode: focus,
            onSelected: (_) {},
          ),
        ),
      );
      expect(_anyExpanded(tester), isFalse);

      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(_anyExpanded(tester), isTrue);
      handle.dispose();
    });
  });

  group('FossCombobox scroll', () {
    testWidgets('closes the popup when an ancestor scrolls', (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        _scrollHost(
          FossCombobox<String>(
            items: _items,
            focusNode: focus,
            onSelected: (_) {},
          ),
        ),
      );

      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(find.text('Engineering'), findsOneWidget);

      await tester.drag(find.byType(Scrollable).first, const Offset(0, -80));
      await tester.pumpAndSettle();
      expect(find.text('Engineering'), findsNothing);
    });
  });

  group('FossMultiCombobox', () {
    testWidgets('chip remove carries a custom removeLabel', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          FossMultiCombobox<String>(
            items: _items,
            values: const {'a'},
            removeLabel: 'Delete tag',
            onSelected: (_) {},
          ),
        ),
      );

      expect(_hasLabel(tester, 'Delete tag'), isTrue);
      handle.dispose();
    });
  });
}
