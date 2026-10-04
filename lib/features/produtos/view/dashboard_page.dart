import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../movimentacoes/model/movimentacao.dart';
import '../../movimentacoes/view_model/movimentacao_view_model.dart';
import '../model/produto.dart';
import '../view_model/produto_view_model.dart';
import 'lista_produtos_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _produtoViewModel = ProdutoViewModel();
  final _movimentacaoViewModel = MovimentacaoViewModel();

  late Future<_DadosDashboard> _dadosFuture;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    _dadosFuture = _buscarDados();
  }

  Future<_DadosDashboard> _buscarDados() async {
    final idUsuario = FirebaseAuth.instance.currentUser?.uid;

    if (idUsuario == null) {
      return const _DadosDashboard(
        produtos: [],
        movimentacoes: [],
      );
    }

    final produtosFuture = _produtoViewModel.listarPorUsuario(idUsuario);
    final movimentacoesFuture =
    _movimentacaoViewModel.listarPorUsuario(idUsuario);

    final produtos = await produtosFuture;
    final movimentacoes = await movimentacoesFuture;

    return _DadosDashboard(
      produtos: produtos,
      movimentacoes: movimentacoes,
    );
  }

  Future<void> _abrirProdutos() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ListaProdutosPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(_carregarDados);
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão geral'),
        actions: [
          IconButton(
            onPressed: () {
              setState(_carregarDados);
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar dados',
          ),
        ],
      ),
      body: FutureBuilder<_DadosDashboard>(
        future: _dadosFuture,
        builder: (context, resultado) {
          if (resultado.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (resultado.hasError) {
            return const Center(
              child: Text('Não foi possível carregar o resumo.'),
            );
          }

          final dados = resultado.data ??
              const _DadosDashboard(
                produtos: [],
                movimentacoes: [],
              );

          final produtosAtivos = dados.produtos
              .where((produto) => produto.ativo)
              .toList();

          final produtosComAlerta = produtosAtivos.where((produto) {
            return produto.quantidadeAtual <= produto.estoqueMinimo;
          }).toList();

          final nomesProdutos = <String, String>{
            for (final produto in dados.produtos) produto.id: produto.nome,
          };

          final movimentacoesRecentes =
          dados.movimentacoes.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(_carregarDados);
              await _dadosFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Resumo do estoque',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Acompanhe os principais dados do seu negócio.',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ResumoCard(
                        titulo: 'Produtos ativos',
                        valor: produtosAtivos.length.toString(),
                        icone: Icons.inventory_2_outlined,
                        cor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResumoCard(
                        titulo: 'Com alerta',
                        valor: produtosComAlerta.length.toString(),
                        icone: Icons.warning_amber_rounded,
                        cor: produtosComAlerta.any(
                              (produto) => produto.quantidadeAtual == 0,
                        )
                            ? Colors.red
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _abrirProdutos,
                  icon: const Icon(Icons.inventory_2_rounded),
                  label: const Text('Abrir produtos'),
                ),
                const SizedBox(height: 28),
                Text(
                  'Movimentações recentes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (movimentacoesRecentes.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Nenhuma movimentação registrada ainda.',
                      ),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (var indice = 0;
                        indice < movimentacoesRecentes.length;
                        indice++) ...[
                          _MovimentacaoRecenteItem(
                            movimentacao: movimentacoesRecentes[indice],
                            nomeProduto: nomesProdutos[
                            movimentacoesRecentes[indice].idProduto] ??
                                'Produto não encontrado',
                            dataFormatada: _formatarData(
                              movimentacoesRecentes[indice].dataMovimentacao,
                            ),
                          ),
                          if (indice < movimentacoesRecentes.length - 1)
                            const Divider(height: 1),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;

  const _ResumoCard({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icone,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 18),
            Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovimentacaoRecenteItem extends StatelessWidget {
  final Movimentacao movimentacao;
  final String nomeProduto;
  final String dataFormatada;

  const _MovimentacaoRecenteItem({
    required this.movimentacao,
    required this.nomeProduto,
    required this.dataFormatada,
  });

  @override
  Widget build(BuildContext context) {
    final entrada = movimentacao.tipo == 'entrada';
    final cor = entrada ? Colors.green : Colors.red;
    final icone = entrada
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cor.withValues(alpha: 0.12),
        child: Icon(
          icone,
          color: cor,
        ),
      ),
      title: Text(nomeProduto),
      subtitle: Text('$dataFormatada • ${movimentacao.tipo}'),
      trailing: Text(
        '${entrada ? '+' : '-'}${movimentacao.quantidade}',
        style: TextStyle(
          color: cor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DadosDashboard {
  final List<Produto> produtos;
  final List<Movimentacao> movimentacoes;

  const _DadosDashboard({
    required this.produtos,
    required this.movimentacoes,
  });
}