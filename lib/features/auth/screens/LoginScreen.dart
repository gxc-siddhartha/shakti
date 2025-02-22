import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shakti/core/router/RouterConstants.dart';
import 'package:shakti/features/auth/controllers/AuthController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _autovalidateMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get isFormValid {
    return _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;
  }

  void _handleEmailSignIn() async {
    setState(() {
      _autovalidateMode = true;
    });

    if (_formKey.currentState!.validate()) {
      await _authController.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  void _handleGoogleSignIn() async {
    await _authController.loginWithGoogle();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your password';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode:
                        _autovalidateMode
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        Image.asset('lib/assets/brand/logo.png', height: 100),
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hey, welcome back! let\'s get back to work. Login to proceed and start working.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Email TextField
                        TextFormField(
                          controller: _emailController,
                          validator: _validateEmail,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            errorStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Password TextField
                        TextFormField(
                          controller: _passwordController,
                          validator: _validatePassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            errorStyle: const TextStyle(fontSize: 12),
                          ),
                        ),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isFormValid ? _handleEmailSignIn : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Google Sign In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _handleGoogleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Image.asset(
                              'lib/assets/google_logo.png',
                              height: 24,
                            ),
                            label: Text(
                              'Continue with Google',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),

                        TextButton(
                          onPressed: () {
                            context.goNamed(
                              RouterConstants.registrationScreenRouteName,
                            );
                          },
                          child: Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Loading Overlay
            Obx(
              () =>
                  _authController.isLoading.value
                      ? Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.2),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
            // Error Message
            Obx(
              () =>
                  _authController.errorMessage.value.isNotEmpty
                      ? Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _authController.errorMessage.value,
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
