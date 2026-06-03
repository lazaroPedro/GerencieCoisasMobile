import 'package:flutter/material.dart';
import 'package:gerencie_coisas/core/theme/theme_notifier.dart';
import '../../auth/services/auth_service.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ValueListenableBuilder<ThemeMode>(
              valueListenable: temaNotifier,
              builder: (context, themeMode, _) {
                return SwitchListTile(
                  title: const Text('Tema Escuro'),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (bool isDark) {
                    temaNotifier.value =
                        isDark ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair da conta'),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () async {
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Sair'),
                      content: const Text(
                        'Deseja realmente sair da sua conta?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Sair'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmar == true) {
                  await authService.logout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
