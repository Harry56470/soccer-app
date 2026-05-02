import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker picker = ImagePicker();
  final storageRef = FirebaseStorage.instance.ref();
  final db=FirebaseFirestore.instance;
  XFile? pickedVideo;
  final nameController=TextEditingController();
  void chooseVideo()async{
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if(image!=null){
        pickedVideo=image;
      }

    });
  }
  Future<void> uploadFile(String filePath) async {
    var url = Uri.parse('http://10.0.2.2:5000/upload');

    // 1. Create a MultipartRequest
    var request = http.MultipartRequest('POST', url);

    // 2. Add text fields (optional)
    request.fields['user_id'] = '123';
    request.fields['category'] = 'reports';

    // 3. Add the file
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // The field name your server expects
        filePath,
      ),
    );

    // 4. Send the request
    var response = await request.send();

    // 5. Handle response
    if (response.statusCode == 200) {
      print("Uploaded!");
      final respStr = await response.stream.bytesToString();
      print(respStr);
    } else {
      print("Upload failed: ${response.statusCode}");
    }
  }
  void upload()async{
    final videoPath = storageRef.child("${nameController.text}.jpg");
    if(pickedVideo!=null){
      File file = File(pickedVideo!.path);
      uploadFile(file.path);
      return;
      try {
        await videoPath.putFile(file);
        String url = await videoPath.getDownloadURL();
        db.collection("videos").doc().set(
            {
              "name": nameController.text,
              "url":url
            }
        );
      } on FirebaseException catch (e) {
        // ...
      }
    }

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
        Container(
          width: 200,
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20)
                )
              ),
            )
        )
      ],
    );
  }
}
