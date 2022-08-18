import 'package:flutter/material.dart';
import 'package:ratus/screens/library_screen.dart';
import 'package:ratus/screens/music_screen.dart';

import '../screens/homedashboard.dart';
import '../screens/homescreen.dart';
import '../screens/search_screen.dart';
import '../screens/video_screen.dart';

var customRoutes = <String, WidgetBuilder>{
  HomeDashboard.homeDashboardId: (BuildContext context) =>
      const HomeDashboard(),
  HomeScreen.homeScreenId: (BuildContext context) => const HomeScreen(),
  Library.libraryScreenId: (BuildContext context) => const Library(),
  MusicScreen.musicScreenId: (BuildContext context) => const MusicScreen(),
  SearchScreen.searchScreenId: (BuildContext context) => const SearchScreen(),
  VideoScreen.videoScreenId: (BuildContext context) => const VideoScreen(),
};
