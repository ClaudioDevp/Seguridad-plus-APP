import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './emergency_options_page.dart';
import '../controllers/streaming_controller.dart';
import '../services/firestore_service.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Si necesitás lógica de inicio, ponela acá
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
                final controller = Provider.of<StreamingController>(
                  context,
                  listen: false,
                );
                final firestoreService = FirestoreService();

                await firestoreService.emitirAlerta(controller.userId);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyOptionsPage(),
                  ),
                );
              },
              child: const Text('SOS'),
            ),
          ),
        ],
      ),
    );
  }
}
