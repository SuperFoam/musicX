import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:music_x/provider/music_card.dart';
import 'package:music_x/provider/player.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/cached_image.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/custom_paint.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:music_x/widgets/music_list_header.dart';
import 'package:music_x/widgets/playList.dart';
import 'package:provider/provider.dart';
import 'package:music_x/widgets/round_img.dart';
import 'dart:math' as math;

class PlaySongsPage extends StatefulWidget {
  @override
  _PlaySongsPageState createState() => _PlaySongsPageState();
}

class _PlaySongsPageState extends State<PlaySongsPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller; // 封面旋转控制器
  Animation<double> animation;
  int switchIndex = 0; //用于切换歌词
  double screenW;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );
    var length2 = math.pi * 2;
    animation = Tween(begin: 0.0, end: length2).animate(_controller);
//    _controller.addStatusListener((status) {
//      // 转完一圈之后继续
//      if (status == AnimationStatus.completed) {
//        _controller.reset();
//        _controller.forward();
//      }
//    });
  }

  @override
  Widget build(BuildContext context) {
    print('----------');
    print('播放详情页rebuild');
    Color baseColor = Colors.grey;
    screenW = MediaQuery.of(context).size.width;
    return Consumer<PlayerModel>(builder: (context, _player, child) {
      var curSong = _player.curSong;
      _player.playerAnimation(_controller);
      return  Scaffold(
          body:
          Stack(
            children: <Widget>[
              BlurBackground(imageUrl:curSong['baseInfo']['picUrl']),
              AppBar(
                centerTitle: true,
                brightness: Brightness.dark,
                iconTheme: IconThemeData(color: Colors.white),
                backgroundColor: Colors.transparent,
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      curSong['baseInfo']['name'],
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      curSong['baseInfo']['author'],
                      style: TextStyle(fontSize: 12, color: baseColor),
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        child: Hero(
                            tag: 'cir',
                            child: Center(
                              child: AnimatedBuilder(
                                  animation: animation,
                                  builder: (BuildContext ctx, Widget child) {
                                    // print('animation.value ${animation.value}');
                                    return Transform.rotate(
                                        angle: animation.value,
                                        child: Container(
                                          width: screenW*0.5,
                                          height: screenW*0.5,
                                        child: xImgRoundRadius(urlOrPath: _player.curSong['baseInfo']['picUrl'],radius: screenW*0.5/2),
                                        ));
                                  }),
                            )),
                      )),
                  CustomPaint(
                    painter: ChatBubblePainter(
                        Funs.isDarkMode(context) ? Colors.white10 : Colors.blue,
                        'bottom3/4'), //TrianglePainter(Colors.blue) ,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      // margin: EdgeInsets.symmetric(horizontal: screenW*0.1),
                      //width: screenW * 0.9,
                     // height: 80,
                                          constraints: BoxConstraints(
                                            maxHeight: 100,
                                            minHeight: 80,
                                            maxWidth: screenW * 0.9,
                                            minWidth: screenW * 0.9,
                                          ),
                      child: Center(
                          child: SingleChildScrollView(
                            child: Text(
                              curSong['commentInfo']['content'],
                              style: TextStyles.textComment,
                            ),
                          )),
                    ),
                  ),
                  Container(
                    width: screenW * 0.9,
                    height: 50,
                    //padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          onPressed: ()=>_player.favoriteSong(),
                          icon: Icon(curSong['isFavorite']==true?Icons.favorite:Icons.favorite_border,
                            color:curSong['isFavorite']==true?Theme.of(context).primaryColor:baseColor,),
                          alignment: Alignment.centerLeft,
                        ),
                        IconButton(
                          onPressed: ()=>downloadSongFun(curSong),
                          icon: Icon(Icons.file_download,color:baseColor),
                          //   alignment: Alignment.centerRight,
                        ),
                        IconButton(
                          onPressed: () {
                            if(curSong['isNetwork']==true)
                            NavigatorUtil.goSongCommentPage(context, curSong);
                            else
                              Utils.showToast('本地歌曲没有评论');
                          },
                          icon: Icon(Icons.comment,color: baseColor),
                          // alignment: Alignment.centerRight,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.more_vert,color:baseColor),
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                  ),
                  Container(
                      width: double.infinity,
                      height: 30,
                      margin: EdgeInsets.symmetric(vertical: 15),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: StreamBuilder<Map>(
                          stream: _player.curPositionStream,
                          builder: (context, snapshot) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(snapshot.data != null
                                    ? snapshot.data['curTimeStr']
                                    : _player.curTimeStr,style: TextStyle(color: baseColor),),
                                Expanded(
                                  flex: 1,
                                  child: Slider(
                                    value: snapshot.data != null
                                        ? snapshot.data['curTime'].toDouble()
                                        : _player.curTime,
                                    onChanged: (data) {
                                      _player.sinkProgress(
                                          data.toInt(), _player.curTimeStr);
                                    },
                                    onChangeStart: (data) {
                                      _player.pausePlay();
                                    },
                                    onChangeEnd: (data) {
                                      _player.seekPlay(data.toInt());
                                    },
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white30,
                                    min: 0.0,
                                    max: snapshot.data != null
                                        ? snapshot.data['totalTime']
                                        : _player.curSongDuration.inMilliseconds
                                        .toDouble(),
                                  ),
                                  // }),
                                ),
                                Text(_player.curSongTotal,style: TextStyle(color: baseColor)),
                              ],
                            );
                          })),
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.only(bottom: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          reverseDuration: const Duration(milliseconds: 200),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(child: child, scale: animation);
                          },
                          child: IconButton(
                            key: ValueKey(_player.curSongMode['tooltip']),
                            icon: _player.curSongMode['icon'],
                            tooltip: _player.curSongMode['tooltip'],
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              _player.switchMode();
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_previous,color: baseColor,),
                          tooltip: '上一首',
                          onPressed: ()=>_player.playPreSong(),
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
                            key: ValueKey(_player.playIcon['tooltip']),
                            icon: _player.playIcon['icon'],
                            tooltip: _player.playIcon['tooltip'],
                            onPressed: () {
                              _player.playSong(curSong);
                            },
                            padding: EdgeInsets.all(0),
                          ),
                        ),
//                  IconButton(
//                    icon: Icon(
//                      Icons.play_circle_outline,
//                      size: 35,
//                    ),
//                    onPressed: () {},
//                  ),
                        IconButton(
                          icon: Icon(Icons.skip_next,color: baseColor),
                          tooltip: '下一首',
                          onPressed: ()=>_player.playNextSong(),
                        ),
                        IconButton(
                          icon: Icon(Icons.menu,color: baseColor),
                          tooltip: '播放列表',
                          onPressed: () {
                            //playList(context,_controllerList);
                            PlayingListDialog.show(context);
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          )

      );

    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

Future playList(context ,_controllerList) {
  // var _player = PlayerModel();
  double offset = 200.0;
  _controllerList = ScrollController(initialScrollOffset: offset);
  return showModalBottomSheet(
    context: context,
    elevation: 10,
    isScrollControlled: false,
    //backgroundColor: Color(0xff303030),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (BuildContext context) {
      return Container(
          height: 500.0,
          padding: EdgeInsets.all(5.0),
          //color: Color(0xfff1f1f1),
          child:
          Consumer<PlayerModel>(builder: (context, _player, child) {
            List listData = _player.playList;
            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      reverseDuration: const Duration(milliseconds: 200),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(child: child, scale: animation);
                      },
                      child: IconButton(
                        key: ValueKey(_player.curSongMode['tooltip']),
                        icon: _player.curSongMode['icon'],
                        tooltip: _player.curSongMode['tooltip'],
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          _player.switchMode();
                        },
                      ),
                    ),
                    Text(_player.curSongMode['tooltip']),
                    Text('(${_player.playList.length}首)')
                  ],
                ),
                Divider(
                  height: 2,
                ),
                Expanded(
                  flex: 1,
                  child:  ListView.separated(
                    controller: _controllerList,
                    itemCount: 50,
                    itemBuilder: ( context, int index) {
                      return Text('Item$index');
                    },
                    separatorBuilder: ( context, int index){
                      return Divider( height: 20,);
                    },

                  ),
                )
//                ListView.builder(
//                  itemCount: listData.length,
//                  itemBuilder: (context, int index) {
//                    return ListTile(
//                        title: Text(listData[index]['baseInfo']['name']));
//                  },
//                )
              ],
            );
          }));
    },
  );
}
