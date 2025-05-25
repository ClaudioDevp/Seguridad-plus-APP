import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:seguridad_plus/controllers/streaming_controller.dart';
import 'package:seguridad_plus/firebase_options.dart';
import 'package:seguridad_plus/pages/alert_page.dart';
import 'package:seguridad_plus/pages/login_page.dart';
import 'package:seguridad_plus/services/auth_service.dart';
import 'package:seguridad_plus/services/firestore_service.dart';
import 'package:seguridad_plus/services/livekit_service.dart';
import 'package:seguridad_plus/services/location_service.dart';
import 'package:seguridad_plus/services/status_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AuthWrapper(),
  ));
}




class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});

  final AuthService _authService = AuthService( firestoreService: FirestoreService());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => StreamingController(
                  locationService: LocationService(firestoreService: FirestoreService()),
                  liveKitService: LiveKitService(),
                  statusService: StatusService(),
                  userId: user.uid,
                )..init(),
              ),
            ],
            child: const AlertPage(),
          );
        } else {
          return LoginPage(
            authService: _authService,
            onLogin: (user) {
              // El StreamBuilder reaccionará automáticamente, no hace falta hacer nada aquí
            },
          );
        }
      },
    );
  }
}
