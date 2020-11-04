import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter/material.dart';


class MediaUtil {
 // FlutterSound flutterSound = new FlutterSound();
  final picker = ImagePicker();
  factory MediaUtil() => _getInstance();
  static MediaUtil get instance => _getInstance();
  static MediaUtil _instance;
  MediaUtil._internal() {
    // 初始化
  }
  static MediaUtil _getInstance() {
    if (_instance == null) {
      _instance = new MediaUtil._internal();
    }
    return _instance;
  }


  //拍照，成功则返回照片的本地路径，注：Android 必须要加 file:// 头
  Future<String> takePhoto() async {
    bool res = await applySomePermission(Permission.camera);
    if(!res) return null;
    PickedFile imgFile = await picker.getImage(source: ImageSource.camera);

    if (imgFile == null) {
      return null;
    }
    String imgPath = imgFile.path;
//    if (TargetPlatform.android == defaultTargetPlatform) {
//      imgPath = "file://" + imgfile.path;
//    }
    return imgPath;
  }

  //从相册选照片，成功则返回照片的本地路径，注：Android 必须要加 file:// 头
  Future< List<AssetEntity> > pickImage(BuildContext context,{int maxAssets:5}) async {
    bool res = await applySomePermission(Permission.storage);
    if(!res) return null;
    List<AssetEntity> assets=await AssetPicker.pickAssets(
      context,
      maxAssets: maxAssets,
      requestType:RequestType.image,
        sortPathDelegate:MyCommonSortPathDelegate()

    );
    return assets;
  }

  //开始录音
  void startRecordAudio() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path +
        "/" +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".aac";

  }

  //录音结束，通过 finished 返回本地路径和语音时长，注：Android 必须要加 file:// 头
  void stopRecordAudio(Function(String path, int duration) finished) async {
//    Recording recording = await AudioRecorder.stop();
    String path = ''; //recording.path;

    if (path == null) {
      if (finished != null) {
        finished(null, 0);
      }
    }

    if (TargetPlatform.android == defaultTargetPlatform) {
      path = "file://" + path;
    }
    if (finished != null) {
//      finished(path, recording.duration.inSeconds);
    }
  }

//  //播放语音
//  void startPlayAudio(String path) {
//    if(flutterSound.isPlaying) {
//      stopPlayAudio();
//    }
//    flutterSound.startPlayer(path);
//  }
//
//  //停止播放语音
//  void stopPlayAudio() {
//    flutterSound.stopPlayer();
//  }

  String getCorrectedLocalPath(String localPath) {
    String path = localPath;
    //Android 本地路径需要删除 file:// 才能被 File 对象识别
    if (TargetPlatform.android == defaultTargetPlatform) {
      path = localPath.replaceFirst("file://", "");
    }
    return path;
  }
}
class MyCommonSortPathDelegate extends CommonSortPathDelegate{
  @override
  void sort(List<AssetPathEntity> list) {
    list.forEach((e) {
      if(e.name=='Recent')
        e.name='最近';
      else if(e.name=='DCIM') e.name='相机';
      else if(e.name.toLowerCase()=='screenshot' || e.name.toLowerCase()=='screenshots') e.name='截图';
    });
//    List<AssetPathEntity> newList=list.map((e) {
//      if(e.name=='Recent')
//        e.name='最近';
//      else if(e.name=='DCIM') e.name='相机';
//      else if(e.name.toLowerCase()=='screenshot' || e.name.toLowerCase()=='screenshots') e.name='相机';
//      return e;
//    }).toList();
    super.sort(list);
  }
}
