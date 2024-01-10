class Offer {
  final int id;
  final int id_user;
  final String userFullname;
  final String status;
  final String added;
  
  

  Offer({
    required this.id,
    required this.id_user,
    required this.userFullname,
    required this.status,
    required this.added,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      id_user: json['id_user'],
      userFullname: json['user_fullname'],
      status: json['status'],
      added: json['added'],
    );
  }
}
