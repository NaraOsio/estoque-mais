import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:estoque_mais/firebase_options.dart';
import 'package:estoque_mais/features/produtos/model/produto.dart';
import 'package:estoque_mais/features/produtos/repository/produto_repository.dart';
import 'package:estoque_mais/features/movimentacoes/model/movimentacao.dart';
import 'package:estoque_mais/features/movimentacoes/repository/movimentacao_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseApp aplicativoTeste;
  late FirebaseAuth autenticacao;
  late FirebaseFirestore banco;
  late ProdutoRepository produtos;
  late MovimentacaoRepository movimentacoes;
  late Produto produto;

  setUpAll(() async {
    final configuracao = DefaultFirebaseOptions.currentPlatform;

    aplicativoTeste = await Firebase.initializeApp(
      name: 'teste-movimentacoes',
      options: FirebaseOptions(
        apiKey: configuracao.apiKey,
        appId: configuracao.appId,
        messagingSenderId: configuracao.messagingSenderId,
        projectId: 'demo-estoque-mais',
      ),
    );

    autenticacao = FirebaseAuth.instanceFor(app: aplicativoTeste);
    banco = FirebaseFirestore.instanceFor(app: aplicativoTeste);

    banco.settings = const Settings(persistenceEnabled: false);

    await autenticacao.useAuthEmulator('10.0.2.2', 9099);
    banco.useFirestoreEmulator('10.0.2.2', 8080);

    produtos = ProdutoRepository(firestore: banco);
    movimentacoes = MovimentacaoRepository(firestore: banco);
  });

  setUp(() async {
    // Cada teste começa com uma conta e um produto novos.
    final identificador = DateTime.now().microsecondsSinceEpoch;

    final conta = await autenticacao.createUserWithEmailAndPassword(
      email: 'movimentacao-$identificador@example.com',
      password: 'SenhaTeste123!',
    );

    produto = Produto(
      id: produtos.gerarId(),
      idUsuario: conta.user!.uid,
      idCategoria: 'categoria-teste',
      nome: 'Produto de teste de movimentação',
      precoVenda: 2.99,
      quantidadeAtual: 5,
      estoqueMinimo: 2,
      exigeValidade: false,
      ativo: true,
      criadoEm: DateTime(2026, 1, 1),
    );

    await produtos.salvar(
      produto,
      registrarEntradaInicial: true,
    );
  });

  tearDown(() async {
    await autenticacao.signOut();
  });

  tearDownAll(() async {
    await banco.terminate();
    await aplicativoTeste.delete();
  });

  testWidgets('TC09 - Entrada atualiza saldo e histórico', (tester) async {
    final entrada = Movimentacao(
      id: movimentacoes.gerarId(),
      idUsuario: produto.idUsuario,
      idProduto: produto.id,
      tipo: 'entrada',
      quantidade: 3,
      motivo: 'Teste TC09',
      dataMovimentacao: DateTime(2026, 1, 2),
    );

    await movimentacoes.registrar(entrada);

    // Consultar o servidor local, sem usar resultado do cache.
    final produtoSalvo = await banco
        .collection('produtos')
        .doc(produto.id)
        .get(const GetOptions(source: Source.server));

    final entradaSalva = await banco
        .collection('movimentacoes')
        .doc(entrada.id)
        .get(const GetOptions(source: Source.server));

    expect(produtoSalvo.exists, isTrue);
    expect(produtoSalvo.data()!['quantidadeAtual'], 8);

    expect(entradaSalva.exists, isTrue);

    final dados = entradaSalva.data()!;
    expect(dados['id'], entrada.id);
    expect(dados['idUsuario'], produto.idUsuario);
    expect(dados['idProduto'], produto.id);
    expect(dados['tipo'], 'entrada');
    expect(dados['quantidade'], 3);
    expect(dados['motivo'], 'Teste TC09');

    final data = dados['dataMovimentacao'] as Timestamp;
    expect(data.toDate(), entrada.dataMovimentacao);
  });

  testWidgets('TC10 - Saída acima do saldo não altera o banco',
          (tester) async {
        final saida = Movimentacao(
          id: movimentacoes.gerarId(),
          idUsuario: produto.idUsuario,
          idProduto: produto.id,
          tipo: 'saida',
          quantidade: 6,
          motivo: 'Teste TC10',
          dataMovimentacao: DateTime(2026, 1, 2),
        );

        final referencia = banco
            .collection('movimentacoes')
            .where('idUsuario', isEqualTo: produto.idUsuario)
            .where('id', isEqualTo: saida.id);

        final antes = await referencia.get(
          const GetOptions(source: Source.server),
        );
        expect(antes.docs, isEmpty);

        await expectLater(
          movimentacoes.registrar(saida),
          throwsA(
            isA<StateError>().having(
                  (erro) => erro.message,
              'mensagem',
              'Quantidade de saída maior que o estoque disponível.',
            ),
          ),
        );

        final produtoSalvo = await banco
            .collection('produtos')
            .doc(produto.id)
            .get(const GetOptions(source: Source.server));

        final tentativa = await referencia.get(
          const GetOptions(source: Source.server),
        );

        expect(produtoSalvo.exists, isTrue);
        expect(produtoSalvo.data()!['quantidadeAtual'], 5);
        expect(tentativa.docs, isEmpty);
      });
}