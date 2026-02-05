import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String a="hello";
  int _selectedIndex=0;
  List<String> titles=['home','business','school'];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(titles[_selectedIndex]),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(a),
              ],
            ),
            ElevatedButton(onPressed: (){
              setState(() {
                a+="hello";
              });
            }, child: Icon(Icons.water))
          ],
        ),
      ),
      bottomNavigationBar:  BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Business'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'School'),

        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      )
    );
  }
}
