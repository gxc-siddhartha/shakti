import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shakti/core/DependencyManager.dart';
import 'package:shakti/core/router/RouterService.dart';
import 'package:shakti/core/theme/appTheme.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  DependencyInjection.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: RouterService.routerService,
      theme: Apptheme.lightAppTheme,
    );
  }
}
