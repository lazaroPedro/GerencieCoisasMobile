import 'package:cloud_firestore/cloud_firestore.dart';
import '../movimentacao_model.dart';

class MovimentacaoService {
  final _colecao = FirebaseFirestore.instance.collection('movimentacoes');

  Future<List<Movimentacao>> listar() async {
    final snapshot = await _colecao.orderBy('data', descending: true).get();
    return snapshot.docs
        .map((doc) => Movimentacao.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> salvar(Movimentacao movimentacao) async {
    await _colecao.add(movimentacao.toMap());
  }

  Future<void> deletar(String id) async {
    await _colecao.doc(id).delete();
  }
}