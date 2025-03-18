import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shakti/core/models/UserModel.dart';
import 'package:shakti/core/router/RouterConstants.dart';
import 'package:shakti/features/auth/repositories/AuthRepository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Loading state
  RxBool isLoading = false.obs;

  Rx<UserModel> activeUser = UserModel.empty().obs;

  // Error state
  RxString errorMessage = ''.obs;
  Rx<File> selectedImage = File("").obs;

  RxString password = "".obs;

  Future<void> getUserData() async {
    isLoading.value = true;
    final response = await _authRepository.getUserData();
    response.fold(
      (error) {
        isLoading.value = false;

        print(error);
      },
      (success) {
        activeUser.value = success;
        print(success.toString());
        isLoading.value = false;
      },
    );
  }

  // Registration flow
  Future<bool> registerUser({required BuildContext context}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Step 1: Create user in Firebase Auth
      final authResult = await _authRepository.createUserInFirestoreEMPS(
        activeUser.value.email!,
        password.value,
      );

      return await authResult.fold(
        (failure) {
          print(failure);
          errorMessage.value = failure;
          return false;
        },
        (success) async {
          // Step 3: Upload image and create user in Firestore
          final databaseResult = await _authRepository
              .createUserInFirestoreDatabase(
                activeUser.value,
                selectedImage.value,
              );

          return databaseResult.fold(
            (failure) {
              errorMessage.value = failure;
              print(failure);
              return false;
            },
            (success) {
              context.goNamed(
                RouterConstants.registrationCompleteScreenRouteName,
              );
              return true;
            },
          );
        },
      );
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // In AuthController
  Future<void> loginWithEmail(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      isLoading.value = true;
      final result = await _authRepository.signInWithEmailAndPassword(
        email,
        password,
      );

      result.fold(
        (error) {
          print(error);
        },
        (userModel) {
          activeUser.value = userModel;
          handleAuthNavigation(context);
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      isLoading.value = true;
      final result = await _authRepository.signInWithGoogle();

      result.fold(
        (error) {
          print(error);
        },
        (userModel) {
          activeUser.value = userModel;
          handleAuthNavigation(context);
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Helper method to check if registration is possible
  bool canRegister({
    required String email,
    required String password,
    required String name,
    required String age,
    required File? profileImage,
  }) {
    if (email.isEmpty || !GetUtils.isEmail(email)) return false;
    if (password.isEmpty || password.length < 6) return false;
    if (name.isEmpty) return false;
    if (age.isEmpty) return false;
    if (profileImage == null) return false;
    return true;
  }

  Future<bool> isLoggedIn() async {
    return _authRepository.isLoggedIn();
  }

  // Method to check registration status
  Future<bool> isRegistered() async {
    return _authRepository.isRegistered();
  }

  // Check user login status from both SharedPreferences and Firebase
  Future<void> checkUserLoginStatus(BuildContext context) async {
    try {
      final loginStatusResult = await _authRepository.checkUserLoginStatus();

      loginStatusResult.fold(
        (error) {
          errorMessage.value = error;
          context.goNamed(RouterConstants.loginScreenRouteName);
        },
        (isLoggedIn) {
          if (isLoggedIn) {
            context.goNamed(RouterConstants.homeScreenRouteName);
          } else {
            context.goNamed(RouterConstants.loginScreenRouteName);
          }
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to check login status: $e';
      context.goNamed(RouterConstants.loginScreenRouteName);
    }
  }

  // Navigate based on login and registration status
  Future<void> handleAuthNavigation(BuildContext context) async {
    try {
      final isUserLoggedIn = await isLoggedIn();
      final isUserRegistered = await isRegistered();

      if (context.mounted) {
        if (isUserLoggedIn && !isUserRegistered) {
          context.goNamed(RouterConstants.registrationScreenRouteName);
        } else if (isUserLoggedIn && isUserRegistered) {
          // User is both logged in and registered - go to home screen
          context.goNamed(RouterConstants.homeScreenRouteName);
        } else {
          // Default to login screen if neither condition is met
          context.goNamed(RouterConstants.loginScreenRouteName);
        }
      }
    } catch (e) {
      errorMessage.value = 'Navigation error: $e';
      // Default to login screen on error
      if (context.mounted) {
        context.goNamed(RouterConstants.loginScreenRouteName);
      }
    }
  }
}
