import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/utils/global_data.dart';
enum UserType{
  GUEST,
  COMMON,
  VIP
}


class UserProvider extends ChangeNotifier {
  UserType _userType;
  String _userId;

  String _userNickname;
  String _userToken;

  UserType get userType => _userType;

  String get userId => _userId;

  String get userNickname => _userNickname;

  String get userToken => _userToken;

  bool get isGuest => _userType==UserType.GUEST;

  void saveUser({UserType userType,String userToken,String userId,String userNickname="卧夜思雨"}){
    _userId=userId;
    _userType=userType;
    _userToken=userToken;
    _userNickname = userNickname;
    //SpUtil.putString(Constant.userToken,userToken);
    Map t = {
    'userId':userId,
    'userType':userType.index,
    'userNickname' : userNickname,
      'userToken':userToken
    };
    SpUtil.putString(Constant.userId, userId);
    SpUtil.putObject(Constant.userInfo+userId, t);
    notifyListeners();
  }
  void logout(){
    try {
      SpUtil.remove(Constant.userId);
      SpUtil.remove(Constant.userInfo + userId);
    }catch(e){

    }
    _userNickname=null;
    _userToken=null;
    _userType=null;
    _userId=null;
    if(EMClient.getInstance().isConnected())
    EMClient.getInstance().logout(true);
  }


}
