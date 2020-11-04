import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:music_x/pages/song/song_manage.dart';
import 'package:music_x/provider/player.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/music.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/custom_search.dart';
import 'package:music_x/widgets/flexible_app_bar.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:music_x/widgets/music_list_header.dart';
import 'package:music_x/widgets/sheet_search.dart';
import 'package:music_x/widgets/song_more_info.dart';
import 'package:provider/provider.dart';

class NetworkSongSheetPage extends StatefulWidget {
  final String sheet;

  NetworkSongSheetPage({@required this.sheet});

  @override
  _NetworkSongSheetPageState createState() => _NetworkSongSheetPageState();
}
class _NetworkSongSheetPageState extends State<NetworkSongSheetPage> {
  Map _sheet;
  List songList=[];
  List originSongList=[];
  String sortType="hotA_Z";

  @override
  void initState() {
    super.initState();
    _sheet = FluroConvertUtils.string2map(widget.sheet);
    print(_sheet);
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      if (mounted) {
      if(_sheet['isAlbum']==true) initAlbumSong();
      else initSongSheet();
      }
    });

  }
  void initSongSheet(){
    var cancel =Utils.showLoading();
    WYMusic('song').getPlaylistSongTotal(_sheet['id']).then((value) {
      if(value==null) Utils.showToast('获取歌曲失败');
      else setState(() {
        songList=value;
        originSongList=value;
      });
      cancel();
    });
  }
  void initAlbumSong() async{
    var cancel =Utils.showLoading();
    List data= await AlbumInfo(_sheet['id']).getAlbumSong();
    cancel();
    if(data==null){
      Utils.showToast('数据获取失败');
      return;
    }
    setState(() {
      songList=data;
      originSongList=data;
    });
  }
  @override
  Widget build(BuildContext context) {
    PlayListHeaderBackground backgroundImage=PlayListHeaderBackground(imageUrl: _sheet['image'],);
    var firstImage = xImgRoundRadius(urlOrPath:_sheet['image']);
    final double screenW = MediaQuery.of(context).size.width;
    double itemW = screenW * 0.2;
   return Scaffold(
     body: Consumer<PlayerModel>(
       builder: (context,_player,child){
         String curSongID =
         _player.curSong != null ? _player.curSong['baseInfo']['id'] : null;
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
                             child:firstImage ,
                           ),
                          Flexible(child:  Container(
                            //width: 100,
                            height: 100,
                            margin: EdgeInsets.only(left: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(_sheet['title'],),
                                Text(_sheet['subtitle'],style: TextStyle(fontSize: 13,color: Colors.grey),)
                              ],
                            ),
                          ),)
                         ],
                       ),
                       SizedBox(
                         height: 5,
                       ),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                         children: <Widget>[
                           InkWell(
                             onTap: ()=>downloadAll(context,songList),
                             child:  SizedBox(width: itemW,child: Column(
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
                             ),),
                           ),
                           InkWell(
                              onTap: ()=>showSortAction(),
                               child: SizedBox(width: itemW,child:  Column(
                                 children: <Widget>[
                                   Icon(Icons.sort, color: Colors.white),
                                   Text('排序', style: TextStyle(color: Colors.white70))
                                 ],
                               ),)
                           ),
                           InkWell(
                               onTap: (){
                                 if(_sheet['isAlbum']==true)return;
                                 Map t={
                                   "baseInfo":{
                                     "name":_sheet['title'],
                                     'author':_sheet['subtitle'],
                                     'picUrl':_sheet['image'],
                                     'id':_sheet['id']
                                   },
                                   'isSheet':_sheet['isSheet']
                                 };
                                 NavigatorUtil.goSongCommentPage(context, t);
                               },
                               child: SizedBox(width: itemW,child:  Column(
                                 children: <Widget>[
                                   Icon(Icons.comment, color: Colors.white),
                                   Text('评论', style: TextStyle(color: Colors.white70))
                                 ],
                               ),)
                           ),
                           InkWell(
                             onTap: (){
                               if(_sheet['isAlbum']==true)return;
                               if(songList.length<=0){
                                 Utils.showToast('当前没有歌曲');
                                 return;
                               }
                               NavigatorUtil.goSongManagePage(context,sheetId: _sheet['id']);
                             },
                             child: SizedBox(width: itemW,child:  Column(
                               children: <Widget>[
                                 Icon(Icons.select_all, color: Colors.white),
                                 Text('多选', style: TextStyle(color: Colors.white70))
                               ],
                             ),),
                           ),

                         ],
                       )
                     ],
                   ),
                 ),
                 builder: (context, t) => AppBar(
                   leading: BackButton(),
                   automaticallyImplyLeading: false,
                   title: Text(t > 0.5 ?   _sheet['title']: _sheet['isAlbum']==true?'专辑':'推荐歌单'),
                   backgroundColor: Colors.transparent,
                   elevation: 0,
                   titleSpacing: 16,
                   actions: <Widget>[
                     IconButton(
                         icon: Icon(Icons.search),
                         tooltip: "歌单内搜索",
                         onPressed: () {
                            myShowSearch(context: context, delegate: SearchBarDelegate(songList: songList,curSongID: curSongID,type: 'card'),);
                         }),
                   ],
                 ),
               ),
             ),
             SliverPadding(
               padding: EdgeInsets.only(bottom: 60),
               sliver: SliverFixedExtentList(
                 itemExtent: 60.0,
                 delegate: SliverChildBuilderDelegate((content, index) {
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
                         _player.playSong(songList[index], songIndex:index,newPlayList: newPlayList);
//                    setState(() {
//                      curSongID = songList[index]['baseInfo']['id'];
//                    });
                       }
                     },
                   );
                 }, childCount: songList.length),
               ),
             )
           ],
         );
       },
     )

   );
  }
  showSortAction(){
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
                    Text('按火热程度顺序',style: TextStyle(color: Colors.black.withOpacity(0.6)),),
                    if(sortType=='hotA_Z') SizedBox(width: 10,),
                    if(sortType=='hotA_Z') Icon(Icons.done,color: Theme.of(context).primaryColor,)
                  ],),
                onPressed: () {
                  if(sortType!='hotA_Z') {
                    setState(() {
                      songList=originSongList;
                      sortType='hotA_Z';
                    });
                    Navigator.of(context).pop();
                  }
                },
                isDefaultAction: sortType=='hotA_Z'?true:false,
              ),
              CupertinoActionSheetAction(
                isDefaultAction: sortType=='hotZ_A'?true:false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('按火热程度倒序',style: TextStyle(color: Colors.black.withOpacity(0.6)),),
                    if(sortType=='hotZ_A') SizedBox(width: 10,),
                    if(sortType=='hotZ_A') Icon(Icons.done,color: Theme.of(context).primaryColor,)
                  ],),
                onPressed: () {
                  if(sortType!='hotZ_A') {
                    setState(() {
                      songList=originSongList.reversed.toList();
                      sortType='hotZ_A';
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
              CupertinoActionSheetAction(
                isDefaultAction: sortType=='nameA_Z'?true:false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('按歌曲名A-Z排序',style: TextStyle(color: Colors.black.withOpacity(0.6)),),
                    if(sortType=='nameA_Z') SizedBox(width: 10,),
                    if(sortType=='nameA_Z') Icon(Icons.done,color: Theme.of(context).primaryColor,)
                  ],),
                onPressed: () {
                  if(sortType!='nameA_Z') {
                    Utils.showLoading();
                    setState(() {
                      List t=List.from(originSongList);
                      t.sort((a, b) => PinyinHelper.getShortPinyin(a['baseInfo']['name']).toLowerCase().
                      compareTo(PinyinHelper.getShortPinyin(b['baseInfo']['name']).toLowerCase()));
                      songList=t;
                      sortType='nameA_Z';
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        }
    );
  }

}
