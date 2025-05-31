import 'package:livekit_client/livekit_client.dart';

class LiveKitService {
  final String url = 'wss://claudev-09yjawm8.livekit.cloud';

  late Room _room;

  Room get room => _room;

  Future<LocalVideoTrack?> connectAndPublish(String token) async {
    try {
      _room = Room();
      await _room.connect(url, token, connectOptions: const ConnectOptions());

      print('✅ Conectado a la sala: ${_room.name}');

      final cameraTrack = await LocalVideoTrack.createCameraTrack(
        const CameraCaptureOptions(cameraPosition: CameraPosition.front),
      );
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
