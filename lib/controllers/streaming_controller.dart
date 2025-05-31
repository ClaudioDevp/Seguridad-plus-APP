import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:seguridad_plus/services/livekit_service.dart';
import 'package:seguridad_plus/services/location_service.dart';
import 'package:seguridad_plus/services/status_service.dart';

class StreamingController extends ChangeNotifier {
  final LocationService locationService;
  final LiveKitService liveKitService;
  final StatusService statusService;
  final String userId;

  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  Map<String, RTCVideoRenderer> remoteRenderers = {};

  bool isStreaming = false;
  Timer? _statusTimer;
  CancelListenFunc? _eventCancelFunc;

  StreamingController({
    required this.locationService,
    required this.liveKitService,
    required this.statusService,
    required this.userId,
  });

  Future<void> init() async {
    await localRenderer.initialize();
    // locationService.startSendingLocation();
    _startStatusTimer();

    // Escuchar eventos de la sala
    _eventCancelFunc = liveKitService.room.events.listen((event) {
      if (event is TrackSubscribedEvent) {
        _handleTrackSubscribed(event);
      } else if (event is ParticipantDisconnectedEvent) {
        _handleParticipantDisconnected(event);
      }
    });
  }

  void _handleTrackSubscribed(TrackSubscribedEvent event) async {
    final participant = event.participant;
    final track = event.track;
    if (track is RemoteVideoTrack) {
      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      renderer.srcObject = track.mediaStream;
      remoteRenderers[participant.sid] = renderer;
      notifyListeners();
    }
  }

  void _handleParticipantDisconnected(ParticipantDisconnectedEvent event) {
    final participant = event.participant;
    final renderer = remoteRenderers.remove(participant.sid);
    renderer?.dispose();
    notifyListeners();
  }

  void _startStatusTimer() {
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      statusService.checkAndSendStatus(userId);
    });
  }

  Future<void> startStreaming(String token) async {
    final track = await liveKitService.connectAndPublish(token);
    if (track != null) {
      final mediaStream = await createLocalMediaStream('local');
      mediaStream.addTrack(track.mediaStreamTrack);
      localRenderer.srcObject = mediaStream;
      isStreaming = true;
      notifyListeners();
    }
  }

  Future<void> stopStreaming() async {
    await liveKitService.disconnect();
    localRenderer.srcObject = null;
    isStreaming = false;

    // Dispose remotos
    remoteRenderers.forEach((_, r) => r.dispose());
    remoteRenderers.clear();

    notifyListeners();
  }

  @override
  void dispose() {
    _eventCancelFunc?.call(); // cancelar la escucha correctamente
    localRenderer.dispose();
    locationService.stopSendingLocation();
    liveKitService.disconnect();
    _statusTimer?.cancel();
    super.dispose();
  }
}
