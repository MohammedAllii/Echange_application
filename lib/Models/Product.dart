class Product {
  final int id;
  final String nomProduit;
  final String description;
  final List<String> images;
  final String added;
  final int? categorieId; // Make it nullable

  // ... Other properties and methods

  Product({
    required this.id,
    required this.nomProduit,
    required this.description,
    required this.images,
    required this.added,
    this.categorieId, // Make it nullable
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> imageList = (json['images'] as List<dynamic>)
        .map((image) => image.toString())
        .toList();

    return Product(
      id: json['id'] as int,
      nomProduit: json['nom_produit'] as String,
      description: json['description'] as String,
      images: imageList.map((imageName) {
        return '$imageName';
      }).toList(),
      categorieId: json['category_id'] as int?, // Make it nullable
      added: json['added'] as String, // Use the correct key from your JSON
    );
  }
}
