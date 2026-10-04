import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../categorias/model/categoria.dart';
import '../../categorias/view_model/categoria_view_model.dart';
import '../model/produto.dart';
import '../view_model/produto_view_model.dart';

class CadastroProdutoPage extends StatefulWidget {
  final Produto? produto;

  const CadastroProdutoPage({
    super.key,
    this.produto,
  });

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final _nomeController = TextEditingController();
  final _quantidadeInicialController = TextEditingController();
  final _estoqueMinimoController = TextEditingController();

  final _produtoViewModel = ProdutoViewModel();
  final _categoriaViewModel = CategoriaViewModel();

  late Future<List<Categoria>> _categoriasFuture;
  String? _idCategoriaSelecionada;
  bool _salvando = false;
  bool _exigeValidade = false;
  DateTime? _dataValidade;

  @override
  void initState() {
    super.initState();

    final produto = widget.produto;

    if (produto != null) {
      _nomeController.text = produto.nome;
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

  Future<void> _salvarProduto() async {
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

    String? mensagemErro;

    if (widget.produto == null) {
      mensagemErro = await _produtoViewModel.criarProduto(
        idUsuario: idUsuario,
        idCategoria: _idCategoriaSelecionada ?? '',
        nome: _nomeController.text,
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
              onPressed: () => Navigator.of(contextoDialogo).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(contextoDialogo).pop(true),
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
    _quantidadeInicialController.dispose();
    _estoqueMinimoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.produto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editando ? 'Editar produto' : 'Cadastrar produto',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do produto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Categoria>>(
              future: _categoriasFuture,
              builder: (context, resultado) {
                if (resultado.connectionState == ConnectionState.waiting) {
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
                      _idCategoriaSelecionada = idCategoria;
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
                labelText: editando ? 'Quantidade atual' : 'Quantidade inicial',
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
                onPressed: _salvando ? null : _selecionarDataValidade,
                icon: const Icon(Icons.calendar_today_outlined),
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
                onPressed: _salvando ? null : _salvarProduto,
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
                  onPressed: _salvando ? null : _desativarProduto,
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
    );
  }
}