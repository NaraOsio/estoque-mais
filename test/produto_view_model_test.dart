import 'package:flutter_test/flutter_test.dart';

import 'package:estoque_mais/features/produtos/model/produto.dart';
import 'package:estoque_mais/features/produtos/repository/produto_repository.dart';
import 'package:estoque_mais/features/produtos/view_model/produto_view_model.dart';

// Impede qualquer acesso ao banco durante este teste.
class RepositorioSemBanco implements ProdutoRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw StateError('Este teste não deve acessar o banco.');
  }
}

Produto criarProdutoParaTeste({
  required String id,
  required int quantidade,
  bool ativo = true,
}) {
  return Produto(
    id: id,
    idUsuario: 'usuario-teste',
    idCategoria: 'categoria-teste',
    nome: id,
    quantidadeAtual: quantidade,
    estoqueMinimo: 5,
    exigeValidade: false,
    ativo: ativo,
    criadoEm: DateTime(2026, 1, 1),
  );
}

void main() {
  test(
    'Reposição inclui somente produtos ativos com saldo até o mínimo',
        () {
      // 1. Preparar os produtos e o ViewModel.
      final viewModel = ProdutoViewModel(
        repository: RepositorioSemBanco(),
      );

      final produtos = [
        criarProdutoParaTeste(id: 'zerado', quantidade: 0),
        criarProdutoParaTeste(id: 'abaixo', quantidade: 4),
        criarProdutoParaTeste(id: 'igual', quantidade: 5),
        criarProdutoParaTeste(id: 'acima', quantidade: 6),
        criarProdutoParaTeste(
          id: 'desativado',
          quantidade: 0,
          ativo: false,
        ),
      ];
      // 2. Executar a regra de reposição.
      final resultado = viewModel.obterProdutosParaReposicao(produtos);

      // 3. Conferir exatamente quais produtos foram selecionados.
      expect(
        resultado.map((produto) => produto.id),
        unorderedEquals(['zerado', 'abaixo', 'igual']),
      );
    },
  );
  test('TC04 - Recusa nome formado apenas por espaços', () {
    final viewModel = ProdutoViewModel(
      repository: RepositorioSemBanco(),
    );

    final resultado = viewModel.validarCadastro(
      nome: '   ',
      quantidadeInicialTexto: '0',
      estoqueMinimoTexto: '5',
      precoVendaTexto: '2,99',
    );

    expect(resultado, 'Informe o nome do produto.');
  });
  test('TC05 - Alerta estoque igual ao mínimo', () {
    final viewModel = ProdutoViewModel(
      repository: RepositorioSemBanco(),
    );

    final produto = criarProdutoParaTeste(
      id: 'estoque-no-minimo',
      quantidade: 5,
    );

    final resultado = viewModel.obterAlertaEstoque(produto);

    expect(resultado, 'Estoque baixo');
  });
  test('TC06 - Alerta produto sem estoque', () {
    final viewModel = ProdutoViewModel(
      repository: RepositorioSemBanco(),
    );

    final produto = criarProdutoParaTeste(
      id: 'sem-estoque',
      quantidade: 0,
    );

    final resultado = viewModel.obterAlertaEstoque(produto);

    expect(resultado, 'Sem estoque');
  });
  test('TC07 - Pesquisa parte do nome sem diferenciar maiúsculas', () {
    final viewModel = ProdutoViewModel(
      repository: RepositorioSemBanco(),
    );

    final produtos = [
      criarProdutoParaTeste(id: 'Refrigerante', quantidade: 5),
      criarProdutoParaTeste(id: 'Arroz', quantidade: 5),
    ];

    final resultado = viewModel.pesquisarProdutos(
      produtos: produtos,
      pesquisa: 'REFRI',
      nomesCategorias: {'categoria-teste': 'Alimentos'},
    );

    expect(
      resultado.map((produto) => produto.id),
      unorderedEquals(['Refrigerante']),
    );
  });
}