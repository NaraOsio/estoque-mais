import 'package:flutter/material.dart';

import '../../produtos/view/lista_produtos_page.dart';
import '../view_model/autenticacao_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _viewModel = AutenticacaoViewModel();

  bool _emCadastro = false;

  Future<void> _enviar() async {
    final erro = _emCadastro
        ? await _viewModel.criarConta(
      email: _emailController.text,
      senha: _senhaController.text,
    )
        : await _viewModel.entrar(
      email: _emailController.text,
      senha: _senhaController.text,
    );

    if (!mounted) {
      return;
    }

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ListaProdutosPage(),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _emCadastro ? 'Criar conta' : 'Entrar';
    final textoBotao = _emCadastro ? 'Criar conta' : 'Entrar';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque+'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              titulo,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _enviar,
                child: Text(textoBotao),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _emCadastro = !_emCadastro;
                });
              },
              child: Text(
                _emCadastro
                    ? 'Já tenho uma conta'
                    : 'Ainda não tenho uma conta',
              ),
            ),
          ],
        ),
      ),
    );
  }
}