import 'package:flutter/material.dart';
import 'package:soccer_app/widgets/video_player_widget.dart';

class VideoPage extends StatefulWidget {
  final String name;
  final String videoUrl;
  const VideoPage({super.key,required this.name,required this.videoUrl});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          AnalysisVideoPlayer(videoUrl: widget.videoUrl,),
          Text(widget.name)
        ],
      ),
    );
  }
}
