import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';

class VideoChatPage extends StatefulWidget {
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
  State<VideoChatPage> createState() => _VideoChatPageState();
}

class _VideoChatPageState extends State<VideoChatPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  Room? _room;
  VoidCallback? _roomEventListener;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    await _localRenderer.initialize();

    final room = Room();

    await room.connect(
      widget.url,
      widget.token,
      roomOptions: const RoomOptions(
        defaultCameraCaptureOptions: CameraCaptureOptions(),
        defaultVideoPublishOptions: VideoPublishOptions(),
      ),
    );

    final localParticipant = room.localParticipant;

    await localParticipant?.setCameraEnabled(true);
    await localParticipant?.setMicrophoneEnabled(true);

    LocalVideoTrack? videoTrack;

    if (localParticipant != null) {
      for (var pub in localParticipant.trackPublications.values) {
        if (pub.track is LocalVideoTrack) {
          videoTrack = pub.track as LocalVideoTrack;
          break;
        }
      }
    }

    if (videoTrack != null) {
      _localRenderer.srcObject = videoTrack.mediaStream;
    }

    _roomEventListener = room.events.listen(_onRoomEvent);

    setState(() {
      _room = room;
    });
  }

  void _onRoomEvent(RoomEvent event) async {
    if (event is TrackSubscribedEvent) {
      final participant = event.participant;
      final track = event.track;

      if (track is RemoteVideoTrack) {
        final renderer = RTCVideoRenderer();
        await renderer.initialize();
        renderer.srcObject = track.mediaStream;

        setState(() {
          _remoteRenderers[participant.sid] = renderer;
        });
      }
    }

    if (event is ParticipantDisconnectedEvent) {
      final renderer = _remoteRenderers.remove(event.participant.sid);
      renderer?.dispose();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _roomEventListener?.call();
    _room?.disconnect();
    _localRenderer.dispose();
    for (final renderer in _remoteRenderers.values) {
      renderer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videollamada - Sala ${widget.roomName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end),
            onPressed: () {
              _room?.disconnect();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_remoteRenderers.isNotEmpty)
            Row(
              children:
                  _remoteRenderers.values.map((r) => Expanded(child: RTCVideoView(r))).toList(),
            )
          else
            const Center(child: Text('Esperando participantes...')),

          Positioned(
            bottom: 16,
            right: 16,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),
        ],
      ),
    );
  }
}
