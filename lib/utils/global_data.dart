

class Dimens {
  static const double font_sp10 = 10.0;
  static const double font_sp12 = 12.0;
  static const double font_sp14 = 14.0;
  static const double font_sp15 = 15.0;
  static const double font_sp16 = 16.0;
  static const double font_sp18 = 18.0;

  static const double gap_dp4 = 4;
  static const double gap_dp5 = 5;
  static const double gap_dp8 = 8;
  static const double gap_dp10 = 10;
  static const double gap_dp12 = 12;
  static const double gap_dp15 = 15;
  static const double gap_dp16 = 16;
  static const double gap_dp24 = 24;
  static const double gap_dp32 = 32;
  static const double gap_dp50 = 50;
}


enum CustomIMType{
  JOIN_GROUP
}

enum GroupIdentity{
  OWNER,
  ADMIN,
  MEMBER
}

class Constant{
  static const bool isProduction = const bool.fromEnvironment("dart.vm.product");
  static const String mapKey = "c61899588ee0a2f401661d6d6acab1cc";  // 高德key
  static const String mapKeyProduction = "21f83bc85c6ee7210f71812c7e4abc80";
  static const String downloadSongPath = "/storage/emulated/0/Download/musicX/";
  static const String localWYYPath = "/storage/emulated/0/netease/cloudmusic/Music"; // 本地网易云路径
  static const double bottomNavHeight = 50.0;
  static const String defaultSongImage ="assets/img/sheet.jpg";
  static const String defaultLoadImage ="assets/img/placeholder.jpeg";
  static const String appTheme = 'appTheme';
  static const String mySongSheet = "mySongSheet";
  static const String myFavoriteSong = "myFavoriteSong";
  static const String localSong = "localSong";
  static const String downloadTask = "downloadTask";
  static const String sheetSearch = "sheetSearch";
  static const String goodsType = "goodsType";
  static const String IMAppKey = '1114190926153992#pmtalk'; // 环信key
  static const List IMUser = ['test', 'test1', 'test2']; // 测试用户
  static const String IMPwd = '123456';
  static const String keyboardH = 'keyboardH';
  static const String personInfo = 'personInfo';  // 好友信息储存
  static const String userToken = 'userToken';
  static const String userInfo = 'userInfo_';  // 自己信息
  static const String userId= 'userId';  // 当前登录用户

}
