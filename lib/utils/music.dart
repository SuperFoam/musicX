import 'dart:math';
import 'package:encrypt/encrypt.dart' ;
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';

import 'package:music_x/utils/request.dart';
import 'package:oktoast/oktoast.dart';

const String modulus = '00e0b509f6259df8642dbc35662901477df22677ec152b5ff68ace615bb7b725152b3ab17a876aea8a5aa76d2e417629ec4ee341f56135fccf695280104e0312ecbda92557c93870114af6c9d05c4f7f0c3685b7a46bee255932575cce10b424d813cfe4875d3e82047b97ddef52741d546b8e289dc6935b3ece0462db0a22b8e7';
const String nonce = '0CoJUm6Qyw8W8jud';
const String pubKey = '010001';

String createSecretKey(size) {
  String alphabet = '0123456789abcdefghijklmnopqrstuvwxyz';
  String key = '';
  for (var i = 0; i < size; i++) {
    key = key + alphabet[Random().nextInt(alphabet.length)];
  }
  return key;
}
String aesEncrypt(String req, secKey) {
  var pad = 16 - req.length % 16;
  var text = req + String.fromCharCode(pad) * pad ;
  var key = Key.fromUtf8(secKey);
  var iv  = IV.fromUtf8('0102030405060708');
  var _encryptor = Encrypter(AES(key, mode: AESMode.cbc,padding: "PKCS7"));
  var encrypted  = _encryptor.encrypt(text,iv:iv);
  //var decrypted = _encryptor.decrypt(encrypted);
  return encrypted.base64;
}
String rsaEncrypt(_text, pubKey, modulus){
  var _tt = _text.codeUnits;
  var t3 = _tt.reversed.toList();
  var t4 =t3.map((e) => e.toRadixString(16)).toList();
  var strT3 = t4.join('');
  BigInt a = BigInt.parse(strT3, radix: 16);
  BigInt b = BigInt.parse(pubKey, radix: 16) ;
  BigInt c = BigInt.parse(modulus, radix: 16);
  BigInt rs = a.modPow(b,c) ;
  String res = rs.toRadixString(16).padLeft(256,'0');
  return res;
}
Map encrypted_request(req){
  var text =jsonEncode(req);
  //print(text);
  var key = createSecretKey(16);
  var aes = aesEncrypt(text, nonce);
  var encText = aesEncrypt(aes, key);
  var encSecKey= rsaEncrypt(key, pubKey, modulus);
  var data = {
    'params': encText,
    'encSecKey': encSecKey
  };
  return data;
}


class MusicComment{
  static String commentUrl2 = 'http://music.163.com/api/v1/resource/comments/R_SO_4_';
  static String commentUrl3="http://music.163.com/api/v1/resource/comments/A_PL_0_";
  static List playSheet=['2884035','3779629','3778678','19723756','2250011882','991319590','71384707','1978921795','11641012'];
  static  var   headers = {
    'Referer': 'http://music.163.com',
    'X-Real-IP': '118.88.88.88',
    'Cookie': 'os=linux; appver=1.0.0.1026; osver=Ubuntu%2016.10',
    "User-Agent":"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.146 Safari/537.36"
  };
  static Future<Map> getCommentInfo(String id,{int page=0,bool isSheet=false}) async {
    String url;
//    if(playSheet.contains(id)) url=commentUrl3+id;
//    else url = commentUrl2+id;
    if(isSheet==true)url=commentUrl3+id;
    else url=commentUrl2+id;
    int pageCount=20;
    var reqData={
      'offset':page*pageCount,
      "csrf_token":'',
      "total":"true",
      "limit":"20",
    };
    RequestOptions requestOptions =  RequestOptions(baseUrl: url,headers: headers);
    Response response = await HttpUtil().get('',options: requestOptions,data: reqData);
    var data =response!=null?jsonDecode(response.data):null;
    return data;
  }
}

class AlbumInfo{
  String  playUrl2 =   "http://music.163.com/song/media/outer/url?id="; // get
   String albumId;
   var   headers = {
     'Referer': 'http://music.163.com',
     'X-Real-IP': '118.88.88.88',
     'Cookie': 'os=linux; appver=1.0.0.1026; osver=Ubuntu%2016.10',
     "User-Agent":"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.146 Safari/537.36"
   };
   AlbumInfo(String id){
     albumId=id;
   }
    getAlbumInfo() async{
     String url='http://music.163.com/api/album/$albumId?ext=true&id=$albumId&offset=0&total=true&limit=10';
     RequestOptions requestOptions =  RequestOptions(baseUrl: url,headers: headers);
     Response response = await HttpUtil().get('',options: requestOptions);
     if (response==null)return;
     var data =jsonDecode(response.data);
     if(data['album']==null)return;
     Map albumData={
       'fans':0,
     };
     var picUrl = data['album']['artist']['picUrl'];
     if(picUrl==null || picUrl=="")return;
     albumData['authorPic']=picUrl;
     var desc=data['album']['description'];
     if(desc==null || desc=="")return;
     albumData['description']=desc;
     var authorId=data['album']['artist']['id'];
     String artistUrl = 'http://music.163.com/api/artist/$authorId';
     RequestOptions requestOptions2 =  RequestOptions(baseUrl: artistUrl,headers: headers);
     Response response2 = await HttpUtil().get('',options: requestOptions2);
     if (response2==null)return albumData;
     var data2 =jsonDecode(response2.data);
     if(data2['artist']==null)return albumData;
     var userId= data2['artist']['accountId'];
     if(userId==null || userId == "") return albumData;
     String userUrl = 'http://music.163.com/api/v1/user/detail/$userId';
     RequestOptions requestOptions3 =  RequestOptions(baseUrl: userUrl,headers: headers);
     Response response3 = await HttpUtil().get('',options: requestOptions3);
     if (response3==null)return albumData;
     var data3 =jsonDecode(response3.data);
     if(data3['profile']==null)return albumData;
     albumData['fans']=data3['profile']['followeds'];
     return albumData;
   }

   getAlbumSong() async{
     String url="http://music.163.com/api/album/$albumId?ext=true&id=$albumId&offset=0&total=true&limit=50";
     RequestOptions requestOptions =  RequestOptions(baseUrl: url,headers: headers);
     Response response = await HttpUtil().get('',options: requestOptions);
     if (response==null)return;
     var data =jsonDecode(response.data);
     if(data['album']==null)return;
     List songList = data['album']['songs'];
     if(songList.length==0)return;
     List res=[];
     songList.forEach((element) {
       Map songData={
         'isFavorite':false,
         'isNetwork':true,
         'isOfficial':true,
       };
       String songID=element['id'].toString();
       songData['baseInfo'] = {
         'id':songID,
         'name':element['name'],
         'author':element['artists'][0]['name'],
         'picUrl':element['album']['picUrl']
       };
       songData['playInfo'] = {
         'url':playUrl2+songID+'.mp3',
         'br':'128000',
         'size':element['lMusic']!=null?element['lMusic']['size']:996,
       };
       songData['commentInfo'] = {
         'name': 'dreamfly',
         'content':'无',
         'likedCount':32,
       };
       res.add(songData);
     });
     return res;
   }
}
class GoodsSheetMusic{ //歌单列表
  String url = "http://music.163.com/api/playlist/list?cat=";
  var   headers = {
    'Referer': 'http://music.163.com',
    'X-Real-IP': '118.88.88.88',
    'Cookie': 'os=linux; appver=1.0.0.1026; osver=Ubuntu%2016.10',
    "User-Agent":"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.146 Safari/537.36"
  };
  GoodsSheetMusic(String name){
    url = url+name;
  }
  getGoodsSheet() async{
    RequestOptions requestOptions =  RequestOptions(baseUrl: url,headers: headers);
    Response response = await HttpUtil().get('',options: requestOptions);
    if (response==null)return;
    var data =jsonDecode(response.data);
    List playList = data['playlists'];
    if(playList==null || playList.length==0)return;
    List res=[];
    playList.forEach((element) {
      Map t={
        "createTime":element['createTime'],
        'id':element['id'],
        'count':element['trackCount'],
        'title':element['name'],
        'description':element['description'],
        'picUrl':element['coverImgUrl'],
        'playCount':element['playCount'],
        'username':element['creator']['nickname']
      };
      res.add(t);
    });
    return res;
  }

}

class SongArtist{ //歌手信息
  String artistId;
  String artistUrl='http://music.163.com/api/artist/';
  String artistDescUrl = "http://music.163.com/api/artist/introduction?id=";
  String albumUrl;
  String  playUrl2 =   "http://music.163.com/song/media/outer/url?id="; // get
  var   headers = {
    'Referer': 'http://music.163.com',
    'X-Real-IP': '118.88.88.88',
    'Cookie': 'os=linux; appver=1.0.0.1026; osver=Ubuntu%2016.10',
    "User-Agent":"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.146 Safari/537.36"
  };
  SongArtist(String id){
    artistId=id;

  }
  getHotSong() async{
    artistUrl=artistUrl+artistId;
    RequestOptions requestOptions =  RequestOptions(baseUrl: artistUrl,headers: headers);
    Response response = await HttpUtil().get('',options: requestOptions);
    if (response==null)return;
    var data =jsonDecode(response.data);
    if(data['hotSongs']==null)return;
    List songList = data['hotSongs'];
    if (songList.length==0) return;
    Map resData={
      "artistName":data['artist']['name'],
      "artistPicUrl":data['artist']['picUrl'],
      "userId":data['artist']['accountId'],
      "song":[]
    };
    List res=[];
    songList.forEach((element) {
      Map songData={
        'isFavorite':false,
        'isNetwork':true,
        'isOfficial':true,
      };
      String songID=element['id'].toString();
      songData['baseInfo'] = {
        'id':songID,
        'name':element['name'],
        'author':element['artists'][0]['name'],
        'picUrl':element['album']['picUrl']
      };
      songData['playInfo'] = {
        'url':playUrl2+songID+'.mp3',
        'br':'128000',
        'size':element['lMusic']!=null?element['lMusic']['size']:996,
      };
      songData['commentInfo'] = {
        'name': 'dreamfly',
        'content':'无',
        'likedCount':32,
      };
      res.add(songData);
    });
    resData['song']=res;
    return resData;
  }

  getAlbum() async{
    albumUrl='http://music.163.com/api/artist/albums/$artistId?id=$artistId&offset=0&total=true&limit=50';
    RequestOptions requestOptions =  RequestOptions(baseUrl: albumUrl,headers: headers);
    Response response = await HttpUtil().get('',options: requestOptions);
    if (response==null)return;
    var data =jsonDecode(response.data);
    if(data['hotAlbums']==null)return;
    List albumList = data['hotAlbums'];
    if (albumList.length==0) return;
    List res=[];
    albumList.forEach((element) {
      Map info={
        'name':element['name'],
        'count':element['size'],
        'picUrl':element['picUrl'],
        'publishTime':element['publishTime'],
        'albumId':element['id'],
      };
      res.add(info);
    });
    return res;

  }
  getArtistDesc() async{
    String url = artistDescUrl+artistId;
    RequestOptions requestOptions =  RequestOptions(baseUrl: url,headers: headers);
    Response response = await HttpUtil().get('',options: requestOptions);
    if (response==null)return;
    var data =jsonDecode(response.data);
    if(data['briefDesc']==null)return;
    List res=[];
    res.add({
      "key":'简介',
      "value":data['briefDesc']
    });
    if(data['introduction']!=null && data['introduction'].length>0){

      List descList = data['introduction'];
      descList.forEach((element) {
        if(element['ti']=="")return;
        Map info={
          "key":element['ti'],
          'value':element['txt']
        };
        res.add(info);
      });
    }
    return res;

  }
}

class GoodsSearch{ //歌曲搜索
  String hotUrl = 'http://music.163.com/api/hotsearchlist/get';
  String suggestUrl = "http://music.163.com/api/search/suggest/keyword?s=";
  String  playUrl2 =   "http://music.163.com/song/media/outer/url?id="; // get
  var   headers = {
    'Referer': 'http://music.163.com',
    'X-Real-IP': '118.88.88.88',
    'Cookie': 'os=linux; appver=1.0.0.1026; osver=Ubuntu%2016.10',
    "User-Agent":"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.146 Safari/537.36"
  };
  Future getHotSearch() async{
    RequestOptions requestOptions =  RequestOptions(baseUrl: hotUrl,headers: headers);
    Response response = await HttpUtil().get('',options: requestOptions);
    if (response==null || response.data==null)return;
    var data =jsonDecode(response.data);
    List res=data['data'];
    if (res==null || res.length==0)return;
    return res;
  }
  getSearchSuggest(String key) async{
    String url = suggestUrl+key+'&limit=10';
    RequestOptions requestOptions =  RequestOptions(baseUrl: url,headers: headers);
    Response response = await HttpUtil().get('',options: requestOptions);
    if (response==null || response.data==null)return [];
    var data =jsonDecode(response.data);
    List res=data['result']!=null?data['result']['allMatch']:null;
    if (res==null || res.length==0){
     return [];
    }
    return res;
  }
  getSearchRes(String key,{int type=1,int limit=10,int page=0}) async{
    String url ="http://music.163.com/weapi/cloudsearch/get/web?csrf_token=";
    Map req= {
      "csrf_token":"",
      "limit":limit.toString(),
      "offset":(page*limit).toString(),
      "s":key,
      'type':type.toString(),
    };
    //print('请求数据$req');
    var reqData =  encrypted_request(req);
    RequestOptions requestOptions =  RequestOptions(baseUrl: url,headers: headers);
    Response response = await HttpUtil().post('',options: requestOptions,data: reqData);
    if (response==null || response.data==null)return ;
    var data =jsonDecode(response.data);
   // print(data);
    if(type==1){
      return handleSong(data);
    }else if(type==10)
      return handleAlbum(data);
    else if(type==100)
      return handleArtist(data);
    else if(type==1000)
      return handleSheet(data);
    else
    return ;

  }
  handleSheet(data){
    List sheetList = data['result']!=null?data['result']['playlists']:null;
    if (sheetList==null || sheetList.length==0) return ;
    List res=[];
    sheetList.forEach((element) {
      Map t={
        'id':element['id'],
        'count':element['trackCount'],
        'title':element['name'],
        'description':element['description'],
        'picUrl':element['coverImgUrl'],
        'playCount':element['playCount'],
        'username':element['creator']['nickname']
      };
      res.add(t);
    });
    return res;
  }
  handleArtist(data){
    List artistList = data['result']!=null?data['result']['artists']:null;
    if (artistList==null || artistList.length==0) return ;
    List res=[];
    artistList.forEach((element) {
     Map t={
       'id':element['id'],
       'name':element['name'],
       'picUrl':element['picUrl'],
       'albumSize':element['albumSize'],
     };
     res.add(t);

    });
    return res;
  }
  handleAlbum(data){
    List albumList = data['result']!=null?data['result']['albums']:null;
    if (albumList==null || albumList.length==0) return ;
    List res=[];
    albumList.forEach((element) {
      Map info={
        'name':element['name'],
        'count':element['size'],
        'picUrl':element['picUrl'],
        'publishTime':element['publishTime'],
        'albumId':element['id'],
        'artistName':element['artists'][0]['name']
      };
      res.add(info);
    });
    return res;
  }
  handleSong(data){
    List songList = data['result']!=null?data['result']['songs']:null;
    if (songList==null || songList.length==0) return ;
    List res=[];
    songList.forEach((element) {
      Map songData={
        'isFavorite':false,
        'isNetwork':true,
        'isOfficial':true,
      };
      String songID=element['id'].toString();
      songData['baseInfo'] = {
        'id':songID,
        'name':element['name'],
        'author':element['ar'][0]['name'],
        'picUrl':element['al']['picUrl']
      };
      songData['playInfo'] = {
        'url':playUrl2+songID+'.mp3',
        'br':'128000',
        'size':element['l']!=null?element['l']['size']:996,
      };
      songData['commentInfo'] = {
        'name': 'dreamfly',
        'content':'无',
        'likedCount':32,
      };
      res.add(songData);
    });
    return res;
  }

}
class WYMusic{
//   String modulus = '00e0b509f6259df8642dbc35662901477df22677ec152b5ff68ace615bb7b725152b3ab17a876aea8a5aa76d2e417629ec4ee341f56135fccf695280104e0312ecbda92557c93870114af6c9d05c4f7f0c3685b7a46bee255932575cce10b424d813cfe4875d3e82047b97ddef52741d546b8e289dc6935b3ece0462db0a22b8e7';
//   String nonce = '0CoJUm6Qyw8W8jud';
//   String pubKey = '010001';
   String commentUrl = 'https://music.163.com/weapi/v1/resource/comments/R_SO_4_'; // song_id + '?csrf_token=';
   String commentUrl2 = 'http://music.163.com/api/v1/resource/comments/R_SO_4_'; // get;
   String  detailUrl = 'http://music.163.com/api/song/detail' ;//?id=855801&ids=%5B855801%5D;
   String  playUrl =   "http://music.163.com/weapi/song/enhance/player/url?csrf_token=";
   String  playUrl2 =   "http://music.163.com/song/media/outer/url?id="; // get
   String  playlistUrl =   "http://music.163.com/weapi/v3/playlist/detail?csrf_token=";
   String playlistUrl2 = "https://music.163.com/api/playlist/detail?id="; // get
   String lyricUrl = "http://music.163.com/api/song/lyric?os=osx&id=85580&lv=-1&kv=-1&tv=-1"; //不需要加密,get
   String lyricUrl2 =  'http://music.163.com/weapi/song/lyric?csrf_token=';
   Map playlistMap = {
     'hot':3778678,
     'new':3779629,
     'original':2884035,
     'hurry':19723756
   };
   int minID = 188057;
   int maxID = 1500000000;
   int reqTime = 0;
   int maxReqTime = 20;
   int timeout = 5;
   int randomCount = 199;
   int curSecond = 0;
   Map<String,dynamic> songData={};
   var   headers = {
    'Referer': 'http://music.163.com',
    'X-Real-IP': '118.88.88.88',
    'Cookie': 'os=linux; appver=1.0.0.1026; osver=Ubuntu%2016.10',
    "User-Agent":"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.146 Safari/537.36"
  };
   var url2 = "http://music.163.com/song/media/outer/url?id=这里填歌曲id.mp3 "; // get
   var url3 = "http://music.163.com/api/v1/resource/comments/R_SO_4_28936510" ;//未加密评论,get
   final String mode;

   WYMusic(this.mode){
     const period = const Duration(seconds: 1);
     Timer.periodic(period, (timer) {
       curSecond++;
       if(curSecond>timeout){
         timer.cancel();
         timer = null;
       }
     });
   }

//   String createSecretKey(size) {
//    String alphabet = '0123456789abcdefghijklmnopqrstuvwxyz';
//    String key = '';
//    for (var i = 0; i < size; i++) {
//      key = key + alphabet[Random().nextInt(alphabet.length)];
//    }
//    return key;
//  }
//   String aesEncrypt(String req, secKey) {
//
//    var pad = 16 - req.length % 16;
//    var text = req + String.fromCharCode(pad) * pad ;
//    var key = Key.fromUtf8(secKey);
//    var iv  = IV.fromUtf8('0102030405060708');
//    var _encryptor = Encrypter(AES(key, mode: AESMode.cbc,padding: null));
//    var encrypted  = _encryptor.encrypt(text,iv:iv);
//    //var decrypted = _encryptor.decrypt(encrypted);
//    return encrypted.base64;
//  }
//   String rsaEncrypt(_text, pubKey, modulus){
//    var _tt = _text.codeUnits;
//    var t3 = _tt.reversed.toList();
//    var t4 =t3.map((e) => e.toRadixString(16)).toList();
//    var strT3 = t4.join('');
//    BigInt a = BigInt.parse(strT3, radix: 16);
//    BigInt b = BigInt.parse(pubKey, radix: 16) ;
//    BigInt c = BigInt.parse(modulus, radix: 16);
//    BigInt rs = a.modPow(b,c) ;
//    String res = rs.toRadixString(16).padLeft(256,'0');
//    return res;
//  }
//   Map encrypted_request(req){
//    var text = jsonEncode(req);
//    print(text);
//    var key = createSecretKey(16);
//    //print('key is $key');
//    var aes = aesEncrypt(text, nonce);
//    var encText = aesEncrypt(aes, key);
//    var encSecKey= rsaEncrypt(key, pubKey, modulus);
//    var data = {
//      'params': encText,
//      'encSecKey': encSecKey
//    };
//    return data;
//  }
   Future<Map> getSongInfo(id) async {
    //var url = detailUrl +'?id='+id+'&ids=%5B'+id+'%5D';
     var url = detailUrl +'?id=$id&ids=%5B$id%5D';
    RequestOptions requestOptions =  RequestOptions(baseUrl: url,headers: headers);
    Response response = await HttpUtil().get('',options: requestOptions);
     var data =response!=null?jsonDecode(response.data):null;
    return data;

  }
   Future<Map> getCommentInfo(id) async {
    var url = commentUrl+id+'?csrf_token=';
    RequestOptions requestOptions =  RequestOptions(baseUrl: url,headers: headers);
    var commentReq= {
      "csrf_token":"",
      "limit":"20",
      "offset":"0",
      "rid":"R_SO_4_" + id,
      "total":"true"
    };
    var reqData =  encrypted_request(commentReq);
    Response response = await HttpUtil().post('',options: requestOptions,data: reqData);
    var data =response!=null?jsonDecode(response.data):null;
    return data;


  }
   Future<Map> getPlayInfo(id) async {
    RequestOptions requestOptions =  RequestOptions(baseUrl: playUrl,headers: headers);
    var playReq={
//      "ids": [id],
      "ids": id,
      "br": 128000,
      "csrf_token": ""
    };

    var reqData =  encrypted_request(playReq);
    Response response = await HttpUtil().post('',options: requestOptions,data: reqData);
    var data =response!=null?jsonDecode(response.data):null;
    return data;

  }
   Future<Map> getPlaylistInfo(id) async {
     RequestOptions requestOptions =  RequestOptions(baseUrl: playlistUrl,headers: headers);
     var playReq={
       "id": id,
       "offset": 0,
       "total": true,
       "limit": 1000,
       "n": 1000,
       "csrf_token": ""
     };

     var reqData =  encrypted_request(playReq);
     Response response = await HttpUtil().post('',options: requestOptions,data: reqData);
     var data =response!=null?jsonDecode(response.data):null;
     return data;
   }
   Future<Map> getPlaylistInfoTotal(String id) async {
     String url = playlistUrl2+id;
     RequestOptions requestOptions =  RequestOptions(baseUrl: url,headers: headers);
     Response response = await HttpUtil().get('',options: requestOptions,);
     var data =response!=null?jsonDecode(response.data):null;
     return data;
   }
   Future<Map> getLyricInfo(id) async { // 歌词
     RequestOptions requestOptions =  RequestOptions(baseUrl: lyricUrl2,headers: headers);
     var playReq={
       "os": "osx",
       "id": id,
       "lv": -1,
       "kv": -1,
       "tv": -1,
       "csrf_token": ""
     };
     var reqData =  encrypted_request(playReq);
     Response response = await HttpUtil().post('',options: requestOptions,data: reqData);
     var data =response!=null?jsonDecode(response.data):null;
     return data;

   }
    Future getPlaylistSongTotal(String playlistID) async { //获取歌单里面所有歌曲
      var playlistInfo = await getPlaylistInfo(playlistID);
      if (playlistInfo==null) return;
      List songList = playlistInfo['playlist']['tracks'];
      if (songList.length==0) return;
      List res=[];
      songList.forEach((element) {
        Map songData={
          'isFavorite':false,
          'isNetwork':true,
          'isOfficial':true,
        };
        String songID=element['id'].toString();
        songData['baseInfo'] = {
          'id':songID,
          'name':element['name'],
          'author':element['ar'][0]['name'],
          'picUrl':element['al']['picUrl']
        };
        songData['playInfo'] = {
          'url':playUrl2+songID+'.mp3',
          'br':'128000',
          'size':element['l']!=null?element['l']['size']:996,
        };
        songData['commentInfo'] = {
          'name': 'dreamfly',
          'content':'无',
          'likedCount':32,
        };
        res.add(songData);
      });
      return res;

//      var playlistInfo = await getPlaylistInfoTotal(playlistID);
//      if (playlistInfo==null) return;
//      if(playlistInfo['code']!=200)return;
//      List songList = playlistInfo['result']['tracks'];
//      if (songList.length==0) return;
//      List res=[];
//      songList.forEach((element) {
//        Map songData={
//          'isFavorite':false,
//          'isNetwork':true,
//          'isOfficial':true,
//        };
//        String songID=element['id'].toString();
//        songData['baseInfo'] = {
//          'id':songID,
//          'name':element['name'],
//          'author':element['artists'][0]['name'],
//          'picUrl':element['album']['picUrl']
//        };
//        songData['playInfo'] = {
//          'url':playUrl2+songID+'.mp3',
//          'br':'128000',
//          'size':element['lMusic']!=null?element['lMusic']['size']:996,
//        };
//        songData['commentInfo'] = {
//          'name': 'dreamfly',
//          'content':'无',
//          'likedCount':32,
//        };
//        res.add(songData);
//      });
//      return res;


   }
  getNextSong() async {
     Map<String,dynamic> res ;
    if(playlistMap.containsKey(mode)){
       res = await getPlaylistSong(playlistMap[mode]);
    }else if(mode=='random'){
       res = await getRandomSong();
    }
    return res;
  }

   Future getPlaylistSong(playlistID) async { // 指定歌单
     await Future.delayed(const Duration(milliseconds: 100));
      var playlistInfo = await getPlaylistInfo(playlistID);
     if (playlistInfo==null) return;
      List songList = playlistInfo['playlist']['tracks'];
      if (songList.length==0) return;
      int select = Random().nextInt(songList.length);
      int songID = songList[select]['id'];
      songData['baseInfo'] = {
        'id':songID.toString(),
        'name':songList[select]['name'],
        'author':songList[select]['ar'][0]['name'],
        'picUrl':songList[select]['al']['picUrl']
      };
      songData['playInfo'] = {
        'url':playUrl2+songID.toString()+'.mp3',
        'br':'128000',
        'size':songList[select]['l']!=null?songList[select]['l']['size']:996,
      };
      String url = commentUrl2 + songID.toString();
      RequestOptions requestOptions =  RequestOptions(baseUrl: url,headers: headers);
     await Future.delayed(const Duration(milliseconds: 100));
      Response response = await HttpUtil().get('',options: requestOptions);
      var commentInfo = jsonDecode(response.data);
      int commentLength = commentInfo['hotComments'].length;
      if (commentLength==0) return;
      int select2 = Random().nextInt(commentLength);
      songData['commentInfo'] = {
        'name': commentInfo['hotComments'][select2]['user']['nickname'],
        'content':commentInfo['hotComments'][select2]['content'],
        'likedCount':commentInfo['hotComments'][select2]['likedCount'],
      };
      return songData;

   }
   Future getRandomSong() async {

     while(curSecond<=timeout){
       ++reqTime;
       //showToast('请求第$reqTime 次');
       var rng = new Random();
       List songIDList=[];
       //int songID = 85580;
       for(int i=0;i<randomCount;i++){
         var songID = (rng.nextInt(maxID-minID) + minID).toString(); //
         songIDList.add(songID);
       }
       var baseInfo = await getSongInfo(songIDList);
       if(baseInfo == null) break;
       var songs = baseInfo['songs'];
       if (songs.length ==0) {
         await Future.delayed(const Duration(milliseconds: 100));
         continue;
       }
       List usefulSongID = [];
       Map  usefulSongMap ={};
       songs.forEach((e){
         if(e['name']!=null){
           usefulSongID.add(e['id']);
           usefulSongMap[e['id']]=e;

         }
       });
       if(usefulSongID.length==0){
         await Future.delayed(const Duration(milliseconds: 100));
         continue;
       }
       var playInfo = await getPlayInfo(usefulSongID);
       print('歌曲url信息 -- $playInfo');
       List urls = playInfo['data'];
       List usefulUrlID = [];
       Map  usefulUrlMap= {};
       urls.forEach((e) {
         if(e['url'] != null) {
           usefulUrlID.add(e['id']);
           usefulUrlMap[e['id']]=e;
         }
       });
       if(usefulUrlID.length==0){
         await Future.delayed(const Duration(milliseconds: 100));
         continue;
       }
       int flag=0;
       var commentInfo;
       var songID;
       for(int i=0;i<usefulUrlID.length;i++) {
         var _commentInfo = await getCommentInfo(usefulUrlID[i].toString());
         print('评论信息 -- $_commentInfo');
         if(_commentInfo['hotComments'].length!=0){
           flag=1;
           songID = usefulUrlID[i];
           commentInfo=_commentInfo;
           break;
         }
       }
       if(flag!=1){
         await Future.delayed(const Duration(milliseconds: 100));
         continue;
       }
       int commentLength = commentInfo['hotComments'].length;
       int select = Random().nextInt(commentLength);
       songData['commentInfo'] = {
         'name': commentInfo['hotComments'][select]['user']['nickname'],
         'content':commentInfo['hotComments'][select]['content'],
         'likedCount':commentInfo['hotComments'][select]['likedCount'],
       };
       songData['playInfo'] = {
         'url':usefulUrlMap[songID]['url'],
         'br':usefulUrlMap[songID]['br'],
         'size':usefulUrlMap[songID]['size'],
       };
       songData['baseInfo'] = {
         'id':songID.toString(),
         'name':usefulSongMap[songID]['name'],
         'author':usefulSongMap[songID]['artists'][0]['name'],
         'picUrl':usefulSongMap[songID]['album']['picUrl']
       };
       break;
     }
     return songData;

  }

  getRandomSongGoods() async{ //瀑布流歌曲
     List<Map> res = List();
     List mode=playlistMap.values.toList();
     int index=Random().nextInt(mode.length);
     List<Map> r;

     try {
        r= await getSongGoods(mode[index]);
     }catch(e){
       print('捕捉到异常$e');
       return res;
     }
    //r= await getSongGoods(mode[index]);
     if (r==null)  return res;
     return r;
  }
   Future getSongGoods(playlistID,{int count=10}) async {
     await Future.delayed(const Duration(milliseconds: 100));
     List<Map> songDataList = List();
//     var playlistInfo = await getPlaylistInfoTotal(playlistID.toString());
//     if (playlistInfo==null) return;
//     if(playlistInfo['code']!=200)return;
//     List songList = playlistInfo['result']['tracks'];
//     if (songList.length==0) return;
     var playlistInfo = await getPlaylistInfo(playlistID);
     if (playlistInfo==null) return;
     List songList = playlistInfo['playlist']['tracks'];
     if (songList.length==0) return;

     Set selectList = Set();
     if(songList.length<=count)
       count=songList.length;
     print('get ok3,songList length is ${songList.length}');
     while(selectList.length<count){
       int select = Random().nextInt(songList.length);
       selectList.add(select);

     }

     String type='未知';
     if (playlistID==3778678)type='热曲';
     else if (playlistID==3779629)type='新品';
     else if (playlistID==2884035)type='原创';
     else if (playlistID==19723756)type='飙升';
     var handleQuality = (List songData,data,name){
       if(data==null)return;
       Map t={
         'name':name,
         'size':(data['size']/1024/1024).toStringAsFixed(1)
       };
       songData.add(t);
     };
     await  Future.forEach(selectList.toList(),(select) async{
       Map songData=Map();
       int songID = songList[select]['id'];
       await Future.delayed(const Duration(milliseconds: 50));
       var songInfo = await getSongInfo(songID);
       if (songInfo==null)return;
       var song;
       try {
          song = songInfo['songs'][0];
       }catch (e){
         print('getSongInfo error -- $songInfo');
         return;
       }
       songData['type']=type;
       songData['oldPrice']=song['score'];
       songData['newPrice']=song['score']-1-Random().nextInt(10);
       songData['publishTime']=song['album']['publishTime'];
       songData['company']=song['album']['company'];
       songData['albumName']=song['album']['name'];
       songData['subType']=song['album']['subType'];
       songData['quality'] = List();
       handleQuality(songData['quality'],song['lMusic'],'标准版');
       handleQuality(songData['quality'],song['mMusic'],'较高版');
       handleQuality(songData['quality'],song['hMusic'],'极高版');
       songData['baseInfo'] = {
         'id':songID.toString(),
         'name':song['name'],
         'author':song['artists'][0]['name'],
         'authorId':song['artists'][0]['id'],
         'picUrl':song['album']['picUrl'],
         'albumId':song['album']['id']
       };
       songData['playInfo'] = {
         'url':playUrl2+songID.toString()+'.mp3',
         'br':'128000',
         'size':song['lMusic']!=null?song['lMusic']['size']:996,
       };

//       songData['type']=type;
//       songData['oldPrice']=songList[select]['score'];
//       songData['newPrice']=songList[select]['score']-1-Random().nextInt(10);
//       songData['publishTime']=songList[select]['album']['publishTime'];
//       songData['company']=songList[select]['album']['company'];
//       songData['albumName']=songList[select]['album']['name'];
//       songData['subType']=songList[select]['album']['subType'];
//       songData['quality'] = List();
//       handleQuality(songData['quality'],songList[select]['lMusic'],'标准版');
//       handleQuality(songData['quality'],songList[select]['mMusic'],'较高版');
//       handleQuality(songData['quality'],songList[select]['hMusic'],'极高版');
//       songData['baseInfo'] = {
//         'id':songID.toString(),
//         'name':songList[select]['name'],
//         'author':songList[select]['artists'][0]['name'],
//         'authorId':songList[select]['artists'][0]['id'],
//         'picUrl':songList[select]['album']['picUrl'],
//         'albumId':songList[select]['album']['id']
//       };
//       songData['playInfo'] = {
//         'url':playUrl2+songID.toString()+'.mp3',
//         'br':'128000',
//         'size':songList[select]['l']!=null?songList[select]['l']['size']:996,
//       };
       String url = commentUrl2 + songID.toString();
       RequestOptions requestOptions =  RequestOptions(baseUrl: url,headers: headers);
       await Future.delayed(const Duration(milliseconds: 50));
       Response response = await HttpUtil().get('',options: requestOptions);
       if((response.data==null)) return;
       var commentInfo = jsonDecode(response.data);
       //print(commentInfo);
       int commentLength = commentInfo['hotComments'].length;
       if(commentLength>0){
         int select2 = Random().nextInt(commentLength);
         songData['commentInfo'] = {
           'name': commentInfo['hotComments'][select2]['user']['nickname'],
           'content':commentInfo['hotComments'][select2]['content'],
           'total':commentInfo['total'],
           'likedCount':commentInfo['hotComments'][select2]['likedCount'],
           'avatarUrl':commentInfo['hotComments'][select2]['user']['avatarUrl'],
         };
         songDataList.add(songData);
       }
     });
     return songDataList;

   }

}

