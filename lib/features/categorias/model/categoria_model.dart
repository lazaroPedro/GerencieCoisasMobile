class CategoriaModel {
  final int id;
  final String name;
  final CategoriaModel? parent;

  CategoriaModel({
    required this.id,
    required this.name,
    this.parent,
  });

}