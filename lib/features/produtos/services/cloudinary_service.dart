import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const _cloudName = 'llyabuyy';
  static const _uploadPreset = 'estoquemais_produtos';

  Future<String> enviarImagem(XFile imagem) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final requisicao = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imagem.path,
        ),
      );

    final resposta = await requisicao.send();
    final corpo = await resposta.stream.bytesToString();
    final dados = jsonDecode(corpo) as Map<String, dynamic>;

    if (resposta.statusCode != 200) {
      final erro =
          dados['error']?['message'] ?? 'Erro ao enviar a imagem.';

      throw Exception(erro);
    }

    return dados['secure_url'] as String;
  }
}