import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'players_screen.dart';
import 'football_api_service.dart';

// Tela de Times - Exibe a lista de times de uma liga específica
class TeamsScreen extends StatefulWidget {
  final int leagueId; // ID da liga para buscar os times

  TeamsScreen({required this.leagueId});

  @override
  _TeamsScreenState createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  FootballApiService _apiService = FootballApiService(); // Instância do serviço de API
  List<dynamic> _teams = []; // Lista de times
  bool _isLoading = true; // Indica se os dados estão sendo carregados
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchTeams(); // Busca os times ao inicializar o estado
  }

  // Função para buscar times da liga usando a API
  Future<void> _fetchTeams() async {
    try {
      final data = await _apiService.get('teams?league=${widget.leagueId}&season=2024');
      setState(() {
        _teams = data['response']; // Armazena a lista de times
        _isLoading = false; // Indica que o carregamento terminou
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Exibe uma mensagem de erro em caso de falha
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar times: $e')),
      );
    }
  }

  // Verifica se um time está nos favoritos
  Future<bool> _isFavorite(int teamId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(teamId.toString())
        .get();

    return doc.exists; // Retorna true se o time estiver nos favoritos
  }

  // Função para adicionar ou remover o time dos favoritos
  Future<void> _toggleFavorite(Map<String, dynamic> team) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(team['id'].toString());

    final doc = await docRef.get();

    if (doc.exists) {
      // Remove o time dos favoritos
      await docRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${team['name']} removido dos favoritos!')),
      );
    } else {
      // Adiciona o time aos favoritos
      await docRef.set({
        'name': team['name'],
        'logo': team['logo'],
        'id': team['id'],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${team['name']} adicionado aos favoritos!')),
      );
    }

    setState(() {}); // Atualiza o estado para refletir a mudança
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Times'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          // Botão para atualizar a lista de times
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchTeams,
          ),
        ],
      ),
      // Verifica se está carregando ou exibe a lista de times
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carregamento
          : ListView.builder(
              itemCount: _teams.length,
              padding: const EdgeInsets.all(12.0),
              itemBuilder: (context, index) {
                final team = _teams[index]['team'];
                // Exibe a lista de times com um FutureBuilder para verificar favoritos
                return FutureBuilder<bool>(
                  future: _isFavorite(team['id']),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return ListTile(
                        title: Text('Carregando...'),
                      );
                    }
                    final isFavorite = snapshot.data!;
                    // Card para exibir o time com opção de favoritar
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12.0),
                        // Exibe o logo do time
                        leading: _buildTeamLogo(team['logo']),
                        // Nome do time
                        title: Text(
                          team['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Botão para adicionar/remover o time dos favoritos
                        trailing: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => _toggleFavorite(team),
                        ),
                        // Navega para a tela de jogadores ao clicar no time
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayersScreen(teamId: team['id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // Função para construir o widget de logo do time
  Widget _buildTeamLogo(String logoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        logoUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.sports_soccer, size: 50, color: Colors.grey);
        },
      ),
    );
  }
}
