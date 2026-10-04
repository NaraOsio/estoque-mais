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

    final produto = Produto(
      id: _repository.gerarId(),
      idUsuario: idUsuario,
      idCategoria: idCategoria,
      nome: nome.trim(),
      quantidadeAtual: int.parse(quantidadeInicialTexto),
      estoqueMinimo: int.parse(estoqueMinimoTexto),
      exigeValidade: false,
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

    final produtoAtualizado = Produto(
      id: produto.id,
      idUsuario: produto.idUsuario,
      idCategoria: idCategoria,
      nome: nome.trim(),
      codigoBarras: produto.codigoBarras,
      quantidadeAtual: produto.quantidadeAtual,
      estoqueMinimo: int.parse(estoqueMinimoTexto),
      dataValidade: produto.dataValidade,
      exigeValidade: produto.exigeValidade,
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

  Future<List<Produto>> listarPorUsuario(String idUsuario) {
    return _repository.listarPorUsuario(idUsuario);
  }
}