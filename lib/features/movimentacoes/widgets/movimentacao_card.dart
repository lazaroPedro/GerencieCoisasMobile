import 'package:flutter/material.dart';
import '../movimentacao_model.dart';

class MovimentacaoCard extends StatelessWidget {
  final Movimentacao movimentacao;
  final VoidCallback onTap;

  const MovimentacaoCard({
    super.key,
    required this.movimentacao,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEntrada = movimentacao.tipo == TipoMovimentacao.entrada;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tipoColor = isEntrada ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final tipoBackground =
        isEntrada ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final tipoLabel = isEntrada ? 'Entrada' : 'Saída';
    final tipoIcon = isEntrada ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone de tipo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tipoBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tipoIcon, color: tipoColor, size: 24),
              ),
              const SizedBox(width: 14),
              // Informações principais
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movimentacao.produto,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movimentacao.fornecedor,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Badge de tipo
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tipoBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tipoLabel,
                            style: TextStyle(
                              color: tipoColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${movimentacao.quantidade} un.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Valor e data
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    movimentacao.valorFormatado,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tipoColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movimentacao.dataFormatada,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.45),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}