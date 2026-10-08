import 'package:flutter/material.dart';

import '../../produtos/view/dashboard_page.dart';
import '../view_model/autenticacao_view_model.dart';

const _verdePrincipal = Color(0xFF1565C0);
const _laranjaDestaque = Color(0xFFF57C00);
const _fundoClaro = Color(0xFFF5F9FF);
const _textoSecundario = Color(0xFF52677D);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _viewModel = AutenticacaoViewModel();

  bool _emCadastro = false;

  Future<void> _enviar() async {
    final erro = _emCadastro
        ? await _viewModel.criarConta(
      nome: _nomeController.text,
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
        builder: (context) => const DashboardPage(),
      ),
    );
  }

  void _trocarModo() {
    setState(() {
      _emCadastro = !_emCadastro;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tituloFormulario =
    _emCadastro ? 'Crie sua conta' : 'Acesse sua conta';

    final textoBotao =
    _emCadastro ? 'Criar minha conta' : 'Entrar';

    final textoAlternativo =
    _emCadastro ? 'Já tenho uma conta' : 'Ainda não tenho uma conta';

    return Scaffold(
      backgroundColor: _fundoClaro,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 30,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E88E5),
                    Color(0xFF0D47A1),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Estoque+',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Controle simples para o seu negócio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 52,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _laranjaDestaque,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 36,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0x1AF57C00),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: _laranjaDestaque,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        tituloFormulario,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: _verdePrincipal,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Entre para organizar seus produtos e acompanhar seu estoque.',
                        style: TextStyle(
                          color: _textoSecundario,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_emCadastro) ...[
                        TextField(
                          controller: _nomeController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _enviar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _verdePrincipal,
                          ),
                          child: Text(textoBotao),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: _trocarModo,
                          child: Text(textoAlternativo),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}