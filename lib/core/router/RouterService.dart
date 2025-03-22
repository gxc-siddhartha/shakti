import 'package:go_router/go_router.dart';
import 'package:shakti/core/models/SubjectModel.dart';
import 'package:shakti/core/router/RouterConstants.dart';
import 'package:shakti/features/auth/screens/LoginScreen.dart';
import 'package:shakti/features/auth/screens/PersonalDetailsScreen.dart';
import 'package:shakti/features/auth/screens/RegistrationComplete.dart';
import 'package:shakti/features/auth/screens/RegistrationScreen.dart';
import 'package:shakti/features/home/screens/HomeScreen.dart';
import 'package:shakti/features/home/screens/ScheduleScreen.dart';
import 'package:shakti/features/home/screens/SettingsScreen.dart';
import 'package:shakti/features/home/screens/ShellScreen.dart';
import 'package:shakti/features/home/screens/SubjectDetailsScreen.dart';
import 'package:shakti/features/splash/screens/SplashScreen.dart';

class RouterService {
  static final GoRouter routerService = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: "/",
        builder: (context, state) {
          return Splashscreen();
        },
      ),
      GoRoute(
        path: "/login",
        name: RouterConstants.loginScreenRouteName,
        builder: (context, state) {
          return LoginScreen();
        },
        routes: [
          GoRoute(
            path: "registration",
            name: RouterConstants.registrationScreenRouteName,
            builder: (context, state) => RegistrationScreen(),
            routes: [
              GoRoute(
                path: "personalDetails",
                name: RouterConstants.personalDetailsScreenRouteName,
                builder: (context, state) => PersonalDetailsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: "/registration/complete",
        name: RouterConstants.registrationCompleteScreenRouteName,
        builder: (context, state) {
          return RegistrationCompleteScreen();
        },
      ),

      // Shell route for tabbed navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Home tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: RouterConstants.homeScreenRouteName,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: '/home/subjectDetails',
                    name: RouterConstants.subjectDetailsScreenRouteName,
                    builder: (context, state) {
                      final subject = state.extra as SubjectModel;
                      return SubjectDetailsScreen(subject: subject);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Schedule tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/schedule',
                name: RouterConstants.scheduleScreenRouteName,
                builder: (context, state) => const ScheduleScreen(),
              ),
            ],
          ),
          // Settings tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: RouterConstants.settingsScreenRouteName,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Route definition
    ],
  );
}
