import 'dart:convert';

import 'package:http/http.dart' as http;

class ProdutoExterno {
  final String nome;
  final String? imagemUrl;
  final String fonteUrl;

  const ProdutoExterno({
    required this.nome,
    this.imagemUrl,
    required this.fonteUrl,
  });
}

class OpenFoodFactsService {
  Future<ProdutoExterno?> buscarPorCodigo(String codigo) async {
    final codigoLimpo = codigo.trim();

    if (!RegExp(r'^\d{8,14}$').hasMatch(codigoLimpo)) {
      throw Exception('Informe um código de barras válido.');
    }

    final url = Uri.https(
      'world.openfoodfacts.org',
      '/api/v3/product/$codigoLimpo.json',
      {
        'fields':
        'product_name_pt,product_name,brands,image_front_url',
      },
    );

    final resposta = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
        'EstoqueMais/1.0 (https://github.com/NaraOsio/estoque-mais)',
      },
    ).timeout(const Duration(seconds: 15));

    if (resposta.statusCode == 404) {
      return null;
    }

    if (resposta.statusCode == 429) {
      throw Exception(
        'Limite de consultas atingido. Tente novamente mais tarde.',
      );
    }

    if (resposta.statusCode != 200) {
      throw Exception('Não foi possível consultar a base de produtos.');
    }

    final dados =
    jsonDecode(utf8.decode(resposta.bodyBytes))
    as Map<String, dynamic>;

    final produto = dados['product'];

    if (produto is! Map<String, dynamic>) {
      return null;
    }

    final nomePt = (produto['product_name_pt'] as String?)?.trim();
    final nomePadrao = (produto['product_name'] as String?)?.trim();
    final marca = (produto['brands'] as String?)?.trim();

    var nome = nomePt != null && nomePt.isNotEmpty
        ? nomePt
        : nomePadrao ?? '';

    if (nome.isEmpty) {
      return null;
    }

    if (marca != null &&
        marca.isNotEmpty &&
        !nome.toLowerCase().contains(marca.toLowerCase())) {
      nome = '$nome — $marca';
    }

    final foto = (produto['image_front_url'] as String?)?.trim();
    final fotoUri = foto == null ? null : Uri.tryParse(foto);

    final imagemValida = fotoUri != null &&
        fotoUri.scheme == 'https' &&
        fotoUri.host.isNotEmpty;

    return ProdutoExterno(
      nome: nome,
      imagemUrl: imagemValida ? foto : null,
      fonteUrl:
      'https://world.openfoodfacts.org/product/$codigoLimpo',
    );
  }
}