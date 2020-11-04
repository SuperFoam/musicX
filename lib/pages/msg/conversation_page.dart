import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/model/msg/conversation.dart';
import 'package:music_x/provider/message_notice.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ConversationPageController {
  Future<void> Function() loadConversion;
}

class ConversationPage extends StatefulWidget {
  final ConversationPageController childController;
  ConversationPage(this.childController);
  @override
  State<StatefulWidget> createState() {
    return _ConversationPageState();
  }
}

class _ConversationPageState extends State<ConversationPage> with AutomaticKeepAliveClientMixin implements EMMessageListener ,EMConnectionListener {
  RefreshController _controllerR = RefreshController(initialRefresh: false);
  List<ConversionModel> conList = List<ConversionModel>();
  List<String> topConIdList = List();
  GlobalKey<SliverAnimatedListState> _animListKey = new GlobalKey();

  bool _isConnected=true ;
  int longPressIndex;

  List<PopupMenuEntry<String>> popupItem = [
    PopupMenuItem(
      value: 'read',
      child: Row(
        children: <Widget>[
          Icon(Icons.remove_red_eye),
          SizedBox(
            width: 3,
          ),
          Text("标为已读"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'top',
      child: Row(
        children: <Widget>[
          Icon(Icons.vertical_align_top),
          SizedBox(
            width: 3,
          ),
          Text("置顶聊天"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'delete',
      child: Row(
        children: <Widget>[
          Icon(Icons.delete),
          SizedBox(
            width: 3,
          ),
          Text("删除聊天"),
        ],
      ),
    ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    this.widget.childController.loadConversion = loadConversion ;
    print('ConversationPage init');
    initIM();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadConversion();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controllerR.dispose();
    EMClient.getInstance().removeConnectionListener(this);
    EMClient.getInstance().chatManager().removeMessageListener(this);
   // EMClient.getInstance().groupManager().removeGroupChangeListener(this);
    Provider.of<IMNoticeProvider>(context,listen: false).removeListener(onS);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void initIM(){
    if(Provider.of<UserProvider>(context,listen: false).isGuest)return;
    _isConnected=EMClient.getInstance().isConnected();
    EMClient.getInstance().addConnectionListener(this);
    EMClient.getInstance().chatManager().addMessageListener(this);
    // EMClient.getInstance().groupManager().addGroupChangeListener(this);
    Provider.of<IMNoticeProvider>(context,listen: false).addListener(onS);

  }

  void onS(){
    print('onS----receive');
   // if(mounted)loadConversion();
    if( Provider.of<IMNoticeProvider>(context,listen: false).loadConversation!=true)return;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(mounted)loadConversion();
      Provider.of<IMNoticeProvider>(context,listen: false).loadConversation=false;
    });
  }

  @override
  void onConnected() {
    print('onConnected');
    _isConnected = true;
    setState(() {});
  }

  @override
  void onDisconnected(int errorCode) {
    print('onDisconnected');
    _isConnected = false;
    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('会话页重建');
    return Column(
      children: <Widget>[
        if (_isConnected!=true) buildShowErrorNetwork,
        Expanded(
          child: CupertinoScrollbar(
            child: RefreshConfiguration(
              //maxUnderScrollExtent:200,
              hideFooterWhenNotFull: true,
              footerTriggerDistance: 150,
              child: SmartRefresher(
                  controller: _controllerR,
                  enablePullDown: true,
                  enablePullUp: false,
                  header: ClassicHeader(),
                  footer: ClassicFooter(
                    loadStyle: LoadStyle.ShowWhenLoading,
                    //completeDuration: Duration(microseconds: 50),
                    idleText: '',
                    loadingIcon: CupertinoActivityIndicator(),
                    canLoadingIcon: CupertinoActivityIndicator(),
                    canLoadingText: '',
                  ),
                  onRefresh: () async {
                    await loadConversion();
                    _controllerR.refreshCompleted();
                  },
                  child: conList.length==0?Center(child: Text('空空如也',style: TextStyles.text12Grey,),):buildShowConversionList()),
            ),
          ),
        )
      ],
    );
  }

  Widget buildShowConversionList() {
   // print('buildShowConversionList $conList ');
    return CustomScrollView(
      slivers: <Widget>[
        SliverAnimatedList(
          key: conList.length > 0 ? _animListKey : null,
          initialItemCount: conList.length,
          itemBuilder: (BuildContext context, int index, Animation animation) {
            return _buildItem(
              index,
              animation,
            );
          },
        )
      ],
    );
  }

  Widget _buildItem(int index, Animation _animation) {
    return SlideTransition(
        position: _animation.drive(Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0)).chain(CurveTween(curve: Curves.easeIn))),
        child: GestureDetector(
            onLongPressStart: (LongPressStartDetails details) {
              onLongPressConversation(details, index);
            },
            child: Material(
              color: longPressIndex == index ? Colors.grey.withOpacity(0.5) : conList[index].isTop ? Colors.grey.withOpacity(0.3) : null,
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  child: xImgRoundRadius(radius: 40 / 2),
                ),
                title: Text(conList[index].name),
                subtitle: buildShowLastMsg(conList[index].lastMsg),
                trailing: Container(
                  width: 50,
                  height: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Text(
                          formatTimeWX(conList[index].lastMsgTime, short: true),
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                      if (conList[index].unRead > 0)
                        Container(
                          alignment: Alignment.center,
                          width: 20,
                          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), borderRadius: BorderRadius.circular(5)),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              conList[index].unRead > 99 ? '99+' : conList[index].unRead.toString(),
                              style: TextStyle(fontSize: 11, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                onTap: () {
                   NavigatorUtil.goChatRoomPage(context, {"conversationId": conList[index].conversationId,
                    "conversationType": conList[index].conversationType}).then((value) {
                      if(value==true)loadConversion();
                   });
                  conList[index].unRead=0;
                 // Future.delayed(Duration(milliseconds: 100)).then((value) => loadConversion());

                },
              ),
            )));
  }

  Widget _buildItem2(ConversionModel item, Animation _animation) {
    return SlideTransition(
        position: _animation.drive(Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0)).chain(CurveTween(curve: Curves.easeIn))),
        child: Material(
          color: item.isTop ? Colors.grey.withOpacity(0.3) : null,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              child: xImgRoundRadius(radius: 40 / 2),
            ),
            title: Text(item.conversationId),
            subtitle: buildShowLastMsg(item.lastMsg),
            trailing: Container(
              width: 50,
              height: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: Text(
                      formatTimeWX(item.lastMsgTime, short: true),
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                  if (item.unRead > 0)
                    Container(
                      alignment: Alignment.center,
                      width: 20,
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(5)),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          item.unRead > 99 ? '99+' : item.unRead.toString(),
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ));
  }


  Widget get buildShowErrorNetwork {
    return Container(
      height: 30,
      color: Colors.red.withOpacity(0.6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error,
            color: Colors.red,
          ),
          SizedBox(
            width: 5,
          ),
          Text('网络连接不可用'),
        ],
      ),
    );
  }

  Widget buildShowLastMsg(EMMessage msg) {
    String content;
    switch (msg.type) {
      case EMMessageType.TXT:
        EMTextMessageBody body = msg.body;
        content = body.message;
        break;
      case EMMessageType.IMAGE:
        content = '[图片]';
        break;
      case EMMessageType.VIDEO:
        content = '[视频]';
        break;
      case EMMessageType.FILE:
        content = '[文件]';
        break;
      case EMMessageType.VOICE:
        content = '[语音]';
        break;
      case EMMessageType.LOCATION:
        content = '[位置]';
        break;
      case EMMessageType.CUSTOM:
        EMCustomMessageBody body = msg.body;
        if(body.event==CustomIMType.JOIN_GROUP.index.toString())
          content = '[加入群聊]';
        break;
      default:
        content = '未知消息内容';
    }

    return Text(
      content,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Future<void> loadConversion() async {
    conList.clear();
    if(Provider.of<UserProvider>(context,listen: false).isGuest){
      loadVirtualData();
      return;
    }
    Map map = await EMClient.getInstance().chatManager().getAllConversations();
    print(map);
    if (map.length == 0) {
      return null;
    }
    Map sortMap = Map();
    await Future.forEach(map.entries, (MapEntry element) async {
      var conversation = element.value as EMConversation;
       print('conversation id is ${conversation.conversationId}');
      EMMessage message = await conversation.getLastMessage();
      int unRead = await conversation.getUnreadMsgCount();
      if (message == null) {
        // print('message  is null');
        return;
      }
//      print(message.toDataMap());
//      print(jsonEncode(message.toDataMap()));
      bool isTop = false;
      int key = topConIdList.indexOf(conversation.conversationId);
      if (key != -1) {
        isTop = true;
      }
      String name;
      if(conversation.type==EMConversationType.GroupChat) {

        EMGroup group = await EMClient.getInstance().groupManager().getGroup(conversation.conversationId);
         name = group.getGroupName();
      }else
       name = conversation.conversationId;
      print('name is $name');
      Map<String, dynamic> t = {'isTop': isTop, 'lastMsg': message, 'unRead': unRead, 'lastMsgTime': message.msgTime,
        'conversationId': conversation.conversationId,"conversationType":conversation.type.index,'name':name};
      ConversionModel c = ConversionModel.fromData(t);
      if (key != -1) {
        sortMap[key] = c;
      } else
        conList.add(c);
    });

    conList.sort((a, b) => b.lastMsgTime.compareTo(a.lastMsgTime));
    if (sortMap.length > 0) {
      List<ConversionModel> t = List();
      List keys = sortMap.keys.toList();
      keys.sort((a, b) => b.compareTo(a));
      keys.forEach((element) {
        t.add(sortMap[element]);
      });
      conList.insertAll(0, t);
    }
     print(conList);
    _animListKey = new GlobalKey();
    setState(() {});
  }

  void loadVirtualData(){
    int count = 20;
    Map sortMap = Map();
    for(int i =0;i<count;i++){
      int unRead = i;
      bool isTop = false;
      int key = topConIdList.indexOf(i.toString());
      if (key != -1) {
        isTop = true;
      }
      String name;
      int msgTime=DateTime.now().millisecondsSinceEpoch-(i*1000*60*60*24);
      Map msg=  {"acked":false,"body":{"message":"测试消息-$i","type":1},
        "chatType":1,"conversationId":"$i","localTime":msgTime.toString(),"msgId":"799404943072036904",
        "msgTime":msgTime.toString(),"to":"guest","type":1,"unread":false,"userName":"admin"};;
      int type;
      if(i.isEven){
        type=1;
        name ='测试群组-$i';
        msg['chatType']=1;
      }

      else {
        type=0;
        name ='测试单聊-$i';
        msg['chatType']=0;
        msg['to']=i.toString();
        msg['userName']=i.toString();
      }

      EMMessage message=EMMessage.from(msg);
      Map<String, dynamic> t = {'isTop': isTop, 'lastMsg': message, 'unRead': unRead,
        'lastMsgTime': message.msgTime, 'conversationId': i.toString(),'conversationType':type,'name':name};
      ConversionModel c = ConversionModel.fromData(t);
      if (key != -1) {
        sortMap[key] = c;
      } else
        conList.add(c);

    }
    conList.sort((a, b) => b.lastMsgTime.compareTo(a.lastMsgTime));
    if (sortMap.length > 0) {
      List<ConversionModel> t = List();
      List keys = sortMap.keys.toList();
      keys.sort((a, b) => b.compareTo(a));
      keys.forEach((element) {
        t.add(sortMap[element]);
      });
      conList.insertAll(0, t);
    }
    print(conList);
    _animListKey = new GlobalKey();
    setState(() {});
  }

  void onLongPressConversation(LongPressStartDetails details, int index) async {
    setState(() {
      longPressIndex = index;
    });
    if (conList[index].isTop == true) {
      popupItem[1] = PopupMenuItem(
        value: 'cancleTop',
        child: Row(
          children: <Widget>[
            Icon(Icons.vertical_align_bottom),
            SizedBox(
              width: 3,
            ),
            Text("取消置顶"),
          ],
        ),
      );
    } else {
      popupItem[1] = PopupMenuItem(
        value: 'top',
        child: Row(
          children: <Widget>[
            Icon(Icons.vertical_align_top),
            SizedBox(
              width: 3,
            ),
            Text("置顶聊天"),
          ],
        ),
      );
    }
    String res = await showCustomPopupMenu(longPressDetail: details, popupItem: popupItem, context: context, bottomHeight: Constant.bottomNavHeight);
    print('res is $res');
    longPressIndex = null;
    if (res == null) {
      setState(() {});
      return;
    }
    int dur = 350;
    if (res == 'top') {
      conList[index].isTop = true;
      ConversionModel t = conList[index];
      //conList.add(conList[index]);
      // AnimatedList.of(context).removeItem(index, (context,animation)=>_buildItem(index,animation,context));

//      int endIndex = conList.length-1;
//      if(index!=endIndex)
//      conList.removeAt(index);
      conList.removeAt(index);
      _animListKey.currentState.removeItem(
          index,
          (context, animation) => _buildItem2(
                t,
                animation,
              ),
          duration: Duration(milliseconds: dur));

      Future.delayed(Duration(milliseconds: dur)).then((value) {
//        if(index==endIndex)
//        conList.removeAt(index);
        conList.insert(0, t);
        topConIdList.add(t.conversationId);
        _animListKey.currentState.insertItem(0, duration: Duration(milliseconds: dur));
      });
    } else if (res == 'cancleTop') {
      if (conList[index].isTop != true) {
        setState(() {});
        return;
      }
      conList[index].isTop = false;
      ConversionModel t = conList[index];
//      conList.removeAt(index);
//     int index2= conList.lastIndexWhere((element) => element.lastMsgTime>t.lastMsgTime);
//      print('index2 is $index2');
//     if(index2!=-1)
//       conList.insert(index2+1, t);
//     else
//       conList.insert(0, t);

//      int endIndex = conList.length-1;
//      if(index!=endIndex)
//        conList.removeAt(index);
      conList.removeAt(index);
      int index2 = conList.lastIndexWhere((element) => element.isTop != true && element.lastMsgTime > t.lastMsgTime);

      _animListKey.currentState.removeItem(
          index,
          (context, animation) => _buildItem2(
                t,
                animation,
              ),
          duration: Duration(milliseconds: dur));

      Future.delayed(Duration(milliseconds: dur)).then((value) {
//        if(index==endIndex)
//          conList.removeAt(index);
        int index3 = 0;
        if (index2 != -1)
          index3 = index2 + 1;
        else {
          index3 = topConIdList.length - 1;
        }
        // print('index3 is $index3');
        conList.insert(index3, t);
        topConIdList.remove(t.conversationId);
        _animListKey.currentState.insertItem(index3, duration: Duration(milliseconds: dur));
      });
    } else if (res == 'delete') {
      Color titleColor = Funs.isDarkMode(context)?Colours.dark_text:Colors.black87;
      bool res = await Funs.showCustomDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: RichText(
                text: TextSpan(style: TextStyles.textDialogTitle, children: [
                  TextSpan(text: '删除会话',  style: TextStyle(color: titleColor)),
                  TextSpan(text: ' - ${conList[index].conversationId}', style: TextStyles.textDialogName),
                ]),
              ),
              content: Text('删除后，将清空聊天记录！'),
              actions: <Widget>[
                FlatButton(
                  child: Text("取消"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text("确认"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          });
      if (res != true)
        setState(() {});
      else {
        ConversionModel t = conList[index];
        _animListKey.currentState.removeItem(
            index,
            (context, animation) => _buildItem2(
                  t,
                  animation,
                ),
            duration: Duration(milliseconds: dur));
        conList.removeAt(index);
        topConIdList.remove(t.conversationId);
//        Future.delayed(Duration(milliseconds: dur)).then((value) {
//          conList.removeAt(index);
//          topConIdList.remove(t.conversation.conversationId);
//        });

      }
    }
    else if (res == 'read'){
      conList[index].unRead=0;
      String id = conList[index].conversationId;
      EMConversationType type =EMConversationType.values[conList[index].conversationType];

      setState(() {

      });
      EMClient.getInstance().chatManager().getConversation(id,type,true).then((conversation){
        conversation.markAllMessagesAsRead();
        Provider.of<IMNoticeProvider>(context,listen: false).updateMsgCount();
      });
    }


  }

  @override
  void onMessageReceived(List<EMMessage> messages) {
    print('会话列表页收到onMessageReceived消息 $messages');
    loadConversion();
  }

  @override
  void onCmdMessageReceived(List<EMMessage> messages) {
    // TODO: implement onCmdMessageReceived
    print('会话列表页收到onCmdMessageReceived消息 $messages');

  }

  @override
  void onMessageChanged(EMMessage message) {
    // TODO: implement onMessageChanged
    print('会话列表页收到onMessageChanged消息 $message');
  }

  @override
  void onMessageDelivered(List<EMMessage> messages) {
    // TODO: implement onMessageDelivered
    print('会话列表页收到onMessageDelivered $messages');
  }

  @override
  void onMessageRead(List<EMMessage> messages) {
    // TODO: implement onMessageRead
    print('会话列表页收到onMessageRead消息 $messages');
  }

  @override
  void onMessageRecalled(List<EMMessage> messages) {
    // TODO: implement onMessageRecalled
    print('会话列表页收到onMessageRecalled消息 $messages');

  }
//  /// id是[groupId], 名称是[groupName]的群邀请被[inviter]拒绝,理由是[reason]
//  void onInvitationReceived(String groupId, String groupName, String inviter, String reason){
//    print('会话列表页收到onInvitationReceived消息 $groupId');
//  }
//
//  /// 收到用户[applicant]申请加入id是[groupId], 名称是[groupName]的群，原因是[reason]
//  void onRequestToJoinReceived(String groupId, String groupName, String applicant, String reason){}
//
//  /// 入群申请被同意
//  void onRequestToJoinAccepted(String groupId, String groupName, String accepter){
//    print('会话列表页收到onRequestToJoinAccepted消息 $groupId');
//  }
//
//  /// 入群申请被拒绝
//  void onRequestToJoinDeclined(String groupId, String groupName, String decliner, String reason){}
//
//  /// 入群邀请被同意
//  void onInvitationAccepted(String groupId, String invitee, String reason){
//    print('会话列表页收到onInvitationAccepted消息 $groupId');
//  }
//
//  /// 入群邀请被拒绝
//  void onInvitationDeclined(String groupId, String invitee, String reason){}
//
//  /// 被移出群组
//  void onUserRemoved(String groupId, String groupName){}
//
//  /// 群组解散
//  void onGroupDestroyed(String groupId, String groupName){}
//
//  /// @nodoc 自动同意加群
//  void onAutoAcceptInvitationFromGroup(String groupId, String inviter, String inviteMessage){
//    print('会话列表页收到onAutoAcceptInvitationFromGroup消息 $groupId');
//  }
//
//  /// 群禁言列表增加
//  void onMuteListAdded(String groupId, List mutes, int muteExpire){}
//
//  /// 群禁言列表减少
//  void onMuteListRemoved(String groupId, List mutes){}
//
//  /// 群管理增加
//  void onAdminAdded(String groupId, String administrator){}
//
//  /// 群管理被移除
//  void onAdminRemoved(String groupId, String administrator){}
//
//  /// 群所有者变更
//  void onOwnerChanged(String groupId, String newOwner, String oldOwner){}
//
//  /// 有用户加入群
//  void onMemberJoined(String groupId, String member){
//    print('会话列表页收到onMemberJoined消息 $groupId,$member');
//  }
//
//  /// 有用户离开群
//  void onMemberExited(String groupId,  String member){}
//
//  /// 群公告变更
//  void onAnnouncementChanged(String groupId, String announcement){}
//
//  /// 群共享文件增加
//  void onSharedFileAdded(String groupId, EMMucSharedFile sharedFile){}
//
//  /// 群共享文件被删除
//  void onSharedFileDeleted(String groupId, String fileId){}
}
