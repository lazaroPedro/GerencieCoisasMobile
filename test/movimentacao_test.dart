import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gerencie_coisas/features/produtos/model/produto.dart';
import 'package:gerencie_coisas/features/produtos/services/produto_service.dart';

class MockProdutoService extends Mock implements ProdutoService {}

void main() {
  test('Produtos - Deve retornar a lista de produtos cadastrados', () async {
    final service = MockProdutoService();
    final produtosMockados = [
      Produto(id: 'p1', name: 'Notebook', quantity: 5, price: 3500.0, categoryId: '1'),
    ];

    when(() => service.getProdutos()).thenAnswer((_) async => produtosMockados);

    final resultado = await service.getProdutos();

    expect(resultado.length, 1);
    expect(resultado.first.name, 'Notebook');
    expect(resultado.first.quantity, 5);
  });
}