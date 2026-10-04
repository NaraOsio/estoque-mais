import '../model/movimentacao.dart';
import '../repository/movimentacao_repository.dart';

class MovimentacaoViewModel {
  final MovimentacaoRepository _repository;

  MovimentacaoViewModel({
    MovimentacaoRepository? repository,
  }) : _repository = repository ?? MovimentacaoRepository();

  Future<String?> registrarMovimentacao({
    required String idUsuario,
    required String idProduto,
    required String tipo,
    required String quantidadeTexto,
    String? motivo,
  }) async {
    if (idUsuario.trim().isEmpty) {
      return 'Não foi possível identificar o usuário.';
    }

    if (idProduto.trim().isEmpty) {
      return 'Selecione um produto.';
    }

    if (tipo != 'entrada' && tipo != 'saida') {
      return 'Selecione entrada ou saída.';
    }

    final quantidade = int.tryParse(quantidadeTexto);

    if (quantidade == null || quantidade <= 0) {
      return 'Informe uma quantidade válida.';
    }

    final motivoLimpo = motivo?.trim();
    final motivoFinal =
    motivoLimpo == null || motivoLimpo.isEmpty ? null : motivoLimpo;

    final movimentacao = Movimentacao(
      id: _repository.gerarId(),
      idUsuario: idUsuario,
      idProduto: idProduto,
      tipo: tipo,
      quantidade: quantidade,
      motivo: motivoFinal,
      dataMovimentacao: DateTime.now(),
    );

    try {
      await _repository.registrar(movimentacao);
      return null;
    } on StateError catch (erro) {
      return erro.message.toString();
    } catch (_) {
      return 'Não foi possível registrar a movimentação. Tente novamente.';
    }
  }
  Future<List<Movimentacao>> listarPorUsuario(String idUsuario) {
    return _repository.listarPorUsuario(idUsuario);
  }
}