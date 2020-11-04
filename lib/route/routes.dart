import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:music_x/widgets/detail_image.dart';
import 'dart:convert';

import './route_handle.dart';

class Application{
  static FluroRouter router;
}

class Routes {
  static String root = "/";
  static String index = "/index";
  static String myFrom = "/form";
  static String myHeroPage = "/heroPage";
  static String myFrom2 = "/form2";
  static String playSong = "/playSongPage";
  static String songSheet = '/songSheetPage';
  static String localSong = '/localSong';
  static String songComment = '/songComment';
  static String songManage = '/songManage';
  static String netSongSheet = '/netSongSheet';
  static String goodsDetail = '/goodsDetail';
  static String songArtist = '/songArtist';
  static String goodsTypeManage = '/goodsTypeManage';
  static String goodsSheet = '/goodsSheet';
  static String appSetting = '/appSetting';
  static String chatRoom = '/chatRoom';
  static String chatRoom2 = '/chatRoom2';
  static String detailImgChat = '/detailImgChat';
  static String locationMap = '/locationMap';
  static String personInfo = '/personInfo';
  static String personInfoSet = '/personInfoSet';
  static String personInfoRemarkSet = '/personInfoRemarkSet';
  static String friendPermissionSet = '/friendPermissionSet';
  static String chatInfo = '/chatInfo';
  static String createGroup = '/createGroup';
  static String groupList = '/groupList';
  static String groupInfo = '/groupInfo';
  static String login = '/login';
  static String groupDetail = '/groupDetail';
  static String groupMember = '/groupMember';
  static String groupNotice = '/groupNotice';

  static void configureRoutes(FluroRouter router) {

    router.notFoundHandler = notFoundPage;
    /// 第一个参数是路由地址，第二个参数是页面跳转和传参，第三个参数是默认的转场动画，可以看上图
    /// 我这边先不设置默认的转场动画，转场动画在下面会讲，可以在另外一个地方设置（可以看NavigatorUtil类）
    router.define(root, handler: splashPage);
    router.define(index, handler: indexPage);
    router.define(playSong, handler: playSongPage);
    router.define(songSheet, handler: songSheetPage);
    router.define(localSong, handler: localAndDownloadPage);
    router.define(songComment, handler: songCommentPage);
    router.define(songManage, handler: songManagePage);
    router.define(netSongSheet, handler: networkSongSheetPage);
    router.define(goodsDetail, handler: goodsDetailPage);
    router.define(songArtist, handler: songArtistPage);
    router.define(goodsTypeManage, handler: goodsTypeManagePage);
    router.define(goodsSheet, handler: goodsSheetPage);
    router.define(appSetting, handler: settingPage);
    router.define(chatRoom, handler: chatRoomPage);
    router.define(chatRoom2, handler: chatRoomPage2);
    router.define(detailImgChat, handler: detailImageChat);
    router.define(locationMap, handler: locationMapPage);
    router.define(personInfo, handler: personInfoPage);
    router.define(personInfoSet, handler: personInfoSetPage);
    router.define(personInfoRemarkSet, handler: personInfoRemarkSetPage);
    router.define(friendPermissionSet, handler: friendPermissionSetPage);
    router.define(chatInfo, handler: chatInfoPage);
    router.define(createGroup, handler: createGroupPage);
    router.define(groupList, handler: groupListPage);
    router.define(groupInfo, handler: groupInfoPage);
    router.define(login, handler: loginPage);
    router.define(groupDetail, handler: groupDetailPage);
    router.define(groupMember, handler: groupMemberPage);
    router.define(groupNotice, handler: groupNoticePage);

  }
}
class NavigatorUtil {
  static void goBack(BuildContext context) {
    Navigator.pop(context);
    Application.router.pop(context);
  }
  // 带参数的返回
  static void goBackWithParams(BuildContext context, result) {
    Navigator.pop(context, result);
  }

  // 路由返回指定页面
  static void goBackUrl(BuildContext context, String title) {
    Navigator.popAndPushNamed(context, title);
  }
  /// 框架自带的有 native，nativeModal，inFromLeft，inFromRight，inFromBottom，fadeIn，custom
  static Future jump(BuildContext context, String title) {
    return Application.router.navigateTo(context, title, transition: TransitionType.cupertino);
  }
  static void goHome(BuildContext context) {
    Application.router.navigateTo(context, Routes.index,replace: true);
  }
  static void goLogin(BuildContext context) {
    Application.router.navigateTo(context, Routes.login,replace: true);
  }

  static void goPlaySong(BuildContext context){
    Application.router.navigateTo(context, Routes.playSong, replace: false,
        transition: TransitionType.fadeIn,transitionDuration:const Duration(milliseconds: 500)
    );
  }

  static void goForm(BuildContext context) {
    Application.router.navigateTo(context, Routes.myFrom, replace: false,transition: TransitionType.custom,
      transitionBuilder: transition, transitionDuration: const Duration(milliseconds: 600));
    //Navigator.push(context, CustomRouteSlide(FormPage()));
    //Application.router.navigateTo(context, Routes.myFrom, replace: false,transition: TransitionType.inFromRight);
//    Navigator.of(context).push(
//      MaterialPageRoute(
//        builder: (context) {
//          return FormPage();
//        },
//      ),
//    );

  }
  static void goForm2(BuildContext context) {

   Application.router.navigateTo(context, Routes.myFrom2, replace: false,transition: TransitionType.native);
//    Navigator.of(context).push(
//      CupertinoPageRoute(
//        builder: (context) {
//          return FormPage2();
//        },
//      ),
//    );

    //Navigator.push(context, CustomRouteSlide(FormPage2()));


  }
  static void goHeroPage(BuildContext context) {
    Application.router.navigateTo(context, Routes.myHeroPage, replace: false,transition: TransitionType.native);
  }
  static void goSongSheetPage(BuildContext context,Map sheetInfo ) {
    String sheet = FluroConvertUtils.object2string(sheetInfo);
    Application.router.navigateTo(context, Routes.songSheet+'?sheet=$sheet', replace: false,transition: TransitionType.cupertino);
  }
  static void goLocalSongPage(BuildContext context) {
    Application.router.navigateTo(context, Routes.localSong, replace: false,transition: TransitionType.cupertino);
  }
  static void goSongCommentPage(BuildContext context,Map songInfo) {
    String song = FluroConvertUtils.object2string(songInfo);
    Application.router.navigateTo(context, Routes.songComment+'?songInfo=$song', replace: false,transition: TransitionType.cupertino);
  }
  static void goSongManagePage(BuildContext context,{String sheetId}) {
    if(sheetId!=null)
    Application.router.navigateTo(context, Routes.songManage+'?sheetId=$sheetId', replace: false,transition: TransitionType.cupertino);
  else
      Application.router.navigateTo(context, Routes.songManage, replace: false,transition: TransitionType.cupertino);
  }
  static void goNetworkSongSheetPage(BuildContext context,Map sheetInfo ) {
    String sheet = FluroConvertUtils.object2string(sheetInfo);
    Application.router.navigateTo(context, Routes.netSongSheet+'?sheet=$sheet', replace: false,transition: TransitionType.cupertino);
  }
  static void goGoodsDetailPage(BuildContext context,Map songInfo) {
    String song = FluroConvertUtils.object2string(songInfo);
    Application.router.navigateTo(context, Routes.goodsDetail+'?songInfo=$song', transition: TransitionType.cupertino);
  }
  static void goSongArtistPage(BuildContext context,String artistId) {
    Application.router.navigateTo(context, Routes.songArtist+'?artistId=$artistId', transition: TransitionType.cupertino);
  }
  static  goGoodsTypeManagePage(BuildContext context) {
    return Application.router.navigateTo(context, Routes.goodsTypeManage, transition: TransitionType.cupertino);
  }
  static void goGoodsSheetPage(BuildContext context,String sheetName) {
    String name =FluroConvertUtils.fluroCnParamsEncode(sheetName);
    Application.router.navigateTo(context, Routes.goodsSheet+'?sheetName=$name', transition: TransitionType.cupertino);
  }
  static  goAppSettingPage(BuildContext context) {
    return Application.router.navigateTo(context, Routes.appSetting, transition: TransitionType.cupertino);
  }
  static Future goChatRoomPage(BuildContext context,Map chatRoomInfo) {
    String info = FluroConvertUtils.object2string(chatRoomInfo);
    return Application.router.navigateTo(context, Routes.chatRoom+'?chatRoomInfo=$info', transition: TransitionType.cupertino);
  }
  static void goChatRoomPage2(BuildContext context) {

    Application.router.navigateTo(context, Routes.chatRoom2, transition: TransitionType.cupertino);
  }
  static void goDetailImageChat(BuildContext context,String userId,Map message) {
//   Map t = {
//     'userId':userId,
//     'msgTimeStamp':msgTimeStamp,
//     'imgPath':imgPath,
//     'isLocal':isLocal
//   };
   //print('t is $t');
    String _userId =FluroConvertUtils.fluroCnParamsEncode(userId);
   String t2 =  FluroConvertUtils.object2string(message);
//    Navigator.of(context).push(
//      MaterialPageRoute(
//        builder: (context) {
//          return ChatDetailImagePage(
//              _userId,
//            t2
//          );
//        },
//      ),
//    );



    Application.router.navigateTo(context, Routes.detailImgChat+'?userId=$_userId&message=$t2', transition: TransitionType.fadeIn);
  }
  static  goLocationMapPage(BuildContext context,{Map location}) {
    String route =  Routes.locationMap;
    if(location!=null){
      String info = FluroConvertUtils.object2string(location);
      route+='?location=$info';
    }
    return Application.router.navigateTo(context, route, transition: TransitionType.cupertino);
  }
  static void goPersonInfoPage(BuildContext context,String userId) {
    String userIdT = FluroConvertUtils.fluroCnParamsEncode(userId);
    Application.router.navigateTo(context, Routes.personInfo+'?userId=$userIdT', transition: TransitionType.cupertino);
  }
  static Future goPersonInfoSetPage(BuildContext context,String  userId) {
    String userIdT = FluroConvertUtils.fluroCnParamsEncode(userId);
   return Application.router.navigateTo(context, Routes.personInfoSet+'?userId=$userIdT', transition: TransitionType.cupertino);
  }
  static Future goPersonInfoRemarkSetPage(BuildContext context,String  userId) {
    String userIdT = FluroConvertUtils.fluroCnParamsEncode(userId);
    return Application.router.navigateTo(context, Routes.personInfoRemarkSet+'?userId=$userIdT', transition: TransitionType.cupertino);
  }
  static Future goFriendPermissionSetPage(BuildContext context,String  userId) {
    String userIdT = FluroConvertUtils.fluroCnParamsEncode(userId);
    return Application.router.navigateTo(context, Routes.friendPermissionSet+'?userId=$userIdT', transition: TransitionType.cupertino);
  }
  static Future goChatInfoPage(BuildContext context,String  userId) {
    String userIdT = FluroConvertUtils.fluroCnParamsEncode(userId);
    return Application.router.navigateTo(context, Routes.chatInfo+'?userId=$userIdT', transition: TransitionType.cupertino);
  }
  static Future goCreateGroupPage(BuildContext context,{String action}) {
    if(action!=null)
    return Application.router.navigateTo(context, Routes.createGroup+'?action=$action', transition: TransitionType.cupertino);
    return Application.router.navigateTo(context, Routes.createGroup, transition: TransitionType.cupertino);
  }
  static void goGroupListPage(BuildContext context) {

    Application.router.navigateTo(context, Routes.groupList, transition: TransitionType.cupertino);
  }
  static Future goGroupInfoPage(BuildContext context,String  groupId) {

    return Application.router.navigateTo(context, Routes.groupInfo+'?groupId=$groupId', transition: TransitionType.cupertino);
  }
  static void goGroupDetailPage(BuildContext context,String  groupId) {

     Application.router.navigateTo(context, Routes.groupDetail+'?groupId=$groupId', transition: TransitionType.cupertino);
  }
  static Future goGroupMemberPage(BuildContext context,String  groupId) {

    return Application.router.navigateTo(context, Routes.groupMember+'?groupId=$groupId', transition: TransitionType.cupertino);
  }
  static Future goGroupNoticePage(BuildContext context,String  groupId) {

    return Application.router.navigateTo(context, Routes.groupNotice+'?groupId=$groupId', transition: TransitionType.cupertino);
  }
}



/// fluro 参数编码解码工具类
class FluroConvertUtils {
  /// fluro 传递中文参数前，先转换，fluro 不支持中文传递
  static String fluroCnParamsEncode(String originalCn) {
    return jsonEncode(Utf8Encoder().convert(originalCn));
  }

  /// fluro 传递后取出参数，解析
  static String fluroCnParamsDecode(String encodeCn) {
    var list = List<int>();

    ///字符串解码
    jsonDecode(encodeCn).forEach(list.add);
    String value = Utf8Decoder().convert(list);
    return value;
  }

  /// string 转为 int
  static int string2int(String str) {
    return int.parse(str);
  }

  /// string 转为 double
  static double string2double(String str) {
    return double.parse(str);
  }

  /// string 转为 bool
  static bool string2bool(String str) {
    if (str == 'true') {
      return true;
    } else {
      return false;
    }
  }

  /// object 转为 string json
  static String object2string<T>(T t) {
    return fluroCnParamsEncode(jsonEncode(t));
  }

  /// string json 转为 map
  static Map<String, dynamic> string2map(String str) {
    return json.decode(fluroCnParamsDecode(str));
  }
}

class CustomRouteSlide extends PageRouteBuilder {
  final Widget widget;

  CustomRouteSlide(this.widget)
      :super(
      transitionDuration: const Duration(seconds: 1),
      pageBuilder: (BuildContext context,
          Animation<double> animation1,
          Animation<double> animation2) {
        return widget;
      },
      transitionsBuilder: (BuildContext context,
          Animation<double> animation1,
          Animation<double> animation2,
          Widget child) {
        return SlideTransition(
          position: Tween<Offset>(
              begin: Offset(-1.0, 0.0),
              end: Offset(0.0, 0.0)
          )
              .animate(CurvedAnimation(
              parent: animation1,
              curve: Curves.fastOutSlowIn
          )),
          child: child,

        );
      }
  );
}


class CustomRouteZoom extends PageRouteBuilder{
  final Widget widget;
  CustomRouteZoom(this.widget)
      :super(
      transitionDuration:const Duration(seconds:1),
      pageBuilder:(
          BuildContext context,
          Animation<double> animation1,
          Animation<double> animation2){
        return widget;
      },
      transitionsBuilder:(
          BuildContext context,
          Animation<double> animation1,
          Animation<double> animation2,
          Widget child){

        return ScaleTransition(
            scale:Tween(begin:0.0,end:1.0).animate(CurvedAnimation(
                parent:animation1,
                curve: Curves.fastOutSlowIn
            )),
            child:child
        );

      }
  );
}

// ignore: top_level_function_literal_block
var transition = (BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  print('child $child');
  return new ScaleTransition(
    scale: animation,
    child: new RotationTransition(
      turns: animation,
      child: child,
    ),
  );
};
