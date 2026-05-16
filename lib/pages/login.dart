import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController=TextEditingController();
  final passwordController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Soccer App",style: TextStyle(fontSize: 50),),
              Card(
                child: SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      Container(
                          width: 200,
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)
                                )
                            ),
                          )
                      ),
                      Container(
                          width: 200,
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)
                                )
                            ),
                          )
                      ),
                      ElevatedButton(
                          onPressed: (){
                            FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
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
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
    );
  }
}
