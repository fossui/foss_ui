// The barrel is imported purely so this smoke test fails to compile if the
// public entry point ever breaks. It exports nothing usable yet, hence unused.
// ignore_for_file: unused_import
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

void main() {
  test('package imports cleanly', () {
    // Smoke test: the barrel resolves. Replace with widget/golden tests
    // as components land.
    expect(true, isTrue);
  });
}
