import 'package:flutter_test/flutter_test.dart';
import 'package:foss_ui/foss_ui.dart';

void main() {
  test('standard durations', () {
    expect(FossMotion.standard.skeleton, const Duration(seconds: 2));
    expect(FossMotion.standard.caretBlink, const Duration(seconds: 1));
  });

  test('copyWith overrides one duration', () {
    final m = FossMotion.standard.copyWith(
      skeleton: const Duration(seconds: 3),
    );
    expect(m.skeleton, const Duration(seconds: 3));
    expect(m.caretBlink, FossMotion.standard.caretBlink);
  });
}
