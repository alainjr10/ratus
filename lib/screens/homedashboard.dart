import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ratus/screens/homescreen.dart';
import 'package:ratus/utils/constants.dart';

class HomeDashboard extends StatefulWidget {
  static const homeDashboardId = '/homedashboard';
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
  ];
  void updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex == 0) return true;
        setState(() {
          _currentIndex = 0;
        });
        return false;
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kSecondaryColor,
          selectedFontSize: 11.0,
          unselectedFontSize: 10.0,
          iconSize: 22.0,
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold, color: kSecondaryColor),
          unselectedLabelStyle: const TextStyle(color: kSecondaryColor),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.audiotrack_outlined), label: 'Music'),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.video), label: 'Video'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(Icons.my_library_music_outlined), label: 'Library'),
          ],
          currentIndex: _currentIndex,
          onTap: updateIndex,
        ),
      ),
    );
  }
}
