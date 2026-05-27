import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gerencie_coisas/features/categorias/model/categoria_model.dart';

class CategoriaRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  Future<void> save(CategoriaModel categoria) async {
    final docRef = firestore.collection('categorias').doc();
    categoria.id = docRef.id;
    await docRef.set(categoria.toMap());
  }   

  Future<List<CategoriaModel>> getAll() async {
    final snapshot = await firestore.collection('categorias').get();

    return snapshot.docs
        .map((doc) => CategoriaModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<CategoriaModel>> getParents() async {
    final snapshot = await firestore.collection('categorias').where('parentId', isEqualTo: null).get();
    return snapshot.docs
        .map((doc) => CategoriaModel.fromMap(doc.data()))
        .where((e) => e.parentId == null)
        .toList();
  }
    Future<List<CategoriaModel>> getParentsChildren(String parentId) async {
    final snapshot = await firestore.collection('categorias').where('parentId', isEqualTo: parentId).get();

    return snapshot.docs
        .map((doc) => CategoriaModel.fromMap(doc.data()))
        .toList();
  }


  Future<CategoriaModel?> getById(String id) async {
    final doc = await firestore.collection('categorias').doc(id).get();

    if (!doc.exists) return null;

    return CategoriaModel.fromMap(doc.data()!);
  }


  Future<void> delete(String id) async {
    await firestore.collection('categorias').doc(id).delete();
  }
}