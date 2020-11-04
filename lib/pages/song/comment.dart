import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_x/provider/song_sheet_detail.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/music.dart';
import 'package:music_x/utils/styles.dart';

import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/flexible_app_bar.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:music_x/widgets/music_list_header.dart';
import 'package:music_x/widgets/tabs.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SongCommentPage extends StatefulWidget {
  final String songInfo;

  SongCommentPage({@required this.songInfo});

  @override
  _SongCommentPageState createState() => _SongCommentPageState();
}

class _SongCommentPageState extends State<SongCommentPage>
    with SingleTickerProviderStateMixin {
  Map _song;
  double screenH;
  TabController _tabController;
  int commentCount = 0;
  List hotComment = [];
  List newComment = [];
  var _tab1 = PageStorageKey('_tab1');
  var _tab2 = PageStorageKey('_tab2');
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  RefreshController _controllerR = RefreshController(initialRefresh: false);
  int sum;
  int page = 0;
  int longPressIndex;

  @override
  void initState() {
    super.initState();
    _song = FluroConvertUtils.string2map(widget.songInfo);
    _tabController = new TabController(
        initialIndex: 0,
        vsync: this, //固定写法
        length: 2 //,// 指定tab长度
        );
    _scrollController.addListener(() {
//      print('位置滚动 $longPressIndex');
//        if(longPressIndex!=null){
//          setState(() {
//            longPressIndex=null;
//          });
//        }
    });
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      if (mounted) {
        var cancel =Utils.showLoading();
        await initData();
        cancel();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<int> initData() async {
    //_song['baseInfo']['id']='1454447163';
    Map value =
        await MusicComment.getCommentInfo(_song['baseInfo']['id'], page: page,isSheet: _song['isSheet']);
    //print(value);
    if (value == null) return -1;
    List hot = value['hotComments'];
    List _new = value['comments'];
    setState(() {
      if (value['total'] != null) sum = value['total'];
      if (page == 0) {
        if (hot != null) hotComment = hot;
        if (_new != null) newComment = _new;
      } else
        newComment.addAll(_new);
    });
    if (hot != null || _new != null) {
      if (_new.length > 0)
        return 1;
      else
        return 0;
    } else
      return 0;
  }

  @override
  Widget build(BuildContext context) {
    screenH = MediaQuery.of(context).size.height;
    double expandedHeight = 220.0; //screenH * 0.30;
    double imageH = 100; //expandedHeight*0.5;
    return Scaffold(
        body: NestedScrollView(
      // controller: _scrollController,
      headerSliverBuilder: (context, _) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              pinned: true,
              expandedHeight: expandedHeight,
              flexibleSpace: FlexibleDetailBar(
                background: PlayListHeaderBackground(
                    imageUrl: _song['baseInfo']['picUrl']),
                content: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: imageH,
                            height: imageH,
                            child: xImgRoundRadius(
                                urlOrPath: _song['baseInfo']['picUrl']),
                          ),
                          Flexible(
                            child: Container(
                              //width: 100,
                              height: imageH,
                              margin: EdgeInsets.only(left: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _song['baseInfo']['name'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${_song['baseInfo']['author']}',
                                    style: TextStyle(color: Colors.white70),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                builder: (context, t) => AppBar(
                  leading: BackButton(),
                  automaticallyImplyLeading: false,
                  title: Text(
                    t > 0.5
                        ? '${_song['baseInfo']['name']}${sum != null ? '($sum)' : ''}'
                        : '评论${sum != null ? '($sum)' : ''}',
                    style: TextStyle(fontSize: 18),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  titleSpacing: 16,
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
              bottom: RoundedTabBar(
                tabController: _tabController,
                tabs: <Widget>[
                  Tab(text: "热门评论"),
                  Tab(text: "最新评论"),
                ],
              ),
            ),
          )
        ];
      },
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              top: kToolbarHeight + kTextTabBarHeight, left: 5.0, right: 5.0),
          child: TabBarView(controller: _tabController, children: <Widget>[
            ListView.builder(
                key: _tab1,
                itemCount: hotComment.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 50,
                                    height: 50,
                                    child: xImgRoundRadius(
                                        urlOrPath: hotComment[index]['user']
                                            ['avatarUrl'],
                                        radius: 25),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        hotComment[index]['user']['nickname'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                          getFormattedTime(
                                              hotComment[index]['time']),
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  '${getFormattedNumber(hotComment[index]['likedCount'])} ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Icon(
                                  Icons.thumb_up,
                                  size: 15,
                                  color: Colors.grey,
                                )
                              ],
                            )
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 60),
                          child: GestureDetector(
                            child: longPressIndex == index
                                ? Container(
                                    color: Colors.grey.withOpacity(0.5),
                                    child: Text(hotComment[index]['content']),
                                  )
                                : Text(hotComment[index]['content']),
                            onLongPress: () async {
                              //if(_song['isOfficial']==true)return;
                              setState(() {
                                longPressIndex = index;
                              });
                              await Funs.showCustomDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      '确认替换歌曲评论吗',
                                      style: TextStyles.textDialogTitle,
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("取消"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FlatButton(
                                        child: Text("替换"),
                                        onPressed: () async {
                                          Provider.of<SongSheetModel>(context,listen: false).changeComment(_song, hotComment[index]['content'],
                                              hotComment[index]['likedCount'], hotComment[index]['user']['nickname']);
                                         // Provider.of<SongSheetModel>(context,listen: false).refresh();
                                          Navigator.of(context).pop();

                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (longPressIndex != null) {
                                setState(() {
                                  longPressIndex = null;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            RefreshConfiguration(
              enableLoadingWhenNoData: true,
              footerTriggerDistance: 50,
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
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
                child: buildNewComment(),
              ),
            ),

//                RefreshIndicator(
//                  displacement:30,
//                  onRefresh: () async{
//                   Utils.showToast('onRefresh');
//                  },
//                  child:   ListView.builder(
//                      key: _tab1,
//                      itemCount: hotComment.length,
//                      physics: BouncingScrollPhysics(),
//                      itemBuilder: (context,index){
//                        return Padding(padding: EdgeInsets.all(10.0),child: Column(
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          children: <Widget>[
//                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                              children: <Widget>[
//                                Container(
//                                  child: Row(children: <Widget>[
//                                    Container(width: 50,height: 50,child: xImgRoundRadius(urlOrPath:hotComment[index]['user']['avatarUrl'],radius: 25 ),),
//                                    SizedBox(width: 10,),
//                                    Column(
//                                      crossAxisAlignment: CrossAxisAlignment.start,
//                                      children: <Widget>[
//                                        Text(hotComment[index]['user']['nickname'],maxLines: 1,overflow: TextOverflow.ellipsis,),
//                                        Text(getFormattedTime(hotComment[index]['time']),style: TextStyle(color: Colors.grey)),
//                                      ],)
//                                  ],),
//                                ),
//                                Row(children: <Widget>[
//                                  Text('${getFormattedNumber(hotComment[index]['likedCount'])} ',style: TextStyle(color: Colors.grey),),
//                                  Icon(Icons.thumb_up,size: 15,color: Colors.grey,)
//                                ],)
//                              ],),
//                            Container(
//                              margin: EdgeInsets.only(left: 60),
//                              child: Text(hotComment[index]['content']),
//                            ),
//                          ],),);
//                      }),
//                ),
//
//                 NotificationListener(
//                    child:   RefreshIndicator(
//                        displacement:30,
//                        onRefresh: () async{
//                          RefreshProgressIndicator(value: 0.5,);
//                          Utils.showToast('onRefresh');
//                        },
//                      child:  buildNewComment(),
//                    ),
//                    onNotification:(notification){
//                      //ScrollEndNotification
//                      if (notification is ScrollUpdateNotification && notification.depth == 0 && !_isLoading){
//                        if (notification.metrics.pixels + 50 >= notification.metrics.maxScrollExtent) {
//                          Utils.showToast('到达底部');
//                        }
//                      }
//
//                      return true;
//                    }
//                ),
          ]),
        ),
      ),
    ));
  }

  Widget buildNewComment() {
    return ListView.builder(
        key: _tab2,
        //controller: _scrollController,
        itemCount: newComment.length,
        // physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 50,
                            child: xImgRoundRadius(
                                urlOrPath: newComment[index]['user']
                                    ['avatarUrl'],
                                radius: 25),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                newComment[index]['user']['nickname'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(getFormattedTime(newComment[index]['time']),
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          '${getFormattedNumber(newComment[index]['likedCount'])} ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Icon(
                          Icons.thumb_up,
                          size: 15,
                          color: Colors.grey,
                        )
                      ],
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 60),
                  child: Text(newComment[index]['content']),
                ),
              ],
            ),
          );
        });
  }
}
