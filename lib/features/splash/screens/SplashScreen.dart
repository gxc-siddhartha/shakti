import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shakti/features/auth/controllers/AuthController.dart';
import 'package:shakti/features/home/controllers/HomeController.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final AuthController _authController = Get.find<AuthController>();
  final HomeController _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _handleInitialNavigation();
  }

  Future<void> _handleInitialNavigation() async {
    if (!mounted) return;
    if (mounted) {
      _authController.handleAuthNavigation(context, _homeController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset('assets/brand/logo.png', height: 100)),
    );
  }
}
