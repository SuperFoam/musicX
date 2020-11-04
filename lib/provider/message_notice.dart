import 'dart:collection';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/utils/global_data.dart';
class IMNoticeProvider with ChangeNotifier{
  //LinkedList newMsg=LinkedList();
  EMMessage _newMsg;
  //ListQueue newMsg = ListQueue();
  int _unreadMsgCount=0;
  EMMessage get newMsg =>_newMsg;
  int get unreadMsgCount=>_unreadMsgCount;
  bool loadConversation=false;

  void updateMsgCount() async{
    String userId=SpUtil.getString(Constant.userId);
    Map userInfo = SpUtil.getObject(Constant.userInfo + userId);
    UserType userType = UserType.values[userInfo['userType']??0];
    if(userType==UserType.GUEST)return;
    int count = await EMClient.getInstance()?.chatManager()?.getUnreadMessageCount();
    _unreadMsgCount=count;

    notifyListeners();
  }
  void updateConversation(){
   // addListener(() { })
    loadConversation=true;
    notifyListeners();

  }

}
