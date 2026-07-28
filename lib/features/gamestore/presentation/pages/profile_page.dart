import 'package:flutter/material.dart';

import '../../data/auth_repository.dart';
import '../../data/wishlist_repository.dart';
import '../../models/game.dart';
import '../theme.dart';
import '../widgets/game_card.dart';
import 'game_detail_page.dart';
import 'login_page.dart';

// Profil : informations de l'utilisateur, sa liste de souhaits
// (récupérée depuis le serveur) et un bouton de déconnexion.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthRepository _auth = AuthRepository();
  final WishlistRepository _wishlist = WishlistRepository();

  List<Game> _souhaits = [];
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  // Recharge la liste de souhaits depuis Firestore
  Future<void> _charger() async {
    setState(() {
      _chargement = true;
    });

    List<Game> jeux = await _wishlist.getSouhaits(_auth.uid ?? '');

    if (!mounted) return;
    setState(() {
      _souhaits = jeux;
      _chargement = false;
    });
  }

  // Demande confirmation avant de retirer un jeu (comme le "Relâcher" du Pokédex)
  void _confirmerRetrait(Game game) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Attention'),
        content: Text('Retirer ${game.nom} de ta liste de souhaits ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _retirer(game);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  // Retire un jeu de la liste de souhaits
  Future<void> _retirer(Game game) async {
    await _wishlist.retirer(_auth.uid ?? '', game.id);
    if (!mounted) return;
    setState(() {
      _souhaits.remove(game);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${game.nom} retiré de ta liste de souhaits'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _deconnexion() async {
    await _auth.deconnexion();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Après un retour de la fiche, on recharge (l'état a pu changer)
  Future<void> _ouvrirFiche(Game game) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameDetailPage(game: game)),
    );
    _charger();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _charger,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte d'information de l'utilisateur
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: kAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Connecté en tant que',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white54)),
                        Text(
                          _auth.email ?? 'Utilisateur',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _deconnexion,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    tooltip: 'Déconnexion',
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ma liste de souhaits',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            // Liste de souhaits (glisser vers la gauche pour retirer)
            Expanded(
              child: _contenuSouhaits(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenuSouhaits() {
    if (_chargement) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_souhaits.isEmpty) {
      return const Center(
        child: Text('Aucun jeu dans ta liste de souhaits.'),
      );
    }

    // Une ligne par jeu : la carte, avec un bouton "Retirer" par-dessus
    return ListView.builder(
      itemCount: _souhaits.length,
      itemBuilder: (context, index) {
        Game game = _souhaits[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            children: [
              GameCard(
                game: game,
                onVoir: () => _ouvrirFiche(game),
              ),
              // Bouton de suppression en bas à gauche (le "Voir" est à droite)
              Positioned(
                bottom: 16,
                left: 16,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmerRetrait(game),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Retirer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
