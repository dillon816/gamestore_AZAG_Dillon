import 'package:flutter/material.dart';

import 'boutique_page.dart';
import 'profile_page.dart';

// Page principale une fois connecté : deux onglets (Boutique et Profil).
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _indexOnglet = 0;

  // Les deux pages affichées selon l'onglet sélectionné
  final List<Widget> _pages = const [
    BoutiquePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_indexOnglet],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexOnglet,
        onTap: (index) {
          setState(() {
            _indexOnglet = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Boutique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
