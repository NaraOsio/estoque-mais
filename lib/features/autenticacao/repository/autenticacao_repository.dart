import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoRepository {
  final FirebaseAuth _firebaseAuth;

  AutenticacaoRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<UserCredential> criarConta({
    required String email,
    required String senha,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
  }

  Future<UserCredential> entrar({
    required String email,
    required String senha,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
  }

  Future<void> sair() {
    return _firebaseAuth.signOut();
  }

  User? get usuarioAtual => _firebaseAuth.currentUser;
}