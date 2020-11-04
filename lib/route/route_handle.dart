import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:music_x/bottom_nav/home.dart';
import 'package:music_x/pages/msg/person/chat_info_page.dart';
import 'package:music_x/pages/msg/chat_room.dart';
import 'package:music_x/pages/msg/chat_room2.dart';
import 'package:music_x/pages/msg/group/group_detail.dart';
import 'package:music_x/pages/msg/group/group_member.dart';
import 'package:music_x/pages/msg/group/group_notice.dart';
import 'package:music_x/pages/msg/group/create_group_page.dart';
import 'package:music_x/pages/msg/person/friend_permission_set_page.dart';
import 'package:music_x/pages/msg/group/group_info_page.dart';
import 'package:music_x/pages/msg/group/group_list_page.dart';
import 'package:music_x/pages/msg/person/info_set_page.dart';
import 'package:music_x/pages/msg/person/person_info_page.dart';
import 'package:music_x/pages/msg/person/remark_set_page.dart';
import 'package:music_x/pages/my/login.dart';
import 'package:music_x/pages/my/setting.dart';
import 'package:music_x/pages/song/comment.dart';
import 'package:music_x/pages/song/local_download.dart';
import 'package:music_x/pages/song/network_song_sheet.dart';
import 'package:music_x/pages/song/play_songs_page.dart';
import 'package:music_x/pages/song/song_manage.dart';
import 'package:music_x/pages/song/song_sheet.dart';
import 'package:music_x/pages/splash.dart';
import 'package:music_x/pages/store/goodsType.dart';
import 'package:music_x/pages/store/goods_detail.dart';
import 'package:music_x/pages/store/goods_sheet.dart';
import 'package:music_x/pages/store/song_artist.dart';
import 'package:music_x/widgets/detail_image.dart';
import 'package:music_x/widgets/location_map.dart';
import '../index.dart';
import '../pages/not_found.dart';


Handler loginPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LoginPage();
});
Handler indexPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return IndexPage();
});

Handler notFoundPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return NotFoundPage();
});

Handler homePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return HomePage();
});

Handler splashPage = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return SplashPage();

  },
);

Handler playSongPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return PlaySongsPage();
});

Handler songSheetPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String sheetInfo = params['sheet']?.first;
  return SongSheetPage(
    sheet: sheetInfo,
  );
});

Handler localAndDownloadPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LocalDownloadPage();
});

Handler songCommentPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String songInfo = params['songInfo']?.first;
  return SongCommentPage(
    songInfo: songInfo,
  );
});

Handler songManagePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String sheetId = params['sheetId']?.first;
  return SongManagePage(
    sheetId: sheetId,
  );
});
Handler networkSongSheetPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String sheetInfo = params['sheet']?.first;
  return NetworkSongSheetPage(
    sheet: sheetInfo,
  );
});
Handler goodsDetailPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String songInfo = params['songInfo']?.first;
  return GoodsDetailPage(
    songInfo: songInfo,
  );
});

Handler songArtistPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String artistId = params['artistId']?.first;
  return SongArtistPage(
    artistId: artistId,
  );
});

Handler goodsTypeManagePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return GoodsTypeManagePage();
});

Handler goodsSheetPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String sheetName = params['sheetName']?.first;
  return GoodsSheetPage(
    sheetName: sheetName,
  );
});

Handler settingPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SettingPage();
});
Handler chatRoomPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String chatRoomInfo = params['chatRoomInfo']?.first;
  return ChatRoomPage(
      chatRoomInfo
  );
});
Handler chatRoomPage2 = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {

  return ChatRoomPage2(
  );
});
Handler detailImageChat = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//  Map imgInfo =  FluroConvertUtils.string2map(params['imgInfo']?.first);
//  String imgPath =imgInfo['imgPath'];
//  bool isLocal = imgInfo['isLocal'];
//  String msgTimeStamp = imgInfo['msgTimeStamp'];
  String userId = params['userId']?.first;
  String message =  params['message']?.first;
  return ChatDetailImagePage(
    userId,
message

//      userId,
//      msgTimeStamp,
//      imgPath,
//      isLocal
  );
});
Handler locationMapPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String locationInfo = params['location']?.first;
  return LocationMapPage(
    locationInfo: locationInfo,
  );
});
Handler personInfoPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String userId = params['userId']?.first;
  return PersonInfoPage(
      userId:userId
  );
});
Handler personInfoSetPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String userId = params['userId']?.first;
  return PersonInfoSetPage(
      userId:userId
  );
});
Handler personInfoRemarkSetPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String userId = params['userId']?.first;
  return PersonInfoRemarkSetPage(
      userId:userId
  );
});
Handler friendPermissionSetPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String userId = params['userId']?.first;
  return FriendPermissionSetPage(
      userId:userId
  );
});
Handler chatInfoPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String userId = params['userId']?.first;
  return ChatInfoPage(
      userId:userId
  );
});
Handler createGroupPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String action = params['action']?.first;
  if(action!=null)
    return CreateGroupPage(
        action: action,
    );
  return CreateGroupPage(

  );
});
Handler groupListPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {

  return GroupListPage(

  );
});
Handler groupInfoPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String groupId = params['groupId']?.first;
  return GroupInfoPage(
      groupId
  );
});

Handler groupDetailPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String groupId = params['groupId']?.first;
  return GroupDetailPage(
      groupId
  );
});
Handler groupMemberPage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String groupId = params['groupId']?.first;
  return GroupMemberPage(
      groupId
  );
});
Handler groupNoticePage = Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String groupId = params['groupId']?.first;
  return GroupNoticePage(
      groupId
  );
});
