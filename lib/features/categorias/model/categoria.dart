class Categoria {
  final String id;
  final String idUsuario;
  final String nome;
  final String? descricao;
  final DateTime criadoEm;

  const Categoria({
    required this.id,
    required this.idUsuario,
    required this.nome,
    this.descricao,
    required this.criadoEm,
  });
}