import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'players_screen.dart';

// Tela de Favoritos - StatefulWidget para permitir atualização dinâmica da interface
class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Instância do Firestore e Firebase Auth
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Função para remover um time dos favoritos
  Future<void> _removeFavorite(String teamId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Deleta o time dos favoritos no Firestore
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(teamId)
        .delete();

    // Exibe uma mensagem de feedback para o usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Time removido dos favoritos!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se o usuário está logado
    final user = _auth.currentUser;
    if (user == null) {
      // Exibe mensagem se o usuário não estiver logado
      return Scaffold(
        appBar: AppBar(title: Text('Favoritos')),
        body: Center(child: Text('Usuário não logado')),
      );
    }

    // Scaffold com StreamBuilder para atualizar a lista de favoritos em tempo real
    return Scaffold(
      appBar: AppBar(title: Text('Favoritos')),
      body: StreamBuilder<QuerySnapshot>(
        // Consulta para obter os times favoritos do usuário
        stream: _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          // Exibe um indicador de carregamento enquanto os dados são obtidos
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Verifica se há dados; caso contrário, exibe uma mensagem
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum time favorito'));
          }

          // Lista de times favoritos
          final favoriteTeams = snapshot.data!.docs;

          // ListView para exibir os times favoritos
          return ListView.builder(
            itemCount: favoriteTeams.length,
            itemBuilder: (context, index) {
              final team = favoriteTeams[index];

              // ListTile para exibir cada time com logo, nome e botão de remoção
              return ListTile(
                leading: Image.network(
                  team['logo'],
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                title: Text(team['name']),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  // Remove o time dos favoritos ao clicar no botão de deletar
                  onPressed: () {
                    _removeFavorite(team.id);
                  },
                ),
                // Navega para a tela de jogadores ao clicar no ListTile
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PlayersScreen(teamId: int.parse(team.id)),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

