import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'features/gamestore/presentation/pages/boutique_page.dart';

void main() async {
  // Obligatoire avant d'utiliser Firebase : il interagit avec le code natif
  WidgetsFlutterBinding.ensureInitialized();

  // Établit le lien avec le serveur Firebase (asynchrone)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GameStoreApp());
}

class GameStoreApp extends StatelessWidget {
  const GameStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameStore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Phase 1 : on démarre directement sur la boutique (sans login).
      // Phase 2 : on remettra ici l'écran de connexion (FirebaseAuth).
      home: const BoutiquePage(),
    );
  }
}
