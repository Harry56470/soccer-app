import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {

  final List<Map<String,String>> data=[
    {
      "url":"https://www.chemwatch.net/wp-content/uploads/2021/11/image-6-1024x682.jpeg",
      "name":"orange"
    },
    {
      "url":"https://static.wikia.nocookie.net/the-snack-encyclopedia/images/7/7d/Apple.png/revision/latest?cb=20200706145821",
      "name":"apple"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) {
          final videoData = (data[index]);
          return videoTile(videoData["url"]!, videoData["name"]!);
        }
    );
  }

  Widget videoTile(String imageURL,String name){
    return Row(
      children: [
        Image.network(imageURL,width: 100,),
        Text(name)
      ],
    );
  }
}
