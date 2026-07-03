import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

void main() {
  group('FossSelectStyle.merge', () {
    test('returns this when other is null', () {
      const base = FossSelectStyle(minHeight: 36, gap: 8);
      expect(base.merge(null), same(base));
    });

    test('other overrides matching fields', () {
      const base = FossSelectStyle(minHeight: 36, borderRadius: 10);
      const override = FossSelectStyle(borderRadius: 99);
      final merged = base.merge(override);
      expect(merged.minHeight, 36, reason: 'kept from base');
      expect(merged.borderRadius, 99, reason: 'overridden');
    });

    test('null fields on other inherit from this', () {
      const base = FossSelectStyle(iconSize: 18, gap: 8);
      const override = FossSelectStyle(gap: 4);
      final merged = base.merge(override);
      expect(merged.iconSize, 18);
      expect(merged.gap, 4);
    });
  });
}
