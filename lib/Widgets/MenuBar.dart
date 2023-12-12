import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/Consts.dart';
import '../Views/login.dart';

Widget buildMenuBar({required int selectedIndex}) {
  return MenuBar(selectedIndex: selectedIndex);
}

class MenuBar extends StatelessWidget {
  const MenuBar({
    Key? key,
    required this.selectedIndex,
  }) : super(key: key);

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Stack(
          children: [
            // Background image with cover effect and border radius
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/user.jpg',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
      ListTile(
        leading: Icon(Icons.home),
        title: Text('Accueil'),
        onTap: () {
          Consts.onItemTapped(context, 0);
        },
        selected: selectedIndex == 0,
      ),
      ListTile(
        leading: Icon(Icons.date_range_outlined),
        title: Text('Mes Produits'),
        onTap: () {
          Consts.onItemTapped(context, 1);
        },
        selected: selectedIndex == 1,
      ),
      ListTile(
        leading: Icon(Icons.person),
        title: Text('Profile'),
        onTap: () {
          Consts.onItemTapped(context, 2);
        },
        selected: selectedIndex == 2,
      ),
      ListTile(
  leading: Icon(Icons.logout_sharp),
  title: Text('Deconnection'),
  onTap: () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear(); // Clears all key-value pairs in SharedPreferences
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PageLogin()),);
  },
),
    ],
  ),
);
  }
}
