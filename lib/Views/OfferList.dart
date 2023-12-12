import 'package:flutter/material.dart';
import '../Models/Offer.dart';
import '../Services/ApiClient.dart';
import 'OfferProductList.dart';

class OfferList extends StatefulWidget {
  final String idProduit;

  OfferList({required this.idProduit});

  @override
  _OfferListState createState() => _OfferListState();
}

class _OfferListState extends State<OfferList> {
  List<Offer> _offerList = [];

  @override
  void initState() {
    _fetchOffersForProduct();
    super.initState();
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

  Widget _buildOfferItem(Offer offer) {
  return InkWell(
    onTap: () {
      _navigateToOfferDetails(offer);
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
        title: Text('Nom : ${offer.userFullname}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${offer.added}'),
          ],
        ),
      ),
    ),
  );
}

void _navigateToOfferDetails(Offer offer) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OfferProductList(idoffre: offer.id.toString()),
    ),
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
            // Display an image or a message when no offers exist
            child: Image.asset('assets/nooffer.png',
             width: 250.0,
              height: 250.0,), // Replace with your image asset
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
