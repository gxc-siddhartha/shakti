import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shakti/core/helpers/HelperWidgets.dart';
import 'package:shakti/features/auth/controllers/AuthController.dart';
import 'package:shakti/features/home/controllers/HomeController.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authController = Get.find<AuthController>();
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get user data first
      _authController.getUserData();
      // Then fetch subjects
      _homeController.activeUser.value = _authController.activeUser.value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(_authController.activeUser.value.profileUrl);
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
          size: 22,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Schedule"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      appBar: CustomAppBar(
        title: Image.asset("lib/assets/brand/logo.png", height: 40),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 16, top: 16, right: 8),
                    child: CCardText(
                      icon: Icons.percent,
                      content: "56%",
                      iconThemeColor: Theme.of(context).colorScheme.primary,
                      cardTitle: "Ovr. Percentage",
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(right: 16, top: 16, left: 8),
                    child: CCardText(
                      icon: Icons.percent,
                      content: "7",
                      iconThemeColor: Theme.of(context).colorScheme.primary,
                      cardTitle: "Today's Events",
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 16, top: 16, right: 8),
                    child: CCardText(
                      icon: Icons.percent,
                      content: "1",
                      iconThemeColor: Theme.of(context).colorScheme.primary,
                      cardTitle: "Missed Events",
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(right: 16, top: 16, left: 8),
                    child: CCardText(
                      icon: Icons.percent,
                      content: "6",
                      iconThemeColor: Theme.of(context).colorScheme.primary,
                      cardTitle: "Events Left",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
