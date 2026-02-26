import 'package:flutter/material.dart';
import 'package:soccer_app/pages/library.dart';
import 'package:soccer_app/pages/settings.dart';
import 'package:soccer_app/pages/upload.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  String a = "hello";
  int _selectedIndex = 0;
  List<String> titles = ['Upload', 'Library', 'Settings'];
  List<Widget> pages = [UploadPage(), LibraryPage(), SettingsPage()];

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
      body: Center(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_sharp),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_add_check),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
