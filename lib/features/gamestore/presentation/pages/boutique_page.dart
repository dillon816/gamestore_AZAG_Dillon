import 'package:flutter/material.dart';

import '../../data/game_repository.dart';
import '../../models/game.dart';
import '../widgets/game_card.dart';
import 'game_detail_page.dart';

// Accueil : la boutique en ligne.
// Les jeux sont récupérés dynamiquement depuis Firestore (pas de données en dur).
class BoutiquePage extends StatefulWidget {
  const BoutiquePage({super.key});

  @override
  State<BoutiquePage> createState() => _BoutiquePageState();
}

class _BoutiquePageState extends State<BoutiquePage> {
  final GameRepository _repository = GameRepository();

  // Le Future contenant la liste des jeux à venir
  late Future<List<Game>> _futureJeux;

  @override
  void initState() {
    super.initState();
    // On lance la récupération une seule fois au chargement de la page
    _futureJeux = _repository.getGames();
  }

  void _ouvrirFiche(Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameDetailPage(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('GameStore'),
      ),
      body: SafeArea(
        // FutureBuilder affiche un état différent selon l'avancée de la requête
        child: FutureBuilder<List<Game>>(
          future: _futureJeux,
          builder: (context, snapshot) {
            // Pendant le chargement : roue de progression
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // En cas d'erreur ou de liste vide
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun jeu disponible.'));
            }

            List<Game> jeux = snapshot.data!;

            // 1 seul jeu par ligne (pleine largeur) : une ListView
            return ListView.builder(
              itemCount: jeux.length,
              itemBuilder: (context, index) {
                Game game = jeux[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GameCard(
                    game: game,
                    onVoir: () => _ouvrirFiche(game),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
