import 'package:flutter_test/flutter_test.dart';
import 'package:gerencie_coisas/features/categorias/model/categoria_model.dart';
import 'package:gerencie_coisas/features/categorias/repositories/categoria_repository.dart';
import 'package:gerencie_coisas/features/categorias/view_model/categoria_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoriaRepository extends Mock implements CategoriaRepository {}

class FakeCategoriaModel extends Fake implements CategoriaModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCategoriaModel());
  });

  group('CategoriaViewModel', () {
    test('deve carregar apenas categorias pai', () async {
      final repository = MockCategoriaRepository();
      final viewModel = CategoriaViewModel(repository: repository);
      final categorias = [
        CategoriaModel(id: '1', name: 'Eletronicos'),
        CategoriaModel(id: '2', name: 'Moveis'),
      ];

      when(() => repository.getParents()).thenAnswer((_) async => categorias);

      final resultado = await viewModel.loadParentCategorias();

      expect(resultado, categorias);
      verify(() => repository.getParents()).called(1);
    });

    test('deve salvar categoria e recarregar lista', () async {
      final repository = MockCategoriaRepository();
      final viewModel = CategoriaViewModel(repository: repository);
      final categoria = CategoriaModel(id: '1', name: 'Eletronicos');

      when(() => repository.save(any())).thenAnswer((_) async {});
      when(() => repository.getParents()).thenAnswer((_) async => [categoria]);
      when(
        () => repository.getParentsChildren('1'),
      ).thenAnswer((_) async => []);

      await viewModel.addCategoria(categoria);

      verify(() => repository.save(categoria)).called(1);
      expect(viewModel.categorias.length, 1);
      expect(viewModel.categorias.first.item.name, 'Eletronicos');
    });

    test('deve excluir categoria e recarregar lista', () async {
      final repository = MockCategoriaRepository();
      final viewModel = CategoriaViewModel(repository: repository);

      when(() => repository.delete('1')).thenAnswer((_) async {});
      when(() => repository.getParents()).thenAnswer((_) async => []);

      await viewModel.deleteCategoria('1');

      verify(() => repository.delete('1')).called(1);
      expect(viewModel.categorias, isEmpty);
    });
  });
}
