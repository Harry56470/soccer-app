import 'package:flutter/material.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [
        Text("Analyze Soccer Match",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
        SizedBox(height: 70,),
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
        ElevatedButton(onPressed: (){}, child: SizedBox(
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Choose From Library",style: TextStyle(fontSize: 15),),
              Icon(Icons.library_add,size: 30,)
            ],
          ),
        )),
      ],
    );
  }
}
