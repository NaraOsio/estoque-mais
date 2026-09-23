class Produto {
  final String id;
  final String idUsuario;
  final String idCategoria;
  final String nome;
  final String? codigoBarras;
  final int quantidadeAtual;
  final int estoqueMinimo;
  final DateTime? dataValidade;
  final bool exigeValidade;
  final bool ativo;
  final DateTime criadoEm;

  const Produto({
    required this.id,
    required this.idUsuario,
    required this.idCategoria,
    required this.nome,
    this.codigoBarras,
    required this.quantidadeAtual,
    required this.estoqueMinimo,
    this.dataValidade,
    required this.exigeValidade,
    required this.ativo,
    required this.criadoEm,
  });
}