import 'package:flutter/material.dart';

import '../../data/auth_repository.dart';
import '../../data/game_repository.dart';
import '../../data/wishlist_repository.dart';
import '../../models/game.dart';
import '../theme.dart';
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
  final AuthRepository _auth = AuthRepository();
  final WishlistRepository _wishlist = WishlistRepository();

  late Future<List<Game>> _futureReco;

  // Le jeu est-il déjà dans la liste de souhaits ?
  bool _dansSouhaits = false;

  @override
  void initState() {
    super.initState();
    // On récupère les recommandations (tous les autres jeux)
    _futureReco = _repository.getRecommandations(widget.game.id);

    // On vérifie si le jeu est déjà dans la liste de souhaits
    _wishlist.estDansSouhaits(_auth.uid ?? '', widget.game.id).then((valeur) {
      if (mounted) {
        setState(() {
          _dansSouhaits = valeur;
        });
      }
    });
  }

  // Ajoute ou retire le jeu de la liste de souhaits selon son état actuel
  Future<void> _basculerSouhaits() async {
    String? uid = _auth.uid;
    if (uid == null) return;

    if (_dansSouhaits) {
      await _wishlist.retirer(uid, widget.game.id);
      if (!mounted) return;
      setState(() {
        _dansSouhaits = false;
      });
      _message('${widget.game.nom} retiré de ta liste de souhaits',
          Colors.orange);
    } else {
      await _wishlist.ajouter(uid, widget.game.id);
      if (!mounted) return;
      setState(() {
        _dansSouhaits = true;
      });
      _message(
          '${widget.game.nom} ajouté à ta liste de souhaits', Colors.green);
    }
  }

  void _message(String texte, Color couleur) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte), backgroundColor: couleur),
    );
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
      appBar: AppBar(
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
                color: kSurface,
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

                    // Prix + mode de jeu
                    Row(
                      children: [
                        Text(
                          game.prixAffiche,
                          style: const TextStyle(
                            fontSize: 18,
                            color: kAccentLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          game.estMultijoueur ? 'Multijoueur' : 'Solo',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Plateformes
                    const Text(
                      'Plateformes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: _puces(game.plateformes),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      game.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),

                    // Bouton liste de souhaits (bascule Ajouter / Retirer)
                    ElevatedButton.icon(
                      onPressed: _basculerSouhaits,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _dansSouhaits ? Colors.red : kAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      icon: Icon(_dansSouhaits
                          ? Icons.favorite
                          : Icons.favorite_border),
                      label: Text(_dansSouhaits
                          ? 'Retirer de la liste de souhaits'
                          : 'Ajouter à la liste de souhaits'),
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

  // Construit une petite étiquette par plateforme
  List<Widget> _puces(List<String> plateformes) {
    List<Widget> puces = [];
    for (var plateforme in plateformes) {
      puces.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: kAccent.withAlpha(60),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kAccent.withAlpha(120)),
          ),
          child: Text(
            plateforme,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      );
    }
    return puces;
  }

  Widget _image(Game game) {
    String? url = game.imageUrl;
    const fallback = Icon(Icons.videogame_asset, size: 80);

    if (url == null || url.isEmpty) {
      return fallback;
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
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
