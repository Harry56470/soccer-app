import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AnalysisVideoPlayer extends StatefulWidget {
  final String videoUrl; // Can be swapped to a File path if downloading locally first

  const AnalysisVideoPlayer({super.key, required this.videoUrl});

  @override
  State<AnalysisVideoPlayer> createState() => _AnalysisVideoPlayerState();
}

class _AnalysisVideoPlayerState extends State<AnalysisVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the URL from Firestore/Cloud Storage
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        // Trigger a rebuild to show the video once the first frame loads
        setState(() {});
      });
  }

  @override
  void dispose() {
    // CRITICAL: Always dispose of the controller to free up resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // 1. The base video
                VideoPlayer(_controller),
                
                // 2. The Play/Pause overlay
                _ControlsOverlay(controller: _controller),
                
                // 3. The timeline scrubber at the bottom
                VideoProgressIndicator(
                  _controller, 
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.blueAccent,
                  ),
                ),
                
                // TODO: 4. Add your CustomPaint overlay here for YOLO bounding boxes
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(), // Shows while video is loading
          );
  }
}

// A simple overlay to handle play/pause tapping
class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 80.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            // Toggle play/pause state
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}