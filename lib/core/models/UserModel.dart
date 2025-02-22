// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class UserModel {
  final String? userId;
  final String? name;
  final String? email;
  final String? age;
  final String? city;
  final String? state;
  final String? photoUrl;
  final String? createdAt;
  final String? standard;
  final String? board;
  final String? schoolName;
  final List<String>? interests;
  final String? points;
  final String? careerPath;

  UserModel({
    this.userId,
    this.name,
    this.email,
    this.age,
    this.city,
    this.state,
    this.photoUrl,
    this.createdAt,
    this.standard,
    this.board,
    this.schoolName,
    this.interests,
    this.points,
    this.careerPath,
  });

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? age,
    String? city,
    String? state,
    String? photoUrl,
    String? createdAt,
    String? standard,
    String? board,
    String? schoolName,
    List<String>? interests,
    String? points,
    String? careerPath,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      city: city ?? this.city,
      state: state ?? this.state,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      standard: standard ?? this.standard,
      board: board ?? this.board,
      schoolName: schoolName ?? this.schoolName,
      interests: interests ?? this.interests,
      points: points ?? this.points,
      careerPath: careerPath ?? this.careerPath,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'email': email,
      'age': age,
      'city': city,
      'state': state,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'standard': standard,
      'board': board,
      'schoolName': schoolName,
      'interests': interests,
      'points': points,
      'careerPath': careerPath,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] as String?,
      name: map['name'] as String?,
      email: map['email'] as String?,
      age: map['age'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: map['createdAt'] as String?,
      standard: map['standard'] as String?,
      board: map['board'] as String?,
      schoolName: map['schoolName'] as String?,
      interests:
          map['interests'] != null
              ? List<String>.from(map['interests'] as List<dynamic>)
              : null,
      points: map['points'] as String?,
      careerPath: map['careerPath'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(userId: $userId, name: $name, email: $email, age: $age, city: $city, state: $state, photoUrl: $photoUrl, createdAt: $createdAt, standard: $standard, board: $board, schoolName: $schoolName, interests: $interests, points: $points, careerPath: $careerPath)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.name == name &&
        other.email == email &&
        other.age == age &&
        other.city == city &&
        other.state == state &&
        other.photoUrl == photoUrl &&
        other.createdAt == createdAt &&
        other.standard == standard &&
        other.board == board &&
        other.schoolName == schoolName &&
        listEquals(other.interests, interests) &&
        other.points == points &&
        other.careerPath == careerPath;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        name.hashCode ^
        email.hashCode ^
        age.hashCode ^
        city.hashCode ^
        state.hashCode ^
        photoUrl.hashCode ^
        createdAt.hashCode ^
        standard.hashCode ^
        board.hashCode ^
        schoolName.hashCode ^
        interests.hashCode ^
        points.hashCode ^
        careerPath.hashCode;
  }

  // Factory constructor for empty user model
  factory UserModel.empty() {
    return UserModel(
      userId: '',
      name: '',
      email: '',
      age: '',
      city: '',
      state: '',
      photoUrl: '',
      createdAt: DateTime.now().toIso8601String(),
      standard: '',
      board: '',
      schoolName: '',
      interests: [],
      points: '0',
      careerPath: '',
    );
  }
}
