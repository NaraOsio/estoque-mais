import 'package:flutter/material.dart';

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
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}