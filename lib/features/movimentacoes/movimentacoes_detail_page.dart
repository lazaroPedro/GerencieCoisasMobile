import 'package:flutter/material.dart';
import 'movimentacao_model.dart';

class MovimentacoesDetailPage extends StatelessWidget {
  final Movimentacao movimentacao;

  const MovimentacoesDetailPage({super.key, required this.movimentacao});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEntrada = movimentacao.tipo == TipoMovimentacao.entrada;

    final tipoColor = isEntrada ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final tipoBackground = isEntrada ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final tipoLabel = isEntrada ? 'Entrada' : 'Saída';
    final tipoIcon =
        isEntrada ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text(
          'Detalhes',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Editar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edição disponível em breve!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card – tipo + produto + valor total
            _HeroCard(
              isEntrada: isEntrada,
              tipoLabel: tipoLabel,
              tipoIcon: tipoIcon,
              tipoColor: tipoColor,
              tipoBackground: tipoBackground,
              movimentacao: movimentacao,
              theme: theme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),

            // Seção: Informações do produto
            _SectionCard(
              title: 'Produto',
              icon: Icons.inventory_2_rounded,
              children: [
                _InfoRow(label: 'Nome', value: movimentacao.produto),
                _InfoRow(label: 'Categoria', value: movimentacao.categoria),
                _InfoRow(
                    label: 'Quantidade',
                    value: '${movimentacao.quantidade} unidades'),
              ],
            ),
            const SizedBox(height: 12),

            // Seção: Fornecedor
            _SectionCard(
              title: 'Fornecedor',
              icon: Icons.store_rounded,
              children: [
                _InfoRow(label: 'Empresa', value: movimentacao.fornecedor),
              ],
            ),
            const SizedBox(height: 12),

            // Seção: Valores
            _SectionCard(
              title: 'Valores',
              icon: Icons.attach_money_rounded,
              children: [
                _InfoRow(
                    label: 'Valor unitário',
                    value: movimentacao.valorUnitarioFormatado),
                _InfoRow(
                    label: 'Quantidade',
                    value: '× ${movimentacao.quantidade}'),
                const Divider(height: 24),
                _InfoRow(
                  label: 'Total',
                  value: movimentacao.valorFormatado,
                  valueStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: tipoColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Seção: Data
            _SectionCard(
              title: 'Data e hora',
              icon: Icons.calendar_today_rounded,
              children: [
                _InfoRow(
                    label: 'Registrado em',
                    value: movimentacao.dataHoraFormatada),
              ],
            ),

            // Observação (condicional)
            if (movimentacao.observacao != null) ...[
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Observação',
                icon: Icons.notes_rounded,
                children: [
                  Text(
                    movimentacao.observacao!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Botão de exclusão (futuro)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFC62828)),
                label: const Text(
                  'Excluir movimentação',
                  style: TextStyle(color: Color(0xFFC62828)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Color(0xFFC62828), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir movimentação?'),
        content: Text(
          'Tem certeza que deseja excluir a movimentação de "${movimentacao.produto}"? Esta ação não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kkkk fiz isso ainda n man'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

// Widgets internos

class _HeroCard extends StatelessWidget {
  final bool isEntrada;
  final String tipoLabel;
  final IconData tipoIcon;
  final Color tipoColor;
  final Color tipoBackground;
  final Movimentacao movimentacao;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _HeroCard({
    required this.isEntrada,
    required this.tipoLabel,
    required this.tipoIcon,
    required this.tipoColor,
    required this.tipoBackground,
    required this.movimentacao,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tipoBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tipoIcon, color: tipoColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tipoBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tipoLabel,
                        style: TextStyle(
                          color: tipoColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      movimentacao.produto,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valor Total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    movimentacao.valorFormatado,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: tipoColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Data',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    movimentacao.dataFormatada,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 16, color: colorScheme.primary.withOpacity(0.8)),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}