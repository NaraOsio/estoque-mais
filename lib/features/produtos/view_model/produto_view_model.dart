class ProdutoViewModel {
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
}