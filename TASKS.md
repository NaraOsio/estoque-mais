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
- [x] Ocultar produtos desativados da lis[README.md](README.md)ta principal.
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