import 'package:flutter/material.dart';
import 'football_api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorites_screen.dart';
import 'top_scorers_screen.dart';
import 'upcoming_fixtures_screen.dart';
import 'leagues_screen.dart';

// Tela para exibir resultados ao vivo
class LiveScoresScreen extends StatefulWidget {
  @override
  _LiveScoresScreenState createState() => _LiveScoresScreenState();
}

class _LiveScoresScreenState extends State<LiveScoresScreen>
    with SingleTickerProviderStateMixin {
  FootballApiService _apiService = FootballApiService();
  List<dynamic> _liveGames = [];
  bool _isLoading = true;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late AnimationController _animationController;

  String _userName = 'Usuário';
  String _userEmail = 'email@exemplo.com';

  @override
  void initState() {
    super.initState();
    // Inicializa o AnimationController para o indicador de "AO VIVO"
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _fetchLiveScores();
    _loadUserData();
  }

  @override
  void dispose() {
    // Libera o AnimationController ao sair da tela
    _animationController.dispose();
    super.dispose();
  }

  // Carrega os dados do usuário do Firebase Firestore
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userName = doc['name'] ?? 'Usuário';
          _userEmail = doc['email'] ?? user.email ?? 'Email não disponível';
        });
      }
    }
  }

  // Busca jogos ao vivo usando a API
  Future<void> _fetchLiveScores() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _apiService.get('fixtures?live=all');
      setState(() {
        _liveGames = data['response'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar jogos ao vivo: $e')),
      );
    }
  }

  // Constrói o menu lateral (Drawer)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Olá, $_userName!', style: TextStyle(fontSize: 18)),
            accountEmail: Text(_userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
            ),
            decoration: BoxDecoration(color: Colors.blueAccent),
          ),
          // Itens do Drawer
          _buildDrawerItem(Icons.calendar_today, 'Próximos Jogos', UpcomingFixturesScreen()),
          _buildDrawerItem(Icons.sports_soccer, 'Ligas', LeaguesScreen()),
          _buildDrawerItem(Icons.favorite, 'Favoritos', FavoritesScreen()),
          _buildDrawerItem(Icons.star, 'Melhores Artilheiros', TopScorersScreen()),
          Spacer(),
          Divider(),
          // Botão de Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  // Constrói os itens do Drawer
  Widget _buildDrawerItem(IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
    );
  }

  // Indicador de "AO VIVO" com animação
  Widget _buildLiveIndicator() {
    return Row(
      children: [
        Text(
          'AO VIVO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        FadeTransition(
          opacity: _animationController,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  // Exibe o logo dos times
  Widget _buildTeamLogo(String logoUrl) {
    return Image.network(
      logoUrl,
      width: 40,
      height: 40,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.sports_soccer, size: 40);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Row(
          children: [
            Icon(Icons.sports_soccer),
            SizedBox(width: 8),
            Text('RessabiadosFut', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        // Botões na AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchLiveScores,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      // Corpo da tela que exibe os jogos ao vivo
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLiveScores,
              child: ListView.builder(
                itemCount: _liveGames.length,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  final game = _liveGames[index]['fixture'];
                  final teams = _liveGames[index]['teams'];
                  final goals = _liveGames[index]['goals'];

                  // Card para exibir os detalhes do jogo
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12.0),
                      title: _buildLiveIndicator(),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${teams['home']['name']} vs ${teams['away']['name']}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      trailing: Text(
                        '${goals['home']} - ${goals['away']}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTeamLogo(teams['home']['logo']),
                          const SizedBox(width: 10),
                          _buildTeamLogo(teams['away']['logo']),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
