import 'package:flutter_test/flutter_test.dart';
import 'package:gerencie_coisas/features/movimentacoes/movimentacao_model.dart';

void main() {
  group('Movimentacao', () {
    test('deve calcular valor total', () {
      final movimentacao = Movimentacao(
        id: 'm1',
        produto: 'Teclado',
        fornecedor: 'Fornecedor A',
        categoria: 'Perifericos',
        tipo: TipoMovimentacao.entrada,
        quantidade: 4,
        valorUnitario: 125.50,
        data: DateTime(2026, 6, 17, 14, 30),
      );

      expect(movimentacao.valorTotal, 502.0);
    });

    test('deve converter para Map e recriar a partir dele', () {
      final data = DateTime(2026, 6, 17, 14, 30);
      final movimentacao = Movimentacao(
        id: 'm2',
        produto: 'Monitor',
        fornecedor: 'Fornecedor B',
        categoria: 'Eletronicos',
        tipo: TipoMovimentacao.saida,
        quantidade: 2,
        valorUnitario: 899.90,
        data: data,
        observacao: 'Venda confirmada',
      );

      final map = movimentacao.toMap();
      final restaurada = Movimentacao.fromMap('m2', map);

      expect(map['tipo'], 'saida');
      expect(map['data'], data.toIso8601String());
      expect(restaurada.id, 'm2');
      expect(restaurada.produto, 'Monitor');
      expect(restaurada.tipo, TipoMovimentacao.saida);
      expect(restaurada.quantidade, 2);
      expect(restaurada.valorUnitario, 899.90);
      expect(restaurada.data, data);
      expect(restaurada.observacao, 'Venda confirmada');
    });

    test('deve formatar data e valores em portugues do Brasil', () {
      final movimentacao = Movimentacao(
        id: 'm3',
        produto: 'Cabo HDMI',
        fornecedor: 'Fornecedor C',
        categoria: 'Acessorios',
        tipo: TipoMovimentacao.entrada,
        quantidade: 3,
        valorUnitario: 20,
        data: DateTime(2026, 6, 17, 9, 5),
      );

      expect(movimentacao.dataFormatada, '17/06/2026');
      expect(movimentacao.dataHoraFormatada, '17/06/2026 às 09:05');
      expect(movimentacao.valorUnitarioFormatado, contains('20,00'));
      expect(movimentacao.valorFormatado, contains('60,00'));
    });
  });
}
