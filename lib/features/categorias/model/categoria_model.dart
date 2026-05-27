class CategoriaModel {
  String id;
  final String name;
  final String? parentId;

  CategoriaModel({
    required this.id,
    required this.name,
    this.parentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
    };
  }

  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    return CategoriaModel(
      id: map['id'],
      name: map['name'],
      parentId: map['parentId'],
    );
  }
}