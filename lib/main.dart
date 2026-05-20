import 'package:flutter/material.dart';
import 'package:gerencie_coisas/core/theme/tema.dart';
import 'package:gerencie_coisas/core/views/home_screen.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerencie Coisas',
      theme: AppTheme.lightTheme,
      home: const HomeScreen()
    );
  }
}
