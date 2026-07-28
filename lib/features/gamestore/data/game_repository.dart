import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/game.dart';

// Accès à la base de données distante (Cloud Firestore).
// Toutes les requêtes passent par internet : elles sont asynchrones (Future).
class GameRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Récupère la liste des jeux depuis la collection "games"
  Future<List<Game>> getGames() async {
    try {
      final snapshot = await _db.collection('games').get();

      // On transforme chaque document en objet Game avec une boucle.
      // Un document mal formé est ignoré au lieu de casser toute la liste.
      List<Game> jeux = [];
      for (var doc in snapshot.docs) {
        try {
          jeux.add(Game.fromFirestore(doc));
        } catch (erreur) {
          print('Jeu ignoré (${doc.id}) : $erreur');
        }
      }
      return jeux;
    } catch (erreur) {
      print('Erreur lors de la récupération des jeux : $erreur');
      return [];
    }
  }

  // Récupère les jeux recommandés (tous les autres jeux sauf celui affiché)
  Future<List<Game>> getRecommandations(String idJeuActuel) async {
    try {
      final snapshot = await _db.collection('games').get();

      List<Game> jeux = [];
      for (var doc in snapshot.docs) {
        if (doc.id != idJeuActuel) {
          try {
            jeux.add(Game.fromFirestore(doc));
          } catch (erreur) {
            print('Jeu ignoré (${doc.id}) : $erreur');
          }
        }
      }
      return jeux;
    } catch (erreur) {
      print('Erreur lors de la récupération des recommandations : $erreur');
      return [];
    }
  }
}
