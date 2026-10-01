import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/categoria.dart';
import '../view_model/categoria_view_model.dart';

class ListaCategoriasPage extends StatefulWidget {
  const ListaCategoriasPage({super.key});

  @override
  State<ListaCategoriasPage> createState() => _ListaCategoriasPageState();
}

class _ListaCategoriasPageState extends State<ListaCategoriasPage> {
  final _viewModel = CategoriaViewModel();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  late Future<List<Categoria>> _categoriasFuture;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _carregarCategorias() {
    final idUsuario = FirebaseAuth.instance.currentUser?.uid;

    _categoriasFuture = idUsuario == null
        ? Future.value(<Categoria>[])
        : _viewModel.listarPorUsuario(idUsuario);
  }

  Future<void> _salvarCategoria() async {
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

    final mensagemErro = await _viewModel.criarCategoria(
      idUsuario: idUsuario,
      nome: _nomeController.text,
      descricao: _descricaoController.text,
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

    _nomeController.clear();
    _descricaoController.clear();

    setState(_carregarCategorias);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Categoria salva com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da categoria',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _salvando ? null : _salvarCategoria,
                child: Text(
                  _salvando ? 'Salvando...' : 'Salvar categoria',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Categoria>>(
                future: _categoriasFuture,
                builder: (context, resultado) {
                  if (resultado.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (resultado.hasError) {
                    return const Center(
                      child: Text(
                        'Não foi possível carregar as categorias.',
                      ),
                    );
                  }

                  final categorias = resultado.data ?? [];

                  if (categorias.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma categoria cadastrada'),
                    );
                  }

                  return ListView.separated(
                    itemCount: categorias.length,
                    separatorBuilder: (_, _) =>
                    const SizedBox(height: 8),
                    itemBuilder: (context, indice) {
                      final categoria = categorias[indice];

                      return Card(
                        child: ListTile(
                          title: Text(categoria.nome),
                          subtitle: categoria.descricao == null
                              ? null
                              : Text(categoria.descricao!),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}