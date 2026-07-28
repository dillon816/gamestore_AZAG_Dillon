import 'package:flutter/material.dart';

import '../../data/auth_repository.dart';
import '../theme.dart';
import 'main_page.dart';

// Écran d'accueil : connexion ou création de compte (email + mot de passe).
// Sans compte, l'accès à la boutique est impossible.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthRepository _auth = AuthRepository();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _chargement = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // true = inscription, false = connexion
  Future<void> _valider(bool inscription) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // Retour visuel en cas de saisie vide
    if (email.isEmpty || password.isEmpty) {
      _afficherMessage('Merci de remplir l\'email et le mot de passe.');
      return;
    }

    setState(() {
      _chargement = true;
    });

    String? erreur;
    if (inscription) {
      erreur = await _auth.inscription(email, password);
    } else {
      erreur = await _auth.connexion(email, password);
    }

    if (!mounted) return;

    setState(() {
      _chargement = false;
    });

    if (erreur != null) {
      // Erreur : on prévient l'utilisateur
      _afficherMessage(erreur);
    } else {
      // Succès : on ouvre la boutique en remplaçant l'écran de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  void _afficherMessage(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GameStore'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.videogame_asset,
                    size: 80, color: kAccentLight),
                const SizedBox(height: 24),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                  ),
                ),
                const SizedBox(height: 24),

                // Pendant une requête, on montre un indicateur de chargement
                if (_chargement)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _valider(false),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                        ),
                        child: const Text('Se connecter'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _valider(true),
                        child: const Text('Créer un compte'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
