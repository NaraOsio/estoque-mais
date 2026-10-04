# TASKS.md - Estoque+

## Sprint 1 - Autenticação

- [x] Configurar Firebase no aplicativo.
- [x] Criar cadastro e login com e-mail e senha.
- [x] Criar saída da conta.
- [x] Testar autenticação no emulador.

## Sprint 2 - Categorias e produtos

- [x] Criar cadastro e listagem de categorias.
- [x] Criar cadastro de produtos.
- [x] Listar produtos do usuário autenticado.
- [x] Editar nome, categoria e estoque mínimo do produto.
- [x] Impedir alteração direta da quantidade na edição.
- [x] Desativar produto sem apagar o documento.
- [x] Ocultar produtos desativados da lista principal.
- [x] Adicionar validade opcional ao produto.

## Sprint 3 - Movimentações e alertas

- [x] Registrar entrada de estoque.
- [x] Registrar saída de estoque.
- [x] Atualizar a quantidade por transação no Cloud Firestore.
- [x] Bloquear saída maior que a quantidade disponível.
- [x] Exibir histórico de movimentações.
- [x] Alertar estoque baixo.
- [x] Alertar produto sem estoque.
- [x] Alertar produtos com validade em até 30 dias.

## Sprint 4 - Validação final

- [x] Testar login e logout no emulador.
- [x] Testar bloqueio de saída maior que o estoque.
- [x] Testar atualização da quantidade após movimentação.
- [x] Testar histórico de movimentações.
- [x] Executar `flutter analyze` sem erros.
- [x] Atualizar README do projeto.

## Melhorias futuras

- [ ] Adicionar imagem de produto com Firebase Storage.
- [ ] Criar regras do Firebase Storage.
- [ ] Criar testes automatizados.