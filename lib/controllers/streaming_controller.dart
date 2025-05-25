import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/location_service.dart';
import '../services/livekit_service.dart';
import '../services/status_service.dart';
import 'package:livekit_client/livekit_client.dart';

class StreamingController extends ChangeNotifier {
  final LocationService locationService;
  final LiveKitService liveKitService;
  final StatusService statusService;

  RTCVideoRenderer renderer = RTCVideoRenderer();
  bool isStreaming = false;
  Timer? _statusTimer;
  final String userId;

  StreamingController({
    required this.locationService,
    required this.liveKitService,
    required this.statusService,
    required this.userId,
  });

  Future<void> init() async {
    await renderer.initialize();
    locationService.startSendingLocation();
    _startStatusTimer();
  }

  void _startStatusTimer() {
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      statusService.checkAndSendStatus(userId);
    });
  }

  Future<void> startStreaming() async {
    final track = await liveKitService.connectAndPublish();
    if (track is LocalVideoTrack) {
      final mediaStream = await createLocalMediaStream('local');
      mediaStream.addTrack(track.mediaStreamTrack);
      renderer.srcObject = mediaStream;
      isStreaming = true;
      notifyListeners();
    }
  }

  Future<void> stopStreaming() async {
    await liveKitService.disconnect();
    renderer.srcObject = null;
    isStreaming = false;
    notifyListeners();
    await renderer.dispose();
  }

  void dispose() {
    renderer.dispose();
    locationService.stopSendingLocation();
    liveKitService.disconnect();
    _statusTimer?.cancel();
    super.dispose();
  }
}
