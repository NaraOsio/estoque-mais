# Estoque+

Aplicativo Android desenvolvido em Flutter para controle de estoque de pequenos comerciantes.

## Objetivo

Permitir o cadastro de produtos, o acompanhamento das quantidades e o registro de entradas e saídas de estoque.

## Tecnologias

- Flutter e Dart.
- Firebase Authentication para autenticação.
- Cloud Firestore para armazenamento dos dados.
- Cloudinary para envio de fotos dos produtos.
- Open Food Facts para consulta de nome e foto por código de barras.
- Mobile Scanner para leitura de códigos pela câmera.
- Organização em MVVM, com telas, ViewModels, modelos e repositórios.
- Git e GitHub para histórico de versões.

## Funcionalidades implementadas

- Cadastro, login e saída da conta.
- Dados organizados por usuário autenticado.
- Cadastro, listagem e edição de categorias.
- Cadastro, listagem, edição e desativação de produtos.
- Preço de venda e foto do produto.
- Consulta de nome e foto na base Open Food Facts.
- Leitor de códigos pela câmera.
- Registro de entradas e saídas.
- Histórico de movimentações.
- Painel com total de produtos ativos, total de produtos com alerta e movimentações recentes.
- Produtos agrupados no painel por situação: sem estoque, estoque baixo e próximos do vencimento.
- Lista de reposição com produtos ativos cuja quantidade está abaixo ou igual ao estoque mínimo.
- Pesquisa de produtos por parte do nome ou da categoria, sem diferenciar maiúsculas e minúsculas.
- Alertas de estoque baixo e sem estoque.
- Alerta de validade entre hoje e os próximos 30 dias.

## Regras de negócio

- Cada usuário acessa seus próprios dados pelo aplicativo.
- Produtos são desativados pelo campo `ativo`, preservando o histórico.
- O aplicativo não oferece exclusão de movimentações.
- A quantidade movimentada deve ser um número inteiro maior que zero.
- Uma saída não pode superar o saldo disponível.
- O registro da movimentação e a atualização do saldo são realizados na mesma transação.
- O cadastro com quantidade inicial positiva registra uma entrada no histórico.
- Edições e desativações preservam a quantidade armazenada no banco.
- Quando o controle de validade é ativado, a data é obrigatória.
- A consulta externa depende da disponibilidade do serviço e do produto na base.
- Preço, quantidade e validade são preenchidos pelo usuário.

## Estrutura do projeto

```text
lib/
  main.dart
  firebase_options.dart
  features/
    autenticacao/
    categorias/
    produtos/
    movimentacoes/
test/
integration_test/
```

As funcionalidades são organizadas em modelos, telas, ViewModels e repositórios. A área de produtos também possui serviços para fotos e consulta externa.

## Validação do MVP

Foram realizados testes manuais no emulador para verificar:

- Cadastro de conta, login e saída.
- Separação dos produtos entre duas contas.
- Cadastro e edição de categorias e produtos.
- Entradas, saídas e atualização do saldo.
- Bloqueio de saída acima do estoque disponível.
- Histórico e painel.
- Alertas de estoque e exibição de validade próxima.
- Desativação com preservação do histórico.
- Consulta externa por código digitado.
- Seleção, salvamento e exibição de foto da galeria.
- Preservação do saldo ao salvar uma edição aberta antes de uma alteração no banco.
- Agrupamento dos produtos no painel por estoque zerado, estoque baixo e validade próxima.
- Lista de reposição com saldo abaixo, igual e acima do mínimo, incluindo saldo zerado e mensagem de lista vazia.
- Pesquisa por parte do nome e por categoria, mensagem sem resultados e retorno da lista ao limpar a pesquisa.

Também foi validada a leitura de código de barras pela câmera de um celular físico com o APK atualizado em 25/10/2026, com consulta de nome e imagem no Open Food Facts.

Também foram simuladas leituras de uma categoria nas regras do Firestore:

- Sem autenticação: negada.
- Com outro usuário: negada.
- Com o proprietário: permitida.

## Testes automatizados

Os testes foram executados com sucesso:

- Teste simples de criação do objeto EstoqueMaisApp.
- Teste unitário da reposição: inclui produtos ativos com saldo zerado, abaixo ou igual ao mínimo e exclui produtos acima do mínimo ou desativados. Não acessa o Firebase.
- Teste de integração no Android: toca em Entrar com e-mail e senha vazios, verifica a mensagem "Informe um e-mail válido." e confirma a permanência na tela de login. Não verifica autenticação com credenciais válidas.

Para executar os testes da pasta test:

```bash
flutter test
```

Para executar o teste de integração com um Android conectado:

```bash
flutter devices
flutter test integration_test/login_test.dart -d ID_DO_DISPOSITIVO
```

Substitua ID_DO_DISPOSITIVO pelo identificador exibido em flutter devices.

O comando flutter analyze também foi executado sem problemas.

## Limitações e pendências

- As regras do Firestore controlam o acesso por usuário, mas ainda precisam de validações adicionais dos dados gravados.
- Produtos já vencidos não recebem aviso específico de validade.
- Os testes realizados não representam uma verificação completa de todos os cenários.

## Executar o projeto

É necessário ter Flutter, um dispositivo Android ou emulador e acesso aos serviços configurados.

Na pasta do projeto:

```bash
flutter pub get
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

Substitua ID_DO_DISPOSITIVO pelo identificador do Android exibido em flutter devices.

Para utilizar outro projeto Firebase, é necessário configurar a integração e as regras de acesso. O envio de fotos também depende da configuração do Cloudinary.

## Repositório

https://github.com/NaraOsio/estoque-mais

## Baixar o aplicativo

[Baixar Estoque+ para Android](https://github.com/NaraOsio/estoque-mais/releases/download/v1.0.1/app-release.apk)

O APK publicado na versão v1.0.1 inclui a correção de preservação do saldo e foi testado no emulador e em celular Android.

As funcionalidades de painel por situação e validade, lista de reposição e pesquisa por nome ou categoria foram adicionadas ao código após essa publicação. O APK v1.0.1 não representa essas alterações mais recentes.

Baixe o APK no dispositivo Android e abra o arquivo para instalar. Se solicitado, autorize a instalação pelo navegador utilizado.
