import 'package:flutter/material.dart';
import 'football_api_service.dart';

// Tela de Próximos Jogos - Exibe uma lista dos próximos jogos
class UpcomingFixturesScreen extends StatefulWidget {
  @override
  _UpcomingFixturesScreenState createState() => _UpcomingFixturesScreenState();
}

class _UpcomingFixturesScreenState extends State<UpcomingFixturesScreen> {
  FootballApiService _apiService = FootballApiService(); // Instância do serviço de API
  List<dynamic> _fixtures = []; // Lista para armazenar os próximos jogos
  bool _isLoading = true; // Indica se os dados estão sendo carregados

  @override
  void initState() {
    super.initState();
    _fetchUpcomingFixtures(); // Busca os próximos jogos ao inicializar o estado
  }

  // Função para buscar os próximos jogos usando a API
  Future<void> _fetchUpcomingFixtures() async {
    try {
      // Consulta para obter os próximos 10 jogos
      final data = await _apiService.get('fixtures?next=10');
      setState(() {
        _fixtures = data['response']; // Armazena a lista de jogos
        _isLoading = false; // Indica que o carregamento terminou
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Exibe uma mensagem de erro em caso de falha
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar próximos jogos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Próximos Jogos')),
      // Verifica se está carregando ou exibe a lista de jogos
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carregamento
          : ListView.builder(
              itemCount: _fixtures.length,
              itemBuilder: (context, index) {
                final fixture = _fixtures[index]['fixture']; // Dados do jogo
                final teams = _fixtures[index]['teams']; // Dados dos times

                // Card para exibir cada jogo
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    // Exibe os logos dos times
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          teams['home']['logo'],
                          width: 30,
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.sports_soccer, size: 30);
                          },
                        ),
                        SizedBox(width: 10),
                        Image.network(
                          teams['away']['logo'],
                          width: 30,
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.sports_soccer, size: 30);
                          },
                        ),
                      ],
                    ),
                    // Nome dos times
                    title: Text(
                      '${teams['home']['name']} vs ${teams['away']['name']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Data do jogo
                    subtitle: Text(
                      'Data: ${fixture['date']}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    // Ícone de navegação
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                );
              },
            ),
    );
  }
}
