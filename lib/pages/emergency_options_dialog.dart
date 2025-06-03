import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:seguridad_plus/pages/videochat_page.dart';
import 'package:seguridad_plus/providers/auth_notifier_provider.dart';
import 'package:seguridad_plus/providers/firebase_provider.dart';
import 'package:seguridad_plus/providers/livekit_provider.dart';
import 'package:seguridad_plus/services/firestore_service.dart';

class EmergencyOptionsDialog extends StatefulWidget {
  final String  url = "wss://claudev-09yjawm8.livekit.cloud";
  const EmergencyOptionsDialog({super.key});

  @override
  State<EmergencyOptionsDialog> createState() => _EmergencyOptionsDialogState();
}

class _EmergencyOptionsDialogState extends State<EmergencyOptionsDialog> {
  bool _loading = false;
  Timer? _autoTriggerTimer;
  Timer? _countdownTimer;
  int _countdown = 10;

  @override
  void initState() {
    super.initState();
    // Iniciar countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 1) {
        timer.cancel();
      }
      setState(() {
        _countdown--;
      });
    });
    // Espera 10 segundos, si el usuario no interactúa, inicia la videollamada
    _autoTriggerTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !_loading) {
        _startVideoChat();
      }
    });
  }

  @override
  void dispose() {
    _autoTriggerTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _startVideoChat() async {
    setState(() => _loading = true);

    final auth = context.read<AuthNotifierProvider>();
    final db = context.read<FirestoreProvider>();
    final lkProvider = context.read<LivekitProvider>();

    final token = await db.emitirAlerta(auth.user!.uid, "video");
    lkProvider.setToken(token);
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirestoreService().linkRoomName(userId, token);

      if (!mounted) return;
      Navigator.of(context).pop(); // Cierra el modal

      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => VideoChatPage(
                token: token,
                url: widget.url,
                roomName: auth.user!.uid, // o usar roomName si lo tenés separado
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al iniciar videochat: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "¿Qué tipo de emergencia es?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 👇 Cuenta regresiva visible
            Text(
              "Seleccionando videollamada en ${_countdown}s...",
              style: const TextStyle(fontSize: 16, color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const CircularProgressIndicator()
            else ...[
              _buildOption(
                label: 'Iniciar Videochat',
                icon: Icons.videocam,
                color: Colors.orange,
                onPressed: _startVideoChat,
              ),
              const SizedBox(height: 12),
              _buildOption(
                label: 'Iniciar Chat de Texto',
                icon: Icons.chat,
                color: Colors.amber.shade700,
                onPressed: () {
                  // TODO: Chat
                },
              ),
              const SizedBox(height: 12),
              _buildOption(
                label: 'Falsa Alarma',
                icon: Icons.keyboard_return,
                color: Colors.black87,
                onPressed: () {
                  Navigator.of(context).pop(); // Solo cierra
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
    );
  }
}
