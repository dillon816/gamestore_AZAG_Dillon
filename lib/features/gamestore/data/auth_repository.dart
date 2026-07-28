import 'package:firebase_auth/firebase_auth.dart';

// Gestion des utilisateurs avec FirebaseAuth.
// Chaque méthode est asynchrone et protégée par un try/catch.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Utilisateur actuellement connecté (null si personne)
  User? get utilisateurActuel => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  String? get email => _auth.currentUser?.email;

  // Création d'un compte. Retourne null si succès, sinon le message d'erreur.
  Future<String?> inscription(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Inscription impossible';
    }
  }

  // Connexion. Retourne null si succès, sinon le message d'erreur.
  Future<String?> connexion(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Connexion impossible';
    }
  }

  // Déconnexion
  Future<void> deconnexion() async {
    await _auth.signOut();
  }
}
