import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'features/gamestore/presentation/theme.dart';
import 'features/gamestore/presentation/pages/login_page.dart';

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
      theme: gameStoreTheme(),
      // On démarre sur l'écran de connexion : sans compte, pas d'accès à la boutique.
      home: const LoginPage(),
    );
  }
}
