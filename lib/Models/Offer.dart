class Offer {
  final int id;
  final String userFullname;
  final String status;
  final String added;

  Offer({
    required this.id,
    required this.userFullname,
    required this.status,
    required this.added,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      userFullname: json['user_fullname'],
      status: json['status'],
      added: json['added'],
    );
  }
}
