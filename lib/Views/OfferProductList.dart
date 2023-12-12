import 'package:flutter/material.dart';
import '../Models/Product.dart';
import '../Services/ApiClient.dart';
import 'ProductDescription.dart';

class OfferProductList extends StatefulWidget {
  final String idoffre;

  OfferProductList({required this.idoffre});

  @override
  _OfferProductListState createState() => _OfferProductListState();
}

class _OfferProductListState extends State<OfferProductList> {
  List<Product> _OfferProductList = [];

  @override
  void initState() {
    _fetchProductsForoffer();
    super.initState();
  }

  Future<void> _fetchProductsForoffer() async {
    try {
      final products = await ApiClient.getProductsForOffer(widget.idoffre);
      setState(() {
        _OfferProductList = products;
      });
    } catch (e) {
      print('Error fetching offers: $e');
    }
  }

  Widget _buildOfferItem(Product produit) {
    return InkWell(
      onTap: () {
        Navigator.push(
             context,
              MaterialPageRoute(
            builder: (context) => ProductDescription(product: produit),
                                 ),
                    );
            },
      child: Container(
        margin: EdgeInsets.all(16),
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
        child: ListTile(
          title: Text('${produit.nomProduit}'),
         
        ),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Details offre'),
    ),
    body: _OfferProductList.isEmpty
        ? Center(
            // Display an image or a message when no products exist
            child: Image.asset(
              'assets/nooffer.png', // Replace with your image asset
              width: 150.0,
              height: 150.0,
            ),
          )
        : ListView.builder(
            itemCount: _OfferProductList.length,
            itemBuilder: (BuildContext context, int index) {
              Product offer = _OfferProductList[index];
              return _buildOfferItem(offer);
            },
          ),
    bottomNavigationBar: Padding(
  padding: EdgeInsets.all(16.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      ElevatedButton.icon(
        onPressed: () {
          // Handle Accept button tap
        },
        icon: Icon(Icons.check),
        label: Text('Accept'),
        style: ElevatedButton.styleFrom(
          primary: Colors.green, // Set the background color to green
        ),
      ),
      ElevatedButton.icon(
        onPressed: () {
          // Handle Decline button tap
        },
        icon: Icon(Icons.close),
        label: Text('Decline'),
        style: ElevatedButton.styleFrom(
          primary: Colors.red, // Set the background color to red
        ),
      ),
    ],
  ),
),

  );
}

}
