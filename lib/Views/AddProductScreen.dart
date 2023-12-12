import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Categorie.dart';
import '../Services/ApiClient.dart';
import '../Utils/Consts.dart';
import '../Utils/size_config.dart';
import '../Views/HomeScreen.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  int? _selectedCategoryId;
  int _selectedIndex = 2;
  
  List<Categorie> _categories = [];
  List<File> _selectedImages = [];
  

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      List<Categorie> categories = await ApiClient.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _selectImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
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
          // Navigate directly to HomeScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false, // Remove all previous routes from the stack
          );
        },
      ),

        title: Text(
          "Add Product",
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
                      'assets/add.png',
                      height: getProportionateScreenHeight(150),
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
                                      child: Image.file(
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
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _selectImages,
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(color: Colors.black),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_a_photo),
                          SizedBox(width: 15.0),
                          Text('Select Images'),
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
                          if (_selectedImages.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Select at least one image'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            await _addProduct();
                          }
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 9.0),
                          Text('Add produit '),
                        ],
                      ),
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
      ),
    );
  }

  Future<void> _addProduct() async {
    String nomProduit = _nameController.text;
    String description = _descriptionController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? iduser = prefs.getString('id');

    if (token != null && iduser != null) {
      try {
        final response = await ApiClient.addProduct(
          nomProduit: nomProduit,
          description: description,
          categorieId: _selectedCategoryId ?? 0,
          token: token,
          iduser: iduser,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product added successfully'),
              duration: Duration(seconds: 3),
            ),
          );
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          int idProduit = jsonResponse['idproduit'];
          print('Product ID: $idProduit');

          // Upload images
          await _uploadImages(idProduit);

          // Optionally, you can navigate to the HomeScreen or perform any other actions
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          print('Failed to add product. ');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add product. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        print('Error adding product: $e');
      }
    } else {
      print('User not authenticated');
    }
  }

  Future<void> _uploadImages(int productId) async {
    try {
      if (_selectedImages.isNotEmpty) {
        for (File image in _selectedImages) {
          Map<String, dynamic> response =
              await ApiClient.uploadImage(productId, image);

          // Check the response from the API
          if (response.containsKey('error')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image upload failed: ${response['error']}'),
                duration: Duration(seconds: 2),
              ),
            );
            return; // Stop if any image upload fails
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Images added to your product successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Select at least one image'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading images: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
