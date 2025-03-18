import 'package:flutter/material.dart';
import 'football_api_service.dart';

// Tela de Artilheiros - Exibe os melhores artilheiros de diferentes ligas
class TopScorersScreen extends StatefulWidget {
  @override
  _TopScorersScreenState createState() => _TopScorersScreenState();
}

class _TopScorersScreenState extends State<TopScorersScreen> {
  FootballApiService _apiService = FootballApiService(); // Instância do serviço de API
  List<dynamic> _topScorers = []; // Lista para armazenar os artilheiros
  bool _isLoading = true; // Indica se os dados estão sendo carregados

  // Lista de ligas para buscar os artilheiros
  final List<Map<String, dynamic>> leagues = [
    {"name": "Premier League", "id": 39, "season": 2023},
    {"name": "La Liga", "id": 140, "season": 2023},
    {"name": "Bundesliga", "id": 78, "season": 2023},
    {"name": "Ligue 1", "id": 61, "season": 2023},
    {"name": "CONMEBOL Libertadores", "id": 13, "season": 2024},
    {"name": "Brasileirão Série A", "id": 71, "season": 2023},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllTopScorers(); // Busca os artilheiros ao inicializar o estado
  }

  // Função para buscar os artilheiros de todas as ligas
  Future<void> _fetchAllTopScorers() async {
    setState(() {
      _isLoading = true; // Inicia o indicador de carregamento
    });

    List<dynamic> aggregatedScorers = []; // Lista para armazenar todos os artilheiros

    try {
      // Loop para buscar os artilheiros de cada liga
      for (var league in leagues) {
        final data = await _apiService.get(
          'players/topscorers?league=${league["id"]}&season=${league["season"]}',
        );
        aggregatedScorers.addAll(data['response']); // Adiciona os artilheiros à lista
      }

      // Ordena todos os artilheiros por número de gols (decrescente)
      aggregatedScorers.sort((a, b) =>
          b['statistics'][0]['goals']['total']
              .compareTo(a['statistics'][0]['goals']['total']));

      setState(() {
        _topScorers = aggregatedScorers; // Armazena a lista de artilheiros
        _isLoading = false; // Indica que o carregamento terminou
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Exibe uma mensagem de erro em caso de falha
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar artilheiros: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Melhores Artilheiros')),
      // Verifica se está carregando ou exibe a lista de artilheiros
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carregamento
          : ListView.builder(
              itemCount: _topScorers.length,
              itemBuilder: (context, index) {
                final scorer = _topScorers[index]['player']; // Dados do artilheiro
                final stats = _topScorers[index]['statistics'][0]; // Estatísticas do artilheiro

                // Card para exibir informações do artilheiro
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    // Foto do artilheiro
                    leading: Image.network(
                      scorer['photo'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    // Nome do artilheiro
                    title: Text(
                      scorer['name'],
                      style: TextStyle(fontSize: 20),
                    ),
                    // Informações adicionais do artilheiro
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Time: ${stats['team']['name']}'), // Nome do time
                        Text('Gols: ${stats['goals']['total']}'), // Total de gols
                      ],
                    ),
                    // Logo do time
                    trailing: Image.network(
                      stats['team']['logo'],
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
