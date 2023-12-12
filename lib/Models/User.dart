class User {
  String? name;
  String? last_name;
  String? email;
  String? password;
  int? phone;

  User({  this.name,  this.last_name,  this.email,   this.password,  this.phone});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      last_name: json['last_name'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'last_name': last_name,
    'email': email,
    'password': password,
    'phone': phone,
  };
}
