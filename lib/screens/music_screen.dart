import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ratus/viewmodels/get_all_audio_files.dart';
import 'package:rxdart/rxdart.dart';

import '../models/music_model.dart';
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
  final _player = AudioPlayer();
  String permissionStatus = "notGranted";
  ScrollController _scrollController = ScrollController();
  final player = AudioPlayer(); // Create a player
  var duration;
  GetSongsVM songsVM = GetSongsVM();
  bool musicPlaying = false;

  void setPlayUrl(String url) async {
    duration = await player.setUrl(url);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  // bool get wantKeepAlive => throw UnimplementedError();
  bool get wantKeepAlive => true;

  Future<void> _init(String filePath) async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    // Try to load audio from a source and catch any errors.
    try {
      // AAC example: https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac
      // _player.setAsset('assets/audio/ff-16b-2c-44100hz.aac');
      await _player.setAudioSource(AudioSource.uri(Uri.parse("$filePath")));
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

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
            SizedBox(
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
            SizedBox(
              child: Column(
                children: [
                  Expanded(
                    child: FutureBuilder(
                      future: songsVM.getAllAudioFilesAndroid(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<MusicModel>> audioSnapshot) {
                        if (audioSnapshot.connectionState ==
                            ConnectionState.done) {
                          List<MusicModel> snapshotData =
                              audioSnapshot.data == null
                                  ? []
                                  : audioSnapshot.data!;
                          // List<String> songNames = [];
                          // for(var singleSong in snapshotData){

                          // }
                          snapshotData
                              .sort((a, b) => a.modified.compareTo(b.modified));

                          debugPrint(
                              "Length of list: ${snapshotData.length}. permission status is $permissionStatus ");
                          return DraggableScrollbar.semicircle(
                            labelTextBuilder: (offset) {
                              final int currentItem =
                                  _scrollController.hasClients
                                      ? (_scrollController.offset /
                                              _scrollController
                                                  .position.maxScrollExtent *
                                              snapshotData.length)
                                          .floor()
                                      : 0;

                              return Text("$currentItem");
                            },
                            labelConstraints: const BoxConstraints.tightFor(
                                width: 80.0, height: 30.0),
                            controller: _scrollController,
                            child: ListView.builder(
                                controller: _scrollController,
                                itemCount: snapshotData.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    onTap: () {
                                      setPlayUrl(snapshotData[index].musicPath);
                                      player.play();
                                    },
                                    leading: const Icon(
                                      Icons.music_note_outlined,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    title: Text(
                                      snapshotData[index].musicName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }),
                          );
                        }
                        return const CircularProgressIndicator(
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 55.0,
                  ),
                ],
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
