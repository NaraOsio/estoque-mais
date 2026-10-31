import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:estoque_mais/firebase_options.dart';
import 'package:estoque_mais/features/produtos/model/produto.dart';
import 'package:estoque_mais/features/produtos/repository/produto_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC08 - Consulta somente produtos do usuário', (tester) async {
    // 1. Configurar uma instância separada para o projeto local.
    final configuracao = DefaultFirebaseOptions.currentPlatform;

    final aplicativoTeste = await Firebase.initializeApp(
      name: 'teste-tc08',
      options: FirebaseOptions(
        apiKey: configuracao.apiKey,
        appId: configuracao.appId,
        messagingSenderId: configuracao.messagingSenderId,
        projectId: 'demo-estoque-mais',
      ),
    );

    final autenticacao = FirebaseAuth.instanceFor(app: aplicativoTeste);
    final banco = FirebaseFirestore.instanceFor(app: aplicativoTeste);

    banco.settings = const Settings(persistenceEnabled: false);

    await autenticacao.useAuthEmulator('10.0.2.2', 9099);
    banco.useFirestoreEmulator('10.0.2.2', 8080);

    final repository = ProdutoRepository(firestore: banco);
    final identificador = DateTime.now().microsecondsSinceEpoch;
    const senhaTeste = 'SenhaTeste123!';

    Produto criarProduto(String idUsuario, String nome, int quantidade) {
      return Produto(
        id: repository.gerarId(),
        idUsuario: idUsuario,
        idCategoria: 'categoria-teste',
        nome: nome,
        precoVenda: 2.99,
        quantidadeAtual: quantidade,
        estoqueMinimo: 2,
        exigeValidade: false,
        ativo: true,
        criadoEm: DateTime(2026, 1, 1),
      );
    }

    try {
      // 2. Criar outro usuário e gravar o produto dele.
      final outraConta =
      await autenticacao.createUserWithEmailAndPassword(
        email: 'outro-$identificador@example.com',
        password: senhaTeste,
      );

      final produtoOutroUsuario = criarProduto(
        outraConta.user!.uid,
        'Produto de outro usuário',
        10,
      );

      await repository.salvar(
        produtoOutroUsuario,
        registrarEntradaInicial: true,
      );

      await autenticacao.signOut();

      // 3. Criar o usuário principal e seus dois produtos.
      final conta = await autenticacao.createUserWithEmailAndPassword(
        email: 'principal-$identificador@example.com',
        password: senhaTeste,
      );

      final idUsuario = conta.user!.uid;

      final produtosEsperados = [
        criarProduto(idUsuario, 'Produto A TC08', 5),
        criarProduto(idUsuario, 'Produto B TC08', 8),
      ];

      for (final produto in produtosEsperados) {
        await repository.salvar(
          produto,
          registrarEntradaInicial: true,
        );
      }

      // 4. Executar a consulta real ao Firestore local.
      final resultado = await repository.listarPorUsuario(idUsuario);

      // 5. Conferir exatamente os produtos retornados.
      expect(
        resultado.map((produto) => produto.id),
        unorderedEquals(produtosEsperados.map((produto) => produto.id)),
      );

      expect(
        resultado.any((produto) => produto.id == produtoOutroUsuario.id),
        isFalse,
      );

      for (final esperado in produtosEsperados) {
        final recebido = resultado.singleWhere(
              (produto) => produto.id == esperado.id,
        );

        expect(recebido.idUsuario, idUsuario);
        expect(recebido.nome, esperado.nome);
        expect(recebido.idCategoria, esperado.idCategoria);
        expect(recebido.quantidadeAtual, esperado.quantidadeAtual);
        expect(recebido.estoqueMinimo, esperado.estoqueMinimo);
        expect(recebido.precoVenda, esperado.precoVenda);
        expect(recebido.ativo, isTrue);
      }
    } finally {
      await autenticacao.signOut();
      await banco.terminate();
      await aplicativoTeste.delete();
    }
  });
}