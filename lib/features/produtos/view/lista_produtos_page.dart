import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../autenticacao/repository/autenticacao_repository.dart';
import '../../autenticacao/view/login_page.dart';
import '../../categorias/view/lista_categorias_page.dart';
import '../../movimentacoes/view/lista_movimentacoes_page.dart';
import '../../movimentacoes/view/registrar_movimentacao_page.dart';
import '../model/produto.dart';
import '../view_model/produto_view_model.dart';
import 'cadastro_produto_page.dart';
import 'leitor_codigo_page.dart';

enum _AcaoMenu {
  historico,
  categorias,
  sair,
}

class ListaProdutosPage extends StatefulWidget {
  const ListaProdutosPage({super.key});

  @override
  State<ListaProdutosPage> createState() => _ListaProdutosPageState();
}

class _ListaProdutosPageState extends State<ListaProdutosPage> {
  final _autenticacaoRepository = AutenticacaoRepository();
  final _produtoViewModel = ProdutoViewModel();

  late Future<List<Produto>> _produtosFuture;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  void _carregarProdutos() {
    final idUsuario = FirebaseAuth.instance.currentUser?.uid;

    _produtosFuture = idUsuario == null
        ? Future.value(<Produto>[])
        : _produtoViewModel.listarPorUsuario(idUsuario);
  }

  Future<void> _abrirCadastroProduto() async {
    final produtoSalvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const CadastroProdutoPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (produtoSalvo == true) {
      setState(_carregarProdutos);
    }
  }

  Future<void> _abrirMovimentacao() async {
    final movimentacaoRegistrada =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const RegistrarMovimentacaoPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (movimentacaoRegistrada == true) {
      setState(_carregarProdutos);
    }
  }

  void _abrirHistorico() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ListaMovimentacoesPage(),
      ),
    );
  }

  void _abrirCategorias() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ListaCategoriasPage(),
      ),
    );
  }

  Future<void> _abrirEdicaoProduto(Produto produto) async {
    final produtoAlterado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CadastroProdutoPage(
          produto: produto,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (produtoAlterado == true) {
      setState(_carregarProdutos);
    }
  }

  Future<void> _sair() async {
    await _autenticacaoRepository.sair();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  void _executarAcaoMenu(_AcaoMenu acao) {
    switch (acao) {
      case _AcaoMenu.historico:
        _abrirHistorico();
      case _AcaoMenu.categorias:
        _abrirCategorias();
      case _AcaoMenu.sair:
        _sair();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LeitorCodigoPage(),
                ),
              );
            },
            icon: const Icon(Icons.qr_code_scanner_rounded),
            iconSize: 28,
            tooltip: 'Consultar produto por código',
          ),
          IconButton(
            onPressed: _abrirMovimentacao,
            icon: const Icon(Icons.swap_vert_rounded),
            iconSize: 28,
            tooltip: 'Movimentar estoque',
          ),
          PopupMenuButton<_AcaoMenu>(
            onSelected: _executarAcaoMenu,
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 28,
            ),
            tooltip: 'Mais opções',
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: _AcaoMenu.historico,
                  child: _ItemMenu(
                    icone: Icons.history_rounded,
                    texto: 'Histórico',
                  ),
                ),
                PopupMenuItem(
                  value: _AcaoMenu.categorias,
                  child: _ItemMenu(
                    icone: Icons.category_rounded,
                    texto: 'Categorias',
                  ),
                ),
                PopupMenuItem(
                  value: _AcaoMenu.sair,
                  child: _ItemMenu(
                    icone: Icons.logout_rounded,
                    texto: 'Sair',
                    cor: Colors.red,
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<List<Produto>>(
        future: _produtosFuture,
        builder: (context, resultado) {
          if (resultado.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (resultado.hasError) {
            return const Center(
              child: Text('Não foi possível carregar os produtos.'),
            );
          }

          final produtos = (resultado.data ?? [])
              .where((produto) => produto.ativo)
              .toList();

          if (produtos.isEmpty) {
            return const Center(
              child: Text('Nenhum produto cadastrado'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: produtos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, indice) {
              final produto = produtos[indice];
              final alertaEstoque =
              _produtoViewModel.obterAlertaEstoque(produto);
              final alertaValidade =
              _produtoViewModel.obterAlertaValidade(produto);

              final alertas = <String>[
                ?alertaEstoque,
                ?alertaValidade,
              ];

              final corAlerta = alertaEstoque == 'Sem estoque'
                  ? Colors.red
                  : Colors.orange;

              final corDestaque = alertas.isEmpty
                  ? Theme.of(context).colorScheme.primary
                  : corAlerta;

              return Card(
                margin: EdgeInsets.zero,
                elevation: 1,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  onTap: () => _abrirEdicaoProduto(produto),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: corDestaque.withValues(alpha: 0.12),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: corDestaque,
                      size: 23,
                    ),
                  ),
                  title: Text(
                    produto.nome,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantidade: ${produto.quantidadeAtual}',
                        ),
                        Text(
                          'Estoque mínimo: ${produto.estoqueMinimo}',
                        ),
                        if (alertas.isNotEmpty) ...[
                          const SizedBox(height: 9),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: corAlerta.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: corAlerta,
                                  size: 17,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    alertas.join(' • '),
                                    style: TextStyle(
                                      color: corAlerta,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing: Icon(
                    Icons.edit_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastroProduto,
        tooltip: 'Cadastrar produto',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Color? cor;

  const _ItemMenu({
    required this.icone,
    required this.texto,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final corFinal = cor ?? Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(
          icone,
          color: corFinal,
        ),
        const SizedBox(width: 12),
        Text(
          texto,
          style: TextStyle(
            color: corFinal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}