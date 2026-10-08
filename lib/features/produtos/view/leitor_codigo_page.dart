import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../model/produto.dart';
import '../view_model/produto_view_model.dart';

class LeitorCodigoPage extends StatefulWidget {
  const LeitorCodigoPage({super.key});

  @override
  State<LeitorCodigoPage> createState() => _LeitorCodigoPageState();
}

class _LeitorCodigoPageState extends State<LeitorCodigoPage> {
  final _controller = MobileScannerController();
  final _produtoViewModel = ProdutoViewModel();

  Produto? _produtoEncontrado;
  String? _mensagem;
  bool _processandoLeitura = false;

  Future<void> _lerCodigo(BarcodeCapture captura) async {
    if (_processandoLeitura || captura.barcodes.isEmpty) {
      return;
    }

    final codigo = captura.barcodes.first.rawValue;

    if (codigo == null || codigo.trim().isEmpty) {
      return;
    }

    setState(() {
      _processandoLeitura = true;
      _mensagem = null;
      _produtoEncontrado = null;
    });

    await _controller.stop();

    final idUsuario = FirebaseAuth.instance.currentUser?.uid;

    if (idUsuario == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _mensagem = 'Usuário não identificado.';
        _processandoLeitura = false;
      });
      return;
    }

    try {
      final produtos = await _produtoViewModel.listarPorUsuario(idUsuario);

      final produto = _produtoViewModel.buscarPorCodigo(
        produtos: produtos,
        codigo: codigo,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _produtoEncontrado = produto;
        _mensagem = produto == null
            ? 'Produto não cadastrado para este código.'
            : null;
        _processandoLeitura = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _mensagem = 'Não foi possível consultar o produto.';
        _processandoLeitura = false;
      });
    }
  }

  Future<void> _lerOutroCodigo() async {
    setState(() {
      _produtoEncontrado = null;
      _mensagem = null;
      _processandoLeitura = false;
    });

    await _controller.start();
  }

  String _formatarPreco(double? preco) {
    if (preco == null) {
      return 'Preço não informado';
    }

    return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produto = _produtoEncontrado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultar produto'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: _controller,
              onDetect: _lerCodigo,
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: produto != null
                  ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto.nome,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _formatarPreco(produto.precoVenda),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Estoque disponível: '
                            '${produto.quantidadeAtual}',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _lerOutroCodigo,
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Ler outro código'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _mensagem ??
                        'Aponte a câmera para o código do produto.',
                    textAlign: TextAlign.center,
                  ),
                  if (_mensagem != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _lerOutroCodigo,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}