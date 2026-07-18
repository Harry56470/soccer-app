import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soccer_app/pages/video.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {




  Future<List<Map<String,dynamic>>> fetchUserData() async {
    List<Map<String,dynamic>>data=[];
    String currentUid=FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("videos").get().then(
          (querySnapshot) {
        print("Successfully completed");
        print(querySnapshot.docs);
        for (var docSnapshot in querySnapshot.docs) {
          Map<String,dynamic> video=docSnapshot.data();
          String uid=video["uid"];
          print(uid+" "+currentUid);
          if(currentUid==uid){
            data.add(video);
          }


        }

      },
      onError: (e) => print("Error completing: $e"),
    );
    print(data);
    return data;
  }


  @override
  void initState(){
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String,dynamic>>>(
        future: fetchUserData(),
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return CircularProgressIndicator();
          }
          if(snapshot.hasError){
            return Text("error");
          }
          List<Map<String, dynamic>>? data=snapshot.data;
          return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: data!.length,
              itemBuilder: (BuildContext context, int index) {
                final videoData = (data[index]);
                return videoTile(videoData);
              }
          );
        }
    );

  }

  Widget videoTile(Map<String,dynamic> videoData){
    String imageURL=videoData["thumbnailUrl"]!;
    String videoURL=videoData["videoUrl"]!;
    String name=videoData["name"]!;
    int progress=videoData["progress"]!;
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_)=>VideoPage(name: name, videoUrl: imageURL)));
      },
      child: Row(
        children: [
          Image.network(imageURL,width: 100,),
          Text(name),Text(progress.toString())
        ],
      ),
    );
  }
}
