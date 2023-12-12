import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/Product.dart';
import '../Services/ApiClient.dart';
import 'HomeScreen.dart';

class ProductDescription extends StatefulWidget {
  final Product product;

  ProductDescription({required this.product});

  @override
  _ProductDescriptionState createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
  }

  void toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
    });

    // Add logic to handle the favorite button click
    // You can call your API or perform any other actions here
    // For example, you can call addToFavorites(widget.product.id, isFavorited);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF545D68)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.product.nomProduit,
          style: TextStyle(
            fontFamily: 'Varela',
            fontSize: 20.0,
            color: Color(0xFF545D68),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_outline,
              color: Color(0xFF545D68),
            ),
            onPressed: _addFavoris,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: widget.product.images
                  .map(
                    (imagePath) => Image.network(
                      imagePath,
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                    ),
                  )
                  .toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.0),
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0), // Adjust margin as needed
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle button click
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Make an Offer',
                      style: TextStyle(
                        fontFamily: 'Varela',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Future<void> _addFavoris() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? iduser = prefs.getString('id');

  if (iduser != null) {
    try {
      // Use the correct product ID from widget.product
      int idproduit = widget.product.id;

      final response = await ApiClient.ajouterFavoris(
        userId: iduser, // Use userId instead of iduser
        productId: idproduit, // Use productId instead of idproduit
      );

      if (true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Favoris added successfully'),
            duration: Duration(seconds: 3),
          ),
        );

        // Optionally, you can navigate to the HomeScreen or perform any other actions
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {

        
      }
    } catch (e) {
      print('Error adding Favoris: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Favoris already exist.'),
            duration: Duration(seconds: 3),
          ),
        );
    }
  } else {
    print('User not authenticated');
  }
}

}
