import 'package:cloud_firestore/cloud_firestore.dart';

// Modèle d'un jeu vidéo.
// Un document Firestore ressemble à une Map, on lit donc les champs un par un.
class Game {
  final String id;
  final String nom;
  final String description;
  final double prix;
  final List<String> plateformes;
  final bool estMultijoueur;
  final String? genre;
  // Optionnel : absent de la base pour l'instant, prêt si on l'ajoute
  final String? imageUrl;

  Game({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.plateformes,
    required this.estMultijoueur,
    this.genre,
    this.imageUrl,
  });

  // Construit un Game à partir d'un document de liste (collection)
  factory Game.fromFirestore(QueryDocumentSnapshot doc) {
    return Game.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // Construit un Game à partir d'un identifiant et d'une Map (document unique)
  factory Game.fromMap(String id, Map<String, dynamic> data) {
    return Game(
      id: id,
      nom: data['nom'] ?? '',
      description: data['description'] ?? '',
      prix: _lirePrix(data['prix']),
      plateformes: List<String>.from(data['plateformes'] ?? []),
      estMultijoueur: _lireMultijoueur(data['multijoueur']),
      genre: data['genre'],
      // On accepte plusieurs noms de champ possibles pour l'image
      imageUrl: data['imageUrl'] ??
          data['imageURL'] ??
          data['image'] ??
          data['url'],
    );
  }

  // Prix affiché : "Gratuit" si le jeu est à 0, sinon le prix en euros
  String get prixAffiche => prix == 0 ? 'Gratuit' : '$prix €';

  // Le prix peut être un nombre ou du texte selon les documents : on gère les deux.
  static double _lirePrix(dynamic valeur) {
    if (valeur is num) {
      return valeur.toDouble();
    }
    if (valeur is String) {
      return double.tryParse(valeur) ?? 0;
    }
    return 0;
  }

  // Le champ multijoueur peut être un booléen ou du texte : on l'interprète.
  static bool _lireMultijoueur(dynamic valeur) {
    if (valeur is bool) {
      return valeur;
    }
    if (valeur is String) {
      String v = valeur.toLowerCase().trim();
      return v == 'true' || v == 'oui' || v == 'multijoueur' || v == '1';
    }
    return false;
  }
}
