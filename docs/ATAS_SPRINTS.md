# Registros das Sprints — Estoque+

Este documento reúne o que foi desenvolvido e testado no Estoque+,
seguindo as quatro etapas da lista de tarefas.

Os registros foram organizados com base nos materiais do projeto
e nos testes realizados.

Estes registros foram organizados depois das atividades,
com base nas informações disponíveis.
As datas de início e término das etapas não foram registradas.

## Sprint 1 — Acesso ao aplicativo

**O que foi feito:**

Foram criadas as opções de cadastro,
entrada com e-mail e senha e saída da conta.

**Como ficou:**

Cada conta passou a ter seus próprios cadastros no aplicativo.

**O que foi conferido:**

Foi criada uma segunda conta,
que abriu sem os produtos da primeira.

Ao sair e entrar novamente na conta original,
os dados continuaram disponíveis.

**Dificuldades:**

Não há dificuldades dessa etapa registradas
nos materiais consultados.

## Sprint 2 — Categorias e produtos

**O que foi feito:**

Foram criados o cadastro e a listagem de categorias e produtos,
a edição dos produtos, a quantidade mínima de estoque
e a validade opcional.

**Decisões:**

A quantidade deve ser alterada pelas entradas e saídas.

Para retirar um produto de uso, foi escolhida a desativação,
mantendo seus registros anteriores.

**O que foi conferido:**

Foram testados o cadastro e a edição de categorias e produtos.

O aplicativo impediu o cadastro sem nome ou categoria.

Ao desativar um produto, ele deixou de aparecer
na lista de produtos ativos,
mas seu histórico permaneceu disponível.

**Dificuldades:**

O problema encontrado na quantidade durante a edição
foi tratado na etapa de testes e ajustes.

## Sprint 3 — Entradas, saídas e alertas

**O que foi feito:**

Foram criados o registro de entradas e saídas,
o histórico e os avisos de estoque baixo,
produto sem estoque e validade próxima.

**Decisões:**

Cada entrada ou saída deve atualizar a quantidade
e guardar o registro da movimentação.

Uma saída não pode ser maior que a quantidade disponível.

**O que foi conferido:**

Uma entrada de 10 unidades deixou o saldo em 10.

Depois, uma saída de 6 deixou o saldo em 4
e fez aparecer o aviso de estoque baixo,
pois o mínimo era 5.

A tentativa de retirar um produto com saldo zero foi bloqueada.

As movimentações apareceram no histórico.

O aviso de vencimento próximo também foi exibido.

**Dificuldades:**

Não há dificuldades da implementação original dessa etapa
registradas nos materiais consultados.

## Sprint 4 — Testes e ajustes

**O que foi feito:**

Foram testados o acesso às contas, as categorias,
os produtos, as entradas e saídas, o histórico,
os alertas, as fotos e a busca por código digitado.

**Decisões e ajustes:**

Foi corrigido um problema que poderia substituir
a quantidade atual por uma quantidade antiga
ao salvar a edição de um produto.

Também foi incluída uma mensagem para informar
quando não há produtos com estoque baixo ou em falta.

**O que foi conferido:**

A edição manteve a quantidade mais recente.

O cadastro com quantidade negativa foi bloqueado.

O cadastro sem data também foi bloqueado
quando a validade estava ativada.

Ao informar a data, o produto foi salvo
e apresentou o aviso de vencimento próximo.

A mensagem de ausência de alertas apareceu
quando não havia estoque baixo.

Ela desapareceu quando um produto ficou abaixo do mínimo.

Também foi conferido, em uma simulação,
que o dono de uma categoria podia consultá-la
e que os outros acessos testados eram bloqueados.

**Dificuldade encontrada:**

Havia alterações diferentes no computador e no GitHub.

Elas foram reunidas sem perder o trabalho realizado.

**O que falta:**

Testar a leitura de código pela câmera real.

Melhorar as verificações dos dados
antes de serem salvos no banco.

## O que foi acrescentado e o que ainda falta

Durante o desenvolvimento, o aplicativo passou a contar com:

- Edição de categorias.
- Preço de venda.
- Fotos escolhidas na galeria.
- Busca de nome e foto por código.
- Painel de resumo.

Não há registro suficiente para indicar
em qual etapa cada recurso foi acrescentado.

Comparando o aplicativo com o planejamento inicial,
ainda faltam:

- **US05:** completar o painel, separando os produtos
  por situação do estoque e validade.
- **US06:** criar uma lista de produtos
  que precisam de reposição.
- **US07:** permitir a pesquisa de produtos
  pelo nome ou pela categoria.

Essas pendências permanecem registradas
na lista de tarefas do projeto.