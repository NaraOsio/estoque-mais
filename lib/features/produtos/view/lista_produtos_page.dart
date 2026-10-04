import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../autenticacao/repository/autenticacao_repository.dart';
import '../../autenticacao/view/login_page.dart';
import '../../categorias/view/lista_categorias_page.dart';
import '../../movimentacoes/view/registrar_movimentacao_page.dart';
import '../../movimentacoes/view/lista_movimentacoes_page.dart';
import '../model/produto.dart';
import '../view_model/produto_view_model.dart';
import 'cadastro_produto_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
            onPressed: _abrirMovimentacao,
            icon: const Icon(Icons.swap_vert),
            tooltip: 'Movimentar estoque',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ListaMovimentacoesPage(),
                ),
              );
            },
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Histórico de movimentações',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ListaCategoriasPage(),
                ),
              );
            },
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categorias',
          ),
          IconButton(
            onPressed: _sair,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
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

          final produtos = resultado.data ?? [];

          if (produtos.isEmpty) {
            return const Center(
              child: Text('Nenhum produto cadastrado'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: produtos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, indice) {
              final produto = produtos[indice];
              final alerta = _produtoViewModel.obterAlertaEstoque(produto);
              final corAlerta = produto.quantidadeAtual == 0
                  ? Colors.red
                  : Colors.orange;

              return Card(
                child: ListTile(
                  onTap: () => _abrirEdicaoProduto(produto),
                  title: Text(
                    alerta == null ? produto.nome : '${produto.nome} — $alerta',
                    style: TextStyle(
                      color: alerta == null ? null : corAlerta,
                      fontWeight: alerta == null ? null : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Quantidade: ${produto.quantidadeAtual}\n'
                        'Estoque mínimo: ${produto.estoqueMinimo}',
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastroProduto,
        child: const Icon(Icons.add),
      ),
    );
  }
}