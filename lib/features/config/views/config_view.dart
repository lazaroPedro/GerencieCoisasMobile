import 'package:flutter/material.dart';
import 'package:gerencie_coisas/core/theme/theme_notifier.dart';


class ConfigView extends StatelessWidget {
  const ConfigView({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Configurações'),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: temaNotifier,
            builder: (context, themeMode, _) {
              return Row(
                children: [
                  const Text('Tema Escuro'),
                  Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (bool isDark) {
                      temaNotifier.value =
                          isDark ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

