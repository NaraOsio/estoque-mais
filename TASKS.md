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

| ID | Tipo | Descrição | Critério de aceite | Responsável | Status |
|---|---|---|---|---|---|
| TC01 | Unitário | Lista de reposição | Incluir somente ativos com saldo até o mínimo | Nara | Passou |
| TC02 | Interface Android — adicional | Login vazio | Exibir erro e permanecer no login | Nara | Passou |
| TC03 | Aceitação | Saída acima do saldo | Bloquear sem alterar saldo ou histórico | Nara | Passou |
| TC04 | Unitário | Nome vazio | Retornar “Informe o nome do produto.” | Nara | Passou |
| TC05 | Unitário | Saldo igual ao mínimo | Retornar “Estoque baixo” | Nara | Passou |
| TC06 | Unitário | Saldo zerado | Retornar “Sem estoque” | Nara | Passou |
| TC07 | Unitário | Pesquisa pelo nome | “REFRI” retorna somente “Refrigerante” | Nara | Não iniciado |
| TC08 | Integração | Consultar produtos | Retornar somente os dois produtos do usuário | Nara | Passou |
| TC09 | Integração | Entrada de 3 unidades | Saldo passa de 5 para 8 e entrada é registrada | Nara | Não iniciado |
| TC10 | Integração | Saída sem saldo | Retornar erro, manter saldo e não gravar movimentação | Nara | Não iniciado |
| TC11 | Aceitação | Cadastrar produto | Produto aparece na lista com os dados informados | Nara | Não iniciado |

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

### TC04 — Recusar nome de produto vazio

- **Tipo:** Unitário.
- **Tarefa relacionada:** Sprint 4 — Validar bloqueios de cadastro.
- **Responsável:** Nara.

**Descrição:**
Verificar se a validação recusa um nome formado apenas por espaços.

**Contexto (Dado):**
Nome igual a três espaços, quantidade inicial "0",
estoque mínimo "5" e preço de venda "2,99".

**Ação (Quando):**
Executar validarCadastro do ProdutoViewModel com esses valores.

**Resultado esperado e critério de aprovação (Então):**
Retornar a mensagem “Informe o nome do produto.”.

**Resultado obtido:**
A validação retornou “Informe o nome do produto.”
para o nome formado apenas por espaços.
O arquivo de testes terminou com:
+2: All tests passed!

**Status:** Passou.

### TC05 — Alertar estoque igual ao mínimo

- **Tipo:** Unitário.
- **Tarefa relacionada:** Sprint 3 — Alertar estoque baixo.
- **Responsável:** Nara.

**Descrição:**
Verificar o alerta quando o saldo é igual ao estoque mínimo.

**Contexto (Dado):**
Produto ativo com quantidade atual de 5 unidades
e estoque mínimo de 5 unidades.

**Ação (Quando):**
Executar obterAlertaEstoque do ProdutoViewModel para esse produto.

**Resultado esperado e critério de aprovação (Então):**
Retornar a mensagem “Estoque baixo”.

**Resultado obtido:**
Para o produto com saldo 5 e estoque mínimo 5,
o método retornou “Estoque baixo”.
A execução do arquivo terminou com:
+3: All tests passed!

**Status:** Passou.

### TC06 — Alertar produto sem estoque

- **Tipo:** Unitário.
- **Tarefa relacionada:** Sprint 3 — Alertar produto sem estoque.
- **Responsável:** Nara.

**Descrição:**
Verificar o alerta de um produto com saldo zerado.

**Contexto (Dado):**
Produto ativo com quantidade atual de 0 unidades
e estoque mínimo de 5 unidades.

**Ação (Quando):**
Executar obterAlertaEstoque do ProdutoViewModel para esse produto.

**Resultado esperado e critério de aprovação (Então):**
Retornar a mensagem “Sem estoque”.

**Resultado obtido:**
Para o produto com saldo 0 e estoque mínimo 5,
o método retornou “Sem estoque”.
A execução do arquivo terminou com:
+4: All tests passed!

**Status:** Passou.

### TC07 — Pesquisar por parte do nome

- **Tipo:** Unitário.
- **Tarefa relacionada:** US07 — Implementar pesquisa por nome ou categoria.
- **Responsável:** Nara.

**Descrição:**
Verificar a pesquisa por parte do nome sem diferenciar
maiúsculas e minúsculas.

**Contexto (Dado):**
Dois produtos ativos: “Refrigerante” e “Arroz”.
Nenhum nome de categoria contém o termo pesquisado.

**Ação (Quando):**
Executar pesquisarProdutos do ProdutoViewModel
com a pesquisa “REFRI” e os nomes das categorias.

**Resultado esperado e critério de aprovação (Então):**
Retornar somente o produto “Refrigerante”.

**Resultado obtido:** Ainda não executado nesta etapa.

**Status:** Não iniciado.

### TC08 — Consultar produtos do usuário no Firestore

- **Tipo:** Integração.
- **Tarefa relacionada:** Sprint 2 — Listar produtos do usuário autenticado.
- **Responsável:** Nara.

**Descrição:**
Verificar a consulta de produtos do usuário no Firestore.

**Contexto (Dado):**
Usuário de teste autenticado.
Existem dois produtos de teste vinculados a esse usuário
e um produto vinculado a outro usuário.

**Ação (Quando):**
Executar listarPorUsuario do ProdutoRepository
com o ID do usuário autenticado.

**Resultado esperado e critério de aprovação (Então):**
Retornar os dois produtos desse usuário com os dados
esperados, sem incluir o produto do outro usuário.

**Resultado obtido:**
Teste executado no Android com Authentication e Firestore
locais, no projeto demo-estoque-mais.

A consulta retornou os dois produtos do usuário autenticado,
com os dados esperados, sem incluir o produto do outro usuário.

O terminal apresentou: +1: All tests passed!

**Status:** Passou.

### TC09 — Registrar entrada no Firestore

- **Tipo:** Integração.
- **Tarefa relacionada:** Sprint 3 — Atualizar saldo e histórico na mesma transação.
- **Responsável:** Nara.

**Descrição:**
Verificar se uma entrada atualiza o saldo e grava
a movimentação no Firestore.

**Contexto (Dado):**
Usuário de teste autenticado.
Produto de teste desse usuário com saldo de 5 unidades.

**Ação (Quando):**
Executar registrar do MovimentacaoRepository
com uma entrada de 3 unidades.
Consultar o produto e a movimentação no Firestore.

**Resultado esperado e critério de aprovação (Então):**
O produto deve apresentar saldo de 8 unidades.
A movimentação deve registrar entrada de 3 unidades,
com os IDs corretos do produto e do usuário.
As duas gravações devem ser concluídas juntas.

**Resultado obtido:** Ainda não executado nesta etapa.

**Status:** Não iniciado.

### TC10 — Bloquear saída sem alterar o Firestore

- **Tipo:** Integração.
- **Tarefa relacionada:** Sprint 3 — Bloquear saída maior que a quantidade disponível.
- **Responsável:** Nara.

**Descrição:**
Verificar se uma saída acima do saldo é recusada
sem alterar o produto nem gravar uma movimentação.

**Contexto (Dado):**
Usuário de teste autenticado.
Produto de teste desse usuário com saldo de 5 unidades.
ID exclusivo reservado para a tentativa de movimentação,
sem documento existente no Firestore.

**Ação (Quando):**
Executar registrar do MovimentacaoRepository
com uma saída de 6 unidades e o ID reservado.
Capturar o erro e consultar o produto
e o documento da movimentação no Firestore.

**Resultado esperado e critério de aprovação (Então):**
Lançar StateError com a mensagem:
“Quantidade de saída maior que o estoque disponível.”

O saldo deve permanecer em 5 unidades.
O documento da movimentação não deve existir.

**Resultado obtido:** Ainda não executado nesta etapa.

**Status:** Não iniciado.

### TC11 — Cadastrar produto e conferir na lista

- **Tipo:** Aceitação manual.
- **Tarefa relacionada:** Sprint 2 — Criar cadastro de produtos e listar produtos do usuário autenticado.
- **Responsável:** Nara.

**Descrição:**
Verificar se o usuário consegue cadastrar um produto
e encontrá-lo na lista.

**Contexto (Dado):**
Usuário autenticado e uma categoria cadastrada.
Não existe produto com o nome “Produto Teste TC11”.

**Ação (Quando):**

1. Abrir a lista de produtos.
2. Abrir o cadastro de produto.
3. Informar o nome “Produto Teste TC11”.
4. Selecionar a categoria cadastrada.
5. Informar quantidade inicial 5, estoque mínimo 2
   e preço de venda 2,99.
6. Manter o controle de validade desativado.
7. Salvar o produto.
8. Retornar à lista e localizar o produto.
9. Abrir seus detalhes e conferir os dados.

**Resultado esperado e critério de aprovação (Então):**

- O cadastro deve ser concluído sem erro.
- O produto deve aparecer na lista.
- Os detalhes devem apresentar o nome e a categoria
  informados, saldo 5, estoque mínimo 2 e preço 2,99.

**Resultado obtido:** Ainda não executado nesta etapa.

**Status:** Não iniciado.