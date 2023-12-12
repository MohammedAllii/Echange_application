class Categorie {
  int id;
  String categorieName;
  String image;

  Categorie({
    required this.id,
    required this.categorieName,
    required this.image,
  });

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'],
      categorieName: json['categorie_name'],
      image: json['image'],
    );
  }
}
