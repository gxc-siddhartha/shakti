import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shakti/core/DependencyManager.dart';
import 'package:shakti/core/router/RouterService.dart';
import 'package:shakti/core/theme/appTheme.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  DependencyInjection.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // if (Theme.of(context).colorScheme.brightness == Brightness.light) {
    //   SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(
    //       statusBarColor: Colors.transparent,
    //       statusBarIconBrightness: Brightness.dark, // This will make icons dark
    //     ),
    //   );
    // } else {
    //   SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(
    //       statusBarColor: Colors.transparent,
    //       statusBarIconBrightness:
    //           Brightness.light, // This will make icons dark
    //     ),
    //   );
    // }

    return MaterialApp.router(
      routerConfig: RouterService.routerService,
      theme: Apptheme.lightAppTheme,
      darkTheme: Apptheme.darkAppTheme,
    );
  }
}
