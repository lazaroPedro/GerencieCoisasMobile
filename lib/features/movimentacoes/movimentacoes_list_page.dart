import 'package:flutter/material.dart';
import 'movimentacao_model.dart';
import 'movimentacoes_detail_page.dart';
import 'movimentacoes_form_page.dart';
import 'widgets/movimentacao_card.dart';

class MovimentacoesListPage extends StatefulWidget {
  const MovimentacoesListPage({super.key});

  @override
  State<MovimentacoesListPage> createState() => _MovimentacoesListPageState();
}

class _MovimentacoesListPageState extends State<MovimentacoesListPage> {
  // Filtro: null = todos, entrada, saida
  TipoMovimentacao? _filtroTipo;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Movimentacao> get _movimentacoesFiltradas {
    return movimentacoesFake.where((m) {
      final matchTipo = _filtroTipo == null || m.tipo == _filtroTipo;
      final matchSearch = _searchQuery.isEmpty ||
          m.produto.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.fornecedor.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchTipo && matchSearch;
    }).toList();
  }

  double get _totalEntradas {
    return movimentacoesFake
        .where((m) => m.tipo == TipoMovimentacao.entrada)
        .fold(0, (sum, m) => sum + m.valorTotal);
  }

  double get _totalSaidas {
    return movimentacoesFake
        .where((m) => m.tipo == TipoMovimentacao.saida)
        .fold(0, (sum, m) => sum + m.valorTotal);
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filtradas = _movimentacoesFiltradas;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text(
          'Movimentações',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filtros avançados',
            onPressed: () {
              // Futuro: bottom sheet de filtros avançados
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kkkkkk fiz isso tbm n man'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumo – cards de totais
          _ResumoBar(
            totalEntradas: _totalEntradas,
            totalSaidas: _totalSaidas,
            formatCurrency: _formatCurrency,
          ),

          // Barra de busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar por produto ou fornecedor...',
              leading: const Icon(Icons.search_rounded),
              trailing: _searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    ]
                  : null,
              onChanged: (v) => setState(() => _searchQuery = v),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                      color: colorScheme.outline.withOpacity(0.3), width: 1),
                ),
              ),
            ),
          ),

          // Chips de filtro
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todos',
                  selected: _filtroTipo == null,
                  onSelected: (_) => setState(() => _filtroTipo = null),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Entradas',
                  selected: _filtroTipo == TipoMovimentacao.entrada,
                  onSelected: (_) => setState(() =>
                      _filtroTipo = TipoMovimentacao.entrada),
                  color: const Color(0xFF2E7D32),
                  icon: Icons.arrow_downward_rounded,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Saídas',
                  selected: _filtroTipo == TipoMovimentacao.saida,
                  onSelected: (_) => setState(
                      () => _filtroTipo = TipoMovimentacao.saida),
                  color: const Color(0xFFC62828),
                  icon: Icons.arrow_upward_rounded,
                ),
              ],
            ),
          ),

          // Contador de resultados
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
            child: Row(
              children: [
                Text(
                  '${filtradas.length} registro${filtradas.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: filtradas.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 100),
                    itemCount: filtradas.length,
                    itemBuilder: (context, index) {
                      final m = filtradas[index];
                      return MovimentacaoCard(
                        movimentacao: m,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MovimentacoesDetailPage(movimentacao: m),
                            ),
                          );
                        },
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
              builder: (_) => const MovimentacoesFormPage(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova movimentação'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}

// Widgets internos

class _ResumoBar extends StatelessWidget {
  final double totalEntradas;
  final double totalSaidas;
  final String Function(double) formatCurrency;

  const _ResumoBar({
    required this.totalEntradas,
    required this.totalSaidas,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _ResumoCard(
              label: 'Entradas',
              valor: formatCurrency(totalEntradas),
              icon: Icons.arrow_downward_rounded,
              color: const Color(0xFF2E7D32),
              background: const Color(0xFFE8F5E9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ResumoCard(
              label: 'Saídas',
              valor: formatCurrency(totalSaidas),
              icon: Icons.arrow_upward_rounded,
              color: const Color(0xFFC62828),
              background: const Color(0xFFFFEBEE),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icon;
  final Color color;
  final Color background;

  const _ResumoCard({
    required this.label,
    required this.valor,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  valor,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Color color;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: selected ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : color,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      backgroundColor: color.withOpacity(0.08),
      side: BorderSide(color: color.withOpacity(0.3)),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma movimentação encontrada',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}