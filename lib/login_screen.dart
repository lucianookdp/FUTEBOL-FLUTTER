import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Tela de Login - StatefulWidget para permitir controle de estado
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para os campos de email e senha
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controle de exibição da senha e estado de carregamento
  bool _showPassword = false;
  bool _isLoading = false;

  // Função para realizar login com Firebase Authentication
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Autenticação com email e senha
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navega para a tela principal após login bem-sucedido
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      // Trata os erros específicos de autenticação
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'Usuário não encontrado. Verifique o email.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta. Tente novamente.';
          break;
        case 'invalid-email':
          message = 'O formato do email é inválido.';
          break;
        case 'user-disabled':
          message = 'Esta conta foi desativada.';
          break;
        default:
          message = 'Ocorreu um erro. Tente novamente mais tarde.';
      }

      // Exibe uma mensagem de erro na tela
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Trata qualquer outro erro inesperado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    } finally {
      // Atualiza o estado para indicar que o carregamento terminou
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Constrói a interface da tela
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carregamento
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo e título da aplicação
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_soccer, size: 40, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'RessabiadosFut',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
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
                    obscuringCharacter: '•',
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
                  // Botão de login
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                  // Botão para navegar para a tela de cadastro
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('Não tem uma conta? Cadastre-se'),
                  ),
                ],
              ),
            ),
    );
  }
}
