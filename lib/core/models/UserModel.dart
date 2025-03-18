// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

class UserModel {
  final String? name;
  final String? profileUrl;
  final String? email;
  final String? uid;
  UserModel({this.name, this.profileUrl, this.email, this.uid});

  // New function: returns an empty UserModel object
  static UserModel empty() {
    return UserModel(name: null, profileUrl: null, email: null, uid: null);
  }

  UserModel copyWith({
    String? name,
    String? profileUrl,
    String? email,
    String? uid,
  }) {
    return UserModel(
      name: name ?? this.name,
      profileUrl: profileUrl ?? this.profileUrl,
      email: email ?? this.email,
      uid: uid ?? this.uid,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profileUrl': profileUrl,
      'email': email,
      'uid': uid,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] != null ? map['name'] as String : null,
      profileUrl:
          map['profileUrl'] != null ? map['profileUrl'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      uid: map['uid'] != null ? map['uid'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, profileUrl: $profileUrl, email: $email, uid: $uid)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.profileUrl == profileUrl &&
        other.email == email &&
        other.uid == uid;
  }

  @override
  int get hashCode {
    return name.hashCode ^ profileUrl.hashCode ^ email.hashCode ^ uid.hashCode;
  }
}
