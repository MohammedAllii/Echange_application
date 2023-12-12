import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../Models/Categorie.dart';
import '../Models/Product.dart';
import '../Services/ApiClient.dart';
import 'ProductDescription.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Categorie category;

  CategoryProductsScreen({required this.category});

  @override
  _CategoryProductsScreenState createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  int _currentPage = 1;
  int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await ApiClient.getProductsByCategory(widget.category.id);
      setState(() {
        _products = products;
        _filteredProducts = products;
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _currentPage = 1;
      if (query.isNotEmpty) {
        _filteredProducts = _products
            .where((product) =>
                product.nomProduit.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        _filteredProducts = _products;
      }
    });
  }

  List<Product> _getCurrentPageProducts() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _filteredProducts.sublist(
        startIndex,
        endIndex <= _filteredProducts.length
            ? endIndex
            : _filteredProducts.length);
  }

  String _truncateDescription(String description) {
    return (description.length <= 20) ? description : '${description.substring(0, 20)}...';
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
        margin: EdgeInsets.all(30),
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
                padding: const EdgeInsets.all(20),
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
                    SizedBox(height: 12),
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
                padding: const EdgeInsets.all(20),
                child: Text(
                  '${product.added}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Image.asset(
        'assets/noresult.png',
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products in ${widget.category.categorieName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.16),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search here...',
                  hintStyle: TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                onChanged: (value) {
                  _filterProducts(value);
                },
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildPlaceholderImage()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _getCurrentPageProducts().length,
                    itemBuilder: (context, index) {
                      Product product = _getCurrentPageProducts()[index];
                      return Container(
                        height: 170, // Set a fixed height for each item
                        child: _buildProductItem(product),
                      );
                    },
                  ),
          ),
          // Pagination controls
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                (_filteredProducts.length / _itemsPerPage).ceil(),
                (page) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentPage = page + 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: _currentPage == page + 1
                          ? Colors.black
                          : null,
                      shape: CircleBorder(),
                    ),
                    child: Text(
                      '${page + 1}',
                      style: TextStyle(
                        color: _currentPage == page + 1
                            ? Colors.white
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
