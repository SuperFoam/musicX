
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownLoadModel with ChangeNotifier{
  List _taskList = [];
  Map _dPMap = {};

  List get dTaskList=>_taskList;
  Map get dPMap => _dPMap;

  void init(){
    String query="SELECT * FROM task WHERE status in (0,1,2,4,5,6)";
    FlutterDownloader.loadTasksWithRawQuery(query: query).then((value){
//        value.forEach((element) {
//          print('${element.filename}-${element.status}-${element.taskId}');
//        });
    //_taskList.clear();
    _taskList=value;
    print('更新下载状态');
    notifyListeners();

    });
  }
  void progressChange(String id,int progress){
    if(progress<=1){
      print('更新下载下载状态和进度');
      _dPMap[id]=double.parse((progress/100).toStringAsFixed(2));
      init();
      return;
    }
    print('更新下载进度');
    _dPMap[id]=double.parse((progress/100).toStringAsFixed(2));
    notifyListeners();
  }


}
