import 'package:flutter/material.dart';
import 'football_api_service.dart';
import 'teams_screen.dart';

// Tela de Ligas - StatefulWidget para permitir atualização dinâmica da interface
class LeaguesScreen extends StatefulWidget {
  @override
  _LeaguesScreenState createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends State<LeaguesScreen> {
  // Instância do serviço de API de futebol
  FootballApiService _apiService = FootballApiService();
  // Lista para armazenar as ligas
  List<dynamic> _leagues = [];
  // Variável para controlar o estado de carregamento
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Busca as ligas ao inicializar o estado
    _fetchLeagues();
  }

  // Função para buscar as ligas usando a API
  Future<void> _fetchLeagues() async {
    try {
      // Chama o serviço de API para obter as ligas
      final data = await _apiService.get('leagues');
      setState(() {
        _leagues = data['response']; // Armazena a lista de ligas
        _isLoading = false; // Atualiza o estado para indicar que o carregamento terminou
      });
    } catch (e) {
      // Trata erros e exibe uma mensagem de erro
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar ligas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold para definir a estrutura da tela
    return Scaffold(
      appBar: AppBar(
        title: Text('Ligas'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      // Verifica se está carregando ou exibe a lista de ligas
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carregamento
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: _leagues.length,
              itemBuilder: (context, index) {
                final league = _leagues[index]['league'];

                // Card para exibir cada liga
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10.0),
                    // Exibe o logo da liga
                    leading: _buildLeagueLogo(league['logo']),
                    // Nome da liga
                    title: Text(
                      league['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Ícone de navegação
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                    // Navega para a tela de times ao clicar na liga
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamsScreen(
                            leagueId: league['id'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  // Função para construir o widget do logo da liga
  Widget _buildLeagueLogo(String logoUrl) {
    return Image.network(
      logoUrl,
      width: 50,
      height: 50,
      fit: BoxFit.contain,
      // Exibe um ícone de fallback se houver erro ao carregar a imagem
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.sports_soccer, size: 50, color: Colors.grey);
      },
    );
  }
}
