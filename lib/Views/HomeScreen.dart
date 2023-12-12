import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_simple_page/Views/AddProductScreen.dart';
import 'package:flutter_simple_page/Views/FavorisPage.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../Models/Product.dart';
import '../Models/Categorie.dart';
import '../Services/ApiClient.dart';
import '../Utils/Consts.dart';
import '../Widgets/MenuBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CategoryProductsScreen.dart';
import 'ProductDescription.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _productList = [];
  int _selectedIndex = 0;
   int _favoriteCount = 0;
  final ApiClient _apiClient = ApiClient();
  List<Categorie> _categories = [];
  String _userId = '';

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Define _scaffoldKey


  @override
  void initState() {
    _fetchProducts();
    _fetchCategories(); 
    _nombreFavoris();// Fetch categories
    super.initState();
  }

  Future<void> _fetchProducts() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var iduser = prefs.getString('id');

      if (iduser != null) {
        final products = await ApiClient.getProducts(iduser);
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

  Future<void> _fetchCategories() async {
    try {
      final categories = await ApiClient.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

 Future<void> _nombreFavoris() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
      var iduser = prefs.getString('id');
    try {
      if (iduser != null) {
        final favorisCount = await ApiClient.getNombrefavoris(iduser);
        setState(() {
          _favoriteCount = favorisCount;
        });
      } else {
        print('User ID is empty');
      }
    } catch (e) {
      print('Error fetching favoris count: $e');
    }
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
        width: 150,
        height: 50,
        margin: EdgeInsets.all(10),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.images.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: false,
                  enlargeCenterPage: true,
                ),
                items: product.images.map((imagePath) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imagePath,
                      height: 50,
                      width: 270,
                    ),
                  );
                }).toList(),
              ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                product.nomProduit.length <= 20
                    ? product.nomProduit
                    : product.nomProduit.substring(0, 20) + '...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${product.added}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 9, 9, 9),
                      backgroundColor: Color.fromARGB(255, 178, 249, 251),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildCategoryCarousel() {
  return CarouselSlider(
    options: CarouselOptions(
      autoPlay: false,
      enlargeCenterPage: true,
    ),
    items: _categories.map((category) {
      return GestureDetector(
        onTap: () {
        print("Category tapped");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsScreen(category: category),
          ),
        );
      },
        child: Container(
          width: 150,
          height: 50,
          margin: EdgeInsets.all(10),
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
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  category.image,
                  height: 50,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  category.categorieName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Accueil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
    Stack(
      children: [
        IconButton(
          icon: Icon(Icons.favorite), // Change the icon as needed
          onPressed: () {
            // Navigate to the other page here
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavorisPage(),
              ),
            );
          },
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.red,
            radius: 10,
            child: Text(
              _favoriteCount.toString(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    ),
  ],
      ),
      drawer: buildMenuBar(selectedIndex: _selectedIndex),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                
                SliverList(
  delegate: SliverChildListDelegate(
    [
      Divider(),

      CarouselSlider(
  options: CarouselOptions(
    autoPlay: true,
    enlargeCenterPage: false,
    aspectRatio: 6 / 2,
  ),
  items: [
    Image.asset('assets/image1.jpg', fit: BoxFit.cover),
    Image.asset('assets/image2.jpg', fit: BoxFit.cover),
  ].map((Widget image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0), // Set border radius as needed
      child: image,
    );
  }).toList(),
),
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Divider(),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: EdgeInsets.only(left: 10, right: 10), // Adjust margins as needed
          child: Text(
            "Catégories",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  ],
),Divider(),
Container(
  margin: EdgeInsets.symmetric(horizontal: 10),
  height: 90.0,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: _categories.length,
    itemBuilder: (BuildContext context, int index) {
      Categorie category = _categories[index];
      return GestureDetector(
        onTap: () {
          print("Category tapped: ${category.categorieName}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryProductsScreen(category: category),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40), // Adjusted padding
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.network(
                    category.image,
                    width: 30.0,
                    height: 30.0,
                  ),
                ),
              ),
              Text(
                category.categorieName,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    },
  ),
),
            ],
          ),
        ),
                SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Text(
                      "Les plus récents",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: null, // Set onPressed to null for no functionality
                      child: Text(
                        "Voir tout",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 300,
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              Product product = _productList[index];
                              return SizedBox(
                                width: 350,
                                height: 150,
                                child: _buildProductItem(product),
                              );
                            },
                            childCount: _productList.length,
                          ),
                        ),
                      ],
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Text(
                      "Différents produits",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: null,
                      child: Text(
                        "Voir tout",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 250,
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              Product product = _productList[index];
                              return SizedBox(
                                width: 250,
                                height: 150,
                                child: _buildProductItem(product),
                              );
                            },
                            childCount: _productList.length,
                          ),
                        ),
                      ],
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
