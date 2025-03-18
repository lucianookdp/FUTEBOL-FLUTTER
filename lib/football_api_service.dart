import 'dart:convert'; // Importa biblioteca para manipulação de JSON
import 'package:http/http.dart' as http; // Importa a biblioteca HTTP para requisições web

// Serviço para integração com a API de futebol
class FootballApiService {
  // Chave de API para autenticação nas requisições
  final String apiKey = 'SUA API KEY';

  // URL base da API
  final String baseUrl = 'https://v3.football.api-sports.io';

  // Função genérica para realizar requisições GET
  Future<dynamic> get(String endpoint) async {
    try {
      // Realiza a requisição GET para o endpoint fornecido
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'), // Constrói a URL completa
        headers: {'x-apisports-key': apiKey}, // Inclui o cabeçalho de autenticação
      );

      // Verifica se a resposta foi bem-sucedida (código 200)
      if (response.statusCode == 200) {
        // Decodifica o corpo da resposta JSON
        return json.decode(response.body);
      } else {
        // Lança uma exceção para códigos de erro
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      // Captura e lança qualquer exceção durante a requisição
      throw Exception('Erro na requisição: $e');
    }
  }
}
