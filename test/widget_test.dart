import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerencie_coisas/core/theme/tema.dart';

void main() {
  testWidgets('Renderiza MaterialApp com tema do projeto', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Text(
                'Gerencie Coisas',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Gerencie Coisas'), findsOneWidget);

    final context = tester.element(find.text('Gerencie Coisas'));
    expect(
      Theme.of(context).scaffoldBackgroundColor,
      AppTheme.lightTheme.scaffoldBackgroundColor,
    );
  });
}
