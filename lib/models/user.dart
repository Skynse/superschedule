class SuperUser {
  String id;
  final String name;
  final String email;
  final String? photoUrl;

  SuperUser(
      {this.id = "", required this.name, required this.email, this.photoUrl});

  factory SuperUser.fromJson(Map<String, dynamic> json) {
    return SuperUser(
      id: json['uid'],
      name: json['display_name'],
      email: json['email'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'display_name': name,
      'email': email,
      'photo_url': photoUrl,
    };
  }
}
