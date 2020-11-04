import 'package:flutter/cupertino.dart';
import 'package:music_x/provider/player.dart';
import 'package:music_x/provider/song_sheet_detail.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/utils/music.dart';
import 'package:music_x/widgets/custom_search.dart';
import 'package:music_x/widgets/custom_serach_goods.dart';
import 'package:flutter/material.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:music_x/widgets/song_more_info.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GoodsSearchBarDelegate extends MySearchDelegateGoods<String> {
  List recentSuggest = List.from(MySheetSearch.getData().reversed.toList());
  int id = 0;

  //List tabTitle = ['单曲', '专辑', '歌手', '歌单'];
  List songList = [];
  List albumList = [];
  List artistList = [];
  List sheetList = [];
  int page1,page2,page3,page4=0;
  List tabTitle = [
    {"name": "单曲", "type": 1},
    {"name": "专辑", "type": 10},
    {"name": "歌手", "type": 100},
    {"name": "歌单", "type": 1000},
  ];
  String oldQuery;
  RefreshController _controllerR1  =RefreshController(initialRefresh: false);
  RefreshController _controllerR2  =RefreshController(initialRefresh: false);
  RefreshController _controllerR3  =RefreshController(initialRefresh: false);
  RefreshController _controllerR4  =RefreshController(initialRefresh: false);
  GoodsSearchBarDelegate();

  @override
  String get searchFieldLabel => '搜点什么';

  @override
  loadData(BuildContext context) async { //加载数据
    if(query.isEmpty){
      Utils.showToast('请输入搜索内容');
      return false;
    }
    if (oldQuery != query) {
      oldQuery = query;
      songList = [];
      albumList = [];
       artistList = [];
       sheetList = [];
      page1=0;
      page2=0;
      page3=0;
      page4=0;
//      if(_controllerR.position!=null)  _controllerR.position.jumpTo(0.0);
//      _controllerR  =RefreshController(initialRefresh: false);
   //  if(_controllerR.position!=null) _controllerR.position.jumpTo(0.0);
//      if(_controllerR!=null)_controllerR.dispose();
//      _controllerR = RefreshController(initialRefresh: false);
    }
    else
      showResults(context);
    if (tabController.index == 0 && (songList==null || songList.isNotEmpty))
      return false;
    else if (tabController.index == 1 && (albumList==null || albumList.isNotEmpty)) return false;
    else if (tabController.index == 2 && (artistList==null || artistList.isNotEmpty)) return false;
    else if (tabController.index == 3 && (sheetList==null || sheetList.isNotEmpty)) return false;
    var cancel = Utils.showLoading();
    List data = await GoodsSearch().getSearchRes(query, type: tabTitle[tabController.index]['type']);
    cancel();
    if (tabController.index == 0) songList = data;
    else if (tabController.index == 1) albumList = data;
    else if (tabController.index == 2) artistList = data;
    else if (tabController.index == 3) sheetList = data;
    showResults(context);

  }
  loadMoreData(int page) async{
   // var cancel = Utils.showLoading();
    List data = await GoodsSearch().getSearchRes(query, type: tabTitle[tabController.index]['type'],page: page);
   // cancel();
    return data;
  }

  @override
  Widget buildAppBarBottom(BuildContext context) { //tabbar
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: Container(
            height: 40,
            child: TabBar(
              controller: tabController,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Theme.of(context).primaryColor,
              tabs: List.generate(
                  tabTitle.length,
                  (index) => Tab(
                        text: tabTitle[index]['name'],
                      )),
            )));
  }

  @override
  Widget buildResults(BuildContext context) {
    if(query.isNotEmpty){
      MySheetSearch.add(query);
      recentSuggest = List.from(MySheetSearch.getData().reversed.toList());
    }

    //print('展示结果');
    return TabBarView(controller: tabController, children: <Widget>[
      songList==null?Center(child: Text('无相关结果1'),):buildSong(),
      albumList==null?Center(child: Text('无相关结果2'),):buildAlbum(),
      artistList==null?Center(child: Text('无相关结果3'),):buildArtist(),
      sheetList==null?Center(child: Text('无相关结果4'),):buildSheet(),
    ]);

  }
  Widget buildSong(){
    return  Consumer<PlayerModel>(
      builder: (context, _player, child) {
        String curSongID = _player.curSong != null ? _player.curSong['baseInfo']['id'] : null;
        return  RefreshConfiguration(
          //enableLoadingWhenNoData: true,
         // enableScrollWhenRefreshCompleted: true,
          footerTriggerDistance: 80,
          child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            footer: ClassicFooter(
             // loadStyle: LoadStyle.ShowAlways,
              //completeDuration: Duration(microseconds: 50),
            ),
            onLoading: () async {
              page1 += 1;
              //page=10000;
              List res = await loadMoreData(page1);
              if (res == null) {
                _controllerR1.loadNoData();
                //controllerRefresh.loadNoData();
                return;
              }else
                _controllerR1.loadComplete();
                //controllerRefresh.loadNoData();
              songList.addAll(res);
              id+=1;
              historyIndex=id;
            },
            controller: _controllerR1,
            child: ListView.builder(
                key: PageStorageKey('tab1_$query'),
                itemExtent: 60.0,
                itemCount: songList.length,
                itemBuilder: (context, int index) {
                  return ListTile(
                    leading: Container(
                        height: 40,
                        width: 40,
                        child: curSongID == songList[index]['baseInfo']['id']
                            ? Icon(Icons.volume_up, color: Theme.of(context).primaryColor)
                            : xImgRoundRadius(urlOrPath: songList[index]['baseInfo']['picUrl'])),
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
                            color: Theme.of(context).primaryColor,
                          )
                        else if (songList[index]['isLocal'] == true)
                          Icon(
                            Icons.phone_android,
                            size: 15,
                            color: Theme.of(context).primaryColor,
                          ),
                        if (songList[index]['isDownload'] == true || songList[index]['isLocal'] == true)
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
                        onTap: () => showMusicMoreInfo(context, songList[index], type: 'card')),
                    onTap: () {
                      if (_player.curSong != null && _player.curSong['baseInfo']['id'] == songList[index]['baseInfo']['id']) {
                        NavigatorUtil.goPlaySong(context);
                      } else {
                        List newPlayList = List.from(songList);
                        Provider.of<PlayerModel>(context, listen: false).playSong(songList[index], songIndex: index, newPlayList: newPlayList);
                      }
                    },
                  );
                })
          ),
        );


      },
    );

  }

  Widget buildAlbum(){
    return RefreshConfiguration(
      //enableLoadingWhenNoData: true,
      // enableScrollWhenRefreshCompleted: true,
       footerTriggerDistance: 80,
      child: SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          footer: ClassicFooter(
            // loadStyle: LoadStyle.ShowAlways,
            //completeDuration: Duration(microseconds: 50),
          ),
          onLoading: () async {
            page2 += 1;
            //page=10000;
            List res = await loadMoreData(page2);
            if (res == null) {
              _controllerR2.loadNoData();
              //controllerRefresh.loadNoData();
              return;
            }else
              _controllerR2.loadComplete();
            //controllerRefresh.loadNoData();
            albumList.addAll(res);
            id+=1;
            historyIndex=id;
          },
          controller: _controllerR2,
          child: ListView.builder(
              key: PageStorageKey('tab2_$query'),
              itemExtent: 60,
              itemCount: albumList.length,
              itemBuilder: (context, int index) {
                return ListTile(
                  leading: Container(
                    height: 50,
                    width: 50,
                    child: xImgRoundRadius(urlOrPath: albumList[index]['picUrl']),
                  ),
                  title: Text(
                    albumList[index]['name'] ?? '未知',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Row(
                    children: <Widget>[
                      Text(albumList[index]['artistName']),
                      SizedBox(
                        width: 5,
                      ),
                      Text('${albumList[index]['count']}首')
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Map t = {
                      'title': albumList[index]['name'],
                      'subtitle': albumList[index]['artistName'],
                      'image': albumList[index]['picUrl'],
                      'id': albumList[index]['albumId'].toString(),
                      'isAlbum': true,
                    };
                    NavigatorUtil.goNetworkSongSheetPage(context, t);
                  },
                );
              })
      ),
    );
  }
  Widget buildArtist(){
    return RefreshConfiguration(
      //enableLoadingWhenNoData: true,
      // enableScrollWhenRefreshCompleted: true,
       footerTriggerDistance: 80,
      child: SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          footer: ClassicFooter(
            // loadStyle: LoadStyle.ShowAlways,
            //completeDuration: Duration(microseconds: 50),
          ),
          onLoading: () async {
            page3 += 1;
            //page=10000;
            List res = await loadMoreData(page3);
            if (res == null) {
              _controllerR3.loadNoData();
              //controllerRefresh.loadNoData();
              return;
            }else
              _controllerR3.loadComplete();
            //controllerRefresh.loadNoData();
            artistList.addAll(res);
            id+=1;
            historyIndex=id;
          },
          controller: _controllerR3,
          child: ListView.builder(
              key: PageStorageKey('tab3_$query'),
              itemExtent: 60,
              itemCount: artistList.length,
              itemBuilder: (context, int index) {
                return ListTile(
                  leading: Container(
                    height: 50,
                    width: 50,
                    child: xImgRoundRadius(urlOrPath: artistList[index]['picUrl']),
                  ),
                  title: Text(
                    artistList[index]['name'] ?? '未知',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${artistList[index]['albumSize']}首') ,
                  trailing:  Icon(Icons.arrow_forward_ios,size: 18,) ,
                  onTap: () {
                    NavigatorUtil.goSongArtistPage(context,artistList[index]['id'].toString() );
                  },
                );
              })
      ),
    );
  }
  Widget buildSheet(){
    return RefreshConfiguration(
      //enableLoadingWhenNoData: true,
      // enableScrollWhenRefreshCompleted: true,
       footerTriggerDistance: 80,
      child: SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          footer: ClassicFooter(
            // loadStyle: LoadStyle.ShowAlways,
            //completeDuration: Duration(microseconds: 50),
          ),
          onLoading: () async {
            page4 += 1;
            //page=10000;
            List res = await loadMoreData(page4);
            if (res == null) {
              _controllerR4.loadNoData();
              //controllerRefresh.loadNoData();
              return;
            }else
              _controllerR4.loadComplete();
            //controllerRefresh.loadNoData();
            sheetList.addAll(res);
            id+=1;
            historyIndex=id;
          },
          controller: _controllerR4,
          child: ListView.builder(
              key: PageStorageKey('tab4_$query'),
              itemCount: sheetList.length,
              cacheExtent: 60,
              itemBuilder: (context,int index){
                return ListTile(
                  leading: Container(width: 50,height:50,child:xImgRoundRadius(urlOrPath: sheetList[index]['picUrl']) ,),
                  title:  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(sheetList[index]['title'],style: TextStyle(fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis,),
                  ),
                  subtitle: Row(children: <Widget>[
                    Icon(Icons.queue_music,size: 14,),
                    Text('${sheetList[index]['count']}首'),
                    SizedBox(width: 10,),
                    Icon(Icons.headset,size: 14,),
                    Text(getFormattedNumber(sheetList[index]['playCount'])+'播放')
                  ],),
                  trailing: Icon(Icons.arrow_forward_ios,size: 18,),
                  onTap: (){
                    Map t={
                      'title':sheetList[index]['title'],
                      'subtitle':sheetList[index]['username'],
                      'image':sheetList[index]['picUrl'],
                      'id':sheetList[index]['id'].toString(),
                      'isSheet':true,
                    };
                    NavigatorUtil.goNetworkSongSheetPage(context, t);
                  },
                );
              })
      ),
    );
  }


  @override
  Widget buildSuggestions(BuildContext context) {
    //print('当前索引${tabController.index}');
    if (query.isEmpty)
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
          ]
            ..addAll(historySearch(context))
            ..add(SizedBox(
              height: 20,
            ))
            ..addAll(hotSearch),
        ),
      );
    else
      return FutureBuilder(
        future: GoodsSearch().getSearchSuggest(query),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List data = snapshot.data;
            if (data.length == 0) data.add({"keyword": query});
            return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, int index) {
                  return ListTile(
                    title: Text(data[index]['keyword']),
                    trailing: RotatedBox(
                      quarterTurns: 3,
                      child: Icon(
                        Icons.call_made,
                        size: 18,
                      ),
                    ),
                    onTap: () {
                      query = data[index]['keyword'];
                      loadData(context);
                      //showResults(context);
                    },
                  );
                });
          } else
            return Center(
              child: CupertinoActivityIndicator(
                radius: 10,
              ),
            );
        },
      );
  }

  List<Widget> historySearch(context) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '历史记录',
            style: TextStyles.textDialogTitle,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              if (recentSuggest.length == 0) return;
              Funs.showCustomDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      '确定要删除${recentSuggest.length}条历史记录',
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
                        child: Text("删除"),
                        onPressed: () {
                          MySheetSearch.clean();
                          recentSuggest.clear();
                          historyIndex = recentSuggest.length + 1;
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      Wrap(
        spacing: 10,
        //runSpacing: 1,
        children: List.generate(recentSuggest.length, (index) {
          return GestureDetector(
            onTap: () {
              query = recentSuggest[index];
             // showResults(context);
            },
            child: Chip(
              label: Text(recentSuggest[index]),
              onDeleted: () {
                MySheetSearch.delete(recentSuggest[index]);
                recentSuggest.removeAt(index);
                id += 1;
                historyIndex = id;
                // showSuggestions(context);
              },
              deleteIcon: Icon(Icons.delete_forever),
              deleteIconColor: Colors.grey,
            ),
          );
        }),
      )
    ];
  }

  List<Widget> get hotSearch {
    return [
      Text(
        '大家在搜',
        style: TextStyles.textDialogTitle,
      ),
      FutureBuilder(
          future: GoodsSearch().getHotSearch(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == null) return SizedBox();
              List hotList = snapshot.data;
              return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: hotList.length,
                  itemBuilder: (context, int index) {
                    return ListTile(
                      contentPadding: EdgeInsets.only(left: 0),
                      leading: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        hotList[index]['searchWord'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(hotList[index]['content'], maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Text(
                        '${hotList[index]['score']}',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      onTap: () {
                        query = hotList[index]['searchWord'];
                        loadData(context);
                        //showResults(context);
                      },
                    );
                  });
            } else
              return SizedBox();
          })
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    // return super.appBarTheme(context);
    ThemeData t = Theme.of(context);
    ThemeData tt = t.copyWith(
        backgroundColor: Funs.isDarkMode(context) ? Colours.dark_page_color : Colors.white,
        primaryIconTheme: t.primaryIconTheme.copyWith(color: Colors.grey),
        primaryTextTheme: t.textTheme);
    return tt;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      InkWell(
        onTap: () async {
          loadData(context);
        },
        child: Container(
          width: 40,
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: Center(
            child: Text('搜索'),
          ),
        ),
      ),
      IconButton(
        icon: Icon(Icons.clear, color: Colors.grey),
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
      ),
      IconButton(
        icon: Icon(
          Icons.camera_alt,
          color: Colors.grey,
          size: 15,
        ),
        onPressed: () {
//          query = "";
//          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = "";
          showSuggestions(context);
        }
      },
    );
  }
}

//note
/*
custom_serach_goods.dart 第347行，maintainState设置为true，可路由跳转返回后保持之前状态
在118行新增loadData，buildAppBarBottom等一些数据并重写用于tabbar，
296行设置historyIndex用于删除历史记录更新页面, and 477
556行用于回车加载数据
 */
