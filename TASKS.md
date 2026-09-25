# TASKS.md - Estoque+

## Sprint 1 - Autenticação

- [x] T1 - Configurar Firebase no aplicativo

Status: feito

Feito:
- Firebase configurado no aplicativo.
- Firebase inicializado no main.dart.
- Aplicativo executado no emulador sem erro de inicialização.

Aceite:
- Firebase inicializa ao abrir o aplicativo.
- O aplicativo abre no emulador sem erro de inicialização.

- [x] T2 - Criar repositório de autenticação

Status: feito

Feito:
- Métodos para criar conta, entrar e sair criados.
- Métodos ligados ao Firebase Authentication.

Aceite:
- O repositório possui métodos para criar conta, entrar e sair.
- Os métodos usam Firebase Authentication.

- [x] T3 - Criar ViewModel de autenticação

Status: feito

Depende de: T2

Feito:
- A ViewModel usa o repositório de autenticação.
- Validação de e-mail e senha criada.
- Mensagens de erro criadas.

Aceite:
- A ViewModel usa o repositório de autenticação.
- A ViewModel controla o estado da autenticação para a tela.

- [x] T4 - Criar tela de login

Status: feito

Depende de: T3

Feito:
- Tela com campos de e-mail e senha criada.
- Tela possui botão para entrar e opção para criar conta.

Aceite:
- A tela possui campo de e-mail.
- A tela possui campo de senha.
- A tela possui botão para entrar.

- [x] T5 - Ligar a tela de login à autenticação

Status: feito

Depende de: T3, T4

Feito:
- Botão chama a autenticação por e-mail e senha.
- Mensagens de validação foram testadas no emulador.

Aceite:
- O botão de entrar chama a autenticação por e-mail e senha.
- A tela mostra uma mensagem quando ocorrer erro.

- [x] T6 - Testar autenticação no emulador

Status: feito

Depende de: T5

Feito:
- Conta criada no aplicativo.
- Entrada com e-mail e senha testada.
- Saída da conta testada.

Aceite:
- Um usuário consegue criar uma conta.
- Um usuário consegue entrar com e-mail e senha válidos.
- Um usuário consegue sair da conta.