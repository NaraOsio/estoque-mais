import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/usuario.dart';

class AutenticacaoRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AutenticacaoRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserCredential> criarConta({
    required String email,
    required String senha,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
  }

  Future<void> salvarUsuario(Usuario usuario) {
    return _firestore
        .collection('usuarios')
        .doc(usuario.id)
        .set(usuario.toMap());
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