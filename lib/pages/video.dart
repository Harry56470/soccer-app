import 'package:flutter/material.dart';

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
          Image.network(widget.videoUrl),
          Text(widget.name)
        ],
      ),
    );
  }
}
