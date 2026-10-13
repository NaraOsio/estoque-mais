import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../model/produto.dart';
import '../view_model/produto_view_model.dart';
import 'cadastro_produto_page.dart';

class LeitorCodigoPage extends StatefulWidget {
  const LeitorCodigoPage({super.key});

  @override
  State<LeitorCodigoPage> createState() =>
      _LeitorCodigoPageState();
}

class _LeitorCodigoPageState extends State<LeitorCodigoPage> {
  final _controller = MobileScannerController();
  final _produtoViewModel = ProdutoViewModel();

  Produto? _produtoEncontrado;
  String? _mensagem;
  String? _codigoLido;
  bool _produtoNaoCadastrado = false;
  bool _processandoLeitura = false;

  Future<void> _lerCodigo(BarcodeCapture captura) async {
    if (_processandoLeitura ||
        _produtoEncontrado != null ||
        _mensagem != null ||
        captura.barcodes.isEmpty) {
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
      _codigoLido = codigo.trim();
      _produtoNaoCadastrado = false;
    });

    try {
      await _controller.stop();

      if (!mounted) {
        return;
      }

      final idUsuario =
          FirebaseAuth.instance.currentUser?.uid;

      if (idUsuario == null) {
        setState(() {
          _mensagem = 'Usuário não identificado.';
          _processandoLeitura = false;
        });
        return;
      }

      final produtos =
      await _produtoViewModel.listarPorUsuario(idUsuario);

      final produto = _produtoViewModel.buscarPorCodigo(
        produtos: produtos,
        codigo: codigo,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _produtoEncontrado = produto;
        _produtoNaoCadastrado = produto == null;
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
    if (_processandoLeitura) {
      return;
    }

    setState(() {
      _produtoEncontrado = null;
      _mensagem = null;
      _codigoLido = null;
      _produtoNaoCadastrado = false;
      _processandoLeitura = false;
    });

    // Aguarda a tela reservar novamente o espaço da câmera.
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      return;
    }

    try {
      await _controller.start();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _mensagem = 'Não foi possível abrir a câmera.';
      });
    }
  }
  Future<void> _cadastrarProduto() async {
    final codigo = _codigoLido;

    if (codigo == null ||
        !_produtoNaoCadastrado ||
        _processandoLeitura) {
      return;
    }

    setState(() {
      _processandoLeitura = true;
    });

    bool? salvou;

    try {
      salvou = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => CadastroProdutoPage(
            codigoInicial: codigo,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processandoLeitura = false;
        });
      }
    }

    if (!mounted) {
      return;
    }

    if (salvou == true) {
      await _lerOutroCodigo();
    }
  }

  String _formatarPreco(double? preco) {
    if (preco == null) {
      return 'Preço não informado';
    }

    return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Widget _montarCartao(Produto produto) {
    final imagemUrl = produto.imagemUrl;

    return Card(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagemUrl != null &&
                imagemUrl.trim().isNotEmpty) ...[
              Center(
                child: Image.network(
                  imagemUrl,
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progresso) {
                    if (progresso == null) {
                      return child;
                    }

                    return const SizedBox(
                      width: 180,
                      height: 180,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, erro, pilha) {
                    return const SizedBox(
                      width: 180,
                      height: 180,
                      child: Center(
                        child: Text(
                          'Não foi possível carregar a foto.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              produto.nome,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              _formatarPreco(produto.precoVenda),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Estoque disponível: ${produto.quantidadeAtual}',
            ),
            const SizedBox(height: 24),
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
    );
  }

  Widget _montarOrientacao() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_processandoLeitura)
              const CircularProgressIndicator()
            else
              Icon(
                Icons.qr_code_scanner,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            const SizedBox(height: 12),
            Text(
              _processandoLeitura
                  ? 'Consultando produto...'
                  : _mensagem ??
                  'Aponte a câmera para o código do produto.',
              textAlign: TextAlign.center,
            ),
            if (_produtoNaoCadastrado) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                  _processandoLeitura ? null : _cadastrarProduto,
                  icon: const Icon(Icons.add),
                  label: const Text('Cadastrar este produto'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 56),
                  ),
                ),
              ),
            ],
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produto = _produtoEncontrado;
    final mostrarCamera =
        produto == null && _mensagem == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultar produto'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, limites) {
            return Column(
              children: [
                // Recolhe a câmera após a consulta,
                // preservando o componente para a próxima leitura.
                SizedBox(
                  height: mostrarCamera
                      ? limites.maxHeight * 0.55
                      : 0,
                  child: Offstage(
                    offstage: !mostrarCamera,
                    child: MobileScanner(
                      controller: _controller,
                      onDetect: _lerCodigo,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: produto != null
                        ? _montarCartao(produto)
                        : _montarOrientacao(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}