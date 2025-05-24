import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'firebase_options.dart';
import 'location_service.dart';
import 'livekit_service.dart';
import 'status_service.dart'; // Nuevo import para el chequeo de estado
import 'dart:async'; // Para el Timer
import 'package:livekit_client/livekit_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocationService _locationService = LocationService();
  final LiveKitService _liveKitService = LiveKitService();
  final StatusService _statusService = StatusService(); // Instancia del servicio de estado

  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  bool _isStreaming = false;

  Timer? _statusTimer; // Timer para enviar estado cada 5 seg
  final String _userId = 'usuario1'; // Puedes reemplazar con UID real si usas Firebase Auth

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
    _locationService.startSendingLocation();

    // Enviar estado al iniciar
    _statusService.checkAndSendStatus(_userId);

    // Enviar estado cada 5 segundos
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _statusService.checkAndSendStatus(_userId);
    });
  }

  Future<void> _initializeRenderer() async {
    await _renderer.initialize();
  }

  Future<void> _startStreaming() async {
    final track = await _liveKitService.connectAndPublish();
    if (track is LocalVideoTrack) {
      final mediaStream = await createLocalMediaStream('local');
      mediaStream.addTrack(track.mediaStreamTrack);
      _renderer.srcObject = mediaStream;

      setState(() {
        _isStreaming = true;
      });
    }
  }

  Future<void> _stopStreaming() async {
    await _liveKitService.disconnect();
    _renderer.srcObject = null;

    setState(() {
      _isStreaming = false;
    });
  }

  @override
  void dispose() {
    _renderer.dispose();
    _locationService.stopSendingLocation();
    _liveKitService.disconnect();
    _statusTimer?.cancel(); // Cancelar el timer al salir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Seguridad Pública')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📡 Enviando ubicación...'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isStreaming ? _stopStreaming : _startStreaming,
                child: Text(_isStreaming ? 'Detener Stream' : 'Iniciar Stream'),
              ),
              const SizedBox(height: 20),
              _isStreaming && _renderer.srcObject != null
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9, // 90% del ancho de pantalla
                      height: MediaQuery.of(context).size.height * 0.6, // 60% del alto de pantalla
                      child: RTCVideoView(_renderer),
                    )
                  : const Text('🎥 Stream no iniciado'),
            ],
          ),
        ),
      ),
    );
  }
}
