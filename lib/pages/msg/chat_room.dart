
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_x/provider/message_notice.dart';
import 'package:music_x/provider/play_voice.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/widgets/chat_item.dart';
import 'package:music_x/widgets/expanded_viewport.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'input_tool.dart';

class ChatRoomPage extends StatefulWidget {
  final String chatInfo;

  ChatRoomPage(this.chatInfo);

  @override
  State<StatefulWidget> createState() {
    return _ChatRoomPageState();
  }
}

class _ChatRoomPageState extends State<ChatRoomPage> with TickerProviderStateMixin implements EMMessageListener,BottomInputBarDelegate {
  Map chatRoomInfo;
  ScrollController _msgListController;
  RefreshController _controllerR = RefreshController(initialRefresh: false);
  String conversationId;
  int conversationType;
  List msgList = [];
  int _pageSize = 10;
  String afterLoadMessageId = '';
  List<EMMessage> messageList = new List(); //消息数组
  List<EMMessage> msgListFromDB = new List();
  EMConversation conversation;
  ChatBottomInputTool child;
  final ChildPageController childController = ChildPageController();
  String appBarName;

  @override
  void initState() {

    chatRoomInfo = FluroConvertUtils.string2map(this.widget.chatInfo);
    conversationId = chatRoomInfo['conversationId']??'未知';
    conversationType = chatRoomInfo['conversationType']??0;
    initIM();
    getAppbarName();
    _onConversationInit();
    _msgListController = ScrollController();
    super.initState();
  }
  void initIM(){
    if(Provider.of<UserProvider>(context,listen: false).isGuest)return;
    EMClient.getInstance().chatManager().addMessageListener(this);

  }
  void getAppbarName()async{
    if(Provider.of<UserProvider>(context,listen: false).isGuest){
      if(conversationType==EMConversationType.GroupChat.index)
      appBarName='测试群组-$conversationId';
      else
        appBarName='测试用户-$conversationId';
      return;
    }
    if(conversationType==EMConversationType.GroupChat.index){
    EMGroup group = await EMClient.getInstance().groupManager().getGroup(conversationId);
    appBarName = group.getGroupName();}
    else
    appBarName=conversationId;
    print(appBarName);
    setState(() {

    });

  }

  @override
  void scrollBottom() {
    if (_msgListController.offset != 0.0)
      //_msgListController.jumpTo(0.0);
      _msgListController.animateTo(
        0.0,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 200),
      );
  }

  @override
  // TODO: implement userIdOrGroupId
  String get userIdOrGroupId => conversationId;

  @override
  // TODO: implement chatType
  int get chatType => conversationType;

  @override
  set userIdOrGroupId(String _userIdOrGroupId) {
    print('设置userIdOrGroupId is $_userIdOrGroupId');
    userIdOrGroupId = conversationId;
  }

  @override
  set chatType(int _chatType) {
    chatType = conversationType;
  }

  @override
  void insertNewMessage(EMMessage msg) {
    messageList.insert(0, msg);
    setState(() {});
  }

  @override
  void dispose() {
    _msgListController.dispose();

    _controllerR.dispose();

    EMClient.getInstance().chatManager().removeMessageListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('chat list rebuild');
    return WillPopScope(
      onWillPop: (){
        Provider.of<IMNoticeProvider>(context,listen: false).updateConversation();
        Navigator.of(context).pop();
        return Future.value(true);
      },
      child:  ChangeNotifierProvider(
        create: (_) => VoicePlayerProvider()..init(),
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          backgroundColor: Theme.of(context).backgroundColor,// Color(0xffededed).withOpacity(0.98),
          appBar: AppBar(
            title: Text(
              appBarName ?? ' ',
              style: TextStyles.textSizeMD,
            ),
            titleSpacing: 0.0,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {
                  if(conversationType==EMConversationType.Chat.index)
                    NavigatorUtil.goChatInfoPage(context,  conversationId);
                  else
                    NavigatorUtil.goGroupInfoPage(context, conversationId);

                },
              )
            ],
          ),
          body: Column(
            children: <Widget>[
              buildChatList,
              ChatBottomInputTool(
                this,
                childController: childController,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget get buildChatList {
    return Expanded(
        flex: 1,
        child: GestureDetector(
            onPanDown: (DragDownDetails detail) {
              print('触摸屏幕');
              childController.closeBottom();
            },
            child: CupertinoScrollbar(
              child: RefreshConfiguration(
                //maxUnderScrollExtent:200,
                hideFooterWhenNotFull: true,
                footerTriggerDistance: 150,
                child: SmartRefresher(
                  controller: _controllerR,
                  enablePullDown: false,
                  enablePullUp: true,
//                footer: CustomFooter(
//                  loadStyle: LoadStyle.ShowAlways,
//                  builder: (context, mode) {
//                    if (mode == LoadStatus.loading) {
//                      return Container(
//                        height: 60.0,
//                        child: Container(
//                          height: 20.0,
//                          width: 20.0,
//                          child: CupertinoActivityIndicator(),
//                        ),
//                      );
//                    } else
//                      return Container();
//                  },
//                ),

                  footer: ClassicFooter(
                    loadStyle: LoadStyle.ShowWhenLoading,
                    //completeDuration: Duration(microseconds: 50),
                    idleText: '',
                    loadingIcon: CupertinoActivityIndicator(),
                    canLoadingIcon: CupertinoActivityIndicator(),
                    canLoadingText: '',
                  ),
                  onLoading: () async {
                    _loadMessage();
                  },
                  child: Scrollable(
                    controller: _msgListController,
                    axisDirection: AxisDirection.up,
                    viewportBuilder: (context, offset) {
                      return ExpandedViewport(
                        offset: offset,
                        axisDirection: AxisDirection.up,
                        slivers: <Widget>[
                          SliverExpanded(),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((c, int index) {
                                return ChatItem(conversationId, messageList[index], _isShowTime(index));
                              }, childCount: messageList.length),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
            )));
  }

  void _onConversationInit() async {
    messageList.clear();
    if(Provider.of<UserProvider>(context,listen: false).isGuest)return;
    conversation = await EMClient.getInstance().chatManager().getConversation(conversationId, fromEMConversationType(conversationType), true);

    if (conversation != null) {
      conversation.markAllMessagesAsRead();
      Provider.of<IMNoticeProvider>(context,listen: false).updateMsgCount();
      msgListFromDB = await conversation.loadMoreMsgFromDB('', 20);
    }
    // print('msgListFromDB is ${msgListFromDB.first}');

    if (msgListFromDB != null && msgListFromDB.length > 0) {
      afterLoadMessageId = msgListFromDB.first.msgId;
      messageList.addAll(msgListFromDB.reversed.toList());
      setState(() {});
    }
  }

  void _loadMessage() async {
    List<EMMessage> loadList = await conversation.loadMoreMsgFromDB(afterLoadMessageId, _pageSize);
    if (loadList.length > 0) {
      afterLoadMessageId = loadList.first.msgId;
      messageList.addAll(loadList.reversed.toList());
      setState(() {});
      _controllerR.loadComplete();
    } else {
      _controllerR.loadNoData();

      print('没有更多数据了');
      return;
    }
  }

  bool _isShowTime(int index) {
    int showInterval = 1000 * 60 * 5;
    if (messageList.length == 1) return true;
    int lastIndex = index - 1;
    if (index == 0) lastIndex = index + 1;
    // print('last msg is ${messageList[lastIndex].toDataMap()},cur msg is ${messageList[index].toDataMap()}');
    int lastMsgTime = int.parse(messageList[lastIndex].msgTime.isNotEmpty ? messageList[lastIndex].msgTime : messageList[lastIndex].localTime);
    int curMsgTime = int.parse(messageList[index].msgTime.isNotEmpty ? messageList[index].msgTime : messageList[index].localTime);
    int delta = lastMsgTime - curMsgTime;
    if (delta < 0) {
      delta = -delta;
    }
    return delta > showInterval;
  }
  @override
  void onMessageReceived(List<EMMessage> messages) {
    print('chatRoom收到onMessageReceived消息 $messages');
    messages.forEach((element) {
      insertNewMessage(messages[0]);
      scrollBottom();
      conversation.markMessageAsRead(messages[0].msgId);
    });
  }

  @override
  void onCmdMessageReceived(List<EMMessage> messages) {
    // TODO: implement onCmdMessageReceived
    print('chatRoom收到onCmdMessageReceived消息 $messages');

  }

  @override
  void onMessageChanged(EMMessage message) {
    // TODO: implement onMessageChanged
    print('chatRoom收到onMessageChanged消息 $message');
  }

  @override
  void onMessageDelivered(List<EMMessage> messages) {
    // TODO: implement onMessageDelivered
    print('chatRoom收到onMessageDelivered $messages');
  }

  @override
  void onMessageRead(List<EMMessage> messages) {
    // TODO: implement onMessageRead
    print('chatRoom收到onMessageRead消息 $messages');
  }

  @override
  void onMessageRecalled(List<EMMessage> messages) {
    // TODO: implement onMessageRecalled
    print('chatRoom收到onMessageRecalled消息 $messages');

  }
}
