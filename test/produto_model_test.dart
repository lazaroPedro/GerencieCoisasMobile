import 'package:flutter_test/flutter_test.dart';
import 'package:gerencie_coisas/features/produtos/model/produto.dart';

void main() {
  group('Produto', () {
    test('deve converter para Map mantendo todos os campos', () {
      final produto = Produto(
        id: 'p1',
        name: 'Notebook',
        description: 'Notebook para trabalho',
        quantity: 3,
        price: 4500.50,
        supplier: 'Fornecedor A',
        categoryId: 'cat1',
        barcode: '7891234567890',
      );

      expect(produto.toMap(), {
        'name': 'Notebook',
        'description': 'Notebook para trabalho',
        'quantity': 3,
        'price': 4500.50,
        'supplier': 'Fornecedor A',
        'categoryId': 'cat1',
        'barcode': '7891234567890',
      });
    });

    test('deve criar Produto a partir de Map', () {
      final produto = Produto.fromMap('p2', {
        'name': 'Mouse',
        'description': 'Mouse sem fio',
        'quantity': 10,
        'price': 99,
        'supplier': 'Fornecedor B',
        'categoryId': 'cat2',
        'barcode': '123',
      });

      expect(produto.id, 'p2');
      expect(produto.name, 'Mouse');
      expect(produto.description, 'Mouse sem fio');
      expect(produto.quantity, 10);
      expect(produto.price, 99.0);
      expect(produto.supplier, 'Fornecedor B');
      expect(produto.categoryId, 'cat2');
      expect(produto.barcode, '123');
    });

    test(
      'deve usar valores padrao quando campos opcionais estiverem ausentes',
      () {
        final produto = Produto.fromMap('p3', {'price': 15.5});

        expect(produto.name, '');
        expect(produto.description, '');
        expect(produto.quantity, 0);
        expect(produto.supplier, '');
        expect(produto.categoryId, '');
        expect(produto.barcode, isNull);
      },
    );
  });
}
