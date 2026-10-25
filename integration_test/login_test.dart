import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:estoque_mais/main.dart' as app;
import 'package:estoque_mais/features/autenticacao/view/login_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Login com campos vazios exibe mensagem e permanece na tela',
        (tester) async {
      // 1. Abrir o aplicativo.
      await app.main();
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);

      final campos = find.byType(TextField);
      expect(campos, findsNWidgets(2));

      // 2. Garantir que e-mail e senha estejam vazios.
      await tester.enterText(campos.at(0), '');
      await tester.enterText(campos.at(1), '');

      // 3. Localizar e tocar no botão Entrar.
      final botaoEntrar = find.widgetWithText(
        ElevatedButton,
        'Entrar',
      );

      await tester.ensureVisible(botaoEntrar);
      await tester.pumpAndSettle();
      await tester.tap(botaoEntrar);

      // Aguardar a exibição da mensagem.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 4. Conferir a mensagem e a permanência no login.
      expect(
        find.text('Informe um e-mail válido.'),
        findsOneWidget,
      );
      expect(find.byType(LoginPage), findsOneWidget);

      final botao = tester.widget<ElevatedButton>(botaoEntrar);
      expect(botao.onPressed, isNotNull);
    },
  );
}