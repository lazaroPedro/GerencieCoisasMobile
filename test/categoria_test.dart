import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gerencie_coisas/features/categorias/model/categoria_model.dart';
import 'package:gerencie_coisas/features/categorias/repositories/categoria_repository.dart';
import 'package:gerencie_coisas/features/categorias/view_model/categoria_view_model.dart';

class MockCategoriaRepository extends Mock implements CategoriaRepository {}

void main() {
  test('Categorias - Deve carregar categorias pai e vincular seus filhos', () async {
    final repository = MockCategoriaRepository();

    final viewModel = CategoriaViewModel(repository: repository);

    final pai = CategoriaModel(id: '1', name: 'Eletrônicos', parentId: null);
    final filho = CategoriaModel(id: '2', name: 'Celulares', parentId: '1');

    when(() => repository.getParents()).thenAnswer((_) async => [pai]);
    when(() => repository.getParentsChildren('1')).thenAnswer((_) async => [filho]);

    await viewModel.loadCategorias();

    expect(viewModel.categorias.length, 1);
    expect(viewModel.categorias.first.item.name, 'Eletrônicos');
    expect(viewModel.categorias.first.children.first.name, 'Celulares');
  });
}