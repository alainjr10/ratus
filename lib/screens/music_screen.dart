import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

import '../utils/constants.dart';
import 'just_audio_utils/common.dart';

class MusicScreen extends StatefulWidget {
  static const musicScreenId = '/music_screen';
  const MusicScreen({Key? key}) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen>
    with AutomaticKeepAliveClientMixin<MusicScreen> {
  // TabController tabController = TabController();
  final _player = AudioPlayer();
  String permissionStatus = "notGranted";
  final Permission _permission = Permission.storage;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  @override
  void initState() {
    super.initState();
    // requestPermission(_permission);
    // _init();
    // getDir();
    // returnFilesAfterPermissionGrant();
    // getAllAudioAndroidFiles();
    // requestPermission(_permission);
  }

  @override
  // bool get wantKeepAlive => throw UnimplementedError();
  bool get wantKeepAlive => true;

  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      permissionStatus = "Granted";
      debugPrint("Permission already granted");
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        debugPrint("Permission already granted");
        permissionStatus = "Granted";
        return true;
      }
    }
    debugPrint(
        "Permission status: $permissionStatus the permission has not been granted. why");
    permissionStatus = "notGranted";
    return false;
  }

  // List<FileSystemEntity> _folders = [];
  // Future<List<FileSystemEntity>> getDir() async {
  //   try {
  //     if (Platform.isAndroid) {
  //       if (await requestPermission(Permission.storage)) {
  //         directory = await getExternalStorageDirectory();
  //         String newPath = "";
  //         debugPrint("directory is: ${directory!.path}");
  //         debugPrint("And the permission status is: $permissionStatus");

  //         /// Section below is to get the full path to the application folder, and split it before we have /Android
  //         /// then create our file path with the lefter part of the splitted path, something like /storage/emulated/0/{new file path}
  //         List<String> paths = directory!.path.split("/");
  //         for (int x = 1; x < paths.length; x++) {
  //           String folder = paths[x];
  //           if (folder != "Android") {
  //             newPath += "/" + folder;
  //           } else {
  //             break;
  //           }
  //         }
  //         // String pathSuffix = returnAdjustedPathLevel() == "OLevel"
  //         //     ? "Ordinary Level"
  //         //     : "Advanced Level";
  //         //newPath = newPath + "/Edutive/Files/$pathSuffix";
  //         newPath = newPath + "/Edutive/Files";
  //         directory = Directory(newPath);
  //         debugPrint("new path is: ${directory!.path}");
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Platform Exception thrown: $e");
  //   }
  //   //setState(() {
  //   /// Here, we get all the folders and files from the given directory and add to the list _folders
  //   // save all files in the directory to _folders variable
  //   _folders = directory!.listSync(recursive: true, followLinks: false);
  //   // });

  //   debugPrint("Files and folders found in this directory are: $_folders");

  //   /// Section to calculate the number of Files (only files, not directories) and then return only files from our whole function, no directories

  //   List<FileSystemEntity> tempList = [];
  //   // final vall = await getHiveContent();
  //   // for (int j = 0; j < vall.length; j++) {
  //   //   for (int i = 0; i < _folders.length; i++) {
  //   //     if (!isDirectory(_folders[i]) && _folders[i].path.contains(vall[j])) {
  //   //       tempList.add(_folders[i]);
  //   //       debugPrint(
  //   //           "From GETDIR function. File encountered: name of file: ${_folders[i].path.split('/').last}");
  //   //       debugPrint("The length: ${vall.length}");
  //   //       //  continue;
  //   //     } else {
  //   //       debugPrint(
  //   //           "From GETDIR function. Directory encounterd: type : ${_folders[i].path.split('/').last}");
  //   //     }
  //   //   }
  //   // }

  //   return tempList;
  // }

  void returnFilesAfterPermissionGrant() async {
    try {
      if (Platform.isAndroid) {
        if (await requestPermission(Permission.storage)) {
          debugPrint("Permission granted");
          getAllAudioFilesAndroid();
        }
      }
    } catch (e) {
      debugPrint("Caught an exveption: $e");
    }
  }

  Directory? directory;

  Future<List<FileSystemEntity>> getAllAudioFilesAndroid() async {
    directory = await getExternalStorageDirectory();
    String newPath = "";
    debugPrint("directory is: ${directory!.path}");
    debugPrint("And the permission status is: $permissionStatus");

    /// Section below is to get the full path to the application folder, and split it before we have /Android
    /// then create our file path with the lefter part of the splitted path, something like /storage/emulated/0/{new file path}
    List<String> paths = directory!.path.split("/");
    for (int x = 1; x < paths.length; x++) {
      String folder = paths[x];
      if (folder != "Android") {
        newPath += "/" + folder;
      } else {
        break;
      }
    }
    directory = Directory(newPath);
    debugPrint("new path is: ${directory!.path}");

    String mp3Path = directory!.toString();
    print("mp3 path: $mp3Path");
    List<FileSystemEntity> _files;
    List<FileSystemEntity> _songs = [];
    _files = directory!.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity entity in _files) {
      String path = entity.path;
      if (path.startsWith('/storage/emulated/0/Android') ||
          path.startsWith('/storage/emulated/0/Notifications')) {
        continue;
      }
      if (path.endsWith('.mp3')) _songs.add(entity);
    }
    print(_songs);
    print(_songs.length);
    debugPrint("Song in position 230 = ${_songs[230].path}");

    return _songs;
  }

  // Future<void> _init() async {
  //   // Inform the operating system of our app's audio attributes etc.
  //   // We pick a reasonable default for an app that plays speech.
  //   final session = await AudioSession.instance;
  //   await session.configure(const AudioSessionConfiguration.speech());
  //   // Listen to errors during playback.
  //   _player.playbackEventStream.listen((event) {},
  //       onError: (Object e, StackTrace stackTrace) {
  //     print('A stream error occurred: $e');
  //   });
  //   // Try to load audio from a source and catch any errors.
  //   try {
  //     // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
  //     _player.setAsset('assets/audio/ff-16b-2c-44100hz.aac');
  //     await _player.setAudioSource(AudioSource.uri(Uri.parse(
  //         "https://firebasestorage.googleapis.com/v0/b/kropco-bc094.appspot.com/o/All%20Nations%20Music%20-%20Bless%20Your%20Name%20(Official%20Music%20Video)%20ft.%20Chandler%20Moore.mp3?alt=media&token=1c0a4485-d062-4d6e-a22c-b3daa31b2907")));
  //   } catch (e) {
  //     print("Error loading audio source: $e");
  //   }
  // }

  @override
  void dispose() {
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _player.stop();
    }
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ratus', style: kAppBarMainHeadingStyle),

          /// The actions (Icons on the right of the appbar)
          actions: musicScreenActions,
          bottom: PreferredSize(
            preferredSize: Size(size.width, 45.0),
            child: const MusicScreenBottomAppBar(),
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display play/pause button and volume/speed sliders.
                  ControlButtons(_player),
                  // Display seek bar. Using StreamBuilder, this widget rebuilds
                  // each time the position, buffered position or duration changes.
                  StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return SeekBar(
                        duration: positionData?.duration ?? Duration.zero,
                        position: positionData?.position ?? Duration.zero,
                        bufferedPosition:
                            positionData?.bufferedPosition ?? Duration.zero,
                        onChangeEnd: _player.seek,
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              child: FutureBuilder(
                future: getAllAudioFilesAndroid(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<FileSystemEntity>> audioSnapshot) {
                  if (audioSnapshot.connectionState == ConnectionState.done) {
                    List<FileSystemEntity> snapshotData =
                        audioSnapshot.data == null ? [] : audioSnapshot.data!;

                    debugPrint(
                        "Length of list: ${snapshotData.length}. permission status is $permissionStatus ");
                    return ListView.builder(
                        itemCount: snapshotData.length,
                        itemBuilder: (context, index) {
                          List splittedPath =
                              snapshotData[index].path.split('/');
                          return ListTile(
                            title: Text(
                              splittedPath.last.split('mp3').first,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        });
                  }
                  return CircularProgressIndicator(
                    color: Colors.white,
                  );
                },
              ),
            ),
            Container(
              child: Text(
                "Third Tab",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              child: Text(
                "Fourth tab",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              child: Text(
                "Yokak",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Opens volume slider dialog
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              value: player.volume,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        Container(
          color: Colors.white,
          child: StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 64.0,
                  height: 64.0,
                  child: const CircularProgressIndicator(),
                );
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(
                    Icons.play_arrow,
                  ),
                  iconSize: 64.0,
                  onPressed: player.play,
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(Icons.pause),
                  iconSize: 64.0,
                  onPressed: player.pause,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.replay),
                  iconSize: 64.0,
                  onPressed: () => player.seek(Duration.zero),
                );
              }
            },
          ),
        ),
        // Opens speed slider dialog
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: player.speed,
                stream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}

List<MusicScreenActionsWidget> musicScreenActions = [
  MusicScreenActionsWidget(
    icon: Icons.notifications_outlined,
    onTap: () {},
  ),
  MusicScreenActionsWidget(
    icon: Icons.settings_outlined,
    onTap: () {},
  ),
];

class MusicScreenActionsWidget extends StatelessWidget {
  const MusicScreenActionsWidget({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);
  final IconData icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: 28.0,
      ),
      onPressed: onTap,
    );
  }
}

class MusicScreenBottomAppBar extends StatelessWidget {
  const MusicScreenBottomAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 45.0,
      child: TabBar(
        isScrollable: true,
        indicatorColor: kPrimaryColor,
        indicatorWeight: 3.0,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: kPrimaryColor,
        unselectedLabelColor: kSecondaryColor,
        labelStyle: TextStyle(fontSize: 16.0),
        unselectedLabelStyle: TextStyle(fontSize: 15.0),
        tabs: [
          Tab(
            text: 'Tracks',
          ),
          Tab(
            text: 'Artists',
          ),
          Tab(
            text: 'Albums',
          ),
          Tab(
            text: 'Playlists',
          ),
          Tab(
            text: 'Folders',
          ),
        ],
        // controller: tabController,
      ),
    );
  }
}
