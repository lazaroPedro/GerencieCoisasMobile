import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerencie_coisas/core/theme/theme_notifier.dart';

void main() {
  group('temaNotifier', () {
    tearDown(() {
      temaNotifier.value = ThemeMode.light;
    });

    test('deve iniciar em modo claro', () {
      expect(temaNotifier.value, ThemeMode.light);
    });

    test('deve permitir alterar para modo escuro', () {
      temaNotifier.value = ThemeMode.dark;

      expect(temaNotifier.value, ThemeMode.dark);
    });
  });
}
