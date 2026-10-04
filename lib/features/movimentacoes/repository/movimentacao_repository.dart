import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/movimentacao.dart';

class MovimentacaoRepository {
  final FirebaseFirestore _firestore;

  MovimentacaoRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  String gerarId() {
    return _firestore.collection('movimentacoes').doc().id;
  }

  Future<void> registrar(Movimentacao movimentacao) async {
    final produtoReferencia =
    _firestore.collection('produtos').doc(movimentacao.idProduto);

    final movimentacaoReferencia =
    _firestore.collection('movimentacoes').doc(movimentacao.id);

    await _firestore.runTransaction((transacao) async {
      final produtoDocumento = await transacao.get(produtoReferencia);

      if (!produtoDocumento.exists) {
        throw StateError('Produto não encontrado.');
      }

      final dadosProduto = produtoDocumento.data();

      if (dadosProduto == null ||
          dadosProduto['idUsuario'] != movimentacao.idUsuario) {
        throw StateError('Produto não pertence ao usuário.');
      }

      final quantidadeAtual = dadosProduto['quantidadeAtual'] as int;

      if (movimentacao.quantidade <= 0) {
        throw StateError('A quantidade deve ser maior que zero.');
      }

      if (movimentacao.tipo != 'entrada' &&
          movimentacao.tipo != 'saida') {
        throw StateError('Tipo de movimentação inválido.');
      }

      if (movimentacao.tipo == 'saida' &&
          movimentacao.quantidade > quantidadeAtual) {
        throw StateError('Quantidade de saída maior que o estoque disponível.');
      }

      final novaQuantidade = movimentacao.tipo == 'entrada'
          ? quantidadeAtual + movimentacao.quantidade
          : quantidadeAtual - movimentacao.quantidade;

      transacao.update(
        produtoReferencia,
        {'quantidadeAtual': novaQuantidade},
      );

      transacao.set(
        movimentacaoReferencia,
        {
          'id': movimentacao.id,
          'idUsuario': movimentacao.idUsuario,
          'idProduto': movimentacao.idProduto,
          'tipo': movimentacao.tipo,
          'quantidade': movimentacao.quantidade,
          'motivo': movimentacao.motivo,
          'dataMovimentacao':
          Timestamp.fromDate(movimentacao.dataMovimentacao),
        },
      );
    });
  }
  Future<List<Movimentacao>> listarPorUsuario(String idUsuario) async {
    final resultado = await _firestore
        .collection('movimentacoes')
        .where('idUsuario', isEqualTo: idUsuario)
        .get();

    final movimentacoes = resultado.docs.map((documento) {
      final dados = documento.data();

      return Movimentacao(
        id: dados['id'] as String,
        idUsuario: dados['idUsuario'] as String,
        idProduto: dados['idProduto'] as String,
        tipo: dados['tipo'] as String,
        quantidade: dados['quantidade'] as int,
        motivo: dados['motivo'] as String?,
        dataMovimentacao:
        (dados['dataMovimentacao'] as Timestamp).toDate(),
      );
    }).toList();

    movimentacoes.sort(
          (primeira, segunda) =>
          segunda.dataMovimentacao.compareTo(primeira.dataMovimentacao),
    );

    return movimentacoes;
  }
}