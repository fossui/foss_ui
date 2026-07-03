import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

void main() {
  const s = FossSpacing.standard;

  test('unit defaults to 4', () {
    expect(s.unit, 4);
  });

  test('call scales the unit, including half steps', () {
    expect(s(2), 8);
    expect(s(1.5), 6);
    expect(s(0.25), 1);
  });

  test('all builds an inset from the scaled unit', () {
    expect(s.all(2), const EdgeInsets.all(8));
  });

  test('retheming the unit reshapes the whole scale', () {
    const dense = FossSpacing(unit: 2);
    expect(dense(4), 8);
  });

  test('lerp eases the unit', () {
    final mid = s.lerp(const FossSpacing(unit: 8), 0.5);
    expect(mid.unit, 6); // 4 -> 8 halfway
  });
}
