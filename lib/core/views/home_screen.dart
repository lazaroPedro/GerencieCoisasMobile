import 'package:flutter/material.dart';
import 'package:gerencie_coisas/features/categorias/views/categoria_view.dart';
import 'package:gerencie_coisas/features/config/views/config_view.dart';
import 'package:gerencie_coisas/features/movimentacoes/movimentacoes_list_page.dart';
import 'package:gerencie_coisas/features/produtos/views/produtos_list_page.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({
    super.key,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      // const Center(child: Text('Dashboard')),
      const ProdutosListPage(),
       CategoriaView(),
      const MovimentacoesListPage(),
       const ConfigView(),
    ];
    final titles = [
     // const Text('Dashboard'),
      const Text('Produtos'),
      const Text('Categorias'),
      const Text('Movimentações'),
      const Text('Configurações'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: titles[_index],
      ),

      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,

        onTap: (i) {
          setState(() {
            _index = i;
          });
        },

        type: BottomNavigationBarType.fixed,

        items: const [
      //    BottomNavigationBarItem(
      //      icon: Icon(Icons.dashboard),
          //  label: 'Dashboard',
     //     ),

          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Produtos',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.sell_outlined),
            label: 'Categorias',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Movimentações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}