import 'package:flutter/material.dart';

import '../../models/game.dart';
import '../theme.dart';

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

        // En grille la hauteur est imposée par la cellule : on la laisse remplir.
        // En liste elle est libre : on fixe une hauteur.
        double? hauteur =
            constraints.maxHeight.isFinite ? null : (grandFormat ? 200 : 160);

        return GestureDetector(
          onTap: onVoir,
          child: Container(
            margin: const EdgeInsets.all(8),
            height: hauteur,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Fond : image du jeu, ou dégradé si pas d'image
                  _fond(),

                  // Voile en dégradé : plus sombre en haut et en bas pour
                  // faire ressortir les badges, le titre et le bouton.
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(120),
                          Colors.black.withAlpha(40),
                          Colors.black.withAlpha(160),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),

                  // Titre centré (avec une ombre pour rester lisible)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        game.nom,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: grandFormat ? 24 : 14,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Badge genre en haut à gauche (grandes cartes seulement,
                  // pour éviter le chevauchement en grille)
                  if (grandFormat)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _badge(_texteGenre()),
                    ),

                  // Badge prix en haut à droite ("Gratuit" si le jeu est à 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _badge(game.prixAffiche),
                  ),

                  // Bouton "Voir" en bas à droite
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: ElevatedButton(
                      onPressed: onVoir,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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

  // Le fond de la carte : image du jeu si disponible, sinon un dégradé.
  // L'image peut être une URL web (http...) ou un fichier local (assets/...).
  Widget _fond() {
    String? url = game.imageUrl;
    if (url == null || url.isEmpty) {
      return _degrade();
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _degrade(),
      );
    }
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _degrade(),
    );
  }

  Widget _degrade() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
        ),
      ),
    );
  }

  // Genre du jeu s'il existe, sinon un libellé par défaut
  String _texteGenre() {
    if (game.genre != null && game.genre!.isNotEmpty) {
      return game.genre!;
    }
    return 'Jeu';
  }

  Widget _badge(String texte) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(160),
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
