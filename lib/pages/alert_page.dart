import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seguridad_plus/controllers/streaming_controller.dart';
import 'package:seguridad_plus/pages/emergency_options_page.dart';
import 'package:seguridad_plus/providers/auth_notifier_provider.dart';
import 'package:seguridad_plus/providers/firebase_provider.dart';
import 'package:seguridad_plus/services/firestore_service.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo blanco (podés cambiar a rojo si querés)
          Container(color: Colors.white),

          // Botón SOS centrado
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.black),
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(80),
                textStyle: const TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                try {
                  final auth = context.read<AuthNotifierProvider>();
                  final db = context.read<FirestoreProvider>();
                  print("user: ${auth.user}");
                  print("Ahora vamos a emitir la alerta");

                  await db.emitirAlerta(auth.user!.uid);

                  print("Alerta emitida");

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyOptionsPage(),
                    ),
                  );
                } catch (e, st) {
                  print("Error al emitir la alerta: $e");
                  print("Stacktrace: $st");

                  // Opcional: mostrar mensaje visual
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al emitir alerta: $e')),
                  );
                }
              },

              child: const Text('SOS'),
            ),
          ),
        ],
      ),
    );
  }
}
