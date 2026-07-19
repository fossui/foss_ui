import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

void main() {
  group('FossOtpFieldStyle.merge', () {
    test('returns this when other is null', () {
      const base = FossOtpFieldStyle(slotSize: 40);
      expect(identical(base.merge(null), base), isTrue);
    });

    test('lays every non-null field of other over this', () {
      const base = FossOtpFieldStyle(slotSize: 36, gap: 8);
      const override = FossOtpFieldStyle(slotSize: 44);

      final merged = base.merge(override);

      expect(merged.slotSize, 44);
      expect(merged.gap, 8);
    });

    test('keeps a field when other leaves it null', () {
      const base = FossOtpFieldStyle(separatorColor: Color(0xFF111111));
      const override = FossOtpFieldStyle(borderColor: Color(0xFF222222));

      final merged = base.merge(override);

      expect(merged.separatorColor, const Color(0xFF111111));
      expect(merged.borderColor, const Color(0xFF222222));
    });
  });
}
