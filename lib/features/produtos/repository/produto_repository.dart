import '../model/produto.dart';

abstract class ProdutoRepository {
  Future<void> salvar(Produto produto);

  Future<List<Produto>> listarPorUsuario(String idUsuario);
}