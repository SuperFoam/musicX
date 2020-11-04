
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:music_x/provider/music_card.dart';
import 'package:music_x/provider/player.dart';
import 'package:music_x/provider/song_sheet_list.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/custom_paint.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:music_x/widgets/song_more_info.dart';
import 'package:provider/provider.dart';
import 'package:flustars/flustars.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/provider/provider.dart';
import 'package:music_x/utils/colors.dart';
import 'dart:async';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  AnimationController controller;
  AnimationController controllerRefresh;
  CurvedAnimation curve;
  CurvedAnimation curveRefresh;
  Animation animation;
  Animation animationRefresh;
  double screenW;
  double cardH = 150.0;
  double cardImage = 100.0;
  String placeImageLocal = 'images/cat.jpeg';
  String placeImageUrl = "https://timgsa.baidu.com/timg?image&quality=80&"
      "size=b9999_10000&sec=1589276078784&di=17ebef04dca43092cf3ad5f0d4d71876"
      "&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2"
      "Fq_70%2Cc_zoom%2Cw_640%2Fimages%2F20180415%2F0613bf541b354a4098bf2ddc92"
      "66e238.jpeg";

  var animationStatus = "dismissed";
  int count = 0;
  String theme;
  List<Map> popupMenu = [
    {"key": "关于", "value": Icons.info_outline},
    {"key": "帮助", "value": Icons.help_outline},
    {"key": "暗黑", "value": Icons.settings_brightness}
  ];
  List<PopupMenuEntry<String>> popupItemList;
  List<Map> recommendData = [
    {
      'image': 'assets/img/yuan.jpg',
      'title': '原创榜',
      'subtitle': '每周四更新',
      'key': 'origin',
      "id":'2884035',
      "isSheet":true,
    },
    {
      'image': 'assets/img/newsong.jpg',
      'title': '新歌榜',
      'subtitle': '每天更新',
      'key': 'new',
      "id":'3779629',
      "isSheet":true,
    },
    {
      'image': 'assets/img/hotsong.jpg',
      'title': '热歌榜',
      'subtitle': '每周四更新',
      'key': 'hot',
      "id":'3778678',
      "isSheet":true,
    },
    {
      'image': 'assets/img/biaosheng.jpg',
      'title': '飙升榜',
      'subtitle': '每天更新',
      'key': 'hurry',
      "id":'19723756',
      "isSheet":true,
    },
    {
      'image': 'assets/img/dy.jpg',
      'title': '抖音榜',
      'subtitle': '每周五更新',
      'key': 'douyin',
      "id":'2250011882',
      "isSheet":true,
    },

    {
      'image': 'assets/img/rap.jpg',
      'title': 'rap榜',
      'subtitle': '每周五更新',
      'key': 'rap',
      "id":'991319590',
      "isSheet":true,
    },
    {
      'image': 'assets/img/gudian.jpg',
      'title': '古典榜',
      'subtitle': '每周四更新',
      'key': 'gudian',
      "id":'71384707',
      "isSheet":true,
    },
    {
      'image': 'assets/img/dianyin.jpg',
      'title': '电音榜',
      'subtitle': '每周五更新',
      'key': 'elect',
      "id":'1978921795',
      "isSheet":true,
    },
    {
      'image': 'assets/img/itunes.jpg',
      'title': 'iTunes榜',
      'subtitle': '每周一更新',
      'key': 'itunes',
      "id":'11641012',
      "isSheet":true,
    },
  ];
  ScrollController _controller ;
  GlobalKey mySheet ;
  GlobalKey reSheet ;
  //List mySongSheetList = [];
  String defaultSSImage = 'assets/img/sheet.jpg';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('HomePage初始化');
    _controller =  ScrollController();
    mySheet = GlobalKey();
    reSheet = GlobalKey();
    initAnimation();
    //initMySongSheet();
//    _controller.addListener(() {
//      print('打印滚动位置${_controller.offset}'); //打印滚动位置
//      print('打印滚动位置22 :${_controller.positions}'); //打印
//
//    });
  }

//  void initMySongSheet() {
//    mySongSheetList = MySongSheet.getData();
//  }

  void initAnimation() {
    controller = AnimationController(
        duration: Duration(milliseconds: 1000),vsync: this);

    curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    theme = SpUtil.getString(Constant.appTheme, defValue: 'Light');
    if (theme == 'Light') {
      animation = ColorTween(
              begin: Colours.light_page_color, end: Colours.dark_page_color)
          .animate(curve);
    } else {
      animation = ColorTween(
              begin: Colours.dark_page_color, end: Colours.light_page_color)
          .animate(curve);
    }

    controllerRefresh = AnimationController(
        duration: Duration(milliseconds: 5000), vsync: this);
    curveRefresh =
        CurvedAnimation(parent: controllerRefresh, curve: Curves.easeInOut);
    animationRefresh =
        Tween(begin: 0.0, end: math.pi * 2 * 7).animate(curveRefresh);

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
  void dispose() {
    print('home page dispose');
    controller.dispose();
    controllerRefresh.dispose();
    super.dispose();

  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
//    print('---------------');
//    print('home page 依赖发生变化');
    screenW = MediaQuery.of(context).size.width;
   // print('屏幕宽度是 $screenW');
    theme = SpUtil.getString(Constant.appTheme, defValue: 'Light');
   // print('theme is $theme');
    if (theme == 'Dark') {
      popupMenu.last = {"key": "阳光", "value": Icons.wb_sunny};
    } else {
      popupMenu.last = {"key": "暗黑", "value": Icons.brightness_2};
    }
    popupItemList = buildItems(context);
    var t = popupItemList.last;
    popupItemList = popupItemList.expand((element) {
      if (element != t) {
        return [element, PopupMenuDivider()];
      }
      return [element];
    }).toList();
  }

  @override
  bool get wantKeepAlive => true;

  List<PopupMenuEntry<String>> buildItems(context) {
    return popupMenu
        .map((obj) => PopupMenuItem<String>(
              value: obj['key'],
              child: Wrap(
                spacing: 10.0,
                children: <Widget>[
                  Icon(obj['value'],
                      color: Funs.isDarkMode(context)
                          ? Colours.dark_icon_color
                          : Colours.light_icon_color),
                  Text(obj['key'], style: TextStyle(color: Colors.blueGrey))
                ],
              ),
            ))
        .toList();
  }

  PopupMenuItem<String> buildLastItem(obj) {
    return PopupMenuItem<String>(
      value: obj['key'],
      child: Wrap(
        spacing: 10.0,
        children: <Widget>[
          Icon(obj['value']),
          Text(obj['key'], style: TextStyle(color: Colors.blueGrey))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('---------------');
    super.build(context);
    print('HomePage rebuild');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('musicX'),
        actions: <Widget>[
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => popupItemList,
            offset: Offset(0, MediaQuery.of(context).size.height),
            onSelected: (String action) {
              int flag = 0;
              if (action == '暗黑') {
                flag = 1;
                Provider.of<ThemeProvider>(context, listen: false)
                    .setTheme(ThemeMode.dark);
              } else if (action == '阳光') {
                flag = 1;
                Provider.of<ThemeProvider>(context, listen: false)
                    .setTheme(ThemeMode.light);
              }
              if (flag == 1) {
                if (animationStatus == "dismissed") {
                  print('正向');
                  controller.forward();
                } else if (animationStatus == "completed") {
                  print('反向');
                  controller.reverse();
                }
              }
            },
          ),

//          AnimatedBuilder(
//            animation: animation,
//          builder: (BuildContext ctx, Widget child) {
//
//              return Visibility(
//                visible: false,
//                child: SizedBox(),
//              );
//          }
//          )
        ],
      ),
      body:
      AnimatedBuilder(
            animation: animation,
            builder: (BuildContext ctx, Widget child) {
              return Scaffold(
                backgroundColor: animation.value,
                body:
                myHomeSliver(),
              );
            }),


    );
  }

  Widget musicCardWidget(_provider, _player) {
    String params = _provider.songData['baseInfo']['id']=='9527'?'':'?param=200y200';
    return Container(
      height: cardH,
      width: screenW,
      //color: Colors.white70,
      margin: EdgeInsets.only(bottom: 10.0),
      child: Center(
        child: Container(
          height: cardH,
          width: screenW * 0.9,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              gradient: Funs.isDarkMode(context)
                  ? LinearGradient(colors: [
                      Colours.dark_page_color,
                      Colors.grey.withAlpha(66)
                    ])
                  : LinearGradient(colors: [
                      Colors.white,
                      Colors.blueGrey,
                    ]), //背景渐变
              borderRadius: BorderRadius.circular(6.0),
              boxShadow: [
                //阴影
                BoxShadow(
                    color: Colors.black54,
                    offset: Offset(2.0, 2.0),
                    blurRadius: 4.0)
              ]),
          child: Column(
            children: <Widget>[
              Container(
                height: cardH * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        child: Container(
                          width: screenW * 0.2 > cardImage
                              ? cardImage
                              : screenW * 0.2,
                          height: screenW * 0.2 > cardImage
                              ? cardImage
                              : screenW * 0.2,
                          child: FadeInImage.assetNetwork(
                            placeholder: Constant.defaultLoadImage,
                            image:
                                '${_provider.songData['baseInfo']['picUrl']}$params',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.fill,
                          ),
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(left: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Tooltip(
                                      message: _provider.songData['baseInfo']
                                          ['name'],
                                      child: Text(
                                          _provider.songData['baseInfo']
                                              ['name'],
                                          style: TextStyles.textSizeMD,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    )),
                                GestureDetector(
                                  child: Icon(
                                    Icons.more_vert,
                                  ),
                                  onTap: () {
                                    showMusicMoreInfo(context,_provider.songData,type: 'card');
                                    //musicCardMore(_provider.songData);
                                  },
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 3.0),
                              //width: 80,
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: BoxDecoration(
                                color: Colours.author_color,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                  _provider.songData['baseInfo']['author'],
                                  style: TextStyles.textSizeSM,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Expanded(
                              flex: 1,
                              child:
                              CustomPaint(
                                painter: ChatBubblePainter(
                                    Funs.isDarkMode(context)
                                        ? Colors.white10
                                        : Colors.blue,
                                    'bottom'), //TrianglePainter(Colors.blue) ,
                                child: Container(
                                  padding: EdgeInsets.all(5.0),
                                  //width:  double.infinity,
                                  //height: 50,
//                                          constraints: BoxConstraints(
//                                            maxWidth: double.infinity,
//                                            maxHeight: double.infinity
//                                          ),
                                  child: Center(
                                      child: SingleChildScrollView(
                                    child: Text(
                                      _provider.songData['commentInfo']
                                          ['content'],
                                      style: TextStyles.textComment,
                                    ),
                                  )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: cardH * 0.2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
//                                  IconButton(
//                                    icon: Icon(Icons.refresh),
//                                    tooltip: '刷新',
//                                    onPressed: ()  {
//                                      print('clikc refresh');
//                                      WYMusic.getRandomSong();
////                                      RequestOptions requestOptions =  RequestOptions(baseUrl: "https://baidu.com");
////                                      HttpUtil().get('/',options: requestOptions).then((val){
////                                      print('请求完成了- $val-----------');
////                                      }).catchError((e){
////                                        print('请求异常了$e------------');
////                                      });
////                                      print('请求完成了2222----------');
//
//                                    },
//                                  ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      reverseDuration: const Duration(milliseconds: 200),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(child: child, scale: animation);
                      },
                      child: IconButton(
                        key: ValueKey(_provider.curMode['tooltip']),
                        icon: Icon(_provider.curMode['icon']),
                        tooltip: _provider.curMode['tooltip'],
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          _provider.nextMode();
                        },
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      reverseDuration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(child: child, opacity: animation);
                      },
                      child: IconButton(
                        key: ValueKey(_provider.likeMode['tooltip']),
                        icon: Icon(_provider.likeMode['icon']),
                        tooltip: _provider.likeMode['tooltip'],
                        onPressed: () => _provider.likeSong(),
                        padding: EdgeInsets.all(0),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      reverseDuration: const Duration(milliseconds: 100),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return RotationTransition(
                          child: child,
                          turns: animation,
                        );
                      },
                      child: IconButton(
                        key: ValueKey(_provider.playMode['tooltip']),
                        icon: Icon(_provider.playMode['icon']),
                        tooltip: _provider.playMode['tooltip'],
                        onPressed: () {
                          // _provider.playSong();
                          _player.playSong(_provider.songData);
                          //.then((res)=>_provider.playSong2(res));

//                          String url = _provider.songData['playInfo']['url'];
//                          if(url==null) {
//                            BotToast.showText(text:'播放失败',align:Alignment.center,contentColor:Colors.black);
//                            return;
//                          }
//
//                          int result = await audioPlayer.play(url);
//                          if(result==1) _provider.playSong();
//                          else BotToast.showText(text:'播放失败',align:Alignment.center,contentColor:Colors.black);
                        },
                        padding: EdgeInsets.all(0),
                      ),
                    ),
                    IconButton(
                      icon: AnimatedBuilder(
                          animation: animationRefresh,
                          builder: (BuildContext ctx, Widget child) {
                            return Transform.rotate(
                              angle: animationRefresh.value,
                              child: Icon(
                                Icons.refresh,
                              ),
                            );
                          }),
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        if (animationRefresh.status == AnimationStatus.forward)
                          return;
                        else
                          controllerRefresh.repeat();

//                        if (animationRefresh.status==AnimationStatus.dismissed) {
//                          controllerRefresh.forward();
//                        }
//                        else if (animationRefresh.status==AnimationStatus.completed){
//                          controllerRefresh.reset();
//                          controllerRefresh.forward();
//                        }
                        _provider.nextSong().whenComplete(() {
                          controllerRefresh.reset();
                        });
                      },
                    ),
                    Tooltip(
                      message: _provider.songData['commentInfo']['name'],
                      child: Icon(
                        Icons.person,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future musicCardMore(songData) {
    final double itemHeight = 40.0;
    return showModalBottomSheet(
        context: context,
        //backgroundColor: Colors.transparent,
        elevation: 10,
        isScrollControlled: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Column(
            children: <Widget>[
              Container(
                height: 65.0,
                width: double.infinity,
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      child: SizedBox(
                        width: screenW * 0.25,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[Icon(Icons.add_box), Text('收藏')],
                        ),
                      ),
                      onTap: () {},
                    ),
                    InkWell(
                      child: SizedBox(
                        width: screenW * 0.25,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.playlist_add),
                            Text('加放')
                          ],
                        ),
                      ),
                      onTap: () {},
                    ),
                    InkWell(
                      child: SizedBox(
                        width: screenW * 0.25,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.file_download),
                            Text('下载')
                          ],
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Divider(
                height: 2,
                thickness: 1,
              ),
              Expanded(
                  flex: 1,
                  child: ListView(
                    padding: EdgeInsets.only(left: 5.0),
                    // itemExtent: 30,
                    //shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      SizedBox(
                        height: itemHeight,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.music_note),
                            SizedBox(width: 5),
                            Text('歌曲：${songData['baseInfo']['name']}')
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 25,
                      ),
                      SizedBox(
                        height: itemHeight,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.person_outline),
                            SizedBox(width: 5),
                            Text('歌手：${songData['baseInfo']['author']}')
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 20,
                      ),
                      SizedBox(
                        height: itemHeight,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.credit_card),
                            SizedBox(width: 5),
                            Text('ID：${songData['baseInfo']['id'].toString()}')
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 20,
                      ),
                      SizedBox(
                        height: itemHeight,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.comment),
                            SizedBox(width: 5),
                            Expanded(
                                flex: 1,
                                child: Text(
                                  '热评：${songData['commentInfo']['content']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 20,
                      ),
                      SizedBox(
                        height: itemHeight,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.person),
                            SizedBox(width: 5),
                            Expanded(
                                flex: 1,
                                child: Text(
                                  '来自：${songData['commentInfo']['name']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 20,
                      ),
                      SizedBox(
                        height: itemHeight,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.thumb_up),
                            SizedBox(width: 5),
                            Text(
                              '点赞：${songData['commentInfo']['likedCount']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 20,
                      ),
                    ],
                  )
//                ListView.separated(
//                    physics: BouncingScrollPhysics(),
//                    itemCount:10,
//                    itemBuilder: (context, int index){
//                      return ListTile(
//                        leading: Icon(Icons.music_note),
//                        title: Text(songData['baseInfo']['name']),
//                      );
//                    },
//                  separatorBuilder: (context, int index) {
//                    return Divider(
//                      height: 1,
//                      thickness: 1,
//                    );
//                  },
//                ),
                  )
            ],
          );
        });
  }

  Widget myHomeSliver() {
    return Column(
      children: <Widget>[
//                    Consumer2<MusicCardModel, PlayerModel>(
//                        builder: (context, _provider, _player, child) {
//                          return musicCardWidget(_provider, _player);
//                        }),
        Expanded(
          flex: 1,
          child: Container(
            margin: EdgeInsets.only(top: 10),
            padding:
                EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0, top: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              //color: Theme.of(context).appBarTheme.color,
              //color: Colors.white70
            ),
            width: screenW,
            child: homeSliver(),
          ),
        )
      ],
    );
  }

  Widget homeSliver() {
    double height = kToolbarHeight * 3;
    double margin = 5.0;

    return CustomScrollView(
      controller: _controller,
      slivers: <Widget>[
//        SliverPersistentHeader(
//          delegate: CustomDelegate(),
//        ),
        SliverToBoxAdapter(
          child: Consumer2<MusicCardModel, PlayerModel>(
              builder: (context, _provider, _player, child) {
            return musicCardWidget(_provider, _player);
          }),
        ),
//        SliverPersistentHeader(
//          delegate: CustomDelegate3(),
//          pinned: false,
//        ),
        SliverAppBar(
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              // Add this code
              preferredSize: Size.fromHeight(margin), // Add this code
              child: Text(''), // Add this code
            ),
            pinned: true,
            expandedHeight: height,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            title: Container(
              margin: EdgeInsets.only(top: margin * 3),
              child: Text(
                '我的音乐',
                style: TextStyles.textSizeMD,
              ),
            ),
            titleSpacing: 5.0,
            //elevation: 10,
            // backgroundColor: Colors.grey,

            flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              double top = constraints.biggest.height;

              double left =
                  height - top > kToolbarHeight ? kToolbarHeight : height - top;
              // print('top is $top,left is $left');
              return FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: EdgeInsets.only(left: left),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        height: kToolbarHeight,
                        margin: EdgeInsets.symmetric(vertical: margin),
                        width: screenW * 0.18,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),

                            ///圆角
                            border: Border.all(color: Colors.white70, width: 1)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.file_download),
                            Text('本地', style: TextStyles.appbarCard)
                          ],
                        ),
                      ),
                      onTap: (){
                       NavigatorUtil.goLocalSongPage(context);
                      },
                    ),
                    InkWell(
                      child: Container(
                        height: kToolbarHeight,
                        width: screenW * 0.18,
                        margin: EdgeInsets.symmetric(vertical: margin),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),

                            ///圆角
                            border:
                                Border.all(color: Colors.white70, width: 1)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.favorite,
                            ),
                            Text('喜欢', style: TextStyles.appbarCard)
                          ],
                        ),
                      ),
                      onTap: () {
                       //MyFavoriteSong.cleanSong();
                       NavigatorUtil.goSongSheetPage(context,MyFavoriteSong.getData());
                      },
                    ),
                    Container(
                      height: kToolbarHeight,
                      width: screenW * 0.18,
                      margin: EdgeInsets.symmetric(vertical: margin),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),

                          ///圆角
                          border: Border.all(color: Colors.white70, width: 1)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.theaters),
                          Text('最近', style: TextStyles.appbarCard)
                        ],
                      ),
                    ),
                  ],
                ),
//              background: Image.network(
//                'http://pic.sc.chinaz.com/files/pic/pic9/202004/zzpic24222.jpg',
//                fit: BoxFit.cover,
//              ),
              );
            })),

        SliverPersistentHeader(
          delegate: CustomDelegate3(),
          pinned: true,
        ),
        SliverAppBar(
            key: mySheet,
            automaticallyImplyLeading: false,
            title: Text('我的歌单', style: TextStyles.textSizeMD),
            titleSpacing: 5.0,
            backgroundColor: Colors.blueGrey,
            pinned: true,
            iconTheme: IconThemeData(
              color: Funs.isDarkMode(context)
                  ? Colours.dark_icon_color
                  : Colors.black45,
            ),
            //stretch: true,
            //elevation: 10,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add_box),
                onPressed: () async {
                   await Funs.showCustomDialog(
                    context: context,
                    builder: (context) {
                      TextEditingController _unameController =
                          TextEditingController();
                      FocusNode focusNode1 = new FocusNode();
                      return AlertDialog(
                        title: Text("创建歌单"),
                        content: TextField(
                          controller: _unameController,
                          focusNode: focusNode1,
                          maxLength: 20,
                          decoration: InputDecoration(
                            // prefixIcon: Icon(Icons.title),
                            hintText: '我掐指一算你要在此输入歌单名',
                            hintStyle: TextStyle(fontSize: 12),
                          ),
                          onSubmitted: (value) {
                            print('点击完成,$value');
                            focusNode1.unfocus();
                          },
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("取消"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text("确认"),
                            onPressed: () {
                              if (_unameController.text.length == 0) {
                                Utils.showToast('请输入歌单名称');
                                return;
                              }
                              //MySongSheet.create(_unameController.text);
                              Provider.of<SongSheetListModel>(context,listen: false).createSongSheet(_unameController.text);
                              Utils.showToast('创建成功');
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );
//                  if (isSuccess == true) {
//                    setState(() {
//                     // mySongSheetList =MySongSheet.getData();
//                    });
//                  }
                },
                tooltip: '创建歌单',
              ),
              IconButton(
                icon: Icon(Icons.format_list_numbered_rtl),
                onPressed: () {},
                tooltip: '歌单管理',
              )
            ],
            expandedHeight: 100,
            flexibleSpace: Consumer<SongSheetListModel>(builder: (context,_model,child){
              List mySongSheetList = _model.songSheetList;
              return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double top = constraints.biggest.height;
                    if (mySongSheetList.length == 0) {
                      return FlexibleSpaceBar(
                        centerTitle: true,
                        title: Text('空空如也', style: TextStyles.appbarCard),
                      );
                    } else {
                      if (top > kToolbarHeight)
                        return FlexibleSpaceBar(
                          centerTitle: true,
                          title: Text('爱生活 爱音乐', style: TextStyles.appbarCard),
                        );
                      else
                        return FlexibleSpaceBar(
                            centerTitle: true,
                            title: InkWell(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('爱生活 爱音乐', style: TextStyles.appbarCard),
                                  Icon(Icons.keyboard_arrow_up),
                                ],
                              ),
                              onTap: () {
                                RenderSliver renderBox2 =
                                mySheet.currentContext.findRenderObject();
                                double offset2 =
                                    Funs.globalToLocal(renderBox2, Offset.zero).dy;
                                //print('offset2 is $offset2, ${renderBox2.getAbsoluteSize().height}');
                                _controller.animateTo(-offset2,
                                    duration: Duration(seconds: 1),
                                    curve: Curves.easeInOut);
                              },
                            ));
                    }
                  });
            },)

        ),

//        SliverToBoxAdapter(
//          child: Container(
//           height: kToolbarHeight*2+10,
//           color: Colors.red,
//           // height: 1,
//           // margin: EdgeInsets.only(top: kToolbarHeight*2+15),
//
//          ),
//        ),
        SliverPadding(
          //padding: EdgeInsets.only(top: kToolbarHeight*2+15),
          padding: EdgeInsets.only(top: 0),
          sliver: Consumer<SongSheetListModel>(builder: (context,_listModel,child){
            List mySongSheetList = _listModel.songSheetList.reversed.toList();
            return SliverFixedExtentList(
              itemExtent: 60.0,
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return GestureDetector(
                    child: ListTile(
                      leading: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                                image: mySongSheetList[index]['song'].length == 0
                                    ? AssetImage(defaultSSImage)
                                    : xImage(urlOrPath:mySongSheetList[index]['song'].values.toList()
                                [0]['baseInfo']['picUrl']),
                                fit: BoxFit.cover)),
                      ),
                      title: Text(mySongSheetList[index]['name']),
                      subtitle: Text('${mySongSheetList[index]['song'].length}首'),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    onTap: (){
                      NavigatorUtil.goSongSheetPage(context,mySongSheetList[index]);
                    },
                    onLongPressStart: (detail) async {
                      double left = detail.globalPosition.dx;
                      double top = detail.globalPosition.dy;
                      double tt = MediaQuery.of(context).size.height;
                      print('$left,$top');
                      if (top + kMinInteractiveDimension * 2 + Constant.bottomNavHeight > tt)
                        top = top - kMinInteractiveDimension * 2;
                      print(tt);
                      String result = await showMenu(
                        position: RelativeRect.fromLTRB(left, top, left, 0),
                        elevation: 8.0,
                        items: <PopupMenuEntry<String>>[
                          PopupMenuItem(
                            value: 'change',
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.create),
                                Text("修改"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.delete),
                                Text("删除"),
                              ],
                            ),
                          ),
                        ],
                        context: context,
                      );
                      print('res is $result');
                      if(result=='change'){
                        Color titleColor = Funs.isDarkMode(context)?Colours.dark_text:Colors.black87;
                        await Funs.showCustomDialog(
                          context: context,
                          builder: (context) {
                            TextEditingController _unameController =
                            TextEditingController();
                            FocusNode focusNode1 = new FocusNode();
                            return AlertDialog(
                              title: RichText(text: TextSpan(
                                style: TextStyles.textDialogTitle,
                                children: [
                                  TextSpan(text: '修改歌单',  style: TextStyle(color: titleColor)),
                                  TextSpan(text: ' - ${mySongSheetList[index]['name']}',style: TextStyles.textDialogName),
                                ]
                              ),),
                              content: TextField(
                                controller: _unameController,
                                focusNode: focusNode1,
                                maxLength: 20,
                                decoration: InputDecoration(
                                  // prefixIcon: Icon(Icons.title),
                                  hintText: '老夫算到你要在此输入新的歌单名',
                                  hintStyle: TextStyle(fontSize: 12),
                                ),
                                onSubmitted: (value) {
                                  print('点击完成,$value');
                                  focusNode1.unfocus();
                                },
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("取消"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
//                            List mySongSheetList = SpUtil.getObjectList(Constant.mySongSheet);
//                            print(mySongSheetList);
                                    // SpUtil.remove(Constant.mySongSheet);
                                  },
                                ),
                                FlatButton(
                                  child: Text("确认"),
                                  onPressed: () {
                                    if (_unameController.text.length == 0) {
                                      Utils.showToast('请输入歌单名称');
                                      return;
                                    }
                                   // MySongSheet.changeName(index,_unameController.text);
                                    Provider.of<SongSheetListModel>(context,listen: false).changeSongSheet(mySongSheetList[index],_unameController.text);
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );
//                        if (isSuccess == true) {
//                          setState(() {
//                            mySongSheetList =MySongSheet.getData();
//                          });
//                        }
                      }else if(result=='delete'){
                        Color titleColor = Funs.isDarkMode(context)?Colours.dark_text:Colors.black87;
                         await Funs.showCustomDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                             // title: Text("确定要删除歌单 ${mySongSheetList[index]['name']}?",style: TextStyles.textSizeMD,),
                              title:RichText(text: TextSpan(
                                  style: TextStyles.textDialogTitle,
                                  children: [
                                    TextSpan(text: '确定要删除歌单?',  style: TextStyle(color: titleColor)),
                                    TextSpan(text: ' - ${mySongSheetList[index]['name']}',style: TextStyles.textDialogName),
                                  ]
                              ),),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("取消"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                FlatButton(
                                  child: Text("删除"),
                                  onPressed: () {
                                    Provider.of<SongSheetListModel>(context,listen: false).deleteSongSheet(mySongSheetList[index]);
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );
//                        if(isSuccess==true) {
//                          MySongSheet.delete(index);
//                          setState(() {
//                            mySongSheetList =MySongSheet.getData();
//
//                          });
//                        }
                      }
                    },
                  );
                },
                childCount: mySongSheetList.length,
              ),
            );
          },)
        ),

        SliverPersistentHeader(
          delegate: CustomDelegate3(),
          pinned: true,
        ),
        SliverAppBar(
          key: reSheet,
          automaticallyImplyLeading: false,
          title: Text('推荐歌单', style: TextStyles.textSizeMD),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          titleSpacing: 5.0,
          iconTheme: IconThemeData(
            color: Funs.isDarkMode(context)
                ? Colours.dark_icon_color
                : Colors.black45,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            )
          ],
          backgroundColor: Colors.grey,
          pinned: true,
          expandedHeight: 100,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            // titlePadding: EdgeInsets.symmetric(vertical: 30),
            title: Text('官方榜单', style: TextStyles.appbarCard),
          ),
        ),
        SliverPadding(
          //padding: EdgeInsets.only(top: kToolbarHeight*2+15),
          padding: EdgeInsets.only(top: 0),
          sliver: SliverFixedExtentList(
            itemExtent: 60.0,
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return Container(
                //color: Colours.dark_app_main,
                child: ListTile(
                  leading: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                            image: AssetImage(recommendData[index]['image']),
                            fit: BoxFit.cover)),
                  ),
                  title: Text(recommendData[index]['title'] ),
                  subtitle: Text(recommendData[index]['subtitle']),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: ()=>NavigatorUtil.goNetworkSongSheetPage(context,recommendData[index]),
                ),
              );
            }, childCount: recommendData.length),
          ),
        )
      ],
    );
  }
}



class CustomDelegate extends SliverPersistentHeaderDelegate {
//  final MusicCardModel music;
//  final PlayerModel player;

  CustomDelegate({
//    @required this.music,
//    @required this.player,
    @required this.maxHeight,
    @required this.child,
  });

  final Widget child;
  final double maxHeight;
  final double minHeight = 100;

  /// 最大高度
  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  /// 最小高度
  @override
  double get minExtent => minHeight;

  /// shrinkOffset: 当前 sliver 顶部越过屏幕顶部的距离
  /// overlapsContent: 下方是否还有 content 显示
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  /// 是否需要刷新
  @override
  bool shouldRebuild(CustomDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class CustomDelegate2 extends SliverPersistentHeaderDelegate {
//  final MusicCardModel music;
//  final PlayerModel player;

  final double maxHeight = 200;
  final double minHeight = 50;

  /// 最大高度
  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  /// 最小高度
  @override
  double get minExtent => minHeight;

  /// shrinkOffset: 当前 sliver 顶部越过屏幕顶部的距离
  /// overlapsContent: 下方是否还有 content 显示
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    print('shrinkOffset is $shrinkOffset');
    return Container(
      color: Colors.orange,
      child: Column(
        children: <Widget>[
          Container(
            height: 50,
            width: double.infinity,
            color: Colors.orange,
            child: Text('appbar'),
          ),
          Expanded(
              flex: 1,
              child: ListView.builder(
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('test$index'),
                    );
                  })
//      CustomScrollView(
//    slivers: <Widget>[
//      SliverList(
//        delegate: SliverChildBuilderDelegate((content, index) {
//          return ListTile(title: Text('test$index'),);
//        }, childCount: 20),
//      )
//    ],
//    )

              )
        ],
      ),
    );

    ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('test$index'),
          );
        });
  }

  /// 是否需要刷新
  @override
  bool shouldRebuild(CustomDelegate2 oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight;
  }
}

class CustomDelegate3 extends SliverPersistentHeaderDelegate {
//  final MusicCardModel music;
//  final PlayerModel player;
  CustomDelegate3({this.maxHeight = 5});

  double maxHeight = 5;

  /// 最大高度
  @override
  double get maxExtent => maxHeight;

  /// 最小高度
  @override
  double get minExtent => maxHeight;

  /// shrinkOffset: 当前 sliver 顶部越过屏幕顶部的距离
  /// overlapsContent: 下方是否还有 content 显示
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: maxHeight,
       color:  Theme.of(context).backgroundColor,
      //color: Colours.light_page_color,
      // color: color,
    );
  }

  /// 是否需要刷新
  @override
  bool shouldRebuild(CustomDelegate3 oldDelegate) {
    return true;
  }
}

class CustomDelegate4 extends SliverPersistentHeaderDelegate {
//  final MusicCardModel music;
//  final PlayerModel player;

  final double maxHeight = 200;
  final double minHeight = 50;

  /// 最大高度
  @override
  double get maxExtent => maxHeight;

  /// 最小高度
  @override
  double get minExtent => minHeight;

  /// shrinkOffset: 当前 sliver 顶部越过屏幕顶部的距离
  /// overlapsContent: 下方是否还有 content 显示
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        child: Expanded(
      flex: 1,
      child: ExpansionTile(
        leading: Icon(Icons.home),
        subtitle: Text('各种学科'),
        backgroundColor: Colors.greenAccent,
        title: Text('学科'),
        children: <Widget>[Text('英语'), Text('数学'), Text('语文')],
      ),
    ));
  }

  /// 是否需要刷新
  @override
  bool shouldRebuild(CustomDelegate4 oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight;
  }
}
//var height = MediaQuery.of(context).padding.top + kToolbarHeight
