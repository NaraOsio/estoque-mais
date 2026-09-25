import 'package:firebase_auth/firebase_auth.dart';

import '../repository/autenticacao_repository.dart';

class AutenticacaoViewModel {
  final AutenticacaoRepository _repository;

  AutenticacaoViewModel({
    AutenticacaoRepository? repository,
  }) : _repository = repository ?? AutenticacaoRepository();

  Future<String?> criarConta({
    required String email,
    required String senha,
  }) async {
    final erro = _validar(email: email, senha: senha);
    if (erro != null) {
      return erro;
    }

    try {
      await _repository.criarConta(
        email: email.trim(),
        senha: senha,
      );
      return null;
    } on FirebaseAuthException catch (erro) {
      return _mensagemDoErro(erro);
    }
  }

  Future<String?> entrar({
    required String email,
    required String senha,
  }) async {
    final erro = _validar(email: email, senha: senha);
    if (erro != null) {
      return erro;
    }

    try {
      await _repository.entrar(
        email: email.trim(),
        senha: senha,
      );
      return null;
    } on FirebaseAuthException catch (erro) {
      return _mensagemDoErro(erro);
    }
  }

  String? _validar({
    required String email,
    required String senha,
  }) {
    if (email.trim().isEmpty || !email.contains('@')) {
      return 'Informe um e-mail válido.';
    }

    if (senha.length < 6) {
      return 'A senha precisa ter pelo menos 6 caracteres.';
    }

    return null;
  }

  String _mensagemDoErro(FirebaseAuthException erro) {
    if (erro.code == 'email-already-in-use') {
      return 'Este e-mail já possui uma conta.';
    }

    if (erro.code == 'invalid-credential') {
      return 'E-mail ou senha incorretos.';
    }

    return 'Não foi possível concluir a operação. Tente novamente.';
  }
}