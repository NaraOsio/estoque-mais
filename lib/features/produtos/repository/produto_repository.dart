import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/produto.dart';

class ProdutoRepository {
  final FirebaseFirestore _firestore;

  ProdutoRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  String gerarId() {
    return _firestore.collection('produtos').doc().id;
  }

  Future<void> salvar(Produto produto) {
    return _firestore.collection('produtos').doc(produto.id).set({
      'id': produto.id,
      'idUsuario': produto.idUsuario,
      'idCategoria': produto.idCategoria,
      'nome': produto.nome,
      'codigoBarras': produto.codigoBarras,
      'quantidadeAtual': produto.quantidadeAtual,
      'estoqueMinimo': produto.estoqueMinimo,
      'dataValidade': produto.dataValidade == null
          ? null
          : Timestamp.fromDate(produto.dataValidade!),
      'exigeValidade': produto.exigeValidade,
      'ativo': produto.ativo,
      'criadoEm': Timestamp.fromDate(produto.criadoEm),
    });
  }

  Future<List<Produto>> listarPorUsuario(String idUsuario) async {
    final resultado = await _firestore
        .collection('produtos')
        .where('idUsuario', isEqualTo: idUsuario)
        .get();

    return resultado.docs.map((documento) {
      final dados = documento.data();
      final dataValidade = dados['dataValidade'];

      return Produto(
        id: dados['id'] as String,
        idUsuario: dados['idUsuario'] as String,
        idCategoria: dados['idCategoria'] as String,
        nome: dados['nome'] as String,
        codigoBarras: dados['codigoBarras'] as String?,
        quantidadeAtual: dados['quantidadeAtual'] as int,
        estoqueMinimo: dados['estoqueMinimo'] as int,
        dataValidade: dataValidade is Timestamp
            ? dataValidade.toDate()
            : null,
        exigeValidade: dados['exigeValidade'] as bool,
        ativo: dados['ativo'] as bool,
        criadoEm: (dados['criadoEm'] as Timestamp).toDate(),
      );
    }).toList();
  }
}