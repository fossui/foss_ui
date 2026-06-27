import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foss_ui/foss_ui.dart';

void main() {
  group('FossTextFieldStyle.merge', () {
    test('lays each non-null field of the argument over the receiver', () {
      const base = FossTextFieldStyle(borderRadius: 8, gap: 4, minHeight: 34);
      const over = FossTextFieldStyle(borderRadius: 99);

      final merged = base.merge(over);

      expect(merged.borderRadius, 99, reason: 'overridden');
      expect(merged.gap, 4, reason: 'kept from base');
      expect(merged.minHeight, 34, reason: 'kept from base');
    });

    test('a null argument keeps the receiver unchanged', () {
      const base = FossTextFieldStyle(borderRadius: 8, gap: 4);

      final merged = base.merge(null);

      expect(merged.borderRadius, 8);
      expect(merged.gap, 4);
    });

    test('a null field on the argument does not erase the receiver', () {
      const base = FossTextFieldStyle(iconSize: 16);
      const over = FossTextFieldStyle(gap: 6);

      final merged = base.merge(over);

      expect(merged.iconSize, 16);
      expect(merged.gap, 6);
    });

    test('colors override', () {
      const base = FossTextFieldStyle(backgroundColor: Color(0xFF000000));
      const over = FossTextFieldStyle(borderColor: Color(0xFFFFFFFF));

      final merged = base.merge(over);

      expect(merged.backgroundColor, const Color(0xFF000000));
      expect(merged.borderColor, const Color(0xFFFFFFFF));
    });
  });
}
