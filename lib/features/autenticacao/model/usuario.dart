class Usuario {
  final String id;
  final String nome;
  final String email;
  final String perfil;
  final bool ativo;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    required this.ativo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'perfil': perfil,
      'ativo': ativo,
    };
  }
}