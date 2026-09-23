class Movimentacao {
  final String id;
  final String idUsuario;
  final String idProduto;
  final String tipo;
  final int quantidade;
  final String? motivo;
  final DateTime dataMovimentacao;

  const Movimentacao({
    required this.id,
    required this.idUsuario,
    required this.idProduto,
    required this.tipo,
    required this.quantidade,
    this.motivo,
    required this.dataMovimentacao,
  });
}