import 'dart:collection';
import 'dart:io';
import 'package:flustars/flustars.dart';
import 'package:music_x/utils/utils_function.dart';

import 'global_data.dart';

class MyFavoriteSong2{
  static String key = Constant.myFavoriteSong;

  static getData(){
    Map songData = SpUtil.getObject(key);

    if(songData==null) {
      // List<Map> tt = [];
      Map<String,List<Map>> t={"song":[]};
      Map tt = {
        "name":'我喜欢的音乐',
        "id":0,
        "create":DateUtil.getNowDateStr(),
      };
      tt.addAll(t);
      SpUtil.putObject(key, tt);
      return tt;
    }
    return songData ;
  }

  static addSong(Map data){
    // cleanSong();return;
//    Function eq = const DeepCollectionEquality().equals;
//    print(eq(listData[0],data);
    if(data['baseInfo']['id']==9527){
      Utils.showToast('当前歌曲不能收藏');
      return false;
    }
    Map songData=getData();
    List listData = songData['song'] ;
    for(int i=0;i<listData.length;i++){
      if(listData[i]['baseInfo']['id']==data['baseInfo']['id']){
        Utils.showToast('歌曲已存在');
        return false;
      }
    }
    data['isFavorite']=true;
    listData.add(data);
    SpUtil.putObject(key, songData);
    Utils.showToast('收藏成功');
    return true;
  }
  static deleteSong(Map data){
    Map songData=getData();
    List listData = songData['song'];
    int flag = -1;
    for(int i=0;i<listData.length;i++){
      print(listData[i]['baseInfo']['id']);
      if(listData[i]['baseInfo']['id']==data['baseInfo']['id']){
        flag=i;
        break;
      }
    }
    if(flag==-1){
      Utils.showToast('歌曲不存在');
      return false;
    }
    listData.removeAt(flag);
    SpUtil.putObject(key, songData);
    // Utils.showToast('取消收藏');
    return true;
  }
  static cleanSong(){
    // SpUtil.putObjectList(key, []);
    SpUtil.remove(key);
    Utils.showToast('清空成功');
  }
  static Future<bool>   isFavorite(String id)   {
    Map songData=getData();
    List listData = songData['song'];

    for(int i=0;i<listData.length;i++){
      if(listData[i]['baseInfo']['id']==id){
        return Future.value(true);
      }
    }
    return Future.value(false);

  }
}
class MyFavoriteSong{
  static String key = Constant.myFavoriteSong;

  static getData(){
    Map songData = SpUtil.getObject(key);

    if(songData==null) {
      // List<Map> tt = [];
      // Map<String,List<Map>> t={"song":[]};
      Map tt = {
        "name":'我喜欢的音乐',
        "id":0,
        "create":DateUtil.getNowDateStr(),
        "song": LinkedHashMap<String, dynamic>(),
        "topSong": LinkedHashMap<String, dynamic>(),
      };
      //tt.addAll(t);
      SpUtil.putObject(key, tt);
      return tt;
    }
    return songData ;
  }

  static addSong(Map data){
    // cleanSong();return;
//    Function eq = const DeepCollectionEquality().equals;
//    print(eq(listData[0],data);
    if(data['baseInfo']['id']=='9527'){
      Utils.showToast('当前歌曲不能收藏');
      return false;
    }
    Map songData=getData();
    LinkedHashMap songList=songData['song'];
    String _key = data['baseInfo']['id'];
    if(songList.containsKey(_key)){
      Utils.showToast('歌曲已存在');
      return false;
    }
    data['isFavorite']=true;
    songList[_key]=data;
    SpUtil.putObject(key, songData);
    Utils.showToast('收藏成功');
    return true;
  }
  static addTopSong(Map data){
    Map songData=getData();
    LinkedHashMap topList=songData['topSong'];
    String _key = data['baseInfo']['id'];
    if(topList.containsKey(_key)){
      Utils.showToast('歌曲已置顶');
      return false;
    }
    LinkedHashMap songList=songData['song'];
    songList.remove(_key);
    topList[_key]=data;
    SpUtil.putObject(key, songData);
    Utils.showToast('置顶成功');
    return true;
  }
  static cancelTopSong(Map data){
    Map songData=getData();
    LinkedHashMap topList=songData['topSong'];
    String _key = data['baseInfo']['id'];
    if(!topList.containsKey(_key)){
      Utils.showToast('歌曲没有置顶');
      return false;
    }
    LinkedHashMap songList=songData['song'];
    topList.remove(_key);
    songList[_key]=data;
    SpUtil.putObject(key, songData);
    Utils.showToast('取消置顶成功');
    return true;
  }
  static batchAddSong(List dataList){
    Map songData=getData();
    bool res=false;
    LinkedHashMap songList=songData['song'];
    dataList.forEach((data) {
      String _key = data['baseInfo']['id'];
      if(!songList.containsKey(_key)){
        res=true;
        data['isFavorite']=true;
        songList[_key]=data;
      }
    });
    if(res==true){
      SpUtil.putObject(key, songData);
      Utils.showToast('收藏成功');
    }

  }
  static deleteSong(Map data){
    Map songData=getData();
    LinkedHashMap songList=songData['song'];
    String _key = data['baseInfo']['id'];
    if(!songList.containsKey(_key)){
      Utils.showToast('歌曲不存在');
      return false;
    }
    songList.remove(_key);
    SpUtil.putObject(key, songData);
    // Utils.showToast('取消收藏');
    return true;
  }
  static batchDeleteSong(List dataList){
    Map songData=getData();
    bool res=false;
    LinkedHashMap songList=songData['song'];
    dataList.forEach((data) {
      String _key = data['baseInfo']['id'];
      if(songList.containsKey(_key)){
        res=true;
        songList.remove(_key);
      }
    });
    if(res==true){
      SpUtil.putObject(key, songData);
      Utils.showToast('操作成功');
    }
    else Utils.showToast('歌曲未找到');
    return res;
  }
  static cleanSong(){
    // SpUtil.putObjectList(key, []);
    SpUtil.remove(key);
    Utils.showToast('清空成功');
  }
  static Future<bool>   isFavorite(String id)   {
    Map songData=getData();
    LinkedHashMap songList=songData['song'];
    if(songList.containsKey(id))  return Future.value(true);
    else   return Future.value(false);
  }
  static downloadSongDone(String songId,String savePath){
    Map songData=getData();
    LinkedHashMap songList=songData['song'];
    String _key = songId;
    if(!songList.containsKey(_key)){
      return null;
    }
    songList[_key]['isDownload']=true;
    songList[_key]['playInfo']['path']=savePath;
    SpUtil.putObject(key, songData);
    return songList[_key];
  }
  static downloadSongDelete(String songId,{bool isDeleteFile=false}){
    Map songData=getData();
    LinkedHashMap songList=songData['song'];
    String _key = songId;
    if(!songList.containsKey(_key)){
      return false;
    }
    songList[_key]['isDownload']=false;
    if(isDeleteFile==true){
      String path=songList[_key]['playInfo']['path'];
      if(path!=null && File(path).existsSync()) File(path).deleteSync();
    }
    SpUtil.putObject(key, songData);
  }
  static changeComment(String songId,String newComment,int count,String user){
    Map songData=getData();
    LinkedHashMap songList=songData['song'];
    String _key = songId;
    if(!songList.containsKey(_key)){
      return null;
    }
    songList[_key]['commentInfo']['content']=newComment;
    songList[_key]['commentInfo']['likedCount']=count;
    songList[_key]['commentInfo']['name']=user;
    SpUtil.putObject(key, songData);
    return true;
  }

  static newSongOrder(List newSongList){
    Map songData=getData();
    LinkedHashMap songList=new LinkedHashMap();
    newSongList.forEach((element) {
      String key=element['baseInfo']['id'];
      songList[key]=element;
    });
    songData['song']=songList;
    SpUtil.putObject(key, songData);
  }
}

//class MySongSheet2{
//  static String key = Constant.mySongSheet;
//  static getData(){
//    List listData = SpUtil.getObjectList(key);
//    if(listData==null) {
//      List<Map> t = [];
//      SpUtil.putObjectList(key, t);
//      return [];
//    }
//    return listData;
//  }
//
//  static create(String value){
//    List listData = SpUtil.getObjectList(key);
//    if(listData==null) {
//      Map _t = {
//        "name":value,
//        "id":1,
//        "create":DateUtil.getNowDateStr(),
//        "song":[]
//      };
//      SpUtil.putObjectList(key, [_t]);
//      return _t;
//    }else{
//      Map _t = {
//        "name":value,
//        "id":listData.length+1,
//        "create":DateUtil.getNowDateStr(),
//        "song":[]
//      };
//      listData.add(_t);
//      SpUtil.putObjectList(key, listData);
//      return _t;
//    }
//  }
//  static changeName(Map oldData, String newName){
//    List listData = SpUtil.getObjectList(key);
//    for(int i=0;i<listData.length;i++){
//      if(listData[i]['id']==oldData['id'] && listData[i]['create']==oldData['create']){
//        listData[i]['name']=newName;
//        SpUtil.putObjectList(key, listData);
//        Utils.showToast('修改成功');
//        return;
//      }
//    }
////      listData[index]['name']=newName;
////      SpUtil.putObjectList(key, listData);
//      Utils.showToast('歌单未找到');
//  }
//  static delete(Map oldData){
//    List listData = SpUtil.getObjectList(key);
//    int index=-1;
//    for(int i=0;i<listData.length;i++){
//      if(listData[i]['id']==oldData['id'] && listData[i]['create']==oldData['create']){
//       index=i;
//       break;
//      }
//    }
//    if(index==-1){
//      Utils.showToast('歌单未找到');
//      return;
//    }
//    listData.removeAt(index);
//    SpUtil.putObjectList(key, listData);
//    Utils.showToast('删除成功');
//  }
//
//  static addSong(Map sheetInfo,Map songData){
//    if(songData['baseInfo']['id']==9527){
//      Utils.showToast('当前歌曲不能收藏');
//      return false;
//    }
//    List listData = getData();
//    for(int i=0;i<listData.length;i++){
//      if(listData[i]['id']==sheetInfo['id'] && listData[i]['create']==sheetInfo['create']){
//        List song= listData[i]['song'];
//        int flag=-1;
//        for(int i=0;i<song.length;i++){
//          if(song[i]['baseInfo']['id']==songData['baseInfo']['id']){
//            flag=i;
//            break;
//          }
//        }
//        if(flag!=-1){
//          Utils.showToast('歌曲已存在');
//          return false;
//        }
//        listData[i]['song'].add(songData);
//        SpUtil.putObjectList(key, listData);
//        Utils.showToast('收藏成功');
//        return true;
//      }
//    }
//
//  }
//  static deleteSong(Map sheetInfo,Map songData){
//    List listData = getData();
//    for(int i=0;i<listData.length;i++){
//      if(listData[i]['id']==sheetInfo['id'] && listData[i]['create']==sheetInfo['create']){
//        List song= listData[i]['song'];
//        int flag=-1;
//        for(int i=0;i<song.length;i++){
//          if(song[i]['baseInfo']['id']==songData['baseInfo']['id']){
//            flag=i;
//            break;
//          }
//        }
//        if(flag==-1){
//          Utils.showToast('歌曲不存在');
//          return false;
//        }
//        listData[i]['song'].removeAt(flag);
//        SpUtil.putObjectList(key, listData);
//        Utils.showToast('取消收藏成功');
//        return true;
//      }
//    }
//  }
//}
class MySongSheet{
  static String key = Constant.mySongSheet;
  static getData(){
    List listData;
    try {
      listData= SpUtil.getObjectList(key);
    }catch(err){
      Utils.showToast('出现错误 清空歌单');
      SpUtil.remove(key);
    }
    if(listData==null) {
      List<Map> t = [];
      SpUtil.putObjectList(key, t);
      return [];
    }
    return listData;
  }

  static create(String value){
    List listData = SpUtil.getObjectList(key);
    if(listData==null) {
      Map _t = {
        "name":value,
        "id":1,
        "create":DateUtil.getNowDateStr(),
        "song":LinkedHashMap<String, dynamic>(),
      };
      SpUtil.putObjectList(key, [_t]);
      return _t;
    }else{
      Map _t = {
        "name":value,
        "id":listData.length+1,
        "create":DateUtil.getNowDateStr(),
        "song":LinkedHashMap<String, dynamic>(),
      };
      listData.add(_t);
      SpUtil.putObjectList(key, listData);
      return _t;
    }
  }
  static changeName(Map oldData, String newName){
    List listData = SpUtil.getObjectList(key);
    for(int i=0;i<listData.length;i++){
      if(listData[i]['id']==oldData['id'] && listData[i]['create']==oldData['create']){
        listData[i]['name']=newName;
        SpUtil.putObjectList(key, listData);
        Utils.showToast('修改成功');
        return;
      }
    }
//      listData[index]['name']=newName;
//      SpUtil.putObjectList(key, listData);
    Utils.showToast('歌单未找到');
  }
  static delete(Map oldData){
    List listData = SpUtil.getObjectList(key);
    int index=-1;
    for(int i=0;i<listData.length;i++){
      if(listData[i]['id']==oldData['id'] && listData[i]['create']==oldData['create']){
        index=i;
        break;
      }
    }
    if(index==-1){
      Utils.showToast('歌单未找到');
      return;
    }
    listData.removeAt(index);
    SpUtil.putObjectList(key, listData);
    Utils.showToast('删除成功');
  }

  static addSong(Map sheetInfo,Map songData){
    if(songData['baseInfo']['id']==9527){
      Utils.showToast('当前歌曲不能收藏');
      return false;
    }
    List listData = getData();
    for(int i=0;i<listData.length;i++){
      if(listData[i]['id']==sheetInfo['id'] && listData[i]['create']==sheetInfo['create']){
        LinkedHashMap songList=listData[i]['song'];
        String _key = songData['baseInfo']['id'];
        if(songList.containsKey(_key)){
          Utils.showToast('歌曲已存在');
          return false;
        }
        songList[_key]=songData;
        SpUtil.putObjectList(key, listData);
        Utils.showToast('收藏成功');
        return true;
      }
    }

  }
  static deleteSong(Map sheetInfo,Map songData){
    List listData = getData();
    for(int i=0;i<listData.length;i++){
      if(listData[i]['id']==sheetInfo['id'] && listData[i]['create']==sheetInfo['create']){
        LinkedHashMap songList=listData[i]['song'];
        String _key = songData['baseInfo']['id'];
        if(!songList.containsKey(_key)){
          Utils.showToast('歌曲不存在');
          return false;
        }
        songList.remove(_key);
        SpUtil.putObjectList(key, listData);
        Utils.showToast('取消收藏成功');
        return true;
      }
    }
  }
  static batchDeleteSong(Map sheetInfo,List songList2){ //批量删除
    List listData = getData();
    bool res=false;
    for(int i=0;i<listData.length;i++){
      if(listData[i]['id']==sheetInfo['id'] && listData[i]['create']==sheetInfo['create']){
        LinkedHashMap songList=listData[i]['song'];
        songList2.forEach((songData) {
          String _key = songData['baseInfo']['id'];
          if(songList.containsKey(_key)){
            songList.remove(_key);
            res=true;
          }
        });
        break;
      }
    }
    if(res==true){
      SpUtil.putObjectList(key, listData);
      Utils.showToast('批量操作成功');
    }
    return res;
  }
  static downloadSongDone(String songId,String savePath){
    List listData = getData();
    bool flag=false;
    Map res;
    for(int i=0;i<listData.length;i++){
      LinkedHashMap songList=listData[i]['song'];
      String _key = songId;
      if(songList.containsKey(_key)){
        flag=true;
        songList[_key]['isDownload']=true;
        songList[_key]['playInfo']['path']=savePath;
        res=songList[_key];
      }
    }
    if(flag==true)  {
      SpUtil.putObjectList(key, listData);
      return res;
    }else return null;
  }
  static downloadSongDelete(String songId,{bool isDeleteFile=false}){
    List listData = getData();
    bool flag=false;
    for(int i=0;i<listData.length;i++){
      LinkedHashMap songList=listData[i]['song'];
      String _key = songId;
      if(songList.containsKey(_key)){
        flag=true;
        songList[_key]['isDownload']=false;
        if(isDeleteFile==true){
          String path=songList[_key]['playInfo']['path'];
          if(path!=null && File(path).existsSync()) File(path).deleteSync();
        }
      }
    }
    if(flag==true)  SpUtil.putObjectList(key, listData);
  }
  static changeComment(Map sheetInfo,String songId,String newComment,int count,String user){
    List listData = getData();
    bool flag=false;
    for(int i=0;i<listData.length;i++){
      if(listData[i]['id']==sheetInfo['id'] && listData[i]['create']==sheetInfo['create']){
        LinkedHashMap songList=listData[i]['song'];
        String _key = songId;
        if(songList.containsKey(_key)){
          flag=true;
          songList[_key]['commentInfo']['content']=newComment;
          songList[_key]['commentInfo']['likedCount']=count;
          songList[_key]['commentInfo']['name']=user;
        }
        break;
      }

    }
    if(flag==true)  {
      SpUtil.putObjectList(key, listData);
      return true;
    }else return null;
  }

  static batchAddSong(Map sheetInfo,List songList2){
    List listData = getData();
    bool res=false;
    for(int i=0;i<listData.length;i++){
      if(listData[i]['id']==sheetInfo['id'] && listData[i]['create']==sheetInfo['create']){
        LinkedHashMap songList=listData[i]['song'];
        songList2.forEach((songData) {
          String _key = songData['baseInfo']['id'];
          if(!songList.containsKey(_key)){
            res=true;
            songList[_key]=songData;
          }
        });
      }
    }
    if(res==true){
      SpUtil.putObjectList(key, listData);
      Utils.showToast('收藏成功');
      return true;
    }
    return false;
  }

  static newSongOrder(Map sheetInfo,List newSongList){
    List listData=getData();
    LinkedHashMap songList=new LinkedHashMap();
    for(int i=0;i<listData.length;i++){
      if(listData[i]['id']==sheetInfo['id'] && listData[i]['create']==sheetInfo['create']){
        newSongList.forEach((element) {
          String key=element['baseInfo']['id'];
          songList[key]=element;
        });
        listData[i]['song']=songList;
        SpUtil.putObjectList(key, listData);
        return true;
      }
    }

  }
}
class MyDownloadTask{
  static String key = Constant.downloadTask;
  static getData(){
    Map songData = SpUtil.getObject(key);
    if(songData==null) {
      Map tt ={};
      SpUtil.putObject(key, tt);
      return tt;
    }
    return songData ;
  }
  static add(String taskId,String songId,String savePath,{Map t}){
    Map songData=getData();
    songData[taskId]={"songId":songId,"savePath":savePath,'t':t};
    SpUtil.putObject(key, songData);
  }
  static delete(String taskId,){
    Map songData=getData();
    songData.remove(taskId);
    SpUtil.putObject(key, songData);
  }
  static getSong(String taskId){
    Map songData=getData();
    return songData[taskId];
  }
  static changeTask(String oldId,String newId){
    Map songData=getData();
    if(songData.containsKey(oldId)){
      Map oldData = songData[oldId];
      songData[newId]=oldData;
      songData.remove(oldId);
      SpUtil.putObject(key, songData);
    }
  }

}
//class LocalSong{
//  static String key = Constant.localSong;
//
//  static getData(){
//    List listData = SpUtil.getObjectList(key);
//    if(listData==null) {
//      List<Map> t = [];
//      SpUtil.putObjectList(key, t);
//      return t;
//    }
//    return listData;
//  }
//  static addSong(List<Map> data){
//    List listData = getData();
//    listData.addAll(data);
//    SpUtil.putObjectList(key, listData);
//  }
//}

class LocalSong{ //本地歌曲
  static String key = Constant.localSong;

  static getData(){
    LinkedHashMap<String, dynamic> listData;
    try {
      listData= SpUtil.getObject(key);
    }catch(e){
      SpUtil.remove(key);
    }
    if(listData==null) {
      LinkedHashMap<String,dynamic> t = LinkedHashMap();
      SpUtil.putObject(key, t);
      return t;
    }
    return listData;
  }
  static addSong( data){
    LinkedHashMap<String,dynamic> listData = getData();
    listData.addAll(data);
    SpUtil.putObject(key, listData);
  }
  static favoriteSong(String _key){
    LinkedHashMap<String,dynamic> listData = getData();
    if(!listData.containsKey(_key)){
      Utils.showToast('歌曲不存在');
      return;
    }
    listData[_key]['isFavorite'] = !listData[_key]['isFavorite'];
    SpUtil.putObject(key, listData);
  }
  static delete(String _key){
    LinkedHashMap<String,dynamic> listData = getData();
    if(!listData.containsKey(_key)){
      Utils.showToast('歌曲不存在');
      return false;
    }
    listData.remove(_key);
    SpUtil.putObject(key, listData);
    return true;
  }
}
class MySheetSearch{ //歌单搜索历史
  static String key = Constant.sheetSearch;
  static getData(){
    List listData;
    try {
      listData= SpUtil.getStringList(key,defValue: []);
    }catch(e){
      SpUtil.remove(key);
    }
    if(listData==null) {
      List t = List();
      SpUtil.putStringList(key, t);
      return t;
    }
    return listData;
  }
  static add(String res){
    List listData= getData();
    if(!listData.contains(res)) {
      listData.add(res);
      if(listData.length>5) listData.removeAt(0);
      SpUtil.putStringList(key, listData);
    }
  }
  static delete(String res){
    List listData= getData();
    int index= listData.indexOf(res);
    if(index!=-1) {
      listData.removeAt(index);
      SpUtil.putStringList(key, listData);
    }
  }
  static clean(){
    SpUtil.remove(key);
  }
}

class MyGoodsType{
  static String key = Constant.goodsType;
  static List goodsTypeList=[
    {"type":"语种","value":["华语","欧美","日语","韩语","粤语"]},
    {"type":"风格","value":["流行","摇滚","民谣","舞曲","说唱","轻音乐","乡村","民族","古风","世界音乐"]},
    {"type":"场景","value":["清晨","夜晚","学习","工作","午休","地铁","驾车","运动","旅行","散步","酒吧"]},
    {"type":"情感","value":["怀旧","清新","浪漫","伤感","治愈","放松","孤独","感到","兴奋","快乐","安静","思念"]},
    {"type":"主题","value":["综艺","影视","儿童","校园","游戏","70后","80后","90后","网络","KTV","经典","翻唱","吉他","钢琴"]},
  ];

  static getData(){
    List listData;
    try {
      listData= SpUtil.getObjectList(key);
    }catch(e){
      SpUtil.remove(key);
    }
    if(listData==null) {
      int count = 9;
      List t =[];
      for(int i=0;i<goodsTypeList.length;i++){
          for(int j=0;j<goodsTypeList[i]['value'].length;j++){
            Map goods={
              "name":goodsTypeList[i]['value'][j],
              "type":goodsTypeList[i]['type']
            };
            if(t.length<count)
            t.add(goods);
            else
              break;
          }
          if(t.length>count)break;
      }
      SpUtil.putObjectList(key, t);
      return t;
    }
    return listData;
  }
 static change(List data){
   SpUtil.putObjectList(key, data);
 }

}

class KeyboardHeight{
  static String key = Constant.keyboardH;
  static getData(){
    double h = SpUtil.getDouble(key,defValue: null);
    return h;
  }
  static change(double newVal){
    SpUtil.putDouble(key, newVal);
  }
}
class PersonInfoStorage{
  static String key =  Constant.personInfo;

  static getData(){
    Map personData;
    try {
      personData= SpUtil.getObject(key);
    }catch(e){
      print('获取出错，重建数据:$e');
      SpUtil.remove(key);
    }
    if(personData==null){
      Map<String,Map> t = Map();
      SpUtil.putObject(key, t);
      return t;
    }
    return personData;
  }

  static get(String _key){
    Map data = getData();
    //print('get data is $data');
    if(data[_key]!=null)return data[_key];
    else{
      Map<String,dynamic> t = Map();
      t['userId']=_key;
      data[_key]=t;
      SpUtil.putObject(key, data);
      return t;
    }
  }
  static put(String userId,String _key,dynamic value){
    Map<String,dynamic> userInfo = get(userId);
    userInfo[_key]=value;
    //print('put userInfo is $userInfo');
    Map data = getData();
    data[userId]=userInfo;
    SpUtil.putObject(key, data);
  }

}
