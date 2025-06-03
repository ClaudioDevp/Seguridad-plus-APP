import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:seguridad_plus/firebase_options.dart';
import 'package:seguridad_plus/pages/alert_page.dart';
import 'package:seguridad_plus/pages/login_page.dart';
import 'package:seguridad_plus/providers/auth_notifier_provider.dart';
import 'package:seguridad_plus/providers/firebase_provider.dart';
import 'package:seguridad_plus/providers/livekit_provider.dart';
import 'package:seguridad_plus/providers/location_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifierProvider()),
        ChangeNotifierProvider(create: (_) => FirestoreProvider()),
        ChangeNotifierProvider(create: (_) => LivekitProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AuthWrapper());
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthNotifierProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const LoginPage();
    }

    return const AlertPage();
  }
}
