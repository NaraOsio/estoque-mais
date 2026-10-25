# AGENTS.md - Projeto Estoque+

## Visão geral do projeto

Aplicativo Android para controle de estoque de pequenos comerciantes.

Nome técnico do projeto: estoque_mais

## Stack tecnológica

- Flutter e Dart
- Arquitetura MVVM
- Firebase Authentication
- Cloud Firestore

- Cloudinary para envio e armazenamento de fotos dos produtos
- Open Food Facts para consulta de nome e imagem por código de barras
- Mobile Scanner para leitura de códigos pela câmera
- Git e GitHub

## Convenções de código

- Classes usam PascalCase.
  Exemplo: ProdutoViewModel.
- Variáveis e métodos usam camelCase.
  Exemplo: quantidadeAtual e criarConta.
- Usar nomes claros em português.
- Manter uma responsabilidade por classe.
- Não criar código fora da arquitetura MVVM.

## Estrutura de pastas

- lib/features/autenticacao: autenticação.
- lib/features/categorias: categorias.
- lib/features/produtos: produtos.
- lib/features/movimentacoes: movimentações.

Dentro de cada funcionalidade, usar as pastas:
- model
- repository
- view
- view_model

## Comandos úteis

```bash
flutter pub get
flutter run
git status
```

## Git e GitHub

- A branch main deve conter código estável.
- Cada nova tarefa deve usar uma branch no formato feature/nome-da-tarefa.
- Antes de criar commit, executar git status.
- Commits devem seguir este padrão:
    - feat: para nova funcionalidade.
    - fix: para correção.
    - docs: para documentação.
    - refactor: para melhoria interna do código.
    - test: para criação ou alteração de testes automatizados.

## Regras e restrições do projeto

- Cadastro e login devem usar e-mail e senha.
- Cada usuário pode ver somente os próprios dados.
- Produto não deve ser apagado. Usar o campo ativo.
- Não permitir saída maior que a quantidade disponível.
- Alertar estoque baixo, zerado e produtos com validade em até 30 dias.
- As fotos enviadas pelo aplicativo são armazenadas no Cloudinary, e a URL da imagem é registrada no produto no Cloud Firestore.
- Movimentação e atualização da quantidade devem ocorrer juntas em uma transação do Cloud Firestore.
- Não apagar, mover ou sobrescrever arquivos sem autorização.
- Não inventar funcionalidades, arquivos, dados ou decisões fora do projeto.

