import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../categorias/model/categoria.dart';
import '../../categorias/view_model/categoria_view_model.dart';
import '../model/produto.dart';
import '../services/cloudinary_service.dart';
import '../services/open_food_facts_service.dart';
import '../view_model/produto_view_model.dart';


class CadastroProdutoPage extends StatefulWidget {
  final Produto? produto;
  final String? codigoInicial;

  const CadastroProdutoPage({
    super.key,
    this.produto,
    this.codigoInicial,
  });

  @override
  State<CadastroProdutoPage> createState() =>
      _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final _nomeController = TextEditingController();
  final _codigoBarrasController = TextEditingController();
  final _precoVendaController = TextEditingController();
  final _quantidadeInicialController = TextEditingController();
  final _estoqueMinimoController = TextEditingController();

  final _produtoViewModel = ProdutoViewModel();
  final _categoriaViewModel = CategoriaViewModel();
  final _imagePicker = ImagePicker();

  XFile? _imagemSelecionada;
  final _openFoodFactsService = OpenFoodFactsService();

  bool _buscandoProduto = false;
  String? _imagemUrlExterna;
  String? _fonteProdutoUrl;
  String? _mensagemBusca;

  late Future<List<Categoria>> _categoriasFuture;

  String? _idCategoriaSelecionada;
  bool _salvando = false;
  bool _exigeValidade = false;
DateTime? _dataValidade;

@override
void initState() {
super.initState();

final produto = widget.produto;

if (produto == null) {
_codigoBarrasController.text =
widget.codigoInicial?.trim() ?? '';
} else {
_nomeController.text = produto.nome;
_codigoBarrasController.text = produto.codigoBarras ?? '';

_precoVendaController.text = produto.precoVenda == null
? ''
: produto.precoVenda!
.toStringAsFixed(2)
.replaceAll('.', ',');

_quantidadeInicialController.text =
produto.quantidadeAtual.toString();

_estoqueMinimoController.text =
produto.estoqueMinimo.toString();

_idCategoriaSelecionada = produto.idCategoria;
_exigeValidade = produto.exigeValidade;
_dataValidade = produto.dataValidade;
}

final idUsuario = FirebaseAuth.instance.currentUser?.uid;

_categoriasFuture = idUsuario == null
    ? Future.value(<Categoria>[])
    : _categoriaViewModel.listarPorUsuario(idUsuario);

if (produto == null &&
    _codigoBarrasController.text.trim().isNotEmpty) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      _buscarProdutoExterno();
    }
  });
}
}
  Future<void> _buscarProdutoExterno() async {
    if (_buscandoProduto || _salvando || widget.produto != null) {
      return;
    }

    final codigo = _codigoBarrasController.text.trim();
    final nomeAntesDaBusca = _nomeController.text;

    if (codigo.isEmpty) {
      setState(() {
        _mensagemBusca = 'Informe ou escaneie o código de barras.';
      });
      return;
    }

    setState(() {
      _buscandoProduto = true;
      _mensagemBusca = null;
    });

    try {
      final resultado =
      await _openFoodFactsService.buscarPorCodigo(codigo);

      if (!mounted) {
        return;
      }

      // Ignora a resposta se o código foi alterado durante a busca.
      if (_codigoBarrasController.text.trim() != codigo) {
        setState(() {
          _mensagemBusca =
          'O código mudou. Faça uma nova busca.';
        });
        return;
      }

      setState(() {
        if (resultado == null) {
          _mensagemBusca =
          'Produto não encontrado. Preencha os dados manualmente.';
          return;
        }

        // Preserva um nome que você já tenha preenchido.
        if (nomeAntesDaBusca.trim().isEmpty &&
            _nomeController.text.trim().isEmpty) {
          _nomeController.text = resultado.nome;
        }

        _imagemUrlExterna = resultado.imagemUrl;
        _fonteProdutoUrl = resultado.fonteUrl;

        _mensagemBusca = resultado.imagemUrl == null
            ? 'Dados encontrados, sem foto. Confira antes de salvar.'
            : 'Dados encontrados. Confira antes de salvar.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _mensagemBusca =
        'Não foi possível buscar os dados. '
            'Tente novamente ou preencha manualmente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _buscandoProduto = false;
        });
      }
    }
  }

  Future<void> _selecionarDataValidade() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataValidade ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataSelecionada == null || !mounted) {
      return;
    }

    setState(() {
      _dataValidade = dataSelecionada;
    });
  }

  Future<void> _selecionarImagem() async {
    final imagem = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (imagem == null || !mounted) {
      return;
    }

    setState(() {
      _imagemSelecionada = imagem;
    });
  }

  Future<void> _salvarProduto() async {
    if (_buscandoProduto || _salvando) {
      return;
    }

    final idUsuario = FirebaseAuth.instance.currentUser?.uid;

    if (idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não identificado.'),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    String? imagemUrl =
        _imagemUrlExterna ?? widget.produto?.imagemUrl;

    try {
      if (_imagemSelecionada != null) {
        imagemUrl = await CloudinaryService().enviarImagem(
          _imagemSelecionada!,
        );
      }
    } catch (erro) {
      debugPrint('ERRO AO ENVIAR FOTO: $erro');
      if (mounted) {
        setState(() {
          _salvando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Não foi possível enviar a foto. Tente novamente.',
            ),
          ),
        );
      }
      return;
    }

    String? mensagemErro;

    if (widget.produto == null) {
      mensagemErro = await _produtoViewModel.criarProduto(
        idUsuario: idUsuario,
        idCategoria: _idCategoriaSelecionada ?? '',
        nome: _nomeController.text,
        codigoBarras: _codigoBarrasController.text,
        imagemUrl: imagemUrl,
        precoVendaTexto: _precoVendaController.text,
        quantidadeInicialTexto: _quantidadeInicialController.text,
        estoqueMinimoTexto: _estoqueMinimoController.text,
        exigeValidade: _exigeValidade,
        dataValidade: _dataValidade,
      );
    } else {
      mensagemErro = await _produtoViewModel.atualizarProduto(
        produto: widget.produto!,
        idCategoria: _idCategoriaSelecionada ?? '',
        nome: _nomeController.text,
        codigoBarras: _codigoBarrasController.text,
        imagemUrl: imagemUrl,
        precoVendaTexto: _precoVendaController.text,
        quantidadeInicialTexto: _quantidadeInicialController.text,
        estoqueMinimoTexto: _estoqueMinimoController.text,
        exigeValidade: _exigeValidade,
        dataValidade: _dataValidade,
      );
    }

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

    final mensagemSucesso = widget.produto == null
        ? 'Produto salvo com sucesso.'
        : 'Produto atualizado com sucesso.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagemSucesso)),
    );

    Navigator.of(context).pop(true);
  }

  Future<void> _desativarProduto() async {
    final produto = widget.produto;

    if (produto == null) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) {
        return AlertDialog(
          title: const Text('Desativar produto'),
          content: Text(
            'Deseja desativar o produto "${produto.nome}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(contextoDialogo).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(contextoDialogo).pop(true);
              },
              child: const Text('Desativar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    final mensagemErro =
    await _produtoViewModel.desativarProduto(produto);

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
    _nomeController.dispose();
    _codigoBarrasController.dispose();
    _precoVendaController.dispose();
    _quantidadeInicialController.dispose();
    _estoqueMinimoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.produto != null;
    final imagemUrl =
        _imagemUrlExterna ?? widget.produto?.imagemUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editando ? 'Editar produto' : 'Cadastrar produto',
        ),
      ),
      body: SafeArea(
        // Reserva uma margem na parte inferior da tela.
        minimum: const EdgeInsets.only(bottom: 24),
        child: SingleChildScrollView(
          // Espaço ao redor do formulário.
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: _imagemSelecionada != null
                            ? Image.file(
                          File(_imagemSelecionada!.path),
                          fit: BoxFit.cover,
                        )
                            : imagemUrl != null && imagemUrl.trim().isNotEmpty
                            ? Image.network(
                          imagemUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, erro, pilha) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                              ),
                            );
                          },
                        )
                            : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_outlined,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed:
                      _salvando ? null : _selecionarImagem,
                      icon: const Icon(
                        Icons.photo_library_outlined,
                      ),
                      label: const Text('Selecionar foto'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do produto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codigoBarrasController,
                enabled: !_salvando && !_buscandoProduto,
                onChanged: (_) {
                  setState(() {
                    _imagemUrlExterna = null;
                    _fonteProdutoUrl = null;
                    _mensagemBusca = null;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Código de barras ou QR Code',
                  helperText:
                  'Opcional. Pode ser preenchido pela câmera.',
                  border: OutlineInputBorder(),
                ),
              ),
              if (!editando) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _buscandoProduto || _salvando
                      ? null
                      : _buscarProdutoExterno,
                  icon: _buscandoProduto
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.search),
                  label: Text(
                    _buscandoProduto
                        ? 'Buscando produto...'
                        : 'Buscar dados pelo código',
                  ),
                ),
                if (_mensagemBusca != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _mensagemBusca!,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_fonteProdutoUrl != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Fonte: Open Food Facts • Dados: ODbL',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  SelectableText(
                    _fonteProdutoUrl!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoVendaController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Preço de venda',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Categoria>>(
                future: _categoriasFuture,
                builder: (context, resultado) {
                  if (resultado.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final categorias = resultado.data ?? [];

                  if (categorias.isEmpty) {
                    return const Text(
                      'Cadastre uma categoria antes de criar um produto.',
                    );
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _idCategoriaSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: categorias.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria.id,
                        child: Text(categoria.nome),
                      );
                    }).toList(),
                    onChanged: _salvando
                        ? null
                        : (idCategoria) {
                      setState(() {
                        _idCategoriaSelecionada =
                            idCategoria;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeInicialController,
                readOnly: editando,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: editando
                      ? 'Quantidade atual'
                      : 'Quantidade inicial',
                  border: const OutlineInputBorder(),
                  helperText: editando
                      ? 'Altere a quantidade pela tela de movimentações.'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _estoqueMinimoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estoque mínimo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Produto possui validade'),
                value: _exigeValidade,
                onChanged: _salvando
                    ? null
                    : (valor) {
                  setState(() {
                    _exigeValidade = valor;

                    if (!valor) {
                      _dataValidade = null;
                    }
                  });
                },
              ),
              if (_exigeValidade) ...[
                OutlinedButton.icon(
                  onPressed:
                  _salvando ? null : _selecionarDataValidade,
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                  ),
                  label: Text(
                    _dataValidade == null
                        ? 'Selecionar data de validade'
                        : 'Validade: '
                        '${_dataValidade!.day.toString().padLeft(2, '0')}/'
                        '${_dataValidade!.month.toString().padLeft(2, '0')}/'
                        '${_dataValidade!.year}',
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvando || _buscandoProduto
                      ? null
                      : _salvarProduto,
                  child: Text(
                    _salvando
                        ? 'Salvando...'
                        : editando
                        ? 'Salvar alterações'
                        : 'Salvar produto',
                  ),
                ),
              ),
              if (editando) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed:
                    _salvando ? null : _desativarProduto,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Desativar produto'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}