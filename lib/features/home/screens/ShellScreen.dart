import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({required this.navigationShell, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                height: 1.0,
                thickness: 0.5,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              ),
              BottomNavigationBar(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                selectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surface.withOpacity(0.8),
                items: const [
                  BottomNavigationBarItem(
                    icon: SFIcon(
                      SFIcons.sf_house,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: SFIcon(
                      SFIcons.sf_calendar,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    label: "Schedule",
                  ),
                  BottomNavigationBarItem(
                    icon: SFIcon(
                      SFIcons.sf_person,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    label: "Profile",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
