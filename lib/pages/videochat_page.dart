import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_components/livekit_components.dart';

class VideoChatPage extends StatelessWidget {
  final String token;
  final String url;
  final String roomName;

  const VideoChatPage({
    super.key,
    required this.token,
    required this.url,
    required this.roomName,
  });

  @override
  Widget build(BuildContext context) {
    return LivekitRoom(
      roomContext: RoomContext(
        url: url,
        token: token,
        connect: true,
        roomOptions: RoomOptions(
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: true,
            videoEncoding: VideoEncoding(
              maxBitrate: 500 * 1000, // 500 kbps
              maxFramerate: 60,
            ),
          ),
          defaultCameraCaptureOptions: CameraCaptureOptions(maxFrameRate: 60),
        )
      ),
      builder: (context, roomCtx) {
        return Scaffold(
          appBar: AppBar(title: Text('Videollamada - Sala $roomName')),
          body: Column(
            children: [
              Expanded(
                child: ParticipantLoop(
                  showAudioTracks: false,
                  showVideoTracks: true,
                  layoutBuilder: const CarouselLayoutBuilder(),
                  participantTrackBuilder: (context, trackIdentifier) {
                    return ParticipantTileWidget();
                  },
                ),
              ),
              const ControlBar(),
            ],
          ),
        );
      },
    );
  }
}
