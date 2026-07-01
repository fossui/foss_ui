import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foss_ui/foss_ui.dart';

void main() {
  group('FossSelectItem', () {
    test('defaults to enabled with no icon', () {
      const item = FossSelectItem<String>(value: 'a', label: 'Apple');
      expect(item.value, 'a');
      expect(item.label, 'Apple');
      expect(item.enabled, isTrue);
      expect(item.icon, isNull);
    });

    test('can be disabled and carry an icon', () {
      const icon = SizedBox.shrink();
      const item = FossSelectItem<int>(
        value: 1,
        label: 'One',
        icon: icon,
        enabled: false,
      );
      expect(item.enabled, isFalse);
      expect(item.icon, same(icon));
    });

    test('constructs at runtime', () {
      for (final v in <String>['a', 'b']) {
        final item = FossSelectItem<String>(value: v, label: v);
        expect(item.value, v);
      }
    });
  });

  group('FossSelectSize', () {
    test('exposes three sizes', () {
      expect(FossSelectSize.values, [
        FossSelectSize.sm,
        FossSelectSize.md,
        FossSelectSize.lg,
      ]);
    });
  });
}
