import 'package:flutter/material.dart';

import '../../models/game.dart';

// Carte "intelligente" : le même composant s'affiche différemment
// selon la place disponible (pleine largeur sur l'accueil, grille en reco).
class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onVoir;

  const GameCard({
    super.key,
    required this.game,
    required this.onVoir,
  });

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder nous donne la largeur réellement disponible pour la carte
    return LayoutBuilder(
      builder: (context, constraints) {
        // Au-delà de 250px on considère qu'on est en "grand" format
        bool grandFormat = constraints.maxWidth > 250;

        return GestureDetector(
          onTap: onVoir,
          child: Container(
            margin: const EdgeInsets.all(8),
            height: grandFormat ? 200 : 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Fond : image du jeu, ou dégradé si pas d'image
                  _fond(),

                  // Voile sombre pour lire le texte par-dessus l'image
                  Container(color: Colors.black.withAlpha(90)),

                  // Titre centré
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        game.nom,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: grandFormat ? 24 : 15,
                        ),
                      ),
                    ),
                  ),

                  // Badge d'info en haut à gauche (genre ou plateforme)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _badge(_texteGenre()),
                  ),

                  // Badge prix en haut à droite
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _badge('${game.prix} €'),
                  ),

                  // Bouton "Voir" en bas
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: ElevatedButton(
                      onPressed: onVoir,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Voir'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Le fond de la carte : image réseau si disponible, sinon un dégradé
  Widget _fond() {
    if (game.imageUrl != null && game.imageUrl!.isNotEmpty) {
      return Image.network(
        game.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _degrade(),
      );
    }
    return _degrade();
  }

  Widget _degrade() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple, Colors.indigo],
        ),
      ),
    );
  }

  // Genre s'il existe, sinon la première plateforme du jeu
  String _texteGenre() {
    if (game.genre != null && game.genre!.isNotEmpty) {
      return game.genre!;
    }
    if (game.plateformes.isNotEmpty) {
      return game.plateformes[0];
    }
    return 'Jeu';
  }

  Widget _badge(String texte) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texte,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
