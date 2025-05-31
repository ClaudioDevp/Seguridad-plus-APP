import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:seguridad_plus/pages/videochat_page.dart';
import 'package:seguridad_plus/services/firestore_service.dart';

class EmergencyOptionsPage extends StatefulWidget {
  const EmergencyOptionsPage({super.key});

  @override
  State<EmergencyOptionsPage> createState() => _EmergencyOptionsPageState();
}

class _EmergencyOptionsPageState extends State<EmergencyOptionsPage>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  bool _loading = false;
  
  static const String liveKitUrl = "wss://claudev-09yjawm8.livekit.cloud";

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  Future<void> _startVideoChat() async {
    setState(() => _loading = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('createCallRoom');
      // Cambia este número al id real del municipio
      final municipalityId = 1;

      final result = await callable.call(<String, dynamic>{
        'municipalityId': municipalityId,
      });

      final data = Map<String, dynamic>.from(result.data);
      final token = data['token'] as String;
      final roomName = data['roomName'] as String;
      final userId = FirebaseAuth.instance.currentUser?.uid;
      await FirestoreService().linkRoomName(userId!, roomName);


      if (!mounted) return;

      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VideoChatPage(
          token: token,
          url: liveKitUrl,
          roomName: roomName,
        ),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar videochat: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo rojo dramático
          Container(color: Colors.red.shade900),

          // Ondas de alerta
          AnimatedBuilder(
            animation: _rippleController,
            builder: (_, __) => CustomPaint(
              painter: RipplePainter(_rippleController.value),
              child: const SizedBox.expand(),
            ),
          ),

          // Contenido principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : _buildAlertButton(
                        label: 'Iniciar Videochat',
                        icon: Icons.videocam,
                        color: Colors.orange,
                        onPressed: _startVideoChat,
                      ),
                const SizedBox(height: 30),
                _buildAlertButton(
                  label: 'Iniciar Chat de Texto',
                  icon: Icons.chat,
                  color: Colors.amber.shade700,
                  onPressed: () {
                    // TODO: Ir a página de chat de texto
                  },
                ),
                const SizedBox(height: 30),
                _buildAlertButton(
                  label: 'Falsa Alarma',
                  icon: Icons.keyboard_return,
                  color: Colors.black87,
                  onPressed: () {
                    // TODO: Cancelar la alarma
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: Colors.black,
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final double progress;
  RipplePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.4 * progress;

    final paint = Paint()
      ..color = Colors.white.withOpacity(1.0 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) => true;
}
