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
- Painel com produtos ativos, alertas de estoque e movimentações recentes.
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

Também foram simuladas leituras de uma categoria nas regras do Firestore:

- Sem autenticação: negada.
- Com outro usuário: negada.
- Com o proprietário: permitida.

O comando `flutter analyze` terminou sem problemas após a correção do saldo.

## Limitações e pendências

- Leitura de código pela câmera real ainda não validada nesta rodada.
- As regras do Firestore controlam o acesso por usuário, mas ainda precisam de validações adicionais dos dados gravados.
- Produtos já vencidos não recebem aviso específico de validade.
- Os testes realizados não representam uma verificação completa de todos os cenários.

## Executar o projeto

É necessário ter Flutter, um dispositivo Android ou emulador e acesso aos serviços configurados.

Na pasta do projeto:

```bash
flutter pub get
flutter run
```

Para utilizar outro projeto Firebase, é necessário configurar a integração e as regras de acesso. O envio de fotos também depende da configuração do Cloudinary.

## Repositório

https://github.com/NaraOsio/estoque-mais

## Baixar o aplicativo

[Baixar Estoque+ para Android](https://github.com/NaraOsio/estoque-mais/releases/download/v1.0.1/app-release.apk)

O APK publicado na versão v1.0.1 inclui a correção de preservação do saldo e foi testado no emulador e em celular Android.

Baixe o APK no dispositivo Android e abra o arquivo para instalar. Se solicitado, autorize a instalação pelo navegador utilizado.