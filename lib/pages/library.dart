import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {

  final List<Map<String,dynamic>> data=[

  ];


  void fetchUserData(){
    FirebaseFirestore.instance.collection("videos").get().then(
          (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          data.add(docSnapshot.data());
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    fetchUserData();
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
