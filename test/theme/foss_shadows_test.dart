import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foss_ui/foss_ui.dart';

void main() {
  const s = FossShadows.standard;

  test('xs is a single soft layer', () {
    expect(s.xs.length, 1);
    expect(s.xs.first.offset, const Offset(0, 1));
    expect(s.xs.first.blurRadius, 2);
    expect(s.xs.first.color, const Color(0x0D000000)); // black at 5%
  });

  test('sm, md and lg are two-layer', () {
    expect(s.sm.length, 2);
    expect(s.md.length, 2);
    expect(s.lg.length, 2);
  });

  test('none is empty', () {
    expect(FossShadows.none, isEmpty);
  });

  test('lerp eases the layers instead of snapping', () {
    final mid = s.lerp(
      s.copyWith(xs: const [BoxShadow(blurRadius: 4)]),
      0.5,
    );
    expect(mid.xs.first.blurRadius, 3); // halfway 2 -> 4
  });

  test('copyWith overrides one step', () {
    final flat = s.copyWith(xs: FossShadows.none);
    expect(flat.xs, isEmpty);
    expect(flat.lg, s.lg);
  });
}
