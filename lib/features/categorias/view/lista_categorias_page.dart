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
  Categoria? _categoriaEditando;
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

  void _iniciarEdicao(Categoria categoria) {
    setState(() {
      _categoriaEditando = categoria;
      _nomeController.text = categoria.nome;
      _descricaoController.text = categoria.descricao ?? '';
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _categoriaEditando = null;
      _nomeController.clear();
      _descricaoController.clear();
    });
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

    final categoriaEditando = _categoriaEditando;

    final mensagemErro = categoriaEditando == null
        ? await _viewModel.criarCategoria(
      idUsuario: idUsuario,
      nome: _nomeController.text,
      descricao: _descricaoController.text,
    )
        : await _viewModel.atualizarCategoria(
      categoria: categoriaEditando,
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

    final mensagemSucesso = categoriaEditando == null
        ? 'Categoria salva com sucesso.'
        : 'Categoria atualizada com sucesso.';

    _nomeController.clear();
    _descricaoController.clear();

    setState(() {
      _categoriaEditando = null;
      _carregarCategorias();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagemSucesso)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = _categoriaEditando != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                editando ? 'Editar categoria' : 'Nova categoria',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome da categoria',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descricaoController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _salvando ? null : _salvarCategoria,
                child: Text(
                  _salvando
                      ? 'Salvando...'
                      : editando
                      ? 'Salvar alterações'
                      : 'Salvar categoria',
                ),
              ),
            ),
            if (editando)
              TextButton(
                onPressed: _salvando ? null : _cancelarEdicao,
                child: const Text('Cancelar edição'),
              ),
            const SizedBox(height: 8),
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
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, indice) {
                      final categoria = categorias[indice];

                      return Card(
                        child: ListTile(
                          onTap: () => _iniciarEdicao(categoria),
                          leading: const Icon(Icons.category_outlined),
                          title: Text(categoria.nome),
                          subtitle: categoria.descricao == null
                              ? const Text('Sem descrição')
                              : Text(categoria.descricao!),
                          trailing: const Icon(Icons.edit_rounded),
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