import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ratus/viewmodels/request_permission.dart';

import '../models/music_model.dart';

class GetSongsVM {
  Directory? directory;

  Future<List<MusicModel>> getAllAudioFilesAndroid() async {
    if (await RequestPermission().requestPermission(Permission.storage)) {
      directory = await getExternalStorageDirectory();
      String newPath = "";
      debugPrint("directory is: ${directory!.path}");

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
      List<MusicModel> _songInfo = [];
      _files = directory!.listSync(recursive: true, followLinks: false);
      for (FileSystemEntity entity in _files) {
        FileStat songEntity = entity.statSync();
        String path = entity.path;

        if (path.startsWith('/storage/emulated/0/Android') ||
            path.startsWith('/storage/emulated/0/Notifications')) {
          continue;
        }
        if (path.endsWith('.mp3')) {
          String songName = path.split("/").last.split('.mp3').first;
          _songs.add(entity);
          _songInfo.add(
            MusicModel(
              songName,
              songEntity.changed,
              songEntity.accessed,
              songEntity.modified,
              songEntity.type,
              songEntity.size,
              path,
            ),
          );
        }
      }
      print(_songs);
      print(_songs.length);
      debugPrint(
          "Song in position 230 = ${_songs[230].path} and ent is ${_songInfo[230].musicName} ");

      return _songInfo;
    }
    return [];
  }
}
