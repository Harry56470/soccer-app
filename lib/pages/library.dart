import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {




  Future<List<Map<String,dynamic>>> fetchUserData() async {
    List<Map<String,dynamic>>data=[];
    String currentUid=FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection("videos").get().then(
          (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          Map<String,dynamic> video=docSnapshot.data();
          String uid=video["uid"];
          if(currentUid==uid){
            data.add(video);
          }


        }

      },
      onError: (e) => print("Error completing: $e"),
    );
    return data;
  }


  @override
  void initState(){
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ,
        builder: builder
    );
    // return ListView.builder(
    //     padding: const EdgeInsets.all(8),
    //     itemCount: data.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       final videoData = (data[index]);
    //       return videoTile(videoData["url"]!, videoData["name"]!);
    //     }
    // );
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
