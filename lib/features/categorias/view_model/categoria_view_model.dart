import '../model/categoria.dart';
import '../repository/categoria_repository.dart';

class CategoriaViewModel {
  final CategoriaRepository _repository;

  CategoriaViewModel({
    CategoriaRepository? repository,
  }) : _repository = repository ?? CategoriaRepository();

  Future<String?> criarCategoria({
    required String idUsuario,
    required String nome,
    String? descricao,
  }) async {
    if (idUsuario.trim().isEmpty) {
      return 'Não foi possível identificar o usuário.';
    }

    if (nome.trim().isEmpty) {
      return 'Informe o nome da categoria.';
    }

    final descricaoLimpa = descricao?.trim();

    final categoria = Categoria(
      id: _repository.gerarId(),
      idUsuario: idUsuario,
      nome: nome.trim(),
      descricao: descricaoLimpa?.isEmpty ?? true ? null : descricaoLimpa,
      criadoEm: DateTime.now(),
    );

    try {
      await _repository.salvar(categoria);
      return null;
    } catch (_) {
      return 'Não foi possível salvar a categoria. Tente novamente.';
    }
  }
  Future<String?> atualizarCategoria({
    required Categoria categoria,
    required String nome,
    String? descricao,
  }) async {
    if (nome.trim().isEmpty) {
      return 'Informe o nome da categoria.';
    }

    final descricaoLimpa = descricao?.trim();

    final categoriaAtualizada = Categoria(
      id: categoria.id,
      idUsuario: categoria.idUsuario,
      nome: nome.trim(),
      descricao: descricaoLimpa?.isEmpty ?? true ? null : descricaoLimpa,
      criadoEm: categoria.criadoEm,
    );

    try {
      await _repository.salvar(categoriaAtualizada);
      return null;
    } catch (_) {
      return 'Não foi possível atualizar a categoria. Tente novamente.';
    }
  }

  Future<List<Categoria>> listarPorUsuario(String idUsuario) {
    return _repository.listarPorUsuario(idUsuario);
  }
}