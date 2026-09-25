import 'package:flutter/material.dart';

import '../../autenticacao/repository/autenticacao_repository.dart';
import '../../autenticacao/view/login_page.dart';
import 'cadastro_produto_page.dart';

class ListaProdutosPage extends StatefulWidget {
  const ListaProdutosPage({super.key});

  @override
  State<ListaProdutosPage> createState() => _ListaProdutosPageState();
}

class _ListaProdutosPageState extends State<ListaProdutosPage> {
  final _autenticacaoRepository = AutenticacaoRepository();

  Future<void> _sair() async {
    await _autenticacaoRepository.sair();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
            onPressed: _sair,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
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