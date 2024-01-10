import 'package:flutter/material.dart';
import 'package:flutter_simple_page/Views/Description.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_simple_page/Models/User.dart';
import 'package:clipboard/clipboard.dart';
import '../Models/Offer.dart';
import '../Models/Product.dart';
import '../Services/ApiClient.dart';
import 'ProductDescription.dart';
import 'MyProducts.dart';

class CombinedOfferProductList extends StatefulWidget {
  final String idProduit;

  CombinedOfferProductList({required this.idProduit});

  @override
  _CombinedOfferProductListState createState() =>
      _CombinedOfferProductListState();
}

class _CombinedOfferProductListState extends State<CombinedOfferProductList> {
  List<Offer> _offerList = [];
  List<Product> _offerProductList = [];
  Offer? _selectedOffer;
  User? _selectedUser;
  late String _token;

  @override
  void initState() {
    _fetchToken();
    _fetchOffersForProduct();
    super.initState();
  }

  Future<void> _fetchToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
  }

  Future<void> _fetchOffersForProduct() async {
    try {
      final offers = await ApiClient.getOffersForProduct(widget.idProduit);
      setState(() {
        _offerList = offers;
      });
    } catch (e) {
      print('Error fetching offers: $e');
    }
  }

  Future<void> _fetchProductsForOffer(String idOffre) async {
    try {
      final products = await ApiClient.getProductsForOffer(idOffre);
      setState(() {
        _offerProductList = products;
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> _acceptOffer(String userId, String offreId) async {
    try {
      final response = await ApiClient.acceptOffer(_token, offreId);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Offre est accepté avec succes"),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyProducts()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error connection"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error accepting offer: $e');
    }
  }

  Future<void> _declineOffer(String userId, String offreId) async {
    try {
      final response = await ApiClient.declineOffer(_token, offreId);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Offre est rejeté avec succes"),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyProducts()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error connection"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error declining offer: $e');
    }
  }

  Widget _buildOfferItem(Offer offer) {
    return Column(
      children: [
        ExpansionTile(
          onExpansionChanged: (bool isExpanded) {
            setState(() {
              _selectedOffer = isExpanded ? offer : null;
              if (_selectedOffer != null) {
                _fetchProductsForOffer(offer.id.toString());
              }
            });
          },
          title: ListTile(
            title: Text('Nom : ${offer.userFullname}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${offer.added}'),
                offer.status == '2'
                    ? Text('Status: Acceptée')
                    : Text('Status: en attente'),
              ],
            ),
          ),
          children: _selectedOffer == offer ? [_buildProductList()] : <Widget>[],
        ),
        if (_selectedOffer == offer)
          
          offer.status == '2'
              ? Padding(
                  
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Offre Acceptée",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final userO= await ApiClient.fetchcontact(offer.id_user.toString());
                          setState(() {
                         _selectedUser=userO;
                       });
                         FlutterClipboard.copy(_selectedUser!.phone ?? '').then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Phone number ${_selectedUser!.phone} copied '),
                              ),
                            );
                          });
                        },
                        icon: Icon(Icons.phone),
                        label: Text('Phone'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final userO= await ApiClient.fetchcontact(offer.id_user.toString());
                          setState(() {
                         _selectedUser=userO;
                       });
                         FlutterClipboard.copy(_selectedUser!.email ?? '').then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Email  ${_selectedUser!.email} copied '),
                            ),
                          );
                        });

                        },
                        icon: Icon(Icons.email),
                        label: Text('Email'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _acceptOffer(_token, offer.id.toString());
                      },
                      icon: Icon(Icons.check),
                      label: Text('Accepter'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _declineOffer(_token, offer.id.toString());
                      },
                      icon: Icon(Icons.close),
                      label: Text('Rejeter'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                    ),
                  ],
                ),
      ],
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _offerProductList.length,
      itemBuilder: (BuildContext context, int index) {
        Product product = _offerProductList[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Description(product: product),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: 16, vertical: 8), // Adjust vertical margin as needed
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
              title: Text('${product.nomProduit}'),
            ),
          ),
        );
      },
    );
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Les Offres'),
      ),
      body: _offerList.isEmpty
          ? Center(
              child: Image.asset(
                'assets/nooffer.png',
                width: 250.0,
                height: 250.0,
              ),
            )
          : ListView.builder(
              itemCount: _offerList.length,
              itemBuilder: (BuildContext context, int index) {
                Offer offer = _offerList[index];
                return _buildOfferItem(offer);
              },
            ),
    );
  }
}
