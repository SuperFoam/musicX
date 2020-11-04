
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/bottom_nav/home.dart';
import 'package:music_x/bottom_nav/msg.dart';
import 'package:music_x/bottom_nav/my.dart';
import 'package:music_x/bottom_nav/store.dart';
import 'package:music_x/provider/download_task.dart';
import 'package:music_x/provider/local_song.dart';
import 'package:music_x/provider/message_notice.dart';
import 'package:music_x/provider/player.dart';
import 'package:music_x/provider/song_sheet_detail.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:flutter/services.dart';
import 'package:music_x/utils/colors.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

DateTime lastPopTime;

Future<bool> _doubleExit() async {
  if (lastPopTime == null || DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
    lastPopTime = DateTime.now();
    Utils.showToast('再按一次退出');

    return new Future.value(false);
  } else {
    lastPopTime = DateTime.now();
    if (PlayerModel().curSong != null) await PlayerModel().audioPlayer.release();
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return new Future.value(true);
    // 退出app
  }
}

class _IndexPageState extends State<IndexPage> with AutomaticKeepAliveClientMixin,
    SingleTickerProviderStateMixin implements EMMessageListener,EMConnectionListener {
  ReceivePort _port = ReceivePort();
  List<Widget> bodyList;
  List<Widget> navItemList;

  PageController pageController;

  int badge1 = 1;
  int currentIndex = 0;
  Animation<double> animation;
  AnimationController controller;
  var animationStatus = "dismissed";
  bool isPause = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('index初始化');
    pageController = PageController();
    bodyList = [HomePage(), MsgPage(), StorePage(), PersonPage()];
    initAnimation();
    initDownloadSong();
    initIMListen();
  }

  void initIMListen(){
    if(Provider.of<UserProvider>(context,listen: false).isGuest)return;
    EMClient.getInstance().addConnectionListener(this);
    EMClient.getInstance()?.chatManager()?.addMessageListener(this);

  }
  void initDownloadSong(){
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      print('index page id is $id,status is $status,progress is $progress');
      if (status == DownloadTaskStatus.running) {

        Provider.of<DownLoadModel>(context, listen: false).progressChange(id, progress);
      } else if (status == DownloadTaskStatus.complete) {
        Provider.of<DownLoadModel>(context, listen: false).init();
        handleTaskDone(id);
      } else if (status == DownloadTaskStatus.paused || status == DownloadTaskStatus.canceled)
        Provider.of<DownLoadModel>(context, listen: false).init();
      else if (status == DownloadTaskStatus.failed) Provider.of<DownLoadModel>(context, listen: false).init();
    });
    FlutterDownloader.registerCallback(taskCallback);
  }

  static void taskCallback(String id, DownloadTaskStatus status, int progress) {
    // print('Download task ($id) is in status ($status) and process ($progress)');
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  Future<void> handleTaskDone(String taskId) async {
    Map songInfo = MyDownloadTask.getSong(taskId);
    if(songInfo==null){
      print('下载完成-歌曲信息为空--任务id$taskId');
      return;
    }
    print('下载完成-歌曲信息不为空--任务id$taskId，$songInfo');
    String songId = songInfo['songId'];
    String savePath = songInfo['savePath'];
    Map t = songInfo['t'];
    Map data = MyFavoriteSong.downloadSongDone(songId, savePath);
    Map data2 = MySongSheet.downloadSongDone(songId, savePath);
    if (data != null || data2 != null) Provider.of<SongSheetModel>(context, listen: false).refresh();
    if (data != null)
      LocalSong.addSong({songId: data});
    else if (data2 != null)
      LocalSong.addSong({songId: data2});
    else if (t != null) {
      t['isDownload'] = true;
      t['playInfo']['path'] = savePath;
      LocalSong.addSong({songId: t});
    }else
      print('没有添加歌曲');
    Provider.of<LocalSongModel>(context, listen: false).init();
    MyDownloadTask.delete(taskId);
  }

  void initAnimation() {
    controller = AnimationController(
      duration: Duration(seconds: 15),
      vsync: this,
    );
    var length2 = math.pi * 2;
    animation = Tween(begin: 0.0, end: length2).animate(controller);
    //controller.forward();
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationStatus = "completed";
      } else if (status == AnimationStatus.dismissed) {
        //动画恢复到初始状态时执行动画（正向）
        animationStatus = "dismissed";
      } else if (status == AnimationStatus.forward) {
        //动画恢复到初始状态时执行动画（正向）
        animationStatus = "forward";
      } else if (status == AnimationStatus.reverse) {
        //动画恢复到初始状态时执行动画（正向）
        animationStatus = "forward";
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    controller.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  void onPageChanged(int index) {
    print('页面改变');
    // currentIndex = index;
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('---------------');
    print('index rebuild');
    super.build(context);
    return WillPopScope(
        child: Scaffold(
            body: PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              children: bodyList,
              physics: NeverScrollableScrollPhysics(), // 禁止滑动
            ),
//            ScrollConfiguration(
//              behavior: CustomScrollBehavior(),
//              child: PageView.builder(
//                itemBuilder: (BuildContext context, int index) {
//                  return bodyList[index];
//                },
//                itemCount: bodyList.length,
//                controller: pageController,
//                //physics: CustomScrollPhysics(),
//                physics: NeverScrollableScrollPhysics(),
//                onPageChanged: onPageChanged,
//              ),
//            ),
            bottomNavigationBar: BottomAppBar(
              //color: Color(0xfafafafa),
              //elevation: 10.0,
              // clipBehavior:Clip.antiAlias,
              child: Consumer<IMNoticeProvider>(
               builder: (context,_imNotice,child){
                 return Row(
                   children: [
                     bottomAppBarItem(0, Icons.home, '首页', badge: badge1),
                     bottomAppBarItem(1, Icons.email, '消息', badge: _imNotice.unreadMsgCount),
                     bottomAppBarItem(-1, Icons.store, '商店', badge: badge1),
                     bottomAppBarItem(2, Icons.store, '商店', badge: 101),
                     bottomAppBarItem(3, Icons.person, '我的', badge: 1, type: 'q'),
                   ],
                   mainAxisAlignment: MainAxisAlignment.spaceAround, //均分底部导航栏横向空间
                   mainAxisSize: MainAxisSize.max,
                 );
               },
              )
            )),
        onWillPop: _doubleExit);
  }

//  @override
//  void didChangeDependencies() {
//    // TODO: implement didChangeDependencies
//    super.didChangeDependencies();
//    print('---------------');
//    print('index page 依赖发生变化');
//    //Provider.of<PlayerModel>(context, listen: true).playerAnimation(controller);
//  }

  Widget bottomAppBarItem(int index, IconData iconData, String title, {int badge = 0, String type = 'badge'}) {
    bool isDark = isDarkMode(context);
    TextStyle textStyle = TextStyle(fontSize: 14.0, color: isDark ? Colors.grey : Colors.black38);
    TextStyle badgeTextStyle = TextStyle(fontSize: 6.0, color: Colors.white);
    EdgeInsetsGeometry marginBottom = EdgeInsets.only(bottom: 5.0);
    EdgeInsetsGeometry marginVertical = EdgeInsets.symmetric(vertical: 5.0);
    Icon _icon = Icon(iconData, color: Colors.grey, size: 22);
    double boxSize = Constant.bottomNavHeight;
    double circularBoxWidth = boxSize - 5.0;
    double circularChildWidth = boxSize - 7.5;
    double circularWidth = 2.5;
    double rightBadge = -7.0;
    double topBadge = -2.0;
    double badgeWidth = 20.0;
    double badgeHeight = 15.0;
    double redDotWidth = 8.0;
    if (index == currentIndex) {
      textStyle = TextStyle(fontSize: 15.0, color: Colors.blue);
      badgeTextStyle = TextStyle(fontSize: 8.0, color: Colors.white);
      _icon = Icon(iconData, color: Colors.blue, size: 25);
    }
    Widget padItem; //= SizedBox();
    if (index >= 0) {
      padItem = Container(
        //color: isDark?Colours.dark_appBar_color: Colours.bottom_nav_color,
        //color: Colors.transparent,
        height: boxSize,
        width: boxSize,
        margin: marginVertical,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Stack(
                // fit: StackFit.expand,
                alignment: AlignmentDirectional.center,
                overflow: Overflow.visible,
                children: <Widget>[
                  _icon,
                  Positioned(
                      right: type == 'badge' ? rightBadge : 0.0,
                      top: type == 'badge' ? topBadge : 0.0,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(child: child, scale: animation);
                        },
                        child: badge > 0
                            ? Container(
                                width: type == 'badge' ? badgeWidth : redDotWidth,
                                height: type == 'badge' ? badgeHeight : redDotWidth,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                child: type == 'badge'
                                    ? Center(
                                        child: Text(badge > 99 ? '99+' : badge.toString(), style: badgeTextStyle),
                                      )
                                    : null)
                            : Text(''),
                      )),
                ],
              ),
              AnimatedDefaultTextStyle(
                style: textStyle,
                child: Text(title),
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
              ),
            ],
          ),
        ),
      );
    } else if (index == -1) {
      padItem = Consumer<PlayerModel>(builder: (context, _provider, child) {
        _provider.playerAnimation(controller);
        return CupertinoContextMenu(
          child: Container(
              width: boxSize,
              height: boxSize,
              child: GestureDetector(
                child: Stack(
                  //fit: StackFit.expand,
                  children: <Widget>[
                    Center(
                      child: SizedBox(
                        width: circularBoxWidth,
                        height: circularBoxWidth,
                        child: StreamBuilder<Map>(
                            stream: _provider.curPositionStream,
                            builder: (context, snapshot) {
                              return CircularProgressIndicator(
                                value: snapshot.data != null ? snapshot.data['curTime'] / snapshot.data['totalTime'] : 0.0,
                                backgroundColor: Funs.isDarkMode(context) ? Colors.grey : Colors.white,
                                strokeWidth: circularWidth,
                              );
                            }),
                      ),
                    ),
                    Center(
                        child: Hero(
                      tag: 'cir',
                      child:
                          // _provider.playerAnimation(controller);
//                            if(_provider.curSongState==AudioPlayerState.PLAYING) controller.repeat();
//                            else if(_provider.curSongState==AudioPlayerState.PAUSED) controller.stop();
//                          else if(_provider.curSongState==AudioPlayerState.COMPLETED) {
//                            print(controller.status);
//                            controller.reset();
//                          }

                          AnimatedBuilder(
                              animation: animation,
                              builder: (BuildContext ctx, Widget child) {
                                // print('animation.value ${animation.value}');
                                return Transform.rotate(
                                    angle: animation.value,
                                    child: Container(
                                      width: circularChildWidth,
                                      height: circularChildWidth,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Funs.isDarkMode(context) ? Colours.dark_appBar_color : Color(0xffc1c1c1),
                                          image: _provider.curSong == null ? null : DecorationImage(image: xImage(urlOrPath: _provider.curSong['baseInfo']['picUrl']), fit: BoxFit.cover)),
                                      child: _provider.curSong == null ? Icon(Icons.add) : null,
                                    ));
                              }),
                    ))
                  ],
                ),

                onTap: () {
                  print('click 1111');
                  if (_provider.curSong != null) NavigatorUtil.goPlaySong(context);
//                setState(() {
//                  badge1 = -badge1;
//                  print(badge1);
//                });
                },
//              onDoubleTap: (){
//                 MusicCardModel().togglePlay(controller: controller);
//              },
              )),
          //  }),
          actions: <Widget>[
            CupertinoContextMenuAction(
              isDefaultAction: false,
              trailingIcon: Icons.thumb_up,
              child: Center(
                child: Text('我的点赞'),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoContextMenuAction(
              isDefaultAction: false,
              // 加粗
            //  isDestructiveAction: true,
              // 红色
              trailingIcon: Icons.collections,
              child: Center(
                child: Text(
                  '我的收藏',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoContextMenuAction(
              trailingIcon: Icons.shopping_cart,
              child: Center(
                child: Text(
                  '我的购物',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoContextMenuAction(
              trailingIcon: Icons.directions_run,
              child: Center(
                child: Text(
                  '删库跑路',
                ),
              ),
              onPressed: () {
                Utils.showToast('年轻人你的思想很危险');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
    }
    if (index == -1) return padItem;
    Widget item = InkWell(
      //behavior: HitTestBehavior.opaque,
      child: padItem,
      onTap: () {
        print('click $index');
        if (index == currentIndex) {
          print('重复点击');
          return;
        }
        //pageController.jumpToPage(index);
        if (index != -1) {
          //  pageController.jumpToPage(index);
          pageController.animateToPage(index, curve: Curves.easeInOut, duration: Duration(milliseconds: 300));
        }
      },
    );

    return item;
  }

  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void onMessageReceived(List<EMMessage> messages) {
    // TODO: implement onMessageReceived
    print('index收到消息 $messages');
    print('消息长度  ${messages.length}');
    Provider.of<IMNoticeProvider>(context,listen: false).updateMsgCount();
   // print('index 打印所有属性:${ messages[0].toDataMap()}');
//    EMClient.getInstance().chatManager().getUnreadMessageCount().then((value) {
//      print('未读数量 $value');
//    });
//    for (var message in messages) {
//      String username ;
//      // group message
//      if (message.chatType == ChatType.GroupChat || message.chatType == ChatType.ChatRoom) {
//        username = message.to;
//      } else {
//        // single chat message
//        username = message.from;
//      }
//      Provider.of<IMNoticeProvider>(context,listen: false).receiveNewMessage(messages[0]);
      // if the message is for current conversation
//      if(username == toChatUsername || message.to == toChatUsername || message.conversationId == toChatUsername) {
//        conversation.markMessageAsRead(message.msgId);
//      }
  //  }

  }

  @override
  void onCmdMessageReceived(List<EMMessage> messages) {
    // TODO: implement onCmdMessageReceived
    print('index收到onCmdMessageReceived消息 $messages');

  }

  @override
  void onMessageChanged(EMMessage message) {
    // TODO: implement onMessageChanged
    print('index收到onMessageChanged消息 $message');
  }

  @override
  void onMessageDelivered(List<EMMessage> messages) {
    // TODO: implement onMessageDelivered
    print('index收到onMessageDelivered $messages');
  }

  @override
  void onMessageRead(List<EMMessage> messages) {
    // TODO: implement onMessageRead
    print('index收到onMessageRead消息 $messages');
  }

  @override
  void onMessageRecalled(List<EMMessage> messages) {
    // TODO: implement onMessageRecalled
    print('index收到onMessageRecalled消息 $messages');

  }

  @override
  void onConnected() {
    print("网络连接成功");
  }

  @override
  void onDisconnected(int errorCode) {
    print("网络连接断开$errorCode");
    if (errorCode == 206){
      Funs.showCustomDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: (){
              print('点击返回');
              return Future.value(false);

            },
            child: AlertDialog(
              title: Text(
                '异地登录提醒！',
                style: TextStyles.textDialogTitle,
              ),
              content: Text('你嘞账号叫人家登啦，很遗憾你被顶下去啦！'),
              actions: <Widget>[
                FlatButton(
                  child: Text("确定"),
                  onPressed: () async {
                    Provider.of<UserProvider>(context,listen: false).logout();
                    NavigatorUtil.goLogin(context);

                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }
}

class CustomScrollPhysics extends ScrollPhysics {
  const CustomScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    print('滑到端点');
    return null;
  }
}

class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
