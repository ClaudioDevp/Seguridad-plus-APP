// ignore_for_file: avoid_print

import 'package:livekit_client/livekit_client.dart';

class LiveKitService {
  final String url = 'wss://claudev-09yjawm8.livekit.cloud';
  final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDg3NTMxMzUsImlzcyI6IkFQSVBHOEVLZ1lvbWFiWSIsIm5iZiI6MTc0Njc1NDEzNSwic3ViIjoiMiIsInZpZGVvIjp7ImNhblB1Ymxpc2giOnRydWUsImNhblB1Ymxpc2hEYXRhIjp0cnVlLCJjYW5TdWJzY3JpYmUiOnRydWUsInJvb20iOiJTZWd1cmlkYWRQdWJsaWNhIiwicm9vbUpvaW4iOnRydWV9fQ.8KxoSsvtk7J5-aPc5MQ77PY3TQaont3OWYoqw83FaeU';

  late Room _room;

  Future<LocalVideoTrack?> connectAndPublish() async {
    try {
      _room = Room();
      await _room.connect(
        url,
        token,
        connectOptions: const ConnectOptions(),
      );

      print('✅ Conectado a la sala: ${_room.name}');

      final cameraTrack = await LocalVideoTrack.createCameraTrack(
      const CameraCaptureOptions(
        cameraPosition: CameraPosition.back,
      ),
    );
     // 🎤 Crear track de audio (micrófono)
    final audioTrack = await LocalAudioTrack.create();

      if (_room.localParticipant != null) {
        await _room.localParticipant!.publishVideoTrack(cameraTrack);
        await _room.localParticipant!.publishAudioTrack(audioTrack);
      }

      print('📸 Cámara publicada en LiveKit.');

      return cameraTrack;
    } catch (e) {
      print('❌ Error al conectar o publicar: $e');
      return null;
    }
  }

  Future<void> disconnect() async {
    await _room.disconnect();
    print('🔌 Desconectado de LiveKit.');
  }
}
