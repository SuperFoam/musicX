import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:music_x/provider/player.dart';
import 'package:music_x/provider/song_sheet_detail.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/custom_search.dart';
import 'package:music_x/widgets/flexible_app_bar.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:music_x/widgets/music_list_header.dart';
import 'package:music_x/widgets/sheet_search.dart';
import 'package:music_x/widgets/song_more_info.dart';
import 'package:provider/provider.dart';

class SongSheetPage extends StatefulWidget {
  final String sheet;

  SongSheetPage({@required this.sheet});

  @override
  _SongSheetPageState createState() => _SongSheetPageState();
}

class _SongSheetPageState extends State<SongSheetPage> {
  String url = "http://p1.music.126.net/6t714sCD46VGEahrR9JKsQ==/109951164623302688.jpg?param=300y300";
  String defaultSSImage = 'assets/img/sheet.jpg';

  //List<Map> favoriteData;
  //PlayerModel player ;
  //int curSongID;
  //SongSheetModel _model;
  String songName = 'favorite';
  ReceivePort _port = ReceivePort();

  //List<Map> songList=[];
  Map _sheet;
  var _listKey = GlobalKey<SliverAnimatedListState>();


  @override
  void initState() {
    super.initState();
    print('歌曲列表init');
    // favoriteData = MyFavoriteSong.getData();
//    player= PlayerModel();
//    curSongID=player.curSong!=null?player.curSong['baseInfo']['id']:null;
    _sheet = FluroConvertUtils.string2map(widget.sheet);
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      if (mounted) {
//        Provider.of<SongSheetModel>(context);
        context.read<SongSheetModel>().init(_sheet);
      }
    });
  }

  @override
  void dispose() {
    // IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('歌曲列表rebuild');
//    _model =Provider.of<SongSheetModel>(context);
//    _model.init(songName);

//    SongSheetModel model = SongSheetModel();
//    model.init(favoriteData);
    return Scaffold(
      body: Consumer2<SongSheetModel, PlayerModel>(
        builder: (context, mo, _player, child) {
          return myFavorite(mo, _player);
        },
      ),
    );
//      ChangeNotifierProvider(
//      lazy: false,
//      create: (_)=>SongSheetModel()..init(favoriteData),
//      child:  Builder(builder: (context){
//        return Scaffold(
//          body: myFavorite(),
//        );
//      },)
//
//
//    );

//      ChangeNotifierProvider(
//        lazy: false,
//          create: (context)=> SongSheetModel()..init(favoriteData,songName),
//          child: Scaffold(
//            body: Consumer<SongSheetModel>(
//              builder: (context,_model,child){
//                return myFavorite(_model);
//              },
//            ),
//          )
////          Builder(builder: (context){
////            return Scaffold(
////              body: myFavorite(context),
////              //singleSliver(),
////              // tabSliver(),
////            );
////          },)
//
//      );

//      ChangeNotifierProvider<SongSheetModel>.value(
//       value: model,
//          child:  Builder(builder: (context){
//            return Scaffold(
//              body: myFavorite(),
//              //singleSliver(),
//              // tabSliver(),
//            );
//          },)
//
//      );
  }

  Widget myFavorite(_model, _player) {
    List songList = _model.songList;
    String curSongID = _player.curSong != null ? _player.curSong['baseInfo']['id'] : null;
//    PlayListHeaderBackground backgroundImage = songList.length == 0
//        ? PlayListHeaderBackground(
//            imageUrl: Constant.defaultSongImage, type: 'local')
//        : songList[0]['baseInfo']['picUrl'] == null
//            ? PlayListHeaderBackground(
//                imageUrl: Constant.defaultSongImage, type: 'local')
//            : PlayListHeaderBackground(
//                imageUrl: songList[0]['baseInfo']['picUrl'],
//              );
    PlayListHeaderBackground backgroundImage = PlayListHeaderBackground(
      imageUrl: songList.length == 0 ? null : songList[0]['baseInfo']['picUrl'],
    );
    var firstImage = xImgRoundRadius(urlOrPath: songList.length == 0 ? null : songList[0]['baseInfo']['picUrl']);
    final double screenW = MediaQuery
        .of(context)
        .size
        .width;
    double itemW = screenW * 0.2;
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          expandedHeight: 280,
          bottom: MusicListHeader(songList.length),
          flexibleSpace: FlexibleDetailBar(
            background: backgroundImage,
            content: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 100,
                        height: 100,
//                        decoration: BoxDecoration(
//                            borderRadius: BorderRadius.circular(5),
//                            image: DecorationImage(
//                                image: firstImage, fit: BoxFit.cover)),
                        child: firstImage,
                      ),
                      Container(
                        //width: 100,
                        height: 100,
                        margin: EdgeInsets.only(left: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[Text('你是我的小丫小歌单'), Text('怎么爱你都不嫌多')],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      InkWell(
                        onTap: () => downloadAll(songList),
                        child: SizedBox(
                          width: itemW,
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.file_download,
                                color: Colors.white,
                              ),
                              Text(
                                '下载',
                                style: TextStyle(color: Colors.white70),
                              )
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                          onTap: () => showSortAction(_model),
                          child: SizedBox(
                            width: itemW,
                            child: Column(
                              children: <Widget>[Icon(Icons.sort, color: Colors.white), Text('排序', style: TextStyle(color: Colors.white70))],
                            ),
                          )),
                      InkWell(
                        onTap: () {
                          if (songList.length <= 0) {
                            Utils.showToast('当前没有歌曲');
                            return;
                          }
                          NavigatorUtil.goSongManagePage(context);
                        },
                        child: SizedBox(
                          width: itemW,
                          child: Column(
                            children: <Widget>[Icon(Icons.select_all, color: Colors.white), Text('多选', style: TextStyle(color: Colors.white70))],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            builder: (context, t) =>
                AppBar(
                  leading: BackButton(),
                  automaticallyImplyLeading: false,
                  title: Text(t > 0.5 ? '我的音乐' : _model.sheetName),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  titleSpacing: 16,
                  actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.search),
                        tooltip: "歌单内搜索",
                        onPressed: () {
                          myShowSearch(
                            context: context,
                            delegate: SearchBarDelegate(songList: songList, curSongID: curSongID),
                          );
                        }),
                  ],
                ),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 60),
            sliver:
            animatedSongList(curSongID: curSongID, songList: songList, player: _player)
          //normalSongList(curSongID: curSongID, songList: songList, player: _player)
        )
      ],
    );
  }

  Widget animatedSongList({String curSongID, List songList, PlayerModel player}) {
    // AnimationLimiter
    return SliverList(
      //itemExtent: 60.0,
      delegate: SliverChildBuilderDelegate((content, index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: Duration(milliseconds: 100),
          // delay: Duration(milliseconds: 10),
          child: SlideAnimation(
            //滑动动画
            verticalOffset: 20.0,
            child: FadeInAnimation(
              //渐隐渐现动画
                child: buildSongList(curSongID: curSongID, songList: songList, index: index, player: player)),
          ),
        );
      }, childCount: songList.length),
    );
  }

  Widget normalSongList({String curSongID, List songList, PlayerModel player}) {
    return SliverFixedExtentList(
        itemExtent: 60.0,
        delegate: SliverChildBuilderDelegate((content, index) {
          return buildSongList(curSongID: curSongID, songList: songList, index: index, player: player);
        }, childCount: songList.length));
  }

  Widget buildSongList({String curSongID, List songList, int index, PlayerModel player}) {
    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        onLongPressSong(details, songList[index]);
      },
      child: Container(
        height: 60,
        child: ListTile(
          leading: Container(
              height: 40,
              width: 40,
              child: curSongID == songList[index]['baseInfo']['id'] ? Icon(Icons.volume_up, color: Theme
                  .of(context)
                  .primaryColor) : xImgRoundRadius(urlOrPath: songList[index]['baseInfo']['picUrl'])),
          title: Text(
            songList[index]['baseInfo']['name'],
            style: TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: <Widget>[
              if (songList[index]['isDownload'] == true)
                Icon(
                  Icons.cloud_done,
                  size: 15,
                  color: Theme
                      .of(context)
                      .primaryColor,
                )
              else
                if (songList[index]['isLocal'] == true)
                  Icon(
                    Icons.phone_android,
                    size: 15,
                    color: Theme
                        .of(context)
                        .primaryColor,
                  ),
              if(songList[index]['isTop']==true)
                Icon(
                  Icons.vertical_align_top,
                  size: 15,
                  color: Theme
                      .of(context)
                      .primaryColor,
                ),
              if (songList[index]['isDownload'] == true || songList[index]['isLocal'] == true || songList[index]['isTop']==true)
                SizedBox(
                  width: 5,
                ),
              Expanded(
                flex: 1,
                child: Text(
                  songList[index]['baseInfo']['author'],
                  style: TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: InkWell(
              child: Container(
                width: 40,
                height: 40,
                child: Icon(Icons.more_vert),
              ),
              onTap: () => showMusicMoreInfo(context, songList[index])),
          onTap: () {
            if (player.curSong != null && player.curSong['baseInfo']['id'] == songList[index]['baseInfo']['id']) {
              NavigatorUtil.goPlaySong(context);
            } else {
              List newPlayList = List.from(songList);
              player.playSong(songList[index], songIndex: index, newPlayList: newPlayList).then((value) {
                if (value == 404) {
                  Provider.of<SongSheetModel>(context, listen: false).refresh();
                }
              });
//                    setState(() {
//                      curSongID = songList[index]['baseInfo']['id'];
//                    });
            }
          },
        ),
      ),
    );
  }

  Future<void> downloadAll(List songList) async {
    List songList2 = [];
    songList.forEach((element) {
      if (element['isNetwork'] == true) {
        if (element['isDownload'] != true) songList2.add(element);
      }
    });
    if (songList2.length == 0) {
      Utils.showToast('没有可下载的歌曲');
      return;
    }
    bool isSuccess = await Funs.showCustomDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('确定要下载${songList2.length.toString()}首歌曲'),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("下载"),
              onPressed: () async {
                await downloadSongAllFun(songList2);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showSortAction(_model) {
    return showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text('选择歌曲排序方式'),
            cancelButton: CupertinoActionSheetAction(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '按添加时间倒序',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                    if (_model.sortType == 'timeZ_A')
                      SizedBox(
                        width: 10,
                      ),
                    if (_model.sortType == 'timeZ_A')
                      Icon(
                        Icons.done,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      )
                  ],
                ),
                onPressed: () {
                  if (_model.sortType != 'timeZ_A') {
                    _model.sortSongList('timeZ_A');
                    Navigator.of(context).pop();
                  }
                },
                isDefaultAction: _model.sortType == 'timeZ_A' ? true : false,
              ),
              CupertinoActionSheetAction(
                isDefaultAction: _model.sortType == 'timeA_Z' ? true : false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '按添加时间顺序',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                    if (_model.sortType == 'timeA_Z')
                      SizedBox(
                        width: 10,
                      ),
                    if (_model.sortType == 'timeA_Z')
                      Icon(
                        Icons.done,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      )
                  ],
                ),
                onPressed: () {
                  if (_model.sortType != 'timeA_Z') {
                    _model.sortSongList('timeA_Z');
                    Navigator.of(context).pop();
                  }
                },
              ),
              CupertinoActionSheetAction(
                isDefaultAction: _model.sortType == 'nameA_Z' ? true : false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '按歌曲名A-Z排序',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                    if (_model.sortType == 'nameA_Z')
                      SizedBox(
                        width: 10,
                      ),
                    if (_model.sortType == 'nameA_Z')
                      Icon(
                        Icons.done,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      )
                  ],
                ),
                onPressed: () {
                  if (_model.sortType != 'nameA_Z') {
                    _model.sortSongList('nameA_Z');
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  void onLongPressSong(LongPressStartDetails details, Map song) async {
   // print('song is $song');
     List<PopupMenuEntry<String>> popupItem = [];
   if(song['isTop']==true){
     final PopupMenuItem<String> cancelTop= PopupMenuItem(
       value: 'cancel_top',
       child: Row(
         children: <Widget>[
           Icon(Icons.arrow_downward),
           SizedBox(
             width: 3,
           ),
           Text("取消置顶"),
         ],
       ),
     );
     popupItem.add(cancelTop);
   }else{
     final PopupMenuItem<String> setTop =PopupMenuItem(
       value: 'set_top',
       child: Row(
         children: <Widget>[
           Icon(Icons.arrow_upward),
           SizedBox(
             width: 3,
           ),
           Text("置顶歌曲"),
         ],
       ),
     );
     popupItem.add(setTop);
   }

    String res = await showCustomPopupMenu(longPressDetail: details, popupItem: popupItem, context: context);
    if(res=='set_top')
      Provider.of<SongSheetModel>(context,listen: false).setTopSong(song);
    else  if(res=='cancel_top')
      Provider.of<SongSheetModel>(context,listen: false).cancelTopSong(song);
  }
}
