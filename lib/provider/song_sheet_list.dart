import 'package:flutter/material.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/utils_function.dart';

class SongSheetListModel with ChangeNotifier{
  List _songSheetList=[];

  List get songSheetList => _songSheetList;

  void init(){
    _songSheetList=MySongSheet.getData();
  }
  void createSongSheet(String sheetName){
    MySongSheet.create(sheetName);
    init();
    notifyListeners();
  }
  bool addSong(Map  sheetInfo,Map songData){
   bool res= MySongSheet.addSong(sheetInfo, songData);
   if(res==true){
     init();
     notifyListeners();
   }
   return res;
  }
  void batchAddSong(Map  sheetInfo,List songList){
    bool res=  MySongSheet.batchAddSong(sheetInfo, songList);
    if(res==true){
      init();
      notifyListeners();
    }
  }

  void createAndAdd(String sheetName,Map songData){
    Map sheetInfo = MySongSheet.create(sheetName);
    MySongSheet.addSong(sheetInfo, songData);
    init();
    notifyListeners();
  }
  void createAndBatchAdd(String sheetName,List songList){
    Map sheetInfo = MySongSheet.create(sheetName);
    MySongSheet.batchAddSong(sheetInfo, songList);
    init();
    notifyListeners();
  }
  void deleteSongSheet(Map oldData,){
    MySongSheet.delete(oldData);
    init();
    notifyListeners();
  }
  void changeSongSheet(Map oldData,String newName){
    MySongSheet.changeName(oldData,newName);
    init();
    notifyListeners();
  }
  void refresh(){
    init();
    notifyListeners();
  }
}
