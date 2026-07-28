import 'package:cloud_firestore/cloud_firestore.dart';

// Modèle d'un jeu vidéo.
// Un document Firestore ressemble à une Map, on lit donc les champs un par un.
class Game {
  final String id;
  final String nom;
  final String description;
  final double prix;
  final List<String> plateformes;
  // Champs optionnels : absents de la base pour l'instant, prêts si on les ajoute
  final String? imageUrl;
  final String? genre;

  Game({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.plateformes,
    this.imageUrl,
    this.genre,
  });

  // Construit un Game à partir d'un document Firestore
  factory Game.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Game(
      id: doc.id,
      nom: data['nom'] ?? '',
      description: data['description'] ?? '',
      prix: (data['prix'] ?? 0).toDouble(),
      plateformes: List<String>.from(data['plateformes'] ?? []),
      imageUrl: data['imageUrl'],
      genre: data['genre'],
    );
  }
}
