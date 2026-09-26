import 'package:flutter_test/flutter_test.dart';

import 'package:estoque_mais/main.dart';

void main() {
  test('O aplicativo EstoqueMaisApp existe', () {
    const aplicativo = EstoqueMaisApp();

    expect(aplicativo, isA<EstoqueMaisApp>());
  });
}