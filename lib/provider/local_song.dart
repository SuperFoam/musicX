import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:permission_handler/permission_handler.dart';
class LocalSongModel with ChangeNotifier{
  List _localSong=[];
  LinkedHashMap _localSongMap;
  String _sortType="timeZ_A";

  List get localSong=>_localSong;
  String get sortType =>_sortType;

  void init({String sortType}){
    _localSongMap = LocalSong.getData();
    if(sortType=='timeZ_A')
      _localSong=_localSongMap.values.toList().reversed.toList();
    else if(sortType=='timeA_Z')
      _localSong=_localSongMap.values.toList();
    else if(sortType=='nameA_Z')
      _localSong=sortName(_localSongMap.values.toList());
    else
      _localSong=_localSongMap.values.toList().reversed.toList();
    if(sortType!=null) _sortType=sortType;
    else _sortType="timeZ_A";
    notifyListeners();
  }
  List sortName(List a){
    a.sort((a, b) => PinyinHelper.getShortPinyin(a['baseInfo']['name']).
    compareTo(PinyinHelper.getShortPinyin(b['baseInfo']['name'])));
    Utils.showToast('排序完成');
    return a;

  }
  void scanMusic( ) async {
    var status = await Permission.storage.status;
    if (status.isPermanentlyDenied) {
      Utils.showToast('权限被永久拒绝');
      openAppSettings();
      return;
    }
    if (!status.isGranted) {
      if (!await Permission.storage.request().isGranted) {
        Utils.showToast('权限申请失败');
        return;
      }
    }

    LinkedHashMap<String, dynamic> songList = LinkedHashMap();
    Future<void> scan(Stream<FileSystemEntity> fileList)async{
      await fileList.forEach((e) {
        File element;
        bool isFile = FileSystemEntity.isFileSync(e.path);
        if (isFile == true) {
          element = e;
        } else
          return;
        String songInfo = element.path.split('/').last;
        String songName = songInfo.split('.').first;
        if (songInfo.split('.').last == 'mp3') {
          String author = songName.split('-').first.trim();
          String name = songName.split('-').last.trim();
          int size = element.lengthSync();
          String key = element.path;
          if (!_localSongMap.containsKey(key)) {
            Map songData = {
              "isLocal": true,
              'baseInfo': {
                'name': name,
                'author': author,
                'id': key,
                'picUrl': null,
              },
              'playInfo': {'url': key, 'br': '128000', 'size': size},
              'commentInfo': {
                'name': 'dreamfly',
                'content': '暂无热评',
                "likedCount": 32
              },
              'isFavorite': false,
            };
            songList[key] = songData;
          }

          //songList.add(songData);
        }
      });
    }
    String dir1 = Constant.localWYYPath;
    String dir2 = Constant.downloadSongPath;
    Directory music1 = Directory(dir1);
    Directory music2 = Directory(dir2);
    if (!(music1.existsSync() || music2.existsSync())) {
      Utils.showToast('网易云音乐路径不存在');
      return;
    }
    Stream<FileSystemEntity> fileList = music1.list(followLinks: false);
    Stream<FileSystemEntity> fileList2 = music2.list(followLinks: false);
    if(music1.existsSync()) await scan(fileList);
    if(music2.existsSync()) await scan(fileList2);
    if (songList.length > 0) {
      LocalSong.addSong(songList);
      Utils.showToast('共添加${songList.length}首歌曲');
      init();
    } else
      Utils.showToast('未扫描到新的歌曲');
  }
  bool deleteSong(Map songData){
    bool res= LocalSong.delete(songData['baseInfo']['id']);
    if(res==true) init(sortType:_sortType);
    return res;
  }
  void sortSongList(String sort) {
    init(sortType:sort );
  }
}
