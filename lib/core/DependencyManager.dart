import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shakti/features/auth/controllers/AuthController.dart';
import 'package:shakti/features/auth/repositories/AuthRepository.dart';
import 'package:shakti/features/home/controllers/HomeController.dart';
import 'package:shakti/features/home/repositories/HomeRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DependencyInjection {
  void initSharedPreferencesServices() async {
    await Get.putAsync<SharedPreferences>(() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs;
    });
  }

  static void init() {
    Get.lazyPut<FirebaseAuth>(
      () => FirebaseAuth.instance,
      fenix: true, // Keeps the instance alive throughout the app lifecycle
    );

    Get.lazyPut<GoogleSignIn>(
      () => GoogleSignIn(),
      fenix: true, // Keeps the instance alive throughout the app lifecycle
    );

    // Firestore
    Get.lazyPut<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
      fenix: true,
    );

    // Firebase Storage
    Get.lazyPut<FirebaseStorage>(() => FirebaseStorage.instance, fenix: true);
    Get.lazyPut<Future<SharedPreferences>>(
      () => SharedPreferences.getInstance(),
      fenix: true,
    );

    // Auth Repository
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<HomeRepository>(() => HomeRepository(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}
