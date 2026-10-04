import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../produtos/model/produto.dart';
import '../../produtos/view_model/produto_view_model.dart';
import '../model/movimentacao.dart';
import '../view_model/movimentacao_view_model.dart';

class ListaMovimentacoesPage extends StatefulWidget {
  const ListaMovimentacoesPage({super.key});

  @override
  State<ListaMovimentacoesPage> createState() =>
      _ListaMovimentacoesPageState();
}

class _ListaMovimentacoesPageState extends State<ListaMovimentacoesPage> {
  final _movimentacaoViewModel = MovimentacaoViewModel();
  final _produtoViewModel = ProdutoViewModel();

  late Future<List<Movimentacao>> _movimentacoesFuture;
  late Future<List<Produto>> _produtosFuture;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    final idUsuario = FirebaseAuth.instance.currentUser?.uid;

    _movimentacoesFuture = idUsuario == null
        ? Future.value(<Movimentacao>[])
        : _movimentacaoViewModel.listarPorUsuario(idUsuario);

    _produtosFuture = idUsuario == null
        ? Future.value(<Produto>[])
        : _produtoViewModel.listarPorUsuario(idUsuario);
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year} às $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de movimentações'),
      ),
      body: FutureBuilder<List<Movimentacao>>(
        future: _movimentacoesFuture,
        builder: (context, resultadoMovimentacoes) {
          if (resultadoMovimentacoes.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (resultadoMovimentacoes.hasError) {
            return const Center(
              child: Text('Não foi possível carregar as movimentações.'),
            );
          }

          final movimentacoes = resultadoMovimentacoes.data ?? [];

          if (movimentacoes.isEmpty) {
            return const Center(
              child: Text('Nenhuma movimentação registrada.'),
            );
          }

          return FutureBuilder<List<Produto>>(
            future: _produtosFuture,
            builder: (context, resultadoProdutos) {
              if (resultadoProdutos.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final produtos = resultadoProdutos.data ?? [];

              final nomesProdutos = {
                for (final produto in produtos) produto.id: produto.nome,
              };

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: movimentacoes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, indice) {
                  final movimentacao = movimentacoes[indice];
                  final ehEntrada = movimentacao.tipo == 'entrada';
                  final nomeProduto = nomesProdutos[movimentacao.idProduto] ??
                      'Produto não encontrado';

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ehEntrada
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Icon(
                          ehEntrada
                              ? Icons.add_circle_outline
                              : Icons.remove_circle_outline,
                          color: ehEntrada ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        '${ehEntrada ? 'Entrada' : 'Saída'}: '
                            '${movimentacao.quantidade} unidade(s)',
                      ),
                      subtitle: Text(
                        'Produto: $nomeProduto\n'
                            'Data: ${_formatarData(movimentacao.dataMovimentacao)}'
                            '${movimentacao.motivo == null ? '' : '\nMotivo: ${movimentacao.motivo}'}',
                      ),
                      isThreeLine: movimentacao.motivo != null,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}