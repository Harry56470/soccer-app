import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        videoTile(),
        videoTile(),
        videoTile(),
        videoTile(),
      ],
    );
  }


  Widget videoTile(){
    return Row(
      children: [
        Image.network("https://static.wikia.nocookie.net/the-snack-encyclopedia/images/7/7d/Apple.png/revision/latest?cb=20200706145821",width: 100,),
        Text("data")
      ],
    );
  }
}
