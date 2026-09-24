import 'package:flutter/material.dart';

import 'cadastro_produto_page.dart';

class ListaProdutosPage extends StatelessWidget {
  const ListaProdutosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      body: const Center(
        child: Text('Nenhum produto cadastrado'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CadastroProdutoPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}