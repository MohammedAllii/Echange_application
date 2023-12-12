import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_simple_page/Models/User.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/Categorie.dart';
import '../Models/Offer.dart';
import '../Models/Product.dart';

class ApiClient {
  static const baseUrl = 'http://192.168.1.10:8000/api';

  static Future<http.Response> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );
    return response;
  }

  static Future<http.Response> registerUser(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'name': name,
        "email": email,
        "password": password,
      }),
    );
    return response;
  }

  static Future<User> fetchUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final userProfileMap = jsonDecode(response.body);
      final userProfile = User.fromJson(userProfileMap);
      return userProfile;
    } else {
      throw Exception('Failed to load User');
    }
  }

  static Future<List<Product>> getProducts(String iduser) async {
    final response = await http.get(
      Uri.parse('$baseUrl/allproducts/$iduser'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> productData = jsonDecode(response.body);
      final List<Product> products = (productData['produits'] as List<dynamic>)
          .map((data) => Product.fromJson(data))
          .toList();

      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> getUserProducts(String iduser) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$iduser'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> productData = jsonDecode(response.body);
      final List<Product> products = (productData['produits'] as List<dynamic>)
          .map((data) => Product.fromJson(data))
          .toList();

      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> getFavorisProducts(String iduser) async {
    final response = await http.get(
      Uri.parse('$baseUrl/favoris/$iduser'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> productData = jsonDecode(response.body);
      final List<Product> products = (productData['produits'] as List<dynamic>? ?? [])
    .map((data) => Product.fromJson(data))
    .toList();


      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> getProductsByCategory(int categoryId) async {
  final response = await http.get(
      Uri.parse('$baseUrl/productsCategorie/$categoryId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> productData = jsonDecode(response.body);
      final List<Product> products = (productData['produits'] as List<dynamic>)
          .map((data) => Product.fromJson(data))
          .toList();

      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

 static Future<void> deleteUserProduct(int idProduit) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/deleteproduit/$idProduit'),
    );

    if (response.statusCode == 200) {
      print('Product deleted successfully');
    } else {
      print('Failed to delete product. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to delete product');
    }
  } catch (e) {
    print('Exception: $e');
    throw Exception('Failed to delete product');
  }
}

static Future<void> deleteFavoriteProduct(int idFavoris) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/deletefavoris/$idFavoris'),
    );

    if (response.statusCode == 200) {
      print('Favoris deleted successfully');
    } else {
      print('Failed to delete Favoris. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to delete Favoris');
    }
  } catch (e) {
    print('Exception: $e');
    throw Exception('Failed to delete Favoris');
  }
}

static Future<int> getNombrefavoris(String iduser) async {
  final response = await http.get(Uri.parse('$baseUrl/favoriscount/$iduser'));

  if (response.statusCode == 201) {
    final List<dynamic> jsonResponse = json.decode(response.body);
    final int favorisCount = jsonResponse[0] as int;

    return favorisCount;
  } else {
    throw Exception('Failed to load favoris count');
  }
}





  static Future<List<Categorie>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categorie'));

   if (response.statusCode == 200) {
  final Map<String, dynamic> jsonResponse = json.decode(response.body);
  final List<dynamic> data = jsonResponse['categories'];

  List<Categorie> categories = data
      .map((categoryData) => Categorie.fromJson(categoryData))
      .toList();

  // Vérifiez les propriétés null ici si nécessaire

  return categories;
} else {
  throw Exception('Failed to load categories');
}
  }

static Future<http.Response> updateProduit({
  required int productId,
  required String nomProduit,
  required String description,
  required int categorieId,
}) async {
  try {
    // API endpoint for updating a product
    Uri uri = Uri.parse('$baseUrl/productUpdate/$productId');

    // Prepare the request body
    Map<String, dynamic> requestBody = {
      'nom_produit': nomProduit,
      'description': description,
      'categorie_id': categorieId,
    };

    // Make the PUT request without including the token in headers
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    return response;
  } catch (e) {
    // Handle exception
    print('Error updating product: $e');
    return http.Response('Error updating product', 500);
  }
}


  

  static Future<http.Response> logoutUser(String token) async {
  final response = await http.post(
    Uri.parse('$baseUrl/users/logout'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token', // Send the user's token in the headers
    },
  );
  return response;
}


static Future<http.Response> addProduct({
    required String nomProduit,
    required String description,
    required int categorieId,
    required String token,
    required String iduser,
  }) async {
    try {
      // API endpoint for adding a product
      Uri uri = Uri.parse('$baseUrl/ajouter-produit');

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'nom_produit': nomProduit,
        'description': description,
        'categorie_id': categorieId,
        'user_id': iduser,
      };

      // Make the POST request
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      return response;
    } catch (e) {
      // Handle exception
      print('Error adding product: $e');
      return http.Response('Error adding product', 500);
    }
  }

 static Future<Map<String, dynamic>> uploadImage(int productId, File imageFile) async {
  try {
    
    var apiUrl = '$baseUrl/upload-image/$productId';

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      // Image uploaded successfully
      print('Image uploaded successfully');
      // Parse the response JSON
      Map<String, dynamic> jsonResponse = json.decode(await response.stream.bytesToString());
      return jsonResponse;
    } else {
      // Handle the case where image upload failed
      print('Image upload failed');
      return {'error': 'Image upload failed'};
    }
  } catch (error) {
    // Handle any errors that occurred during the API request
    print('Error uploading image: $error');
    return {'error': 'Error uploading image'};
  }
}

static Future<void> deleteImage(int imageId) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/images/$imageId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('Image deleted successfully');
    } else {
      print('Failed to delete image. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to delete image');
    }
  } catch (e) {
    print('Exception: $e');
    throw Exception('Failed to delete image');
  }
}


static Future<Map<String, dynamic>> updateProductImages(int productId, File imageFile) async {
  try {
    var apiUrl = '$baseUrl/update-product-images/$productId';

    var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));

    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      // Image updated successfully
      print('Image updated successfully');
      // Parse the response JSON
      Map<String, dynamic> jsonResponse = json.decode(await response.stream.bytesToString());
      return jsonResponse;
    } else {
      // Handle the case where image update failed
      print('Image update failed');
      return {'error': 'Image update failed'};
    }
  } catch (error) {
    // Handle any errors that occurred during the API request
    print('Error updating image: $error');
    return {'error': 'Error updating image'};
  }
}

  static Future<void> ajouterFavoris({
  required String userId,
  required int productId,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/ajouter-favoris/$userId/$productId'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      // Product added to favorites successfully
      print('Product added to favorites');
    } else {
      // Handle API error, throw an exception, or perform any other actions
      print('Failed to add product to favorites: ${response.statusCode}');
      throw Exception('Failed to add product to favorites');
    }
  } catch (e) {
    // Handle network or other errors
    print('Error adding to favorites: $e');
    throw Exception('Error adding product to favorites');
  }
}

static Future<List<Offer>> getOffersForProduct(String idProduit) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/offers/$idProduit'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> offersData = responseData['offers'];

        List<Offer> offers = offersData
            .map((offerData) => Offer.fromJson(offerData))
            .toList();

        return offers;
      } else {
        throw Exception('Failed to load offers');
      }
    } catch (e) {
      print('Error fetching offers: $e');
      throw Exception('Failed to load offers');
    }
  }
  static Future<List<Product>> getProductsForOffer(String offerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prodoffers/$offerId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> productsData = responseData['produits'];

        List<Product> products = productsData
            .map((productData) => Product.fromJson(productData))
            .toList();

        return products;
      } else {
        throw Exception('Failed to load products for offer');
      }
    } catch (e) {
      print('Error fetching products for offer: $e');
      throw Exception('Failed to load products for offer');
    }
  }


}
