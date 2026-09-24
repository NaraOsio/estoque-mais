import 'package:flutter/material.dart';

import '../view_model/produto_view_model.dart';

class CadastroProdutoPage extends StatefulWidget {
  const CadastroProdutoPage({super.key});

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final _nomeController = TextEditingController();
  final _quantidadeInicialController = TextEditingController();
  final _estoqueMinimoController = TextEditingController();
  final _produtoViewModel = ProdutoViewModel();

  void _salvarProduto() {
    final erro = _produtoViewModel.validarCadastro(
      nome: _nomeController.text,
      quantidadeInicialTexto: _quantidadeInicialController.text,
      estoqueMinimoTexto: _estoqueMinimoController.text,
    );

    final mensagem = erro ?? 'Dados validados com sucesso.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar produto'),
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
            TextFormField(
              controller: _quantidadeInicialController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade inicial',
                border: OutlineInputBorder(),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvarProduto,
                child: const Text('Salvar produto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}