import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/game.dart';

// Liste de souhaits : on stocke les identifiants des jeux dans le document
// de l'utilisateur (collection "users"), pour les relier à son compte.
class WishlistRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ajoute un jeu à la liste de souhaits de l'utilisateur
  Future<void> ajouter(String uid, String gameId) async {
    try {
      await _db.collection('users').doc(uid).set(
        {
          'wishlist': FieldValue.arrayUnion([gameId]),
        },
        SetOptions(merge: true),
      );
    } catch (erreur) {
      print('Erreur lors de l\'ajout aux souhaits : $erreur');
    }
  }

  // Retire un jeu de la liste de souhaits
  Future<void> retirer(String uid, String gameId) async {
    try {
      await _db.collection('users').doc(uid).set(
        {
          'wishlist': FieldValue.arrayRemove([gameId]),
        },
        SetOptions(merge: true),
      );
    } catch (erreur) {
      print('Erreur lors du retrait des souhaits : $erreur');
    }
  }

  // Indique si un jeu est déjà dans la liste de souhaits de l'utilisateur
  Future<bool> estDansSouhaits(String uid, String gameId) async {
    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return false;
      }
      final data = userDoc.data();
      List<String> ids = List<String>.from(data?['wishlist'] ?? []);
      return ids.contains(gameId);
    } catch (erreur) {
      print('Erreur lors de la vérification des souhaits : $erreur');
      return false;
    }
  }

  // Récupère les jeux de la liste de souhaits de l'utilisateur
  Future<List<Game>> getSouhaits(String uid) async {
    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return [];
      }

      final data = userDoc.data();
      List<String> ids = List<String>.from(data?['wishlist'] ?? []);

      // Pour chaque identifiant, on récupère le jeu correspondant
      List<Game> jeux = [];
      for (var id in ids) {
        final gameDoc = await _db.collection('games').doc(id).get();
        if (gameDoc.exists) {
          try {
            jeux.add(Game.fromMap(gameDoc.id, gameDoc.data()!));
          } catch (erreur) {
            print('Jeu ignoré ($id) : $erreur');
          }
        }
      }
      return jeux;
    } catch (erreur) {
      print('Erreur lors de la récupération des souhaits : $erreur');
      return [];
    }
  }
}
