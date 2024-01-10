import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../Models/Offer.dart';
import '../Models/User.dart';
import '../Services/ApiClient.dart';
import '../Utils/Consts.dart';
import 'OfferProductList.dart';
import 'package:clipboard/clipboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class ListOffersUser extends StatefulWidget {
  @override
  _ListOffersUserState createState() => _ListOffersUserState();
}

class _ListOffersUserState extends State<ListOffersUser> {
  List<Offer> _offerList = [];
  List<Offer> _filteredOffers = [];
  int _selectedIndex = 2;
  bool _showWaiting = true; 
  User? _selectedUser; 

  @override
  void initState() {
    _fetchOffersForUser();
    super.initState();
  }

  Future<void> _fetchOffersForUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var iduser = prefs.getString('id');
      if (iduser != null) {
        final offers = await ApiClient.getProductsForUser(iduser);
        setState(() {
          _offerList = offers;
          _updateFilteredOffers();
        });
      }
    } catch (e) {
      print('Error fetching offers: $e');
    }
  }

  void _updateFilteredOffers() {
    _filteredOffers = _showWaiting
        ? _offerList.where((offer) => offer.status == "1").toList()
        : _offerList.where((offer) => offer.status == "2").toList();
  }

  Widget _buildOfferItem(Offer offer) {
    bool isStatusOne = offer.status == "1";

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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Produit Cible : ${offer.userFullname}'),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${offer.added}'),
            ],
          ),
          // Choose the icon based on the offer's status
          trailing: Visibility(
            visible: isStatusOne,
            child: Icon(
              Icons.hourglass_empty, // Waiting icon
              color: Colors.orange,
            ),
            replacement: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final userO = await ApiClient.fetchcontact(offer.id_user.toString());
                    setState(() {
                      _selectedUser = userO;
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
                SizedBox(width: 8), // Add some spacing between buttons
                ElevatedButton.icon(
                  onPressed: () async {
                    final userO = await ApiClient.fetchcontact(offer.id_user.toString());
                    setState(() {
                      _selectedUser = userO;
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
          ),
        ),
      ),
    );
  }

  void _navigateToOfferDetails(Offer offer) {
    // Implement navigation logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Offres'),
        actions: [
          Switch(
            value: _showWaiting,
            onChanged: (value) {
              setState(() {
                _showWaiting = value;
                _updateFilteredOffers();
              });
            },
          ),
        ],
      ),
      body: _filteredOffers.isEmpty
          ? Center(
              child: Image.asset(
                'assets/nooffer.png',
                width: 250.0,
                height: 250.0,
              ),
            )
          : ListView.builder(
              itemCount: _filteredOffers.length,
              itemBuilder: (BuildContext context, int index) {
                Offer offer = _filteredOffers[index];
                return _buildOfferItem(offer);
              },
            ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // Assuming onItemTapped is a method in Consts class
            Consts.onItemTapped(context, _selectedIndex);
          });
        },
        items: Consts.navBarItems,
      ),
    );
  }
}
