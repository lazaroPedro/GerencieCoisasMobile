import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/produto.dart';

class ProdutoService {
  final _colecao = FirebaseFirestore.instance.collection('produtos');

  Future<List<Produto>> listar() async {
    // Ordenando por nome para ficar bonitinho na lista
    final snapshot = await _colecao.orderBy('name').get();
    return snapshot.docs
        .map((doc) => Produto.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> salvar(Produto produto) async {
    // Se quiser implementar a edição no futuro, dá pra usar _colecao.doc(produto.id).update()
    await _colecao.add(produto.toMap());
  }

  Future<void> deletar(String id) async {
    await _colecao.doc(id).delete();
  }
}