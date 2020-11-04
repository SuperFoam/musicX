import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/utils_function.dart';
import 'player.dart';

import 'music_card.dart';

class SongSheetModel with ChangeNotifier {
//  static SongSheetModel _instance;
//
//  SongSheetModel._internal() {
//    print("_SongSheetModel internal");
//  }
//
//  static SongSheetModel _getInstance() {
//    if (_instance == null) {
//      _instance = SongSheetModel._internal();
//    }
//    return _instance;
//  }
//
//  factory SongSheetModel() => _getInstance();
//
//  static SongSheetModel get instance => _getInstance();

  List _songList = [];
  List _originSongList = [];
  String _sheetName = "未知";
  int _sheetID;
  Map _sheetInfo;
  String _sortType = "timeZ_A";

  List get songList => _songList;

  List get originSongList => _originSongList;

  String get sheetName => _sheetName;

  String get sortType => _sortType;

  void init(Map sheet, {String sortType}) {
    if (sheet['id'] == 0) {
      Map t = MyFavoriteSong.getData();
      // _songList=t['song'];
      _originSongList = t['song'].values.toList();
      List topSongList = t['topSong'].values.toList().reversed.toList();
      sortSong(t, sortType);
      _songList.insertAll(0, topSongList);
      _sheetName = t['name'];
      _sheetInfo = t;
    } else {
      getMySongSheet(sheet, sortType);
    }
    if (sortType != null)
      _sortType = sortType;
    else
      _sortType = "timeZ_A";
    _sheetID = sheet['id'];
    notifyListeners();
  }

  void sortSong(Map t, String sortType) {
    if (sortType == 'timeZ_A')
      _songList = t['song'].values.toList().reversed.toList();
    else if (sortType == 'timeA_Z')
      _songList = t['song'].values.toList();
    else if (sortType == 'nameA_Z'){
      _songList=sortName(t['song'].values.toList());
    }

    else
      _songList = t['song'].values.toList().reversed.toList();
  }

  List sortName(List list) {
   // list.sort((a, b) => PinyinHelper.getShortPinyin(a['baseInfo']['name']).toLowerCase().compareTo(PinyinHelper.getShortPinyin(b['baseInfo']['name']).toLowerCase()));
    list.sort((a, b) {
      try {
        return PinyinHelper.getShortPinyin(a['baseInfo']['name']).toLowerCase().compareTo(PinyinHelper.getShortPinyin(b['baseInfo']['name']).toLowerCase());
      }catch (e){
        return -1;
      }
    });

    return list;
  }

  void getMySongSheet(Map sheet, String sortType) {
    List d = MySongSheet.getData();
    for (int i = 0; i < d.length; i++) {
      if (d[i]['id'] == sheet['id'] && d[i]['create'] == sheet['create']) {
        // _songList=d[i]['song'];
        _originSongList = d[i]['song'].values.toList();
        sortSong(d[i], sortType);
        //_songList=d[i]['song'].values.toList();
        _sheetName = d[i]['name'];
        _sheetInfo = d[i];
        break;
      }
    }
  }

  bool deleteSong(Map songData) {
    bool res;
    if (_sheetID == 0)
      res = MyFavoriteSong.deleteSong(songData);
    else
      res = MySongSheet.deleteSong(_sheetInfo, songData);
    if (res == true && _sheetID == 0) MusicCardModel().collectSongNotice(songData);
    init(_sheetInfo, sortType: _sortType);
    return res;
//    if (res==true){
//      if(_sheetID==0) {
//        sortSong(MyFavoriteSong.getData(), _sortType);
//        //_songList=MyFavoriteSong.getData()['song'].values.toList();
//        MusicCardModel().collectSongNotice(songData);
//      }
//      else   {
//        getMySongSheet(_sheetInfo,_sortType);
//
//      }//MySongSheet.getData()[_sheetID-1]['song'];
//      notifyListeners();
//
//      return true;
//    }
//      return false;
  }

  bool batchDeleteSong(List songList) {
    bool res;
    if (_sheetID == 0)
      res = MyFavoriteSong.batchDeleteSong(songList);
    else
      res = MySongSheet.batchDeleteSong(_sheetInfo, songList);
    if (res == true && _sheetID == 0)
      songList.forEach((songData) {
        MusicCardModel().collectSongNotice(songData);
      });
    init(_sheetInfo, sortType: _sortType);
    return res;
//    if (res==true){
//      if(_sheetID==0) {
//        sortSong(MyFavoriteSong.getData(), _sortType);
//        //_songList=MyFavoriteSong.getData()['song'].values.toList();
//        songList.forEach((songData) {
//          MusicCardModel().collectSongNotice(songData);
//        });
//
//      }
//      else   {
//        getMySongSheet(_sheetInfo,_sortType);
//
//      }//MySongSheet.getData()[_sheetID-1]['song'];
//      notifyListeners();
//
//      return true;
//    }
//    return false;
  }

  void refresh() {
    if (_sheetInfo != null) init(_sheetInfo);
  }

  void sortSongList(String sort) {
    init(_sheetInfo, sortType: sort);
  }

  Future<void> moveSongOrder(List songList) async {
    if (_sheetID == 0) {
      MyFavoriteSong.newSongOrder(songList);
      sortSong(MyFavoriteSong.getData(), _sortType);
    } else {
      MySongSheet.newSongOrder(_sheetInfo, songList);
      getMySongSheet(_sheetInfo, _sortType);
    }
    if (_sortType == 'timeZ_A') notifyListeners();
  }

  void changeComment(Map songData, String newComment, int count, String user) {
    if (_sheetID == null) {
      Utils.showToast('不可替换');
      return;
    }
    String songId = songData['baseInfo']['id'];
    bool res;
    if (_sheetID == 0) {
      res = MyFavoriteSong.changeComment(songId, newComment, count, user);
    } else {
      res = MySongSheet.changeComment(_sheetInfo, songId, newComment, count, user);
    }
    if (res == true) {
      PlayerModel().changeComment(songId, newComment);
      refresh();
      Utils.showToast('替换成功');
    }
  }

  void setTopSong(Map songData) {
    if (_sheetID != 0) {
      Utils.showToast('不可置顶');
      return;
    }
    songData['isTop'] = true;
    bool res = MyFavoriteSong.addTopSong(songData);
    if (res) refresh();
  }

  void cancelTopSong(Map songData) {
    if (_sheetID != 0) {
      Utils.showToast('不可操作');
      return;
    }
    songData['isTop'] = false;
    bool res = MyFavoriteSong.cancelTopSong(songData);
    if (res) refresh();
  }
}
