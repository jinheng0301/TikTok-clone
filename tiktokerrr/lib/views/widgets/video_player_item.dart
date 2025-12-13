import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _videoPlayerController;
  bool isVideoPlaying = false;
  bool showControls = false;
  bool isInitialized = false;
  bool hasError = false;
  String? errorMessage;
  Timer? controlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Validate URL
      if (widget.videoUrl.isEmpty) {
        setState(() {
          hasError = true;
          errorMessage = 'Invalid video URL';
        });
        return;
      }

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      // Add error listener
      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.hasError) {
          if (mounted) {
            setState(() {
              hasError = true;
              errorMessage = _videoPlayerController.value.errorDescription ??
                  'Failed to load video';
            });
          }
        }
      });

      await _videoPlayerController.initialize();

      if (mounted) {
        setState(() {
          isInitialized = true;
        });

        _videoPlayerController.play();
        _videoPlayerController.setVolume(1);
        _videoPlayerController.setLooping(true);
        isVideoPlaying = true;

        // Start auto-hide timer
        _startControlsTimer();
      }
    } catch (e) {
      print('Video initialization error: $e');
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  void _startControlsTimer() {
    controlsTimer?.cancel();
    if (isVideoPlaying && showControls) {
      controlsTimer = Timer(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showControls = false;
          });
        }
      });
    }
  }

  void _togglePlayPause() {
    if (!isInitialized) return;

    setState(() {
      if (isVideoPlaying) {
        _videoPlayerController.pause();
        isVideoPlaying = false;
        showControls = true;
        controlsTimer?.cancel();
      } else {
        _videoPlayerController.play();
        isVideoPlaying = true;
        showControls = true;
        _startControlsTimer();
      }
    });
  }

  @override
  void dispose() {
    controlsTimer?.cancel();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  errorMessage ?? 'Unknown error',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    hasError = false;
                    errorMessage = null;
                    isInitialized = false;
                  });
                  _initializeVideo();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          showControls = !showControls;
          if (showControls && isVideoPlaying) {
            _startControlsTimer();
          }
        });
      },
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              ),
            ),
          ),
          if (showControls)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    isVideoPlaying ? Icons.pause : Icons.play_arrow,
                    size: 50,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
