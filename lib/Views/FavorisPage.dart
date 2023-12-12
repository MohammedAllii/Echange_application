import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../Models/Product.dart';
import '../Services/ApiClient.dart';
import '../Utils/Consts.dart';
import '../Widgets/MenuBar.dart';
import 'AddProductScreen.dart';
import 'EditProductScreen.dart';
import 'ProductDescription.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavorisPage extends StatefulWidget {
  @override
  _FavorisPageState createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  List<Product> _productList = [];
  int _selectedIndex = 5;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _fetchFavorisProduct();
    super.initState();
  }

  Future<void> _fetchFavorisProduct() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var iduser = prefs.getString('id');

      if (iduser != null) {
        final products = await ApiClient.getFavorisProducts(iduser);
        setState(() {
          _productList = products;
        });
      } else {
        print('no id ');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  String _truncateDescription(String description) {
    return (description.length <= 60) ? description : '${description.substring(0, 60)}...';
  }

Widget _buildProductItem(Product product) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDescription(product: product),
        ),
      );
    },
    child: Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nomProduit,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _truncateDescription(product.description),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _showDeleteConfirmationModal(product);
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${product.added}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showDeleteConfirmationModal(Product product) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to delete this favorite?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomIconButton(
                  icon: Icons.cancel,
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                  },
                  color: Colors.grey,
                ),
                CustomIconButton(
                  icon: Icons.delete,
                  onPressed: () async {
                    try {
                      await ApiClient.deleteFavoriteProduct(product.id);
                      _fetchFavorisProduct(); // Refresh the list after deletion
                      Navigator.of(context).pop();
                    } catch (e) {
                      print('Delete error: $e');
                    }
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    key: _scaffoldKey,
    body: SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              Text(
                'Mes Produits Favoris',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: _productList.isEmpty
                ? Center(
                    child: Image.asset(
                      'assets/noresult.png', // Replace with your image path
                      width: 200,
                      height: 200,
                    ),
                  )
                : ListView.builder(
                    itemCount: _productList.length,
                    itemBuilder: (BuildContext context, int index) {
                      Product product = _productList[index];
                      return _buildProductItem(product);
                    },
                  ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: SalomonBottomBar(
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xff6200ee),
      unselectedItemColor: const Color(0xff757575),
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
          Consts.onItemTapped(context, _selectedIndex);
        });
      },
      items: Consts.navBarItems,
    ),
  );
}

}

void _handleButtonAction(int index, Product product) {
    switch (index) {
      case 0:
        break;
      case 1:
        break;
      default:
        break;
    }
  }

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  CustomIconButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          '',
          style: TextStyle(
            fontFamily: 'Varela',
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
