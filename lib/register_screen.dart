import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Tela de Cadastro - StatefulWidget para permitir controle de estado
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para os campos de nome, email e senha
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controle de exibição da senha e estado de carregamento
  bool _showPassword = false;
  bool _isLoading = false;

  // Função para registrar o usuário no Firebase Authentication e Firestore
  Future<void> _register() async {
    setState(() {
      _isLoading = true; // Inicia o indicador de carregamento
    });

    try {
      // Cria o usuário no Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Armazena os dados do usuário no Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      // Navega para a tela anterior e exibe uma mensagem de sucesso
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conta criada com sucesso!')),
      );
    } catch (e) {
      // Exibe uma mensagem de erro em caso de falha
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar conta: $e')),
      );
    } finally {
      // Finaliza o indicador de carregamento
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      // Verifica se está carregando ou exibe o formulário de cadastro
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carregamento
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Campo de texto para o nome
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Campo de texto para o email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Campo de texto para a senha
                  TextField(
                    controller: _passwordController,
                    obscureText: !_showPassword, // Oculta a senha se _showPassword for falso
                    obscuringCharacter: '•', // Exibe o caractere "•" ao ocultar a senha
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      // Botão para alternar a visibilidade da senha
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Botão para realizar o cadastro
                  ElevatedButton(
                    onPressed: _register,
                    child: Text('Cadastrar'),
                  ),
                ],
              ),
            ),
    );
  }
}
