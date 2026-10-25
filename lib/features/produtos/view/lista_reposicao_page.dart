import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/produto.dart';
import '../view_model/produto_view_model.dart';

class ListaReposicaoPage extends StatefulWidget {
  const ListaReposicaoPage({super.key});

  @override
  State<ListaReposicaoPage> createState() => _ListaReposicaoPageState();
}

class _ListaReposicaoPageState extends State<ListaReposicaoPage> {
  final _produtoViewModel = ProdutoViewModel();

  late Future<List<Produto>> _produtosFuture;

  @override
  void initState() {
    super.initState();
    _produtosFuture = _carregarProdutos();
  }

  Future<List<Produto>> _carregarProdutos() async {
    final idUsuario = FirebaseAuth.instance.currentUser?.uid;

    if (idUsuario == null) {
      throw Exception('Usuário não autenticado.');
    }

    final produtos = await _produtoViewModel.listarPorUsuario(idUsuario);
    return _produtoViewModel.obterProdutosParaReposicao(produtos);
  }

  void _atualizarLista() {
    setState(() {
      _produtosFuture = _carregarProdutos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de reposição'),
        actions: [
          IconButton(
            onPressed: _atualizarLista,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar lista',
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Não foi possível carregar a reposição.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _atualizarLista,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final produtos = resultado.data ?? <Produto>[];

          if (produtos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhum produto precisa de reposição.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: produtos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, indice) {
              final produto = produtos[indice];
              final semEstoque = produto.quantidadeAtual == 0;

              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.shopping_cart_outlined,
                    color: semEstoque ? Colors.red : Colors.orange,
                  ),
                  title: Text(produto.nome),
                  subtitle: Text(
                    'Quantidade atual: ${produto.quantidadeAtual}\n'
                        'Estoque mínimo: ${produto.estoqueMinimo}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}