import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../produtos/model/produto.dart';
import '../../produtos/view_model/produto_view_model.dart';
import '../view_model/movimentacao_view_model.dart';

class RegistrarMovimentacaoPage extends StatefulWidget {
  const RegistrarMovimentacaoPage({super.key});

  @override
  State<RegistrarMovimentacaoPage> createState() =>
      _RegistrarMovimentacaoPageState();
}

class _RegistrarMovimentacaoPageState
    extends State<RegistrarMovimentacaoPage> {
  final _produtoViewModel = ProdutoViewModel();
  final _movimentacaoViewModel = MovimentacaoViewModel();
  final _quantidadeController = TextEditingController();
  final _motivoController = TextEditingController();

  late Future<List<Produto>> _produtosFuture;
  String? _idProdutoSelecionado;
  String? _tipoSelecionado;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    final idUsuario = FirebaseAuth.instance.currentUser?.uid;

    _produtosFuture = idUsuario == null
        ? Future.value(<Produto>[])
        : _produtoViewModel.listarPorUsuario(idUsuario);
  }

  Future<void> _registrarMovimentacao() async {
    final idUsuario = FirebaseAuth.instance.currentUser?.uid;

    if (idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não identificado.')),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    final mensagemErro =
    await _movimentacaoViewModel.registrarMovimentacao(
      idUsuario: idUsuario,
      idProduto: _idProdutoSelecionado ?? '',
      tipo: _tipoSelecionado ?? '',
      quantidadeTexto: _quantidadeController.text,
      motivo: _motivoController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _salvando = false;
    });

    if (mensagemErro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErro)),
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimentar estoque'),
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

          final produtosAtivos = (resultado.data ?? [])
              .where((produto) => produto.ativo)
              .toList();

          if (produtosAtivos.isEmpty) {
            return const Center(
              child: Text('Nenhum produto ativo cadastrado.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _idProdutoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Produto',
                    border: OutlineInputBorder(),
                  ),
                  items: produtosAtivos.map((produto) {
                    return DropdownMenuItem(
                      value: produto.id,
                      child: Text(
                        '${produto.nome} (${produto.quantidadeAtual})',
                      ),
                    );
                  }).toList(),
                  onChanged: _salvando
                      ? null
                      : (idProduto) {
                    setState(() {
                      _idProdutoSelecionado = idProduto;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _tipoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de movimentação',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'entrada',
                      child: Text('Entrada'),
                    ),
                    DropdownMenuItem(
                      value: 'saida',
                      child: Text('Saída'),
                    ),
                  ],
                  onChanged: _salvando
                      ? null
                      : (tipo) {
                    setState(() {
                      _tipoSelecionado = tipo;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantidadeController,
                  keyboardType: TextInputType.number,
                  enabled: !_salvando,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _motivoController,
                  enabled: !_salvando,
                  decoration: const InputDecoration(
                    labelText: 'Motivo (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                    _salvando ? null : _registrarMovimentacao,
                    child: Text(
                      _salvando
                          ? 'Registrando...'
                          : 'Registrar movimentação',
                    ),
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