# TASKS.md - Estoque+

## Sprint 1 - Autenticação

## T1 - Configurar Firebase no aplicativo

Status: feito

Aceite:
- Firebase inicializa ao abrir o aplicativo.
- O aplicativo abre no emulador sem erro de inicialização.

## T2 - Criar repositório de autenticação

Status: em andamento

Aceite:
- O repositório possui métodos para criar conta, entrar e sair.
- Os métodos usam Firebase Authentication.

## T3 - Criar ViewModel de autenticação

Status: em andamento

Depende de: T2

Aceite:
- A ViewModel usa o repositório de autenticação.
- A ViewModel controla o estado da autenticação para a tela.

## T4 - Criar tela de login

Status: em andamento

Depende de: T3

Aceite:
- A tela possui campo de e-mail.
- A tela possui campo de senha.
- A tela possui botão para entrar.

## T5 - Ligar a tela de login à autenticação

Status: a fazer

Depende de: T3, T4

Aceite:
- O botão de entrar chama a autenticação por e-mail e senha.
- A tela mostra uma mensagem quando ocorrer erro.

## T6 - Testar autenticação no emulador

Status: a fazer

Depende de: T5

Aceite:
- Um usuário consegue criar uma conta.
- Um usuário consegue entrar com e-mail e senha válidos.
- Um usuário consegue sair da conta.