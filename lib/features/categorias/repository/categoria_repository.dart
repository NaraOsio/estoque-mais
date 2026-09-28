import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/categoria.dart';

class CategoriaRepository {
  final FirebaseFirestore _firestore;

  CategoriaRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  String gerarId() {
    return _firestore.collection('categorias').doc().id;
  }

  Future<void> salvar(Categoria categoria) {
    return _firestore
        .collection('categorias')
        .doc(categoria.id)
        .set({
      'id': categoria.id,
      'idUsuario': categoria.idUsuario,
      'nome': categoria.nome,
      'descricao': categoria.descricao,
      'criadoEm': Timestamp.fromDate(categoria.criadoEm),
    });
  }

  Future<List<Categoria>> listarPorUsuario(String idUsuario) async {
    final resultado = await _firestore
        .collection('categorias')
        .where('idUsuario', isEqualTo: idUsuario)
        .get();

    return resultado.docs.map((documento) {
      final dados = documento.data();

      return Categoria(
        id: dados['id'] as String,
        idUsuario: dados['idUsuario'] as String,
        nome: dados['nome'] as String,
        descricao: dados['descricao'] as String?,
        criadoEm: (dados['criadoEm'] as Timestamp).toDate(),
      );
    }).toList();
  }
}