import 'dart:io';

class MusicModel {
  final String musicName;
  final DateTime changed, acessed, modified;
  final FileSystemEntityType fileType;
  final int fileSize;
  final String musicPath;

  MusicModel(
    this.musicName,
    this.changed,
    this.acessed,
    this.modified,
    this.fileType,
    this.fileSize,
    this.musicPath,
  );
}
