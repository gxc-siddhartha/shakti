import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shakti/features/auth/controllers/AuthController.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _handleInitialNavigation();
  }

  Future<void> _handleInitialNavigation() async {
    // Add a small delay to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    if (mounted) {
      _authController.handleAuthNavigation(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('lib/assets/brand/logo.png', height: 100),
      ),
    );
  }
}
