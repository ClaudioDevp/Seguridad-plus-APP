import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class CameraPreviewWidget extends StatelessWidget {
  final LocalVideoTrack? videoTrack;

  const CameraPreviewWidget({super.key, required this.videoTrack});

  @override
  Widget build(BuildContext context) {
    if (videoTrack == null) {
      return Center(child: Text('Esperando video...'));
    }

    return VideoTrackRenderer(videoTrack!);
  }
}
