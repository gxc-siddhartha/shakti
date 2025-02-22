import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/instance_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as path;
import 'package:shakti/core/constants/SharedPreferencesConstants.dart';
import 'package:shakti/core/models/UserModel.dart';
import 'package:shakti/core/typedefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final GoogleSignIn googleSignIn = Get.find();
  final FirebaseAuth _auth = Get.find<FirebaseAuth>();
  final FirebaseStorage _storage = Get.find<FirebaseStorage>();
  final FirebaseFirestore _firestore = Get.find<FirebaseFirestore>();

  FutureEither<void> createUserInFirestoreEMPS(
    String email,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      // Create the user in Firebase Authentication
      final _ = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // If user creation is successful, return right with void
      await prefs.setBool(SharedPreferencesConstants.loginStatus, true);
      return right(null);
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth exceptions
      await prefs.setBool(SharedPreferencesConstants.loginStatus, false);

      switch (e.code) {
        case 'email-already-in-use':
          return left(
            'This email is already registered. Please use a different email.',
          );
        case 'invalid-email':
          return left(
            'The email address is invalid. Please check and try again.',
          );
        case 'operation-not-allowed':
          return left(
            'Email/password accounts are not enabled. Please contact support.',
          );
        case 'weak-password':
          return left(
            'The password is too weak. Please use a stronger password.',
          );
        default:
          return left(
            'An error occurred while creating your account: ${e.message}',
          );
      }
    } catch (e) {
      // Handle any other unexpected errors
      return left('An unexpected error occurred: $e');
    }
  }

  FutureEither<void> createUserInFirestoreDatabase(
    UserModel? userModel,
    File file,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      // Validate user model
      if (userModel == null) {
        return left('User model cannot be null');
      }

      // Update the userModel with the current user's UID
      final updatedUserModel = userModel.copyWith(
        userId: _auth.currentUser!.uid,
      );

      // Reference to the users collection with the updated userId
      final userDoc = _firestore
          .collection('users')
          .doc(updatedUserModel.userId);

      final downloadUrl = await uploadUserImageToFirebaseStorage(file);

      await userDoc.set(
        updatedUserModel
            .copyWith(
              photoUrl: downloadUrl.fold((error) => "", (success) => success),
            )
            .toMap(),
        SetOptions(merge: true),
      );
      await prefs.setBool(SharedPreferencesConstants.loginStatus, true);
      await prefs.setString(
        SharedPreferencesConstants.userId,
        userModel.userId ?? "no-uid",
      );
      return right(null);
    } on FirebaseException catch (e) {
      return left('Failed to create user in database: ${e.message}');
    } catch (e) {
      return left('An unexpected error occurred while creating user: $e');
    }
  }

  // Upload user image to Firebase Storage
  FutureEither<String> uploadUserImageToFirebaseStorage(File image) async {
    try {
      // Generate unique file name using timestamp
      final fileName =
          'user_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';

      // Create storage reference
      final storageRef = _storage.ref().child('user_images').child(fileName);

      // Upload file
      final uploadTask = await storageRef.putFile(
        image,
        SettableMetadata(
          contentType: 'image/${path.extension(image.path).substring(1)}',
          customMetadata: {'uploaded_at': DateTime.now().toIso8601String()},
        ),
      );

      // Get download URL
      if (uploadTask.state == TaskState.success) {
        final downloadUrl = await storageRef.getDownloadURL();
        return right(downloadUrl);
      } else {
        return left('Failed to upload image: Upload task unsuccessful');
      }
    } on FirebaseException catch (e) {
      return left('Failed to upload image: ${e.message}');
    } catch (e) {
      return left('An unexpected error occurred while uploading image: $e');
    }
  }

  // Method to clear auth status
  Future<void> _clearAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(SharedPreferencesConstants.loginStatus, false);
    await prefs.remove(SharedPreferencesConstants.userId);
  }

  // Method to check login status
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(SharedPreferencesConstants.loginStatus) ?? false;
  }

  // Method to check registration status
  Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(SharedPreferencesConstants.registrationStatus) ??
        false;
  }

  // Check user login status from both SharedPreferences and Firebase
  FutureEither<bool> checkUserLoginStatus() async {
    try {
      // Check SharedPreferences login status
      final bool isLocallyLoggedIn = await isLoggedIn();

      // Check Firebase Auth state
      final currentUser = _auth.currentUser;

      // If locally logged in but no Firebase user, clear local status
      if (isLocallyLoggedIn && currentUser == null) {
        await _clearAuthStatus();
        return right(false);
      }

      // If Firebase user exists but not locally logged in, update local status
      if (!isLocallyLoggedIn && currentUser != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool(SharedPreferencesConstants.loginStatus, true);
        await prefs.setString(
          SharedPreferencesConstants.userId,
          currentUser.uid,
        );
        return right(true);
      }

      // Return the current login state
      return right(currentUser != null && isLocallyLoggedIn);
    } catch (e) {
      return left('Failed to check login status: $e');
    }
  }

  // Email/Password Sign In
  FutureEither<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      // Attempt to sign in with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return left('Login failed: No user data received');
      }

      // Get user data from Firestore
      final userDoc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (!userDoc.exists) {
        return left('User data not found in database');
      }

      // Update SharedPreferences
      await prefs.setBool(SharedPreferencesConstants.loginStatus, true);
      await prefs.setBool(SharedPreferencesConstants.registrationStatus, true);
      await prefs.setString(
        SharedPreferencesConstants.userId,
        userCredential.user!.uid,
      );

      // Return user model
      return right(UserModel.fromMap(userDoc.data()!));
    } on FirebaseAuthException catch (e) {
      await prefs.setBool(SharedPreferencesConstants.loginStatus, false);

      switch (e.code) {
        case 'user-not-found':
          return left('No user found with this email');
        case 'wrong-password':
          return left('Invalid password');
        case 'user-disabled':
          return left('This account has been disabled');
        case 'invalid-email':
          return left('Invalid email address');
        default:
          return left('Login failed: ${e.message}');
      }
    } catch (e) {
      await prefs.setBool(SharedPreferencesConstants.loginStatus, false);
      return left('An unexpected error occurred: $e');
    }
  }

  // Google Sign In
  FutureEither<UserModel> signInWithGoogle() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      // Start the interactive sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return left('Google sign in was cancelled');
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return left('Login failed: No user data received');
      }

      // Check if user exists in Firestore
      final userDoc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      UserModel userModel;

      if (!userDoc.exists) {
        // Create new user model if first time sign in
        userModel = UserModel(
          userId: userCredential.user!.uid,
          email: userCredential.user!.email,
          name: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now().toIso8601String(),
          points: '0',
          interests: [],
        );

        // Save new user to Firestore
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());
      } else {
        userModel = UserModel.fromMap(userDoc.data()!);
      }

      await prefs.setBool(SharedPreferencesConstants.loginStatus, true);
      await prefs.setBool(SharedPreferencesConstants.registrationStatus, true);
      await prefs.setString(
        SharedPreferencesConstants.userId,
        userCredential.user!.uid,
      );

      return right(userModel);
    } on FirebaseAuthException catch (e) {
      await prefs.setBool(SharedPreferencesConstants.loginStatus, false);
      return left('Firebase Auth Error: ${e.message}');
    } catch (e) {
      await prefs.setBool(SharedPreferencesConstants.loginStatus, false);
      return left('An unexpected error occurred: $e');
    }
  }
}
