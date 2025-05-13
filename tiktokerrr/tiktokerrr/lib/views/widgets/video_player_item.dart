import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  VideoPlayerItem({required this.videoUrl});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _videoPlayerController;
  late bool isVideoPlaying = false;
  late bool showControls = true;
  late Timer controlsTimer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
      // convert String to Uri
    )..initialize().then((_) {
        setState(() {
          _videoPlayerController.setLooping(true);
          _videoPlayerController.play();
          _videoPlayerController.setVolume(1);
          isVideoPlaying = true;
        });
      });

    controlsTimer = Timer.periodic(
      Duration(seconds: 2),
      (timer) {
        if (!isVideoPlaying) {
          timer.cancel();
          // stop the timer if the video is paused
        }
        setState(() {
          showControls = false;
          // Hide controls after a few seconds
        });
      },
    );
  }

  void _togglePlayPause() {
    if (isVideoPlaying) {
      _videoPlayerController.pause();
    } else {
      _videoPlayerController.play();
    }
    setState(() {
      isVideoPlaying = !isVideoPlaying;
      showControls = true;
      // Show controls when toggling play/pause
    });

    // Restart the timer when controls are shown
    controlsTimer.cancel();

    controlsTimer = Timer.periodic(
      Duration(seconds: 3),
      (timer) {
        if (!isVideoPlaying) {
          timer.cancel();
        }
        setState(() {
          showControls = false;
        });
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _videoPlayerController.dispose();
    controlsTimer.cancel();
    // cancel the timer to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Stack(
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: VideoPlayer(_videoPlayerController),
          ),
        ),
        Visibility(
          visible: showControls,
          child: Center(
            child: IconButton(
              onPressed: _togglePlayPause,
              icon: Icon(
                isVideoPlaying ? Icons.pause : Icons.play_arrow,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
