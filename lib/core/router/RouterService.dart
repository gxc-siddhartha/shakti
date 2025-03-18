import 'package:go_router/go_router.dart';
import 'package:shakti/core/router/RouterConstants.dart';
import 'package:shakti/features/auth/screens/LoginScreen.dart';
import 'package:shakti/features/auth/screens/PersonalDetailsScreen.dart';
import 'package:shakti/features/auth/screens/RegistrationComplete.dart';
import 'package:shakti/features/auth/screens/RegistrationScreen.dart';
import 'package:shakti/features/home/screens/HomeScreen.dart';
import 'package:shakti/features/splash/screens/SplashScreen.dart';

class RouterService {
  static final GoRouter routerService = GoRouter(
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
            path: "/registraion",
            name: RouterConstants.registrationScreenRouteName,
            builder: (context, state) => RegistrationScreen(),
            routes: [
              GoRoute(
                path: "/registraion/personalDetails",
                name: RouterConstants.personalDetailsScreenRouteName,
                builder: (context, state) => PersonalDetailsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: "/registraion/complete",
        name: RouterConstants.registrationCompleteScreenRouteName,
        builder: (context, state) {
          return RegistrationCompleteScreen();
        },
      ),
      GoRoute(
        path: "/home",
        name: RouterConstants.homeScreenRouteName,
        builder: (context, state) {
          return HomeScreen();
        },
      ),
    ],
  );
}
