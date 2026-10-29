# Sprint Backlog — Estoque+

## Sprint 1 — Autenticação

- [x] Configurar Firebase no aplicativo.
- [x] Criar cadastro e login com e-mail e senha.
- [x] Criar saída da conta.
- [x] Testar autenticação no emulador.

## Sprint 2 — Categorias e produtos

- [x] Criar cadastro e listagem de categorias.
- [x] Criar cadastro de produtos.
- [x] Listar produtos do usuário autenticado.
- [x] Editar nome, categoria e estoque mínimo do produto.
- [x] Impedir alteração direta da quantidade na tela de edição.
- [x] Desativar produto sem apagar o documento.
- [x] Ocultar produtos desativados da lista principal.
- [x] Adicionar validade opcional ao produto.

## Sprint 3 — Movimentações e alertas

- [x] Registrar entrada de estoque.
- [x] Registrar saída de estoque.
- [x] Atualizar saldo e histórico na mesma transação no Firestore.
- [x] Bloquear saída maior que a quantidade disponível.
- [x] Exibir histórico de movimentações.
- [x] Alertar estoque baixo.
- [x] Alertar produto sem estoque.
- [x] Alertar validade entre hoje e os próximos 30 dias.


## Sprint 4 — Validação

- [x] Validar cadastro de conta, login, saída e dados após novo acesso.
- [x] Conferir separação dos produtos entre duas contas na interface.
- [x] Validar cadastro e edição de categorias e produtos.
- [x] Validar bloqueios de cadastro: categoria e nome ausentes, quantidade negativa, estoque mínimo vazio e validade obrigatória sem data.
- [x] Validar entradas, saídas, saldo, histórico e bloqueio de saída sem estoque.
- [x] Conferir painel e alertas de estoque e validade próxima.
- [x] Validar mensagem de ausência de alertas e sua ocultação quando há estoque baixo.
- [x] Validar desativação com preservação do histórico.
- [x] Validar busca por código digitado e salvamento de fotos.
- [x] Conferir permissões de leitura de uma categoria no simulador do Firestore.
- [x] Corrigir e testar preservação do saldo em edição desatualizada.
- [x] Executar flutter analyze sem problemas e atualizar README localmente.
- [x] Validar leitura de código pela câmera real.
- [x] Bloquear estoque e estoque mínimo negativos nas regras do Firestore; testar no simulador e conferir edição, entrada, saída e histórico no aplicativo.


## Funcionalidades adicionais implementadas

- [x] Editar categorias.
- [x] Adicionar preço de venda ao produto.
- [x] Selecionar fotos da galeria e enviar ao Cloudinary.
- [x] Consultar nome e foto por código na base Open Food Facts.
- [x] Implementar leitor de códigos pela câmera.
- [x] Exibir painel com produtos ativos, alertas de estoque e movimentações recentes.
- [x] Registrar entrada inicial no histórico ao cadastrar produto com quantidade positiva.

## Histórias do planejamento original — acompanhamento

- [x] US05 — Completar o painel com produtos separados por situação e validade.
- [x] US06 — Implementar lista de reposição.
- [x] US07 — Implementar pesquisa por nome ou categoria.

## Plano de testes — Aula 14

Objetivo: verificar as regras e as principais funcionalidades
do Estoque+.

Os testes TC01 e TC02 já existem no projeto e passaram
em execuções anteriores.

O status abaixo corresponde à nova rodada de conferência.

### Controle de execução

| ID | Tipo | Responsável | Status |
|---|---|---|---|
| TC01 | Unitário | Nara | Passou |
| TC02 | Integração de interface no Android | Nara | Passou |
| TC03 | Aceitação manual | Nara | Passou |

### TC01 — Regra da lista de reposição

- **Tipo:** Unitário.
- **Tarefa relacionada:** US06 — Lista de reposição.
- **Arquivo:** test/produto_view_model_test.dart.
- **Responsável:** Nara.

**Descrição:**
Verificar quais produtos precisam de reposição.

**Contexto (Dado):**
Produtos com estoque mínimo de 5 unidades:

- Produto ativo com saldo 0.
- Produto ativo com saldo 4.
- Produto ativo com saldo 5.
- Produto ativo com saldo 6.
- Produto desativado com saldo 0.

**Ação (Quando):**
Executar o método obterProdutosParaReposicao.

**Resultado esperado e critério de aprovação (Então):**
Retornar somente os produtos ativos com saldos 0, 4 e 5.
Excluir o produto com saldo 6 e o produto desativado.
**Comando:**

```bash
flutter test test/produto_view_model_test.dart
```
**Resultado obtido:**
O teste retornou somente os produtos ativos com saldos 0, 4 e 5.
O terminal apresentou: +1: All tests passed!

**Status:** Passou.

### TC02 — Login com campos vazios

- **Tipo:** Integração de interface no Android.
- **Tarefa relacionada:** Sprint 1 — Login.
- **Arquivo:** integration_test/login_test.dart.
- **Responsável:** Nara.

**Descrição:**
Verificar a tentativa de login com os campos vazios.

**Contexto (Dado):**
Aplicativo aberto na tela de login,
com e-mail e senha vazios.

**Ação (Quando):**
Tocar no botão Entrar.

**Resultado esperado e critério de aprovação (Então):**

- Exibir “Informe um e-mail válido.”.
- Permanecer na tela de login.
- Manter o botão Entrar disponível.

**Comando:**

```bash
flutter test integration_test/login_test.dart -d emulator-5554
```

**Resultado obtido:**
Teste executado no Android, no dispositivo emulator-5554.
O terminal apresentou: +1: All tests passed!

**Limite do teste:**
Não verifica autenticação com credenciais válidas
nem consulta ao Firestore.

**Status:** Passou.

### TC03 — Bloqueio de saída acima do saldo

- **Tipo:** Aceitação manual.
- **Tarefa relacionada:** Sprint 3 — Bloquear saída maior que o saldo.
- **Responsável:** Nara.

**Contexto (Dado):**
Usuário autenticado e produto ativo com 5 unidades em estoque.

**Ação (Quando):**

1. Abrir o registro de movimentação.
2. Selecionar o produto.
3. Escolher saída.
4. Informar 6 unidades.
5. Tentar confirmar a movimentação.

**Resultado esperado e critério de aprovação (Então):**

- Recusar a saída e exibir uma mensagem explicando o bloqueio.
- Manter o saldo em 5 unidades.
- Não registrar essa tentativa como movimentação no histórico.

**Resultado obtido:**
Nesta execução, a tentativa de saída de 6 unidades do
Teste AP2, com saldo de 5, foi bloqueada com a mensagem:
“Quantidade de saída maior que o estoque disponível.”

O saldo permaneceu em 5 e não apareceu uma nova saída
desse produto no histórico consultado.

**Status:** Passou.