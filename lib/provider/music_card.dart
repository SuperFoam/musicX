import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/music.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:oktoast/oktoast.dart';
import 'package:bot_toast/bot_toast.dart';

class MusicCardModel with ChangeNotifier {
  static MusicCardModel _instance;

  MusicCardModel._internal() {
    print("_internal");
  }

  static MusicCardModel _getInstance() {
    if (_instance == null) {
      _instance = MusicCardModel._internal();
    }
    return _instance;
  }

  factory MusicCardModel() => _getInstance();

  static MusicCardModel get instance => _getInstance();
  List _modes = [
    {'icon': Icons.music_note, 'tooltip': '原创模式', 'key': 'original'},
    {'icon': Icons.fiber_new, 'tooltip': '新歌模式', 'key': 'new'},
    {'icon': Icons.whatshot, 'tooltip': '热歌模式', 'key': 'hot'},
    {'icon': Icons.trending_up, 'tooltip': '飙升模式', 'key': 'hurry'},
    {'icon': Icons.toys, 'tooltip': '随机模式', 'key': 'random'},
  ];
  List _likeList = [
    {'icon': Icons.favorite_border, 'tooltip': '未收藏'},
    {'icon': Icons.favorite, 'tooltip': '已收藏'},
  ];
  List _playList = [
    {'icon': Icons.play_circle_outline, 'tooltip': '未播放', 'key': 'pause'},
    {'icon': Icons.pause_circle_outline, 'tooltip': '正在播放', 'key': 'play'},
  ];
  List _songMode = [
    {'icon': const Icon(IconData(0xe802, fontFamily: 'playMode')), 'tooltip': '顺序播放', 'key': 'order'},
    {'icon': const Icon(IconData(0xe60a, fontFamily: 'playMode')), 'tooltip': '随机播放', 'key': 'random'},
    {'icon': const Icon(IconData(0xe66d, fontFamily: 'playMode')), 'tooltip': '单曲循环', 'key': 'singleRepeat'},
    {'icon': const Icon(IconData(0xe66c, fontFamily: 'playMode')), 'tooltip': '列表循环', 'key': 'listRepeat'},
  ];
  static String placeImageUrl =
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1594097019353&di="
      "5840a307f0da8052bb5c7c1005079f7b&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com"
      "%2Fq_70%2Cc_zoom%2Cw_640%2Fimages%2F20180415%2F0613bf541b354a4098bf2ddc9266e238.jpeg";

  int _curModeIndex = 0;
  bool _isLike = false;
  bool _isPlay = false;
  int _songID = 0;
  Map<String,dynamic> _songData = {
    'baseInfo': {
      'name': '南山南',
      'author': '马頔',
      'id': "9527",
      'picUrl': placeImageUrl
    },
    'playInfo': {},
    'commentInfo': {'name': 'dreamfly', 'content': '你任何为人称道的美丽,不及第一次遇见你',"likedCount":32},
    'isFavorite':false,
  };
  bool _isFirst = true;

  Map get curMode => _modes[_curModeIndex];

  Map get likeMode => _isLike ? _likeList[1] : _likeList[0];

  Map get playMode => _isPlay ? _playList[1] : _playList[0];
  Map get songMode => _songMode[0];

  int get songID => _songID;

  Map get songData => _songData;
  bool get isFirst => _isFirst;


  void nextMode() {
    ++_curModeIndex;
    if (_curModeIndex >= _modes.length) _curModeIndex = 0;
    //showToast(_modes[_curModeIndex]['tooltip'],animationBuilder: OffsetAnimationBuilder(),animationCurve: Curves.easeInOut,);
    BotToast.showText(
        text: _modes[_curModeIndex]['tooltip'],
        align: Alignment.center,
        contentColor: Colors.black);
    notifyListeners();
  }

  void likeSong() {
    String msg;
    _isLike = !_isLike;
    _isLike ? msg = '添加收藏' : msg = '取消收藏';
    //showToast(msg);
    if(_isLike==true){
      _songData['isFavorite']=true;
      bool res=MyFavoriteSong.addSong(_songData);
      if(res==true){
        notifyListeners();
      }
    }
    else{
      _songData['isFavorite']=false;
      bool res=MyFavoriteSong.deleteSong(_songData);
      if(res==true){
        notifyListeners();
      }
    }

  }


  Future<void> nextSong() async {
    //++_songID;
//    Future.delayed(const Duration(milliseconds: 5000));
//    notifyListeners();
    //var songData2= await WYMusic(curMode['key']).getRandomSong();
    Map<String,dynamic> songData2;
    try {
      songData2 = await WYMusic(curMode['key']).getNextSong();
    }catch(e){
      songData2={};
    }
    print('songData is --$songData2,${songData2==null}');

    String msg = '刷新成功';
    if (songData2 !=null && songData2.length!=0 && songData2['baseInfo']['id'] != _songData['baseInfo']['id']) {
      _songData = songData2;
      _songData['isNetwork']=true;
      _isLike = false;
      MyFavoriteSong.isFavorite(songData2['baseInfo']['id']).then((value){
        if(value==true){
          _isLike = true;
          _songData['isFavorite']=true;
          notifyListeners();
        }
      });
      _isPlay = false;
      notifyListeners();
    } else
      msg = '刷新失败！';
    Utils.showToast(msg);
  }

  void finishNotice(songData){
    if (songData==_songData) _isPlay=false;
  }
  void collectSongNotice(Map data){
    if(data['baseInfo']['id']==_songData['baseInfo']['id']){
      _isLike=!_isLike;
      notifyListeners();
    }
  }
  void togglePlay(Map songData,String status){
    if(songData['baseInfo']['id']!=_songData['baseInfo']['id']) {
      _isPlay=false;
      return;
    }
    if(status=='play') _isPlay=true;
    else if(status=='pause') _isPlay=false;

  }

}
