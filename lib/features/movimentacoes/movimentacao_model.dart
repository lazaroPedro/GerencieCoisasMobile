import 'package:intl/intl.dart';
 
enum TipoMovimentacao { entrada, saida }
 
class Movimentacao {
  final String id;
  final String produto;
  final String fornecedor;
  final String categoria;
  final TipoMovimentacao tipo;
  final int quantidade;
  final double valorUnitario;
  final DateTime data;
  final String? observacao;
 
  const Movimentacao({
    required this.id,
    required this.produto,
    required this.fornecedor,
    required this.categoria,
    required this.tipo,
    required this.quantidade,
    required this.valorUnitario,
    required this.data,
    this.observacao,
  });

  Map<String, dynamic> toMap() {
  return {
    'produto': produto,
    'fornecedor': fornecedor,
    'categoria': categoria,
    'tipo': tipo.name,           // "entrada" ou "saida"
    'quantidade': quantidade,
    'valorUnitario': valorUnitario,
    'data': data.toIso8601String(),
    'observacao': observacao,
  };
}

factory Movimentacao.fromMap(String id, Map<String, dynamic> map) {
  return Movimentacao(
    id: id,
    produto: map['produto'],
    fornecedor: map['fornecedor'],
    categoria: map['categoria'],
    tipo: TipoMovimentacao.values.byName(map['tipo']),
    quantidade: map['quantidade'],
    valorUnitario: (map['valorUnitario'] as num).toDouble(),
    data: DateTime.parse(map['data']),
    observacao: map['observacao'],
  );
}
 
  double get valorTotal => quantidade * valorUnitario;
 
  String get valorFormatado {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(valorTotal);
  }
 
  String get valorUnitarioFormatado {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(valorUnitario);
  }
 
  String get dataFormatada => DateFormat('dd/MM/yyyy').format(data);
 
  String get dataHoraFormatada => DateFormat('dd/MM/yyyy \'às\' HH:mm').format(data);
}
 
// Dados falsos
final List<Movimentacao> movimentacoesFake = [
  Movimentacao(
    id: '1',
    produto: 'Notebook Dell Inspiron 15',
    fornecedor: 'Tech Distribuidora Ltda',
    categoria: 'Eletrônicos',
    tipo: TipoMovimentacao.entrada,
    quantidade: 10,
    valorUnitario: 2499.90,
    data: DateTime(2026, 5, 18, 9, 30),
    observacao: 'Recebimento do pedido #4512. Todos os itens conferidos e aprovados.',
  ),
  Movimentacao(
    id: '2',
    produto: 'Mouse sem fio Logitech M705',
    fornecedor: 'InfoShop Comércio',
    categoria: 'Periféricos',
    tipo: TipoMovimentacao.saida,
    quantidade: 5,
    valorUnitario: 189.90,
    data: DateTime(2026, 5, 17, 14, 0),
    observacao: 'Venda para cliente corporativo.',
  ),
  Movimentacao(
    id: '3',
    produto: 'Teclado Mecânico Redragon K552',
    fornecedor: 'Gamer Store',
    categoria: 'Periféricos',
    tipo: TipoMovimentacao.entrada,
    quantidade: 20,
    valorUnitario: 320.00,
    data: DateTime(2026, 5, 16, 11, 15),
    observacao: null,
  ),
  Movimentacao(
    id: '4',
    produto: 'Monitor LG 24" Full HD',
    fornecedor: 'Tech Distribuidora Ltda',
    categoria: 'Eletrônicos',
    tipo: TipoMovimentacao.saida,
    quantidade: 3,
    valorUnitario: 1099.00,
    data: DateTime(2026, 5, 15, 16, 45),
    observacao: 'Transferência para filial centro.',
  ),
  Movimentacao(
    id: '5',
    produto: 'Cabo HDMI 2m',
    fornecedor: 'Conect Acessórios',
    categoria: 'Acessórios',
    tipo: TipoMovimentacao.entrada,
    quantidade: 50,
    valorUnitario: 29.90,
    data: DateTime(2026, 5, 14, 10, 0),
    observacao: null,
  ),
  Movimentacao(
    id: '6',
    produto: 'Headset HyperX Cloud II',
    fornecedor: 'Gamer Store',
    categoria: 'Periféricos',
    tipo: TipoMovimentacao.saida,
    quantidade: 2,
    valorUnitario: 549.90,
    data: DateTime(2026, 5, 13, 13, 30),
    observacao: 'Devolução de cliente – produto com defeito substituído.',
  ),
  Movimentacao(
    id: '7',
    produto: 'SSD Kingston 480GB',
    fornecedor: 'MegaInfo LTDA',
    categoria: 'Armazenamento',
    tipo: TipoMovimentacao.entrada,
    quantidade: 15,
    valorUnitario: 249.90,
    data: DateTime(2026, 5, 12, 8, 0),
    observacao: null,
  ),
];