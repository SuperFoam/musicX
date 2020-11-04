import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_x/provider/music_card.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/utils_function.dart';

class PlayerModel with ChangeNotifier{
  static PlayerModel _instance;

  PlayerModel._internal() {
    print("_PlayerModel internal");
  }

  static PlayerModel _getInstance() {
    if (_instance == null) {
      _instance = PlayerModel._internal();
    }
    return _instance;
  }

  factory PlayerModel() => _getInstance();

  static PlayerModel get instance => _getInstance();
  static const Color _icon = Colors.grey;
  List _songMode = [
    {'icon': const Icon(IconData(0xe802, fontFamily: 'playMode',),color: _icon,), 'tooltip': '顺序播放', 'key': 'order'},
    {'icon': const Icon(IconData(0xe60a, fontFamily: 'playMode'),color: _icon), 'tooltip': '随机播放', 'key': 'random'},
    {'icon': const Icon(IconData(0xe66d, fontFamily: 'playMode'),color: _icon), 'tooltip': '单曲循环', 'key': 'singleRepeat'},
    {'icon': const Icon(IconData(0xe66c, fontFamily: 'playMode'),color: _icon), 'tooltip': '列表循环', 'key': 'listRepeat'},
  ];
  List _playIcon = [
    {'icon': const Icon(Icons.play_circle_outline,size: 35,color: _icon), 'tooltip': '点击播放', 'key': 'play'},
    {'icon': const Icon(Icons.pause_circle_outline,size: 35,color: _icon), 'tooltip': '点击暂停', 'key': 'pause'},
  ];
  int _curModeIndex = 0;
  List _playList=[];
//  new List.generate(10, (index) => {'baseInfo':{ 'name': 'test$index',
//    'author': '作者$index',}});
  AudioPlayer _audioPlayer;
  Duration _curSongDuration=Duration(milliseconds: 0); // 当前歌曲时长
  AudioPlayerState _curState; // 播放器状态
  StreamController<Map> _curPositionController =
  StreamController<Map>.broadcast(); // 播放广播
  String _curSongTotal='00:00'; // 当前歌曲时长
  Map _curSong; // 当前播放歌曲
  double _curTime=0.0; // 当前歌曲时间，毫秒
  String _curTimeStr='00:00'; // 当前歌曲时间
  bool _isPlay = false; // 是否正在播放
  int _curSongIndex=0;
  List _nextPlay=[];

  Stream<Map> get curPositionStream => _curPositionController.stream;
  AudioPlayerState get curSongState => _curState;
  Map get curSong => _curSong;
  String get  curSongTotal => _curSongTotal;
  AudioPlayer get audioPlayer => _audioPlayer;
  Map get curSongMode => _songMode[_curModeIndex];
  bool get isPlay =>_isPlay;
  Map get playIcon => _isPlay?_playIcon[1]:_playIcon[0];
  String get curTimeStr => _curTimeStr;
  double get curTime => _curTime;
  Duration get curSongDuration => _curSongDuration;
  List get playList =>_playList;
  int get curSongIndex=>_curSongIndex;


  void init() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.STOP);
    _audioPlayer.onPlayerStateChanged.listen((state) {
      print('播放器状态变了 $state');
      _curState = state;
      if(state==AudioPlayerState.COMPLETED){
//        _isPlay=false;
//        int curTime = _curSongDuration.inMilliseconds;
//
//        sinkProgress(curTime,_curSongTotal);
        onPlayFinish();
      }
      /// 先做顺序播放
//      if (state == AudioPlayerState.COMPLETED) {}
//      // 其实也只有在播放状态更新时才需要通知。
      notifyListeners();
    });

    _audioPlayer.onAudioPositionChanged.listen((Duration p) { //进度条
      //print('Current position: $p');
      int curTime = p.inMilliseconds > _curSongDuration.inMilliseconds
          ? _curSongDuration.inMilliseconds
          : p.inMilliseconds;
      String minute = curTime/60000 <1?'00':(curTime/60000).truncate().toString().padLeft(2,'0');
      String second = (curTime/1000%60).truncate().toString().padLeft(2,'0').substring(0,2);
      String curTimeStr =minute+':'+second;
      _curTime = curTime.toDouble();
      _curTimeStr=curTimeStr;
      sinkProgress(curTime,curTimeStr);
    });

    _audioPlayer.onDurationChanged.listen((Duration d) { //音频时长
      if (d.inMinutes > 0)
        _curSongTotal = d.inMinutes.toString().padLeft(2, '0') +
            ':' +
            (d.inSeconds % (d.inMinutes * 60)).toString().padLeft(2, '0');
      else
        _curSongTotal = '00:' + d.inSeconds.toString().padLeft(2, '0');
     // print('获取音频时长 Max duration: $d,s is $curSongTotal');
      _curSongDuration = d;
    });
  }
  void sinkProgress(int m,String curTimeStr) {
   // print('管道添加数据 -${curTimeStr}---${m.toDouble()}--- $m-${_curSongDuration.inMilliseconds.toDouble()}');
    Map curProgress = {
      'curTime':m.toDouble(),
      'curTimeStr':curTimeStr,
      'totalTime':_curSongDuration.inMilliseconds.toDouble(),
      'totalTimeStr':_curSongTotal,
    };
    _curPositionController.sink.add(curProgress);
  }
  void onPlayFinish(){
    _isPlay=false;
    int curTime = _curSongDuration.inMilliseconds;
    sinkProgress(curTime,_curSongTotal);
    Future.delayed(const Duration(milliseconds: 300)).then((_)=>autoPlayNextSong());

  }
  Future<void> handleFileNotExist(Map songData) async{
    String id=songData['baseInfo']['id'];
    MyFavoriteSong.downloadSongDelete(id);
    MySongSheet.downloadSongDelete(id);
  }
  Future<int> playSong(Map songData,{int songIndex,List newPlayList,bool isLocal=false}) async {
    String msg = "不可操作";
    //_isPlay?msg='正在播放':msg='暂停播放';
    bool localNotExist=false;
    int result;
    if (songData!=null && songData != _curSong) {
      String url;
      //print('songData is$songData');
      if(songData['isDownload']==true || songData['isLocal']==true){
         url= songData['playInfo']!=null?songData['playInfo']['path']??songData['playInfo']['url']:null;

        if(url ==null || !File(url).existsSync()){
          localNotExist=true;
          url = songData['playInfo']!=null?songData['playInfo']['url']:null;
          handleFileNotExist(songData);
        }else{
          isLocal=true;
        }
      }else{
        url = songData['playInfo']!=null?songData['playInfo']['url']:null;
      }
      if (url != null) {
        print('播放地址：$url,是否本地-$isLocal');
        result = await _audioPlayer.play(url,isLocal: isLocal);
        if (result == 1) {
          _curSong = songData;
          _isPlay=true;
          if(songIndex !=null) _curSongIndex=songIndex;
          if(newPlayList!=null) _playList=newPlayList;
          if(!_playList.contains(songData)) {
            if(_playList.length==0)_playList.add(songData);
          else {
            _playList.insert(_curSongIndex+1, songData);
          _curSongIndex+=1;
          }
          }
          if(_nextPlay.contains(songData)){
            _nextPlay.remove(songData);
          }
          MusicCardModel().togglePlay(songData,'play');
          if(localNotExist==true) {
            msg='歌曲本地路径不存在 改用在线播放';
            result=404;
          }
          else msg = '正在播放';
        } else {
          msg = '播放失败';
        }
        notifyListeners();
      }else msg = '播放链接为空';
    }else if(songData!=null && songData == _curSong){
      result=2;
      if (_audioPlayer.state == AudioPlayerState.PAUSED) {
        _audioPlayer.resume();
        _isPlay=true;
        msg = '已恢复播放';
        MusicCardModel().togglePlay(songData,'play');
      } else if(audioPlayer.state == AudioPlayerState.COMPLETED){
        _audioPlayer.resume();
        msg = '已重新播放';
        _isPlay=true;
        MusicCardModel().togglePlay(songData,'play');
      }
      else {
        _audioPlayer.pause();
        _isPlay=false;
        msg = '已暂停播放';
        MusicCardModel().togglePlay(songData,'pause');
      }
    }
    Utils.showToast(msg);
    return result;
  }
  void switchMode(){
    ++_curModeIndex;
    if (_curModeIndex >= _songMode.length) _curModeIndex = 0;
    notifyListeners();
    Utils.showToast(_songMode[_curModeIndex]['tooltip']);
  }
  void pausePlay(){
    _audioPlayer.pause();
  }
  void seekPlay(int milliseconds) {
    _audioPlayer.seek(Duration(milliseconds: milliseconds));
    if(_isPlay) _audioPlayer.resume();
    else _audioPlayer.pause();
  }

  void playerAnimation(AnimationController controller){
    //print('_curState is $_curState');
    if(_curState == AudioPlayerState.PLAYING) controller.repeat();
    else  if(_curState == AudioPlayerState.PAUSED) controller.stop();
    else  if(_curState == AudioPlayerState.COMPLETED) {
      controller.reset();
      MusicCardModel().finishNotice(_curSong);
    }
  }
  void addPlayList(songData){
    if(!_playList.contains(songData)) _playList.add(songData);
  }
  void deletePlayItem(songData){
    if(_playList.contains(songData)) {
      _playList.remove(songData);
      Utils.showToast('移除成功');
      notifyListeners();
    }
  }

  void switchSong(Map songData,int index){
    if(songData==_curSong) return;
    playSong(songData,songIndex: index);
  }
  void autoPlayNextSong(){
    if(_nextPlay.length>0){
      playSong(_nextPlay.last);
      _nextPlay.removeLast();
      return;
    }
    String curMode = curSongMode['key'];
    int sumLength = _playList.length;
    int curIndex = _playList.indexOf(_curSong);
    int nextIndex;
    if(curMode=='order'){
      if(curIndex+1==sumLength){
        Utils.showToast('当前顺序播放已完成');
        return;
      }else {
        nextIndex = curIndex + 1;
      }
    }else if(curMode=='random'){
      if(sumLength==1) nextIndex=0;
      else  {
        while(true){
          nextIndex = Random().nextInt(sumLength);
          if(nextIndex!=curIndex) break;
        }
      }
    }else if(curMode=='singleRepeat'){
      nextIndex=curIndex;
    }else if(curMode=='listRepeat'){
      if(curIndex+1==sumLength) nextIndex=0;
      else nextIndex=curIndex+1;
    }
    playSong(_playList[nextIndex]);
  }
  void playNextSong(){
    if(_nextPlay.length>0){
      playSong(_nextPlay.last);
      _nextPlay.removeLast();
      return;
    }
    String curMode = curSongMode['key'];
    int sumLength = _playList.length;
    int curIndex = _playList.indexOf(_curSong);
    if(sumLength==1){
      Utils.showToast('当前播放列表仅有一首歌曲');
      return;
    }
    int nextIndex;
    if(curMode=='random'){
     while(true){
        nextIndex = Random().nextInt(sumLength);
       if(nextIndex!=curIndex) break;
     }
     playSong(_playList[nextIndex],songIndex: nextIndex);
    }else{
      if(curIndex+1==sumLength) nextIndex=0;
      else nextIndex=curIndex+1;
      playSong(_playList[nextIndex],songIndex: nextIndex);
    }
  }
  void playPreSong(){
    String curMode = curSongMode['key'];
    int sumLength = _playList.length;
    int curIndex = _playList.indexOf(_curSong);
    if(sumLength==1){
      Utils.showToast('当前播放列表仅有一首歌曲');
      return;
    }
    int nextIndex;
    if(curMode=='random'){
      while(true){
        nextIndex = Random().nextInt(sumLength);
        if(nextIndex!=curIndex) break;
      }
      playSong(_playList[nextIndex],songIndex: nextIndex);
    }else{
      if(curIndex==0) nextIndex=sumLength-1;
      else nextIndex=curIndex-1;
      playSong(_playList[nextIndex],songIndex: nextIndex);
    }
  }
  void favoriteSong(){
    if(_curSong['isFavorite']==true){
      bool res=MyFavoriteSong.deleteSong(_curSong);
      if(res==true){
        _curSong['isFavorite']=false;
        notifyListeners();
        MusicCardModel().collectSongNotice(_curSong);
        if(_curSong['isLocal']==true)
          LocalSong.favoriteSong(_curSong['baseInfo']['id']);
      }
    }else{
      bool res=MyFavoriteSong.addSong(_curSong);
      if(res==true){
        _curSong['isFavorite']=true;
        notifyListeners();
        MusicCardModel().collectSongNotice(_curSong);
        if(_curSong['isLocal']==true)
        LocalSong.favoriteSong(_curSong['baseInfo']['id']);
      }
    }
  }
  Future<void> downloadSong(Map songData) async {
      if(songData['isLocal']==true){
        Utils.showToast('当前歌曲不可下载');
        return;
      }
      if(songData['isDownload']==true){
        Utils.showToast('当前歌曲已经下载到本地');
        return;
      }
      bool res = await applyStoragePermanent();
      if(res==false) return;

  }
  void changeComment(String songId,String newComment ){
          if(songId==_curSong['baseInfo']['id']){
        _curSong['commentInfo']['content']=newComment;
        notifyListeners();
      }
//    String songId=songData['baseInfo']['id'];
//    bool res=MyFavoriteSong.changeComment(songId, newComment);
//    if(res==true){
//      MySongSheet.changeComment(songId, newComment);
//      if(songId==_curSong['baseInfo']['id']){
//        _curSong['commentInfo']['content']=newComment;
//        notifyListeners();
//      }
//      Utils.showToast('替换成功');
//    }

  }
  void addNextPlay(Map songData){
    if(songData['baseInfo']['id']=="9527"){
      Utils.showToast('不可添加');
      return;
    }
    if(_playList.length==0){
      Utils.showToast('当前没有播放列表');
      return;
    }
    if(_playList.contains(songData)) {
        _playList.remove(songData);
    }
    _playList.insert(_curSongIndex+1, songData);
    if(!_nextPlay.contains(songData))
    {
      _nextPlay.add(songData);
      Utils.showToast('添加到下一首播放成功');
    }
    else
      Utils.showToast('歌曲已经添加到下一首播放');
  }

  @override
  Future<void> dispose() async {
    _curPositionController.close();
    await _audioPlayer.release();
    super.dispose();
    //await _audioPlayer.dispose();
  }


}
