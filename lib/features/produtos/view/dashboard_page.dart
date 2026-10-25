import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../autenticacao/view/login_page.dart';
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
      return const _DadosDashboard(produtos: [], movimentacoes: []);
    }

    final produtosFuture = _produtoViewModel.listarPorUsuario(idUsuario);
    final movimentacoesFuture = _movimentacaoViewModel.listarPorUsuario(
      idUsuario,
    );

    final produtos = await produtosFuture;
    final movimentacoes = await movimentacoesFuture;

    return _DadosDashboard(produtos: produtos, movimentacoes: movimentacoes);
  }

  Future<void> _abrirProdutos() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ListaProdutosPage()));

    if (!mounted) {
      return;
    }

    setState(_carregarDados);
  }

  Future<void> _sairDaConta() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (rota) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível sair. Tente novamente.'),
        ),
      );
    }
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
        title: const Text(
          'Visão geral',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _sairDaConta,
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
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
            return const Center(child: CircularProgressIndicator());
          }

          if (resultado.hasError) {
            return const Center(
              child: Text('Não foi possível carregar o resumo.'),
            );
          }

          final dados =
              resultado.data ??
              const _DadosDashboard(produtos: [], movimentacoes: []);

          final produtosAtivos = dados.produtos
              .where((produto) => produto.ativo)
              .toList();

          final produtosEmFalta = produtosAtivos
              .where((produto) => produto.quantidadeAtual == 0)
              .toList();

          final produtosEstoqueBaixo = produtosAtivos
              .where(
                (produto) =>
                    produto.quantidadeAtual > 0 &&
                    produto.quantidadeAtual <= produto.estoqueMinimo,
              )
              .toList();

          final produtosProximosVencimento = produtosAtivos
              .where(
                (produto) =>
                    _produtoViewModel.obterAlertaValidade(produto) != null,
              )
              .toList();

          final produtosComAlerta = produtosAtivos.where((produto) {
            return _produtoViewModel.obterAlertaEstoque(produto) != null ||
                _produtoViewModel.obterAlertaValidade(produto) != null;
          }).toList();

          final nomesProdutos = <String, String>{
            for (final produto in dados.produtos) produto.id: produto.nome,
          };

          final movimentacoesRecentes = dados.movimentacoes.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(_carregarDados);
              await _dadosFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Resumo do estoque',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF19334D),
                  ),
                ),
                const SizedBox(height: 8),

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
                        cor:
                            produtosComAlerta.any(
                              (produto) => produto.quantidadeAtual == 0,
                            )
                            ? Colors.red
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
                if (produtosComAlerta.isEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Não há itens que exigem atenção.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _abrirProdutos,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.inventory_2_rounded, size: 24),
                  label: const Text(
                    'Abrir produtos',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                if (produtosEmFalta.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: ExpansionTile(
                      title: Text('Em falta (${produtosEmFalta.length})'),
                      initiallyExpanded: true,
                      children: [
                        for (final produto in produtosEmFalta)
                          ListTile(
                            title: Text(produto.nome),
                            subtitle: Text(
                              'Quantidade: ${produto.quantidadeAtual} • '
                              'Mínimo: ${produto.estoqueMinimo}',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (produtosEstoqueBaixo.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: ExpansionTile(
                      title: Text(
                        'Estoque baixo (${produtosEstoqueBaixo.length})',
                      ),
                      initiallyExpanded: true,
                      children: [
                        for (final produto in produtosEstoqueBaixo)
                          ListTile(
                            title: Text(produto.nome),
                            subtitle: Text(
                              'Quantidade: ${produto.quantidadeAtual} • '
                              'Mínimo: ${produto.estoqueMinimo}',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (produtosProximosVencimento.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: ExpansionTile(
                      title: Text(
                        'Próximos do vencimento '
                        '(${produtosProximosVencimento.length})',
                      ),
                      initiallyExpanded: true,
                      children: [
                        for (final produto in produtosProximosVencimento)
                          ListTile(
                            title: Text(produto.nome),
                            subtitle: Text(
                              'Validade: ${_formatarData(produto.dataValidade!)}'
                              ' • ${_produtoViewModel.obterAlertaValidade(produto) ?? ''}',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
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
                      child: Text('Nenhuma movimentação registrada ainda.'),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (
                          var indice = 0;
                          indice < movimentacoesRecentes.length;
                          indice++
                        ) ...[
                          _MovimentacaoRecenteItem(
                            movimentacao: movimentacoesRecentes[indice],
                            nomeProduto:
                                nomesProdutos[movimentacoesRecentes[indice]
                                    .idProduto] ??
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
    final corEscura = Color.lerp(cor, Colors.black, 0.22)!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cor, corEscura],
        ),
        boxShadow: [
          BoxShadow(
            color: cor.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: Colors.white, size: 25),
          ),
          const SizedBox(height: 18),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
    final cor = entrada ? const Color(0xFF187544) : const Color(0xFFB3261E);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              entrada
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: cor,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomeProduto,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF19334D),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dataFormatada,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF52677D),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: cor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entrada ? 'Entrada' : 'Saída',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cor,
                        ),
                      ),
                    ),
                    Text(
                      '${entrada ? '+' : '-'}'
                      '${movimentacao.quantidade} unidade(s)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DadosDashboard {
  final List<Produto> produtos;
  final List<Movimentacao> movimentacoes;

  const _DadosDashboard({required this.produtos, required this.movimentacoes});
}
