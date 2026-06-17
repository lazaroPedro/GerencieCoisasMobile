import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart'; // <-- Importação do pacote
import 'package:gerencie_coisas/core/theme/app_colors.dart';
import '../model/produto.dart';
import '../services/produto_service.dart';
import 'produtos_detail_page.dart';
import 'produtos_form_page.dart';

class ProdutosListPage extends StatefulWidget {
  const ProdutosListPage({super.key});

  @override
  State<ProdutosListPage> createState() => _ProdutosListPageState();
}

class _ProdutosListPageState extends State<ProdutosListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Produto> _todosProdutos = [];
  final _service = ProdutoService();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final dados = await _service.listar();
    setState(() => _todosProdutos = dados);
  }

  List<Produto> get _produtosFiltrados {
    if (_searchQuery.isEmpty) return _todosProdutos;
    return _todosProdutos.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.supplier.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.barcode?.contains(_searchQuery) ?? false);
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
        title: Text(
          'titulo_produtos'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Semantics(
              label: 'semantics_buscar_produto'.tr(),
              textField: true,
              child: SearchBar(
                controller: _searchController,
                hintText: 'hint_buscar_produto'.tr(),
                hintStyle: const WidgetStatePropertyAll(
                  TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                leading: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                ),
                trailing:
                    _searchQuery.isNotEmpty
                        ? [
                          IconButton(
                            tooltip: 'tooltip_limpar_busca'.tr(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                        ]
                        : null,
                onChanged: (v) => setState(() => _searchQuery = v),
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: const WidgetStatePropertyAll(
                  AppColors.surface,
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtrados.length} ${filtrados.length != 1 ? 'produto_plural'.tr() : 'produto_singular'.tr()}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                filtrados.isEmpty
                    ? Center(
                      child: Text(
                        'msg_nenhum_produto'.tr(),
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _carregarDados,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 100,
                          left: 16,
                          right: 16,
                        ),
                        itemCount: filtrados.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final produto = filtrados[index];
                          final estoqueBaixo = produto.quantity < 10;
                          final barcodeLabel =
                              produto.barcode != null &&
                                      produto.barcode!.isNotEmpty
                                  ? 'texto_codigo_barras_prefix'.tr(args: [produto.barcode!])
                                  : '';
                          final statusEstoque =
                              estoqueBaixo
                                  ? 'status_estoque_baixo'.tr()
                                  : 'status_estoque_suficiente'.tr();

                          return Semantics(
                            button: true,
                            label: 'semantics_produto_card'.tr(args: [
                              produto.name, 
                              produto.supplier, 
                              _formatarMoeda(produto.price), 
                              produto.quantity.toString(), 
                              statusEstoque, 
                              barcodeLabel
                            ]),
                            child: ExcludeSemantics(
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ProdutosDetailPage(
                                            produto: produto,
                                          ),
                                    ),
                                  );
                                  _carregarDados();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.hoverBg,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                            if (produto.barcode != null &&
                                                produto
                                                    .barcode!
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'label_codigo'.tr(args: [produto.barcode!]),
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        estoqueBaixo
                                                            ? AppColors.danger
                                                                .withValues(
                                                                  alpha: 0.1,
                                                                )
                                                            : AppColors.success
                                                                .withValues(
                                                                  alpha: 0.1,
                                                                ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'label_qtd'.tr(args: [produto.quantity.toString()]),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          estoqueBaixo
                                                              ? AppColors.danger
                                                              : AppColors
                                                                  .success,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'tooltip_add_produto'.tr(), 
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProdutosFormPage()),
          );
          _carregarDados();
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'botao_novo_produto'.tr(), // <-- Texto traduzido
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}