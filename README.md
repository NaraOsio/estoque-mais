# Estoque+

Aplicativo Flutter para controle de estoque de pequenos comerciantes.

## Objetivo

Permitir que o comerciante cadastre produtos, acompanhe a quantidade disponível e registre entradas e saídas de estoque.

## Tecnologias

- Flutter e Dart
- Firebase Authentication
- Cloud Firestore
- Arquitetura MVVM
- Git e GitHub

## Funcionalidades concluídas

- Cadastro e login com e-mail e senha.
- Dados separados por usuário autenticado.
- Cadastro e listagem de categorias.
- Cadastro, listagem e edição de produtos.
- Registro de entrada e saída de estoque.
- Bloqueio de saída maior que a quantidade disponível.
- Histórico de movimentações.
- Alerta de estoque baixo e sem estoque.
- Alerta para produto com validade em até 30 dias.
- Desativação de produto sem apagá-lo.

## Regras de negócio

- Cada usuário acessa apenas os próprios dados.
- Produtos não são apagados; são desativados pelo campo `ativo`.
- Movimentações não são apagadas.
- A saída não pode ser maior que a quantidade atual do produto.
- A movimentação e a atualização da quantidade ocorrem juntas no Cloud Firestore.
- Produtos podem possuir validade opcional.

## Estrutura do projeto

```text
lib/
  features/
    autenticacao/
    categorias/
    produtos/
    movimentacoes/