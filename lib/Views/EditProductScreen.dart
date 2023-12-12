import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Categorie.dart';
import '../Models/Product.dart';
import '../Services/ApiClient.dart';
import '../Utils/Consts.dart';
import '../Utils/size_config.dart';
import '../Views/HomeScreen.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  int? _selectedCategoryId;
  int _selectedIndex = 1;
  String _selectedCategoryName = '';
  List<Categorie> _categories = [];
  List<File> _selectedImages = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _initFormData();
  }

  void _initFormData() {
    _nameController.text = widget.product.nomProduit;
    _descriptionController.text = widget.product.description;
    _selectedCategoryId = widget.product.categorieId ?? null;

    _selectedImages.addAll(widget.product.images.map((imagePath) => File(imagePath)));

    _selectedCategoryName = _categories
        .firstWhere((categorie) => categorie.id == _selectedCategoryId,
            orElse: () => Categorie(id: 0, categorieName: '', image: ''))
        .categorieName;
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await ApiClient.getCategories();
      setState(() {
        _categories = categories;
      });

      if (_selectedCategoryId != null) {
        setState(() {
          _selectedCategoryName = _categories
              .firstWhere(
                  (categorie) => categorie.id == _selectedCategoryId,
                  orElse: () =>
                      Categorie(id: 0, categorieName: '', image: ''))
              .categorieName;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _selectImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter a $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<int>(
        value: _selectedCategoryId,
        items: _categories.map((categorie) {
          return DropdownMenuItem<int>(
            value: categorie.id,
            child: Text(categorie.categorieName),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategoryId = value;
          });
        },
        decoration: InputDecoration(labelText: 'Category'),
        validator: (value) {
          if (value == null) {
            return 'Please select a category';
          }
          return null;
        },
        hint: Text('Select a category'),
      ),
    );
  }

  Future<void> _editProductInfo() async {
  String nomProduit = _nameController.text;
  String description = _descriptionController.text;

  try {
    final response = await ApiClient.updateProduit(
      productId: widget.product.id,
      nomProduit: nomProduit,
      description: description,
      categorieId: _selectedCategoryId ?? 0,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product information edited successfully'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      print('Failed to edit product information. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to edit product information. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    print('Error editing product information: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error editing product information. Please try again.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}


  Future<void> _updateImages() async {
    try {
      // Implement this function to update images separately
      // You can use a similar approach as in the _uploadImages function
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating images: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
          "Edit Product",
          style: TextStyle(
            fontFamily: 'Varela',
            fontSize: 20.0,
            color: Color(0xFF545D68),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/edit.png',
                      height: getProportionateScreenHeight(100),
                    ),
                    Divider(),
                    SizedBox(height: 16),
                    _selectedImages.isNotEmpty
                        ? SizedBox(
                            height: 200.0,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: _selectedImages[index].path.startsWith('http')
                                          ? Image.network(
                                              _selectedImages[index].path,
                                              height: 200,
                                              width: 200,
                                            )
                                          : Image.file(
                                              _selectedImages[index],
                                              height: 200,
                                              width: 200,
                                            ),
                                    ),
                                    Positioned(
                                      top: 8.0,
                                      right: 8.0,
                                      child: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          _removeImage(index);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        : Placeholder(
                            fallbackHeight: 200.0,
                          ),
                    ElevatedButton(
                      onPressed: _selectImages,
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(color: Colors.black),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.update),
                          SizedBox(width: 15.0),
                          Text('Update images'),
                        ],
                      ),
                    ),
                    Divider(),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Product Name',
                    ),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                    ),
                    _buildDropdown(),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _editProductInfo();
                        }
                      },
                      child: Text('Update Product Information'),
                    ),
                
                  ],
                ),
              ),
            ),
          ),
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