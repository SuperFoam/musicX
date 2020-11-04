import 'dart:ui';

import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:provider/provider.dart';
import 'package:music_x/provider/provider.dart';
import 'package:flustars/flustars.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}
class _SplashPageState extends State<SplashPage> {
  StreamController<double> processController = StreamController<double>();
  double value=0.0;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
//    if (Platform.isAndroid) {
//      SystemUiOverlayStyle style =
//      SystemUiOverlayStyle(statusBarColor: Colors.transparent,
//          statusBarIconBrightness: Brightness.light );
//      SystemChrome.setSystemUIOverlayStyle(style);
//    }
    _timer=Timer.periodic(Duration(milliseconds: 100), (timer) {
      value+=0.05;
      if(value>=1.0){
        value=1.0;
        timer.cancel();
      }
      processController.add(value);
    });
    _initSplash();


  }
  @override
  void dispose(){
    _timer?.cancel();
    processController.close();
    super.dispose();
  }
  void loadDone(){
    while(value<=1.0){
      value+=0.2;
      processController.add(value);
    }
    _timer.cancel();

  }


  _initSplash()  async{
    print('-------------getInstance');
    await SpUtil.getInstance();
    Provider.of<ThemeProvider>(context, listen: false).syncTheme();
     await FlutterDownloader.initialize(
        debug: Constant.isProduction // optional: set false to disable printing logs to console
    );
     String key;
     if(Constant.isProduction==true)
       key = Constant.mapKeyProduction;
     else
       key=Constant.mapKey;
    // Utils.showToast('是否生产-${Constant.isProduction}');
    print('是否生产-${Constant.isProduction},key is $key');
      await AmapService.instance.init(
      androidKey: key,
        iosKey:  key,
    );
    checkLogin();

  }
  void checkLogin(){
    String userId=SpUtil.getString(Constant.userId);
    Map userInfo = getUserInfo(userId);
   // print('userInfo is $userInfo');
    if(userId == null || userInfo == null){
      loadDone();
      NavigatorUtil.goLogin(context);
    }
    else{
      UserType userType = UserType.values[userInfo['userType']??0];
      if(userType==UserType.GUEST)guestLogin();
      else initIM(userId, userInfo);
    }

  }
  void initIM(String userId,Map userInfo) {
    //var cancel = Utils.showLoading();
    EMOptions options = new EMOptions(appKey: Constant.IMAppKey);
    EMClient.getInstance().init(options);
    EMClient.getInstance().setDebugMode(Constant.isProduction);
    EMClient.getInstance().login(userId, Constant.IMPwd, onSuccess: (username) {
     // cancel();
      EMClient.getInstance().groupManager().loadAllGroups();
      EMClient.getInstance().chatManager().loadAllConversations();
      String token = userId + '_test_token';
      UserType userType = UserType.values[userInfo['userType']??0];
        Provider.of<UserProvider>(context, listen: false).saveUser(userToken: token, userId: userId,
            userType: userType, userNickname: userInfo['userNickname']);
      loadDone();
      Utils.showToast('$username登录成功');
      NavigatorUtil.goHome(context);
    }, onError: (code, desc) {
     // cancel();
      loadDone();
      Utils.showToast('登录失败-$desc');
      print('登录错误 -$code-- $desc');
      NavigatorUtil.goLogin(context);
    });
  }

  Map getUserInfo(String userId) {
    Map userInfo = SpUtil.getObject(Constant.userInfo + userId);
    return userInfo;
  }
  void guestLogin(){
    String token = 'guest_test_token';
    String userId = 'guest';
    UserType userType = UserType.GUEST;
    Provider.of<UserProvider>(context, listen: false).saveUser(userToken: token, userId: userId, userType: userType);
    loadDone();
    NavigatorUtil.goHome(context);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<double>(
          stream: processController.stream,
          builder: (BuildContext context, AsyncSnapshot<double> snapshot){
            return LinearProgressIndicator(
              value: snapshot.data??0.0,
            );
          },
        )
      ),
    );

  }
}
