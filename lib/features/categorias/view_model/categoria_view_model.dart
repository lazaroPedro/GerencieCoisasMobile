
import 'package:gerencie_coisas/features/categorias/model/categoria_model.dart';
import 'package:gerencie_coisas/features/categorias/repositories/categoria_repository.dart';
import 'package:flutter/material.dart';

class Categoria {
  final CategoriaModel item;
  final List<CategoriaModel> children;

  Categoria({
    required this.item,
    this.children = const [],
  });
}


class CategoriaViewModel extends ChangeNotifier {
  CategoriaRepository repository = CategoriaRepository();

  CategoriaViewModel({CategoriaRepository? repository}) {
    this.repository = repository ?? CategoriaRepository();
  }

  List<Categoria> categorias = [];

  Future<void> loadCategorias() async {
    final parents = await repository.getParents();
    categorias.clear();
    for (final parent in parents) {
      final children = await repository.getParentsChildren(parent.id);
      categorias.add(Categoria(item: parent, children: children));
    }

    notifyListeners();
  }

  Future<List<CategoriaModel>> loadParentCategorias() async {
    final parents = await repository.getParents();
    return parents;
  }

  Future<void> addCategoria(CategoriaModel categoria) async {
    await repository.save(categoria);
    await loadCategorias();
  }

  Future<void> deleteCategoria(String id) async {
    await repository.delete(id);
    await loadCategorias();
  }

}