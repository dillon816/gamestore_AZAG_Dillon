import 'package:flutter/material.dart';

import '../../data/game_repository.dart';
import '../../models/game.dart';
import '../widgets/game_card.dart';

// Fiche détaillée d'un jeu : image en grand, titre, description,
// puis une grille de jeux recommandés (3 par ligne).
class GameDetailPage extends StatefulWidget {
  final Game game;

  const GameDetailPage({super.key, required this.game});

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  final GameRepository _repository = GameRepository();

  late Future<List<Game>> _futureReco;

  @override
  void initState() {
    super.initState();
    // On récupère les recommandations (tous les autres jeux)
    _futureReco = _repository.getRecommandations(widget.game.id);
  }

  void _ouvrirFiche(Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameDetailPage(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Game game = widget.game;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Text(game.nom),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du jeu en grand format
              Container(
                height: 220,
                width: double.infinity,
                color: Colors.deepPurple.shade100,
                child: _image(game),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      game.nom,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Prix
                    Text(
                      '${game.prix} €',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      game.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Titre de la section recommandations
                    const Text(
                      'Jeux recommandés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Grille de recommandations (3 par ligne)
                    _recommandations(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _image(Game game) {
    if (game.imageUrl != null && game.imageUrl!.isNotEmpty) {
      return Image.network(
        game.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.videogame_asset, size: 80),
      );
    }
    return const Icon(Icons.videogame_asset, size: 80);
  }

  Widget _recommandations() {
    return FutureBuilder<List<Game>>(
      future: _futureReco,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Aucune recommandation.');
        }

        List<Game> reco = snapshot.data!;

        // GridView 3 colonnes. shrinkWrap + NeverScrollable car on est
        // déjà dans un SingleChildScrollView.
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
          ),
          itemCount: reco.length,
          itemBuilder: (context, index) {
            Game game = reco[index];
            return GameCard(
              game: game,
              onVoir: () => _ouvrirFiche(game),
            );
          },
        );
      },
    );
  }
}
