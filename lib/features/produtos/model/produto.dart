class Produto {
  final String id; // Mudou de int para String
  final String name;
  final String description;
  final int quantity;
  final double price;
  final String supplier;  
  final String categoryId; // Mudou para String para seguir o padrão Firebase

  Produto({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.supplier,
    required this.categoryId,
  });

  // Converte o objeto Produto para um formato que o Firebase entende
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'supplier': supplier,
      'categoryId': categoryId,
    };
  }

  // Pega os dados do Firebase e transforma de volta em um Produto
  factory Produto.fromMap(String id, Map<String, dynamic> map) {
    return Produto(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      price: (map['price'] as num).toDouble(),
      supplier: map['supplier'] ?? '',
      categoryId: map['categoryId'] ?? '',
    );
  }
}