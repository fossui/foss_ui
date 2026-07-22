import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

void main() {
  group('FossAccordionStyle.merge', () {
    test('null other returns this unchanged', () {
      const base = FossAccordionStyle(dividerColor: Color(0xFF111111));
      expect(base.merge(null), same(base));
    });

    test('other non-null fields win over this', () {
      const base = FossAccordionStyle(
        dividerColor: Color(0xFF111111),
        chevronColor: Color(0xFF222222),
      );
      const other = FossAccordionStyle(chevronColor: Color(0xFF333333));
      final merged = base.merge(other);
      expect(merged.chevronColor, const Color(0xFF333333));
      expect(merged.dividerColor, const Color(0xFF111111));
    });

    test('other null fields keep this values', () {
      const base = FossAccordionStyle(
        headerPadding: EdgeInsets.all(8),
        panelPadding: EdgeInsets.all(4),
      );
      const other = FossAccordionStyle(panelPadding: EdgeInsets.all(12));
      final merged = base.merge(other);
      expect(merged.headerPadding, const EdgeInsets.all(8));
      expect(merged.panelPadding, const EdgeInsets.all(12));
    });
  });
}
