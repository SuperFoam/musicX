import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:music_x/pages/store/goods_search.dart';
import 'package:music_x/route/routes.dart';

import 'package:music_x/utils/custom_animation.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/music.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/custom_search.dart';
import 'package:music_x/widgets/custom_serach_goods.dart';

import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';

import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:collection/collection.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  SystemUiOverlayStyle statusColor = SystemUiOverlayStyle.light;
  int count = 0;
  double appBarAlpha = 0.0;
  List _imageUrl = [
    'https://wx1.sinaimg.cn/mw690/684e58a1gy1g56ma49gxtj22c02xvb2b.jpg',
    'https://wx2.sinaimg.cn/mw690/6a0576a9ly1g2d262s749j24s036okjs.jpg',
  ];
  List<Map> songGoodsList = [];
  RefreshController _controllerR = RefreshController(initialRefresh: false);
  int page = 0;
  bool enablePullUp = false;
  double appBarH;
  StreamController<double> _streamController;
  StreamController<List<Map>> _streamGridGoodsController;
  ScrollController gridController;
  StreamController<List<String>> _streamFlashKill;
  Color color;

  @override
  void initState() {
    super.initState();
    print('StorePage 初始化');
    _streamController = StreamController<double>();
    // _streamGridGoodsController =  StreamController<List<Map>>.broadcast();
    _streamGridGoodsController = BehaviorSubject<List<Map>>();
    _streamFlashKill = BehaviorSubject<List<String>>();
    gridController = ScrollController();
    Timer.periodic(Duration(seconds: 1), (_) {
      var date = new DateTime.now();
      String hour = date.hour.toString().padLeft(2, '0');
      String minute = (59 - date.minute.toInt()).toString().padLeft(2, '0');
      String second = (59 - date.second.toInt()).toString().padLeft(2, '0');
      _streamFlashKill.add([hour, minute, second]);
    });
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      if (mounted) {
        initData();
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  Future<int> initData() async {
    //_song['baseInfo']['id']='1454447163';
    List<Map> d = await WYMusic('song').getRandomSongGoods();
    //print(value);
    if (d == null) return -1;
    if (page == 0) {
      songGoodsList = d;
    } else
      songGoodsList.addAll(d);
    _streamGridGoodsController.sink.add(songGoodsList);
    if (page == 0)
      setState(() {
        enablePullUp = true;
      });
//    setState(() {
//      if (page == 0) {
//        songGoodsList=d;
//      } else
//        songGoodsList.addAll(d);
//    });

    if (songGoodsList.length > 0)
      return 1;
    else
      return 0;
  }

  @override
  void dispose() {
    _streamController.close();
    _streamGridGoodsController.close();
    _streamFlashKill.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('StorePage rebuild');
    color =Theme.of(context).scaffoldBackgroundColor;
    appBarH = MediaQuery.of(context).padding.top + 45;
    return ok();
  }

  Widget ok() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: statusColor,
        child: Scaffold(
        //  backgroundColor: Colors.grey.withOpacity(0.2), // Color(0xffededed),
          backgroundColor: Theme.of(context).splashColor,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(100), //kToolbarHeight
              child: StreamBuilder(
                stream: _streamController.stream,
                initialData: 0.0,
                builder: (context, snapshot) {
                  return _appBar(snapshot.data);
                },
              )),
          body: MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: NotificationListener(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollUpdateNotification) {
                      if (scrollNotification.metrics.axis == Axis.vertical) _onScroll(scrollNotification.metrics.pixels);
                    }
                    return false;
                  },
                  child: RefreshConfiguration(
                    hideFooterWhenNotFull: true,
                    footerTriggerDistance: 300,
                    enableLoadingWhenNoData: true,
                    maxOverScrollExtent: 150,
                    child: SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: enablePullUp,
                        header: ClassicHeader(),
                        footer: ClassicFooter(
                          loadStyle: LoadStyle.ShowAlways,
                          completeDuration: Duration(microseconds: 50),
                        ),
                        onRefresh: () async {
                          page = 0;
                          int res = await initData();
                          if (res == 1)
                            _controllerR.refreshCompleted();
                          else if (res == 0) {
                            _controllerR.refreshToIdle();
                            Utils.showToast('没有数据了');
                          } else
                            _controllerR.refreshFailed();
                        },
                        onLoading: () async {
//                          if(page==0){
//                            _controllerR.loadComplete();
//                            return;
//                          }
                          page += 1;
                          //page=10000;
                          int res = await initData();
                          if (res == 1)
                            _controllerR.loadComplete();
                          else if (res == 0)
                            _controllerR.loadNoData();
                          else
                            _controllerR.loadFailed();
                        },
                        controller: _controllerR,
                        child: ListView(
                          shrinkWrap: true,
                          controller: gridController,
                          children: <Widget>[
                            Container(
                              height: 200,
                              child: Swiper(
                                itemCount: _imageUrl.length,
                                autoplay: false,
                                itemBuilder: (context, int index) {
                                  return Image.network(
                                    _imageUrl[index],
                                    fit: BoxFit.cover,
                                  );
                                },
                                pagination: SwiperPagination(),
                              ),
                            ),
                            Container(
                                // height: 150,
                                margin: EdgeInsets.only(top: 10.0),
                                // color: Colors.white,
                                child: nav),
                            hotAct[0],
                            hotAct[1],
                            hotAct[2],
                            flashKill,
                            SizedBox(
                              height: 10,
                            ),
                            StreamBuilder(
                              stream: _streamGridGoodsController.stream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData)
                                  return Container(
                                    height: 100,
                                    width: double.infinity,
                                    child: Center(
                                      child: CupertinoActivityIndicator(
                                        radius: 10,
                                      ),
                                    ),
                                  );
                                List<Map> songGoodsList = snapshot.data;
                                return WaterfallFlow.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: songGoodsList.length,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 5.0,
                                    mainAxisSpacing: 10.0,
                                  ),
                                  itemBuilder: (BuildContext c, int index) => GestureDetector(
                                    onTap: () {
                                      if (_controllerR.isRefresh || _controllerR.isLoading) return;
                                      Map t = songGoodsList[index];
                                      t['tag'] = index.toString();
                                      NavigatorUtil.goGoodsDetailPage(context, t);
                                    },
                                    onDoubleTap: () {
                                      gridController.animateTo(0.0, duration: Duration(seconds: 1), curve: Curves.easeInOut);
                                    },
                                    child: buildTile(songGoodsList[index], index.toString()),
                                  ),
                                );
                                return StaggeredGridView.countBuilder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisCount: 4,
                                  //// 容器单元格数
                                  itemCount: songGoodsList.length,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  itemBuilder: (BuildContext context, int index) => GestureDetector(
                                    onTap: () {
                                      Map t = songGoodsList[index];
                                      t['tag'] = index.toString();
                                      NavigatorUtil.goGoodsDetailPage(context, t);
                                    },
                                    child: buildTile(songGoodsList[index], index.toString()),
                                  ),
                                  staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
                                  // StaggeredTile.count(2, index==0?1:1.5), // 每个widget占多少单元格
                                  mainAxisSpacing: 10.0,
                                  crossAxisSpacing: 4.0,
                                );
                              },
                            ),
                          ],
                        )),
                  ))),
        ));
  }

  _onScroll(offset) {
    //print(offset);
    if (offset > appBarH) return;
    double alpha = offset / appBarH;
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    _streamController.add(alpha);
    return;
    if (alpha < 0.3 && statusColor != SystemUiOverlayStyle.light)
      setState(() {
        statusColor = SystemUiOverlayStyle.light;
      });
    else if (alpha >= 0.3 && statusColor != SystemUiOverlayStyle.dark)
      setState(() {
        statusColor = SystemUiOverlayStyle.dark;
      });
  }

  Stream<List> timeStream() {
    return Stream.periodic(Duration(seconds: 1), (_) {
      var date = new DateTime.now();
      String hour = date.hour.toString().padLeft(2, '0');
      String minute = (59 - date.minute.toInt()).toString().padLeft(2, '0');
      String second = (59 - date.second.toInt()).toString().padLeft(2, '0');
      return [hour, minute, second];
    }).asBroadcastStream();
  }

  Widget _appBar(double opacity) {
    double statusH = MediaQuery.of(context).padding.top;
    double appBarAlpha = opacity;
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        //border: Border.all(color: Colors.orange,width: 1),
        gradient: LinearGradient(
          //AppBar渐变遮罩背景
          colors: [Color(0x66000000), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        height: appBarH,
        //56+statusH,
        padding: EdgeInsets.fromLTRB(10, statusH, 10, 0),
        decoration: BoxDecoration(
          //border: Border.all(color: Colors.black,width: 1),
          //color: Color.fromARGB((appBarAlpha * 255).toInt(), 255, 255, 255),
          color: color.withOpacity(appBarAlpha),
//            boxShadow: [BoxShadow(
//              color: appBarAlpha == 1.0 ? Colors.black12 : Colors.transparent,
//              offset: Offset(2, 3),
//              blurRadius: 6,
//              spreadRadius: 0.6,
//            ),]
        ),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => myShowSearchGoods(context: context, delegate: GoodsSearchBarDelegate()),
                  child: Container(
                    height: 30,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: appBarAlpha >= 0.4 ? Color.fromARGB((appBarAlpha * 255).toInt(), 237, 237, 237) : Color.fromARGB(((1 - appBarAlpha) * 255).toInt(), 255, 255, 255),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.search,
                          size: 16,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '搜点什么',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Icon(
                          Icons.camera_alt,
                          size: 16,
                        )
                      ],
                    ),
                  ),
                )),
            IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: appBarAlpha >= 0.4 ? Colors.grey : Colors.white70,
              ),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }

  IconData getGoodsTypeIcon(String type) {
    switch (type) {
      case "语种":
        return Icons.language;
      case "风格":
        return Icons.toys;
      case "场景":
        return Icons.radio;
      case "情感":
        return Icons.accessibility_new;
      case "主题":
        return Icons.redeem;
      default:
        return Icons.help_outline;
    }
  }

  Widget get nav {
    double itemW = MediaQuery.of(context).size.width / 5.0;
    double itemH = itemW * 0.8;
    List goodsType = MyGoodsType.getData();
    List<Widget> row1 = [];
    List<Widget> row2 = [];
    if (goodsType.length > 4) {
      goodsType.sublist(0, 5).forEach((element) {
        Widget t = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => NavigatorUtil.goGoodsSheetPage(context, element['name']),
          child: Container(
            width: itemW,
            //height: itemH,
            constraints: BoxConstraints(
              minHeight: itemH
            ),

            child: Column(
              children: <Widget>[Icon(getGoodsTypeIcon(element['type'])), Text(element['name'])],
            ),
          ),
        );

        row1.add(t);
      });
      goodsType.sublist(5).forEach((element) {
        Widget t = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => NavigatorUtil.goGoodsSheetPage(context, element['name']),
          child: Container(
            width: itemW,
           // height: itemH,
            constraints: BoxConstraints(
              minHeight: itemH
            ),
            child: Column(
              children: <Widget>[Icon(getGoodsTypeIcon(element['type'])), Text(element['name'])],
            ),
          ),
        );
        row2.add(t);
      });
      row2.add(InkWell(
          onTap: () => NavigatorUtil.goGoodsTypeManagePage(context).then((_) {
                Function deepEq = const DeepCollectionEquality().equals;
                List goodsType2 = MyGoodsType.getData();
                if (deepEq(goodsType, goodsType2) == false) {
                  print('数据不相同');
                  setState(() {});
                }
              }),
          child: Container(
            width: itemW,
            //height: itemH,
            constraints: BoxConstraints(
              minHeight: itemH
            ),
            child: Column(
              children: <Widget>[Icon(Icons.view_module), Text('全部')],
            ),
          )));
    } else {
      goodsType.sublist(0, goodsType.length).forEach((element) {
        Widget t = GestureDetector(
          onTap: () => NavigatorUtil.goGoodsSheetPage(context, element['name']),
          child: Container(
            width: itemW,
           // height: itemH,
            constraints: BoxConstraints(
              minHeight: itemH
            ),
            child: Column(
              children: <Widget>[Icon(getGoodsTypeIcon(element['type'])), Text(element['name'])],
            ),
          ),
        );

        row1.add(t);
      });
      row1.add(InkWell(
          onTap: () => NavigatorUtil.goGoodsTypeManagePage(context).then((_) {
                Function deepEq = const DeepCollectionEquality().equals;
                List goodsType2 = MyGoodsType.getData();
                if (deepEq(goodsType, goodsType2) == false) {
                  print('数据不相同');
                  setState(() {});
                }
              }),
          child: Container(
            width: itemW,
           // height: itemH,
            constraints: BoxConstraints(minHeight: itemH),
            child: Column(
              children: <Widget>[Icon(Icons.view_module), Text('全部')],
            ),
          )));
    }

    return Column(
      children: <Widget>[
        Row(
            //    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row1),
        Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row2),
      ],
    );
  }

  Widget get flashKill {
    return Container(
      height: 150,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: StreamBuilder(
              stream: _streamFlashKill.stream, //timeStream() ,//_streamFlashKill.stream,
              initialData: ['0', '00', '00'],
              builder: (context, snapshot) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '即刻秒杀',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${snapshot.data[0]}点场', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                    Row(
                      children: <Widget>[
                        Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2)),
                            child: Center(
                              child: Text(
                                '${snapshot.data[1]}',
                                style: TextStyle(fontSize: 10, color: color),
                              ),
                            )),
                        SizedBox(
                          width: 2,
                        ),
                        Text(':', style: TextStyle(fontSize: 15, color: Colors.red)),
                        SizedBox(
                          width: 2,
                        ),
                        Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2)),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                reverseDuration: const Duration(milliseconds: 200),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return SlideTransitionX(
                                    child: child,
                                    direction: AxisDirection.down, //上入下出
                                    position: animation,
                                  );
                                },
                                child: Text(
                                  '${snapshot.data[2]}',
                                  style: TextStyle(fontSize: 10, color: color),
                                  key: ValueKey(snapshot.data[2]),
                                ),
                              ),
                            ))
                      ],
                    )
                  ],
                );
              },
            ),
          ),
          Expanded(
              flex: 1,
              child: Container(
                //padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.redAccent.withOpacity(0.7), Colors.red]), borderRadius: BorderRadius.circular(5)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      3,
                      (index) => Container(
                          width: MediaQuery.of(context).size.width / 4,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          //height: 80,
                          child: Column(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                width: 50,
                                height: 50,
                                child: xImgRoundRadius(urlOrPath: Constant.defaultSongImage, radius: 3),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Text(
                                      '你是人间四月天',
                                      style: TextStyle(
                                        fontSize: 11,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '￥99',
                                          style: TextStyle(fontSize: 10, decoration: TextDecoration.lineThrough),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '￥199',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          )),
                    )),
              ))
        ],
      ),
    );
  }

  List<Widget> get hotAct {
    return <Widget>[
      Container(
        // height: 50,
        margin: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 1),
        padding: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
          //border:Border(bottom:BorderSide(width: 1) ),
          //border: Border.all(),
          // borderRadius: BorderRadius.only(topLeft: Radius.circular(5))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(width: 55, height: 40, child: Image.asset('assets/img/hotAct.png')),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.redAccent.withOpacity(0.8), Colors.red]), borderRadius: BorderRadius.circular(3)),
              child: Text('查看更多', style: TextStyle(fontSize: 11, color:color)),
            ),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                    color: color,
                    // borderRadius: BorderRadius.circular(5),
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(5))),
                child: xImgRoundRadius(urlOrPath: 'http://p3.music.126.net/QA5MLyRPtxHmOgPznDzCvw==/109951165031812212.jpg', radius: 1, smallSize: false),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            //Container(width: 1,color: Colors.grey.withOpacity(0.2),),
            Expanded(
              flex: 1,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                    color:color,
                    // borderRadius: BorderRadius.circular(5),
                    // borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5))),
                child: xImgRoundRadius(urlOrPath: 'http://p4.music.126.net/yNi0wbraAGKCB-v-m7ARbg==/109951165095170275.jpg', radius: 1, smallSize: false),
              ),
            ),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 10),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: color,
                      // borderRadius: BorderRadius.circular(5),
                      borderRadius: BorderRadius.only(topRight: Radius.circular(5))),
                  child: xImgRoundRadius(urlOrPath: 'http://p4.music.126.net/xoMJEFU4Prn_F8NN8NrYXw==/109951165086119801.jpg', radius: 1, smallSize: false)),
            ),
            SizedBox(
              width: 10,
            ),
            //Container(width: 1,color: Colors.grey.withOpacity(0.2),),
            Expanded(
              flex: 1,
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: color,
                      // borderRadius: BorderRadius.circular(5),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(5))),
                  child: xImgRoundRadius(
                    urlOrPath: 'http://p4.music.126.net/T1XggVRR2mBTLHhibhe_vw==/109951165096569433.jpg',
                    radius: 1,
                    smallSize: false,
                  )),
            ),
          ],
        ),
      ),
    ];
  }

  Widget buildTile(Map data, String tag) {
    return Container(
        width: double.infinity,
        //height: 150+Random().nextInt(100).toDouble(),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: color,
//            boxShadow: [
//              BoxShadow(
//                  color: Colors.black12,
//                  offset: Offset(3.0, 5.0), //阴影xy轴偏移量
//                  blurRadius: 15.0, //阴影模糊程度
//                  spreadRadius: 3.0 //阴影扩散程度
//              )
//            ],
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(1, 1),
                blurRadius: 3,
              ),
              BoxShadow(
                color: Colors.black12,
                offset: Offset(-1, -1),
                blurRadius: 3,
              ),
              BoxShadow(
                color: Colors.black12,
                offset: Offset(1, -1),
                blurRadius: 3,
              ),
              BoxShadow(
                color: Colors.black12,
                offset: Offset(-1, 1),
                blurRadius: 3,
              )
            ]),
        child: Column(
          children: <Widget>[
            Hero(
              tag: tag,
              child: Container(
                height: 150,
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: 150,
                      width: double.infinity,
                      child: xImgRoundRadius(
                        urlOrPath: data['baseInfo']['picUrl'],
                        //radius: 0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 3, bottom: 3, right: 3),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                flex: 2,
                                child: Container(
                                  // margin: EdgeInsets.symmetric(vertical: 3.0),
                                  //width: 80,
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(data['baseInfo']['name'], style: TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(
                                    // margin: EdgeInsets.symmetric(vertical: 3.0),
                                    //width: 80,
                                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: RichText(
                                      text: TextSpan(text: '￥', style: TextStyle(fontSize: 10, color: Colors.red), children: <TextSpan>[
                                        TextSpan(text: data['newPrice'].toString(), style: TextStyle(fontSize: 12)),
                                      ]),
                                    )),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                data['commentInfo']['content'],
                style: TextStyles.textComment,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 25,
                          height: 25,
                          child: xImgRoundRadius(urlOrPath: data['commentInfo']['avatarUrl'], radius: 25 / 2),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            data['commentInfo']['name'],
                            style: TextStyles.textSizeSM,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.thumb_up,
                        size: 13,
                      ),
                      Text(
                        ' ${getFormattedNumber(data['commentInfo']['likedCount'])}',
                        style: TextStyles.textSizeSM,
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 3,
            ),
          ],
        ));
  }
}
