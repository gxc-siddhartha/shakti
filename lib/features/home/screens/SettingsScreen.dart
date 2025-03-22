import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:go_router/go_router.dart';
import 'package:shakti/core/helpers/HelperWidgets.dart';
import 'package:shakti/features/auth/controllers/AuthController.dart';

// Assuming the HelperWidgets.dart is imported as follows:
// import 'path_to_helper_widgets/HelperWidgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthController _authController = Get.find();
  // Mock user data - in a real app, this would come from a user model or provider
  final String name = "Danny Rico";

  final String profileImageUrl = "s";
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("Account")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile section with circular avatar
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: Column(
                    children: [
                      // Profile image
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        backgroundImage:
                            profileImageUrl.isNotEmpty
                                ? NetworkImage(
                                      _authController
                                              .activeUser
                                              .value
                                              .profileUrl ??
                                          "",
                                    )
                                    as ImageProvider
                                : null,
                        child:
                            profileImageUrl.isEmpty
                                ? Text(
                                  name.isNotEmpty ? name[0] : "U",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                                : null,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Name
                      Text(
                        _authController.activeUser.value.name ?? "",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.8,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      // Email
                      Text(
                        _authController.activeUser.value.email ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Sign Out option using CCardText widget
                GestureDetector(
                  onTap: () {
                    // Handle sign out logic
                    _showSignOutConfirmation(context);
                  },
                  child: CCardText(
                    content: Column(
                      children: [
                        ListTile(
                          minTileHeight: 30,
                          contentPadding: EdgeInsets.only(right: 16),
                          trailing: SFIcon(
                            SFIcons.sf_chevron_forward,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          title: Text(
                            "Sign Out",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    iconThemeColor: Theme.of(context).colorScheme.primary,
                    cardTitle: "Account Actions",
                    icon: Icons.person,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Opacity(
                  opacity: 0.5,
                  child: Text(
                    "A Product by  ",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Image.asset('assets/brand/signature.png', height: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Sign out confirmation dialog
  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dcontext) => AlertDialog(
            title: const Text("Sign Out"),
            content: const Text("Are you sure you want to sign out?"),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await _authController.signOut(context);
                  if (dcontext.mounted) {
                    dcontext.pop();
                  }
                  // For example: AuthService.signOut();
                  // Then navigate to login screen
                  // Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text("Sign Out"),
              ),
            ],
          ),
    );
  }
}
