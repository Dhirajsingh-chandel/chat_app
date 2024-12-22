// User Model (models/user_model.dart)
class UserModel {
  String uid;
  String name;
  String email;
  String profileImageUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImageUrl,
  });

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "name": name,
    "email": email,
    "profileImageUrl": profileImageUrl,
  };

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'],
    name: json['name'],
    email: json['email'],
    profileImageUrl: json['profileImageUrl'],
  );
}
