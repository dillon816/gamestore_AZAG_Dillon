import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gamestore/features/gamestore/models/game.dart';
import 'package:gamestore/features/gamestore/presentation/widgets/game_card.dart';

void main() {
  // On teste la carte intelligente isolément (sans Firebase).
  testWidgets('GameCard affiche le titre, les badges et le bouton Voir',
      (WidgetTester tester) async {
    final game = Game(
      id: 'test1',
      nom: 'Starlight Explorers',
      description: 'Un jeu de survie spatial.',
      prix: 49.99,
      plateformes: ['PC', 'Xbox Series X', 'PS5'],
    );

    bool aCliqueVoir = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameCard(
            game: game,
            onVoir: () => aCliqueVoir = true,
          ),
        ),
      ),
    );

    // Le titre, le badge prix, le badge plateforme et le bouton sont présents
    expect(find.text('Starlight Explorers'), findsOneWidget);
    expect(find.text('49.99 €'), findsOneWidget);
    expect(find.text('PC'), findsOneWidget);
    expect(find.text('Voir'), findsOneWidget);

    // Le bouton Voir déclenche bien le callback
    await tester.tap(find.text('Voir'));
    expect(aCliqueVoir, isTrue);
  });
}
