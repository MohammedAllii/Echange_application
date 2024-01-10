import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Product.dart'; 
import '../Services/ApiClient.dart'; 
import 'package:multi_select_flutter/multi_select_flutter.dart';

class UserProductsScreen extends StatefulWidget {
  final int id;

  // Corrected constructor to receive the 'id' parameter
  UserProductsScreen({required this.id});

  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  List<Product> _productList = [];
  List<Product> _selectedProducts = [];
   String  _userid='' ;

  @override
  void initState() {
    super.initState();
    _fetchUserProducts();
  }

  Future<void> _fetchUserProducts() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var iduser = prefs.getString('id');

      if (iduser != null) {
        final products = await ApiClient.getUserProducts(iduser);
        setState(() {
          _productList = products;
          _userid=iduser;
        });
      } else {
        print('no id ');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _showSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: _productList
              .map((product) => MultiSelectItem<Product>(product, product.nomProduit))
              .toList(),
          onConfirm: (values) {
            setState(() {
              _selectedProducts = values.cast<Product>();
            });
          },
          initialValue: _selectedProducts,
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Select products'),
    ),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _selectedProducts
              .map((product) => Chip(
                    label: Text(product.nomProduit),
                    onDeleted: () {
                      setState(() {
                        _selectedProducts.remove(product);
                      });
                    },
                    deleteIcon: Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                    deleteIconColor: Colors.red,
                  ))
              .toList(),
        ),
        SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              _showSelectionDialog();
            },
            icon: Icon(Icons.select_all),
            label: Text('Make offer'),
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
            ),
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: () async {
              List<String> selectedProductIds =
                  _selectedProducts.map((product) => product.id.toString()).toList();

              final result = await ApiClient.addOffer(_userid, widget.id, selectedProductIds);

              if (result.containsKey('error')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['error']),
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Offre ajoutée avec succès'),
                    duration: Duration(seconds: 3),
                  ),
                );
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.check),
            label: Text('Terminé'),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
            ),
          ),
        ),
      ],
    ),
  );
}

}
