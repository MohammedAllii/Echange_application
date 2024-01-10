import 'package:flutter/material.dart';
import 'package:flutter_simple_page/Views/FavorisPage.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/ApiClient.dart';
import '../Views/AddProductScreen.dart';
import '../Views/ListOffersUser.dart';
import '../Views/Profile.dart';
import '../Views/HomeScreen.dart';
import '../Views/MyProducts.dart';

class Category {
  final String name;
  final IconData icon;

  Category({required this.name, required this.icon});
}

 

class Consts {
  static final navBarItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home),
    title: const Text("Accueil"),
    selectedColor: Color.fromARGB(255, 28, 168, 96),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.my_library_books_sharp),
    title: const Text("Mes Produits"),
    selectedColor: Color.fromARGB(255, 102, 138, 217),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.list),
    title: const Text("Mes Offres"),
    selectedColor: Color.fromARGB(255, 233, 175, 27),
  ),
   SalomonBottomBarItem(
    icon: const Icon(Icons.account_circle_rounded),
    title: const Text("My Profile"),
    selectedColor: Color.fromARGB(255, 233, 27, 27),
  ),
];

  static void onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyProducts()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ListOffersUser()),
        );
        break;
        case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
        break;
        case 7:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddProductScreen()),
        );
        break;
    }
  }
}
