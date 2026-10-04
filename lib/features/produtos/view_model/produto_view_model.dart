import '../model/produto.dart';
import '../repository/produto_repository.dart';

class ProdutoViewModel {
  final ProdutoRepository _repository;

  ProdutoViewModel({
    ProdutoRepository? repository,
  }) : _repository = repository ?? ProdutoRepository();

  String? validarCadastro({
    required String nome,
    required String quantidadeInicialTexto,
    required String estoqueMinimoTexto,
  }) {
    if (nome.trim().isEmpty) {
      return 'Informe o nome do produto.';
    }

    final quantidadeInicial = int.tryParse(quantidadeInicialTexto);
    if (quantidadeInicial == null || quantidadeInicial < 0) {
      return 'Informe uma quantidade inicial válida.';
    }

    final estoqueMinimo = int.tryParse(estoqueMinimoTexto);
    if (estoqueMinimo == null || estoqueMinimo < 0) {
      return 'Informe um estoque mínimo válido.';
    }

    return null;
  }

  Future<String?> criarProduto({
    required String idUsuario,
    required String idCategoria,
    required String nome,
    required String quantidadeInicialTexto,
    required String estoqueMinimoTexto,
    bool exigeValidade = false,
    DateTime? dataValidade,
  }) async {
    if (idUsuario.trim().isEmpty) {
      return 'Não foi possível identificar o usuário.';
    }

    if (idCategoria.trim().isEmpty) {
      return 'Selecione uma categoria.';
    }

    final mensagemErro = validarCadastro(
      nome: nome,
      quantidadeInicialTexto: quantidadeInicialTexto,
      estoqueMinimoTexto: estoqueMinimoTexto,
    );

    if (mensagemErro != null) {
      return mensagemErro;
    }

    if (exigeValidade && dataValidade == null) {
      return 'Informe a data de validade.';
    }

    final produto = Produto(
      id: _repository.gerarId(),
      idUsuario: idUsuario,
      idCategoria: idCategoria,
      nome: nome.trim(),
      quantidadeAtual: int.parse(quantidadeInicialTexto),
      estoqueMinimo: int.parse(estoqueMinimoTexto),
      dataValidade: exigeValidade ? dataValidade : null,
      exigeValidade: exigeValidade,
      ativo: true,
      criadoEm: DateTime.now(),
    );

    try {
      await _repository.salvar(produto);
      return null;
    } catch (_) {
      return 'Não foi possível salvar o produto. Tente novamente.';
    }
  }

  Future<String?> atualizarProduto({
    required Produto produto,
    required String idCategoria,
    required String nome,
    required String quantidadeInicialTexto,
    required String estoqueMinimoTexto,
    bool? exigeValidade,
    DateTime? dataValidade,
  }) async {
    if (idCategoria.trim().isEmpty) {
      return 'Selecione uma categoria.';
    }

    final mensagemErro = validarCadastro(
      nome: nome,
      quantidadeInicialTexto: quantidadeInicialTexto,
      estoqueMinimoTexto: estoqueMinimoTexto,
    );

    if (mensagemErro != null) {
      return mensagemErro;
    }

    final exigeValidadeFinal = exigeValidade ?? produto.exigeValidade;

    final dataValidadeFinal = exigeValidade == null
        ? produto.dataValidade
        : exigeValidadeFinal
        ? dataValidade
        : null;

    if (exigeValidadeFinal && dataValidadeFinal == null) {
      return 'Informe a data de validade.';
    }

    final produtoAtualizado = Produto(
      id: produto.id,
      idUsuario: produto.idUsuario,
      idCategoria: idCategoria,
      nome: nome.trim(),
      codigoBarras: produto.codigoBarras,
      quantidadeAtual: produto.quantidadeAtual,
      estoqueMinimo: int.parse(estoqueMinimoTexto),
      dataValidade: dataValidadeFinal,
      exigeValidade: exigeValidadeFinal,
      ativo: produto.ativo,
      criadoEm: produto.criadoEm,
    );

    try {
      await _repository.salvar(produtoAtualizado);
      return null;
    } catch (_) {
      return 'Não foi possível atualizar o produto. Tente novamente.';
    }
  }
  Future<String?> desativarProduto(Produto produto) async {
    final produtoDesativado = Produto(
      id: produto.id,
      idUsuario: produto.idUsuario,
      idCategoria: produto.idCategoria,
      nome: produto.nome,
      codigoBarras: produto.codigoBarras,
      quantidadeAtual: produto.quantidadeAtual,
      estoqueMinimo: produto.estoqueMinimo,
      dataValidade: produto.dataValidade,
      exigeValidade: produto.exigeValidade,
      ativo: false,
      criadoEm: produto.criadoEm,
    );

    try {
      await _repository.salvar(produtoDesativado);
      return null;
    } catch (_) {
      return 'Não foi possível desativar o produto. Tente novamente.';
    }
  }
  String? obterAlertaEstoque(Produto produto) {
    if (produto.quantidadeAtual == 0) {
      return 'Sem estoque';
    }

    if (produto.quantidadeAtual <= produto.estoqueMinimo) {
      return 'Estoque baixo';
    }

    return null;
  }
  String? obterAlertaValidade(Produto produto) {
    if (!produto.exigeValidade || produto.dataValidade == null) {
      return null;
    }

    final hoje = DateTime.now();
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);

    final validade = produto.dataValidade!;
    final validadeSemHora = DateTime(
      validade.year,
      validade.month,
      validade.day,
    );

    final diasRestantes =
        validadeSemHora.difference(hojeSemHora).inDays;

    if (diasRestantes >= 0 && diasRestantes <= 30) {
      return 'Vence em $diasRestantes dia(s)';
    }

    return null;
  }

  Future<List<Produto>> listarPorUsuario(String idUsuario) {
    return _repository.listarPorUsuario(idUsuario);
  }
}