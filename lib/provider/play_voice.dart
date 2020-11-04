import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/utils/utils_function.dart';
class VoicePlayerProvider extends ChangeNotifier{
  String _msgId;
  int _voiceDuration;
  StreamController<int> _curPositionController =
  StreamController<int>.broadcast();
  FlutterSoundPlayer _playerModule ;
  StreamSubscription _playerSubscription;
  String get msgId =>_msgId;
  int get voiceDuration =>_voiceDuration;
  StreamController get curPositionController=>_curPositionController;

  void init() async{
    _playerModule = await FlutterSoundPlayer().openAudioSession(focus: AudioFocus.requestFocusAndStopOthers,  device: AudioDevice.speaker);
    await _playerModule.setSubscriptionDuration(Duration(milliseconds: 250));
    _playerSubscription = _playerModule.onProgress.listen((e) {
      if (e != null) {
        int curTime = e.position.inMilliseconds;
        _curPositionController.sink.add(curTime);


      }
    });
  }

 void  playVoice(EMMessage message) async{
    if (message.type != EMMessageType.VOICE){
      Utils.showToast('非语音消息');
      return;
    }
    if( _msgId!=message.msgId)
      playNewVoice(message);
    else
      togglePlayVoice();

  }
  void togglePlayVoice(){
    if(_playerModule.isPlaying)_playerModule.pausePlayer();
    else if(_playerModule.isPaused)_playerModule.resumePlayer();

  }
  void playNewVoice(EMMessage message)async {
    EMVoiceMessageBody msg = message.body;
    String localUrl = msg.localUrl;
    if(localUrl!=null && File(localUrl).existsSync()){
      await _playerModule.startPlayer(fromURI: localUrl,whenFinished:handelPlayDone);
    }else{
      String remoteUrl = msg.remoteUrl;
      if(remoteUrl==null){
        Utils.showToast('远程播放地址为空');
        return;
      }
      await _playerModule.startPlayer(fromURI: remoteUrl,whenFinished:handelPlayDone);
    }
    _msgId=message.msgId;
    _voiceDuration=msg.getVoiceDuration();
    notifyListeners();
  }
  void handelPlayDone(){
    _msgId=null;
    _voiceDuration=null;
    notifyListeners();
  }

  @override
  void dispose() {
    print('VoicePlayerProvider 销毁');
    _curPositionController.close();
    _playerModule.closeAudioSession();
    _playerSubscription.cancel();
    super.dispose();
  }
}
