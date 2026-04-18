import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker picker = ImagePicker();
  final db=FirebaseFirestore.instance;
  XFile? pickedVideo;
  void chooseVideo()async{
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if(image!=null){
        pickedVideo=image;
      }

    });
  }
  void upload()async{
    db.collection("videos").doc().set(
        {
          "name": "blueberry",
          "url":"https://www.fourwindsgrowers.com/cdn/shop/products/shutterstock_722035450blueberry2_70d2b1fb-ee3f-46fb-afde-5df11232bdbe_grande.jpg?v=1729795889"
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [
        Text("Analyze Soccer Match",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
        SizedBox(height: 70,),
        (pickedVideo!=null)?Image.file(File(pickedVideo!.path)):Container(),
        ElevatedButton(onPressed: (){}, child: SizedBox(
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Take Video",style: TextStyle(fontSize: 20),),
              Icon(Icons.video_call,size: 40,)
            ],
          ),
        )),
        ElevatedButton(
            onPressed: (){
             chooseVideo();
            },
            child: SizedBox(
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Choose From Library",style: TextStyle(fontSize: 15),),
                  Icon(Icons.library_add,size: 30,)
                ],
              ),
          )
        ),
        ElevatedButton(
            onPressed: (){
              upload();
            },
            child: SizedBox(
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Submit",style: TextStyle(fontSize: 15),),
                  Icon(Icons.upload_sharp,size: 30,)
                ],
              ),
            )
        ),
      ],
    );
  }
}
