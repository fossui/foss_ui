import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

void main() {
  group('FossToggleGroupStyle.merge', () {
    test('null other returns this', () {
      // Non-const so the constructor runs at runtime.
      final base = FossToggleGroupStyle(gap: 2);
      expect(identical(base.merge(null), base), isTrue);
    });

    test('other overrides set fields, keeps the rest', () {
      const base = FossToggleGroupStyle(gap: 2);
      const override = FossToggleGroupStyle(
        connectedBorderColor: Color(0xFF0000FF),
      );

      final merged = base.merge(override);
      expect(merged.gap, 2);
      expect(merged.connectedBorderColor, const Color(0xFF0000FF));
    });
  });
}
