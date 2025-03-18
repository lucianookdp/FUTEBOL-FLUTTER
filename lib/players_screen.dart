import 'package:flutter/material.dart';
import 'football_api_service.dart';

// Tela de Jogadores - Exibe a lista de jogadores de um time específico
class PlayersScreen extends StatefulWidget {
  final int teamId; // ID do time para buscar jogadores

  PlayersScreen({required this.teamId});

  @override
  _PlayersScreenState createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  FootballApiService _apiService = FootballApiService(); // Instância do serviço de API
  List<dynamic> _players = []; // Lista de jogadores
  bool _isLoading = true; // Indica se os dados estão sendo carregados

  @override
  void initState() {
    super.initState();
    _fetchPlayers(); // Busca os jogadores ao inicializar o estado
  }

  // Função para buscar jogadores do time usando a API
  Future<void> _fetchPlayers() async {
    try {
      // Chama o serviço de API para obter os jogadores do time
      final data = await _apiService.get('players?team=${widget.teamId}&season=2024');
      setState(() {
        _players = data['response']; // Armazena a lista de jogadores
        _isLoading = false; // Atualiza o estado para indicar que o carregamento terminou
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Exibe uma mensagem de erro em caso de falha
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar jogadores: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jogadores'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      // Verifica se está carregando ou exibe a lista de jogadores
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carregamento
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index]['player']; // Dados do jogador
                final stats = _players[index]['statistics'][0]; // Estatísticas do jogador

                // Card para exibir informações do jogador
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12.0),
                    // Foto do jogador com fallback em caso de erro
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        player['photo'],
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                    // Nome do jogador
                    title: Text(
                      player['name'],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Informações adicionais do jogador
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Linha para idade do jogador
                          _buildPlayerInfoRow(
                            Icons.cake_outlined,
                            'Idade: ${player['age']} anos',
                          ),
                          // Linha para posição do jogador
                          _buildPlayerInfoRow(
                            Icons.sports_soccer,
                            'Posição: ${stats['games']['position'] ?? 'Desconhecida'}',
                          ),
                          // Linha para nacionalidade do jogador
                          _buildPlayerInfoRow(
                            Icons.flag_outlined,
                            'Nacionalidade: ${player['nationality']}',
                          ),
                          // Linha para gols marcados
                          _buildPlayerInfoRow(
                            Icons.emoji_events_outlined,
                            'Gols: ${stats['goals']['total'] ?? 0}',
                          ),
                          // Linha para partidas jogadas
                          _buildPlayerInfoRow(
                            Icons.sports_baseball,
                            'Partidas: ${stats['games']['appearences'] ?? 0}',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Função para construir uma linha de informação do jogador
  Widget _buildPlayerInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
