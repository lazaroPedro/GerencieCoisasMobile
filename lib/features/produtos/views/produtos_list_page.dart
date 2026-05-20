import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gerencie_coisas/core/theme/app_colors.dart';
import '../model/produto.dart';
import 'produtos_detail_page.dart';
import 'produtos_form_page.dart';

final List<Produto> produtosFake = [
  Produto(
    id: 1,
    name: 'Notebook Dell Inspiron 15',
    description: 'Processador i5, 8GB RAM, 256GB SSD',
    quantity: 15,
    price: 2499.90,
    supplier: 'Tech Distribuidora Ltda',
    categoryId: 1,
  ),
  Produto(
    id: 2,
    name: 'Mouse sem fio Logitech M705',
    description: 'Mouse ergonômico com pilha de longa duração',
    quantity: 5,
    price: 189.90,
    supplier: 'InfoShop Comércio',
    categoryId: 2,
  ),
  Produto(
    id: 3,
    name: 'Monitor LG 24" Full HD',
    description: 'Monitor IPS 75Hz',
    quantity: 8,
    price: 1099.00,
    supplier: 'Tech Distribuidora Ltda',
    categoryId: 1,
  ),
];

class ProdutosListPage extends StatefulWidget {
  const ProdutosListPage({super.key});

  @override
  State<ProdutosListPage> createState() => _ProdutosListPageState();
}

class _ProdutosListPageState extends State<ProdutosListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Produto> get _produtosFiltrados {
    if (_searchQuery.isEmpty) return produtosFake;
    return produtosFake.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             p.supplier.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _formatarMoeda(double valor) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(valor);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _produtosFiltrados;

    return Scaffold(
      backgroundColor: AppColors.bodyBg,
      appBar: AppBar(
        title: const Text(
          'Produtos',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar produto ou fornecedor...',
              hintStyle: const WidgetStatePropertyAll(
                TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              leading: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              trailing: _searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    ]
                  : null,
              onChanged: (v) => setState(() => _searchQuery = v),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtrados.length} produto${filtrados.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: filtrados.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum produto encontrado.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 100, left: 16, right: 16),
                    itemCount: filtrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final produto = filtrados[index];
                      final estoqueBaixo = produto.quantity < 10;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProdutosDetailPage(produto: produto),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.hoverBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_rounded, 
                                  color: AppColors.primary, 
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      produto.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      produto.supplier,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatarMoeda(produto.price),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: estoqueBaixo 
                                                ? AppColors.danger.withOpacity(0.1) 
                                                : AppColors.success.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Qtd: ${produto.quantity}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: estoqueBaixo 
                                                  ? AppColors.danger 
                                                  : AppColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProdutosFormPage(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo Produto', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}