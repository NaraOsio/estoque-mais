import 'package:flutter/material.dart';

import '../../produtos/view/dashboard_page.dart';
import '../view_model/autenticacao_view_model.dart';

const _azulPrincipal = Color(0xFF1767CF);
const _laranjaDestaque = Color(0xFFF57C00);
const _fundoClaro = Color(0xFFF3F7FD);
const _textoPrincipal = Color(0xFF172C46);
const _textoSecundario = Color(0xFF617289);

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
  bool _ocultarSenha = true;
  bool _enviando = false;

  Future<void> _enviar() async {
    if (_enviando) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _enviando = true;
    });

    try {
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
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível concluir. Tente novamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  void _trocarModo() {
    if (_enviando) {
      return;
    }

    setState(() {
      _emCadastro = !_emCadastro;
    });
  }

  InputDecoration _decoracaoCampo({
    required String dica,
    required IconData icone,
    Widget? acao,
  }) {
    return InputDecoration(
      hintText: dica,
      hintStyle: const TextStyle(
        color: Color(0xFF7A8798),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icone,
        color: _azulPrincipal,
        size: 22,
      ),
      suffixIcon: acao,
      filled: true,
      fillColor: const Color(0xFFF6F9FE),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _azulPrincipal,
          width: 1.5,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5F0),
        ),
      ),
    );
  }

  Widget _rotulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          color: _textoPrincipal,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF197DE2),
            Color(0xFF1548A4),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -65,
            top: 40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x12FFFFFF),
                  width: 28,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              26,
              28,
              26,
              60,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x29FFFFFF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Flexible(
                      child: Text(
                        'Estoque+',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Seu estoque organizado.\n'
                      'Seu negócio em movimento.',
                  style: TextStyle(
                    color: Color(0xFFE5EFFF),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _laranjaDestaque,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoFormulario() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14092955),
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1DF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _emCadastro
                  ? Icons.person_add_alt_1_outlined
                  : Icons.person_outline,
              color: _laranjaDestaque,
              size: 26,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _emCadastro
                ? 'Crie sua conta'
                : 'Bom ter você aqui!',
            style: const TextStyle(
              color: _textoPrincipal,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _emCadastro
                ? 'Cadastre-se para começar a organizar '
                'seus produtos e acompanhar seu estoque.'
                : 'Acesse sua conta para cuidar dos seus '
                'produtos e acompanhar seu estoque.',
            style: const TextStyle(
              color: _textoSecundario,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 26),
          if (_emCadastro) ...[
            _rotulo('Nome'),
            TextField(
              controller: _nomeController,
              enabled: !_enviando,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                color: _textoPrincipal,
                fontSize: 16,
              ),
              decoration: _decoracaoCampo(
                dica: 'Seu nome',
                icone: Icons.person_outline,
              ),
            ),
            const SizedBox(height: 18),
          ],
          _rotulo('E-mail'),
          TextField(
            controller: _emailController,
            enabled: !_enviando,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(
              color: _textoPrincipal,
              fontSize: 16,
            ),
            decoration: _decoracaoCampo(
              dica: 'Seu e-mail',
              icone: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 18),
          _rotulo('Senha'),
          TextField(
            controller: _senhaController,
            enabled: !_enviando,
            obscureText: _ocultarSenha,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            onSubmitted: (_) => _enviar(),
            style: const TextStyle(
              color: _textoPrincipal,
              fontSize: 16,
            ),
            decoration: _decoracaoCampo(
              dica: 'Sua senha',
              icone: Icons.lock_outline,
              acao: IconButton(
                tooltip: _ocultarSenha
                    ? 'Mostrar senha'
                    : 'Ocultar senha',
                onPressed: _enviando
                    ? null
                    : () {
                  setState(() {
                    _ocultarSenha = !_ocultarSenha;
                  });
                },
                icon: Icon(
                  _ocultarSenha
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _textoSecundario,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _enviando ? null : _enviar,
              style: ElevatedButton.styleFrom(
                backgroundColor: _azulPrincipal,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                const Color(0xFFADC8EC),
                disabledForegroundColor: Colors.white,
                minimumSize: const Size(0, 52),
                elevation: 2,
                shadowColor: const Color(0x401767CF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _enviando
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _emCadastro
                          ? 'Criar minha conta'
                          : 'Entrar',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              _emCadastro
                  ? 'Já tem uma conta?'
                  : 'Ainda não tem uma conta?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textoSecundario,
                fontSize: 14,
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: _enviando ? null : _trocarModo,
              style: TextButton.styleFrom(
                foregroundColor: _azulPrincipal,
              ),
              child: Text(
                _emCadastro
                    ? 'Acessar minha conta'
                    : 'Criar minha conta',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
    return Scaffold(
      backgroundColor: _fundoClaro,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      // O espaço final do cabeçalho permite
                      // que o cartão fique sobreposto a ele.
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 32,
                        ),
                        child: _cabecalho(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          204,
                          18,
                          0,
                        ),
                        child: _cartaoFormulario(),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      24,
                      20,
                      28,
                    ),
                    child: Text(
                      'Controle simples para o seu negócio.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _textoSecundario,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}