import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/instance_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeRepository {
  final GoogleSignIn googleSignIn = Get.find();
  final FirebaseAuth _auth = Get.find<FirebaseAuth>();
  final FirebaseStorage _storage = Get.find<FirebaseStorage>();
  final FirebaseFirestore _firestore = Get.find<FirebaseFirestore>();
}
