import 'package:flutter/material.dart';
import 'package:music_x/provider/player.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/utils/music.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/flexible_app_bar.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:music_x/widgets/song_more_info.dart';
import 'package:music_x/widgets/tabs.dart';
import 'package:provider/provider.dart';

class SongArtistPage extends StatefulWidget {
  final String artistId;
  SongArtistPage({@required this.artistId});

  @override
  _SongArtistPageState createState() => _SongArtistPageState();
}

class _SongArtistPageState extends State<SongArtistPage>  with SingleTickerProviderStateMixin {
  var _tab1 = PageStorageKey('_tab1');
  var _tab2 = PageStorageKey('_tab2');
  String artistId;
  String artistName='未知';
  String artistImg = Constant.defaultSongImage;
  String userId;
  List songList=[];
  List albumList=[];
  TabController _tabController;
  bool isFirstAlbum=true;
  bool isFirstDesc=true;
  List artistIntroduction=[];

  @override
  void initState() {
    super.initState();
    artistId=widget.artistId;
    _tabController = new TabController(
        initialIndex: 0,
        vsync: this, //固定写法
        length: 3 //,// 指定tab长度
    );
    _tabController.addListener(() {
      if (_tabController.index == _tabController.animation.value) {
        var index = _tabController.index;
          if(index==1){
            if(isFirstAlbum){
              isFirstAlbum=false;
              initAlbum();
            }
          }else if(index==2){
          if(isFirstDesc){
            isFirstDesc=false;
            initArtistDesc();
          }
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(mounted){
        initHotSong();
      }
    });
  }
  void initHotSong() async{
    var cancel =Utils.showLoading();
    Map data = await SongArtist(artistId).getHotSong();
    cancel();
    if(data==null){
      Utils.showToast('数据获取失败');
      return;
    }
    setState(() {
      artistImg=data['artistPicUrl'];
      userId=data['userId'].toString();
      songList=data['song'];
      artistName=data['artistName'];
    });
  }
  void initAlbum() async{
    var cancel =Utils.showLoading();
    List data = await SongArtist(artistId).getAlbum();
    cancel();
    if(data==null){
      Utils.showToast('数据获取失败');
      return;
    }
    setState(() {
      albumList=data;
    });
  }
  void initArtistDesc() async{
    var cancel =Utils.showLoading();
    List data = await SongArtist(artistId).getArtistDesc();
    cancel();
    if(data==null){
      Utils.showToast('数据获取失败');
      return;
    }
    setState(() {
      artistIntroduction = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenH = MediaQuery.of(context).size.height;
//    Map curSong = Provider.of<PlayerModel>(context,listen: false).curSong;
//    String curSongID =curSong != null ? curSong['baseInfo']['id'] : null;
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (context, _) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    pinned: true,
                    expandedHeight: screenH * 0.35,
                    flexibleSpace: FlexibleDetailBar(
                      background: FlexShadowBackground(
                        child: Image(fit: BoxFit.cover, image: xImage(urlOrPath:artistImg )),
                      ),
                      content: Text(''),
                      builder: (context, t) => AppBar(
                        leading: BackButton(),
                        automaticallyImplyLeading: false,
                        title: Text(t > 0.5 ? artistName : ''),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        titleSpacing: 16,
                      ),
                    ),
                    bottom: RoundedTabBar(
                      tabController: _tabController,
                      tabs: <Widget>[
                        Tab(text: "热门歌曲"),
                        Tab(text: "专辑"),
                        Tab(text: "艺人介绍"),
                      ],
                    ),
                  ),
                )
              ];
            },
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight + kTextTabBarHeight, left: 5.0, right: 5.0),
                child: TabBarView(
                    controller: _tabController,
                  children: <Widget>[
                    Consumer<PlayerModel>(
                      builder: (context,_player,child){
                        String curSongID =
                        _player.curSong != null ? _player.curSong['baseInfo']['id'] : null;
                        return ListView.builder(
                          key: _tab1,
                            itemExtent: 60.0,
                            itemCount: songList.length,
                            itemBuilder: (context,int index){
                              return ListTile(
                                leading: Container(
                                    height: 40,
                                    width: 40,
                                    child: curSongID == songList[index]['baseInfo']['id']
                                        ? Icon(Icons.volume_up,
                                        color: Theme.of(context).primaryColor)
                                        : xImgRoundRadius(
                                        urlOrPath: songList[index]['baseInfo']['picUrl'])),
                                title: Text(
                                  songList[index]['baseInfo']['name'],
                                  style: TextStyle(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Row(children: <Widget>[
                                  if(songList[index]['isDownload']==true)  Icon(Icons.cloud_done,size: 15,color: Theme.of(context).primaryColor,)
                                  else if (songList[index]['isLocal']==true)  Icon(Icons.phone_android,size: 15,color: Theme.of(context).primaryColor,),
                                  if(songList[index]['isDownload']==true || songList[index]['isLocal']==true) SizedBox(width: 5,),
                                  Expanded(flex: 1,child:  Text(songList[index]['baseInfo']['author'],
                                    style: TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis,),),
                                ],),
                                trailing: InkWell(
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      child: Icon(Icons.more_vert),
                                    ),
                                    onTap: () => showMusicMoreInfo(context, songList[index],type: 'card')),
                                onTap: () {
                                  if (_player.curSong != null &&
                                      _player.curSong['baseInfo']['id'] ==
                                          songList[index]['baseInfo']['id']) {
                                    NavigatorUtil.goPlaySong(context);
                                  } else {
                                    List newPlayList=List.from(songList);
                                    Provider.of<PlayerModel>(context,listen: false).playSong(songList[index], songIndex:index,newPlayList: newPlayList);
                                  }
                                },
                              );
                            });
                      },
                    ),

                   ListView.builder(
                     key: _tab2,
                     itemExtent: 60,
                     itemCount: albumList.length,
                       itemBuilder: (context,int index){
                     return ListTile(
                       leading: Container(
                         height: 50,
                         width: 50,
                         child: xImgRoundRadius(urlOrPath: albumList[index]['picUrl']),
                       ),
                       title: Text(albumList[index]['name'],maxLines: 1,overflow: TextOverflow.ellipsis,),
                       subtitle: Row(children: <Widget>[
                         Text( getFormattedTime(albumList[index]['publishTime']),),
                         SizedBox(width: 5,),
                         Text('${albumList[index]['count']}首')
                       ],),
                       onTap: (){
                         Map t={
                           'title':albumList[index]['name'],
                           'subtitle':artistName,
                           'image':albumList[index]['picUrl'],
                           'id':albumList[index]['albumId'].toString(),
                           'isAlbum':true,
                         };
                         NavigatorUtil.goNetworkSongSheetPage(context, t);
                       },
                     );
                   }),
                    ListView(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      children:   List.generate(artistIntroduction.length, (index)  {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(children: <Widget>[
                              Icon(Icons.info_outline),
                              SizedBox(width: 5,),
                              Text(artistIntroduction[index]['key'])
                            ],),
                            SizedBox(height: 5,),
                            Text(artistIntroduction[index]['value']),
                            if(index!=artistIntroduction.length-1)Divider(thickness: 1,),
                            SizedBox(height: 10,),
                          ],
                        );
                      }),
                    )
                  ],
                ),
              ),
            ),
          ) ,

       );
  }
}
