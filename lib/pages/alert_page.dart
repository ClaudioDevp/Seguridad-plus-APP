import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seguridad_plus/pages/emergency_options_dialog.dart';

import '../providers/location_provider.dart';

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
    final locationProvider = context.read<LocationProvider>();
    locationProvider.startSendingLocation();
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
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => EmergencyOptionsDialog(),
                  );
                } catch (e) {
                  print("❌ Error al emitir alerta: $e");
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
