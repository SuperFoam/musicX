import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_x/provider/local_song.dart';
import 'package:music_x/provider/music_card.dart';
import 'package:music_x/provider/player.dart';
import 'package:music_x/provider/song_sheet_detail.dart';
import 'package:music_x/provider/song_sheet_list.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/utils/custom_bottom_sheet.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:provider/provider.dart';
import 'local_or_network_image.dart';

const List allowDeleteType = ['sheet', 'localSheet'];

Future showMusicMoreInfo(context, songData, {type = 'sheet'}) {
  final double itemHeight = 40.0;
  final double screenW = MediaQuery.of(context).size.width;
  double itemW = screenW * 0.2;
  return myShowModalBottomSheet(
      context: context,
      //backgroundColor: Colors.transparent,
      elevation: 10,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                        width: itemW,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[Icon(Icons.add_box), Text('收藏')],
                        ),
                      ),
                      onTap: () => collectSong(context, songData, screenW)),
                  InkWell(
                    child: SizedBox(
                      width: itemW,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[Icon(Icons.playlist_add), Text('加放')],
                      ),
                    ),
                    onTap: () {
                      Provider.of<PlayerModel>(context, listen: false).addNextPlay(songData);
                      Navigator.of(context).pop();
                    },
                  ),
                  InkWell(
                    child: SizedBox(
                      width: itemW,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[Icon(Icons.file_download), Text('下载')],
                      ),
                    ),
                    onTap: () => downloadSong(context, songData, type),
                  ),
                  if (allowDeleteType.contains(type))
                    InkWell(
                      child: SizedBox(
                        width: itemW,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[Icon(Icons.delete), Text('删除')],
                        ),
                      ),
                      onTap: () {
                        deleteSong(context, songData, type);
                      },
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
                        children: <Widget>[Icon(Icons.music_note), SizedBox(width: 5), Text('歌曲：${songData['baseInfo']['name']}', maxLines: 1,
                          overflow: TextOverflow.ellipsis,)],
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
                        children: <Widget>[Icon(Icons.person_outline), SizedBox(width: 5), Text('歌手：${songData['baseInfo']['author']}', maxLines: 1,
                          overflow: TextOverflow.ellipsis,)],
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
                          Expanded(
                            flex: 1,
                            child: Text(
                              'ID：${songData['baseInfo']['id'].toString()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
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

void collectSong(context, songData, screenW) {
  List mySheet = MySongSheet.getData().reversed.toList();
  Map myFavorite = MyFavoriteSong.getData();
  myFavorite['icon'] = Icon(
    Icons.favorite_border,
    color: Theme.of(context).primaryColor,
  );
  mySheet.insert(0, {
    "name": "新建歌单",
    "id": -1,
    "icon": Icon(
      Icons.add,
      color: Theme.of(context).primaryColor,
    ),
    "song": []
  });
  mySheet.insert(1, myFavorite);
  // var defaultImg = AssetImage('assets/img/sheet.jpg');
  Color titleColor = Funs.isDarkMode(context)?Colours.dark_text:Colors.black87;
  Funs.showCustomDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        // title: Text("收藏歌曲 ${songData['baseInfo']['name']}",style: TextStyles.textSizeMD,),
        title: RichText(
          text: TextSpan(style: TextStyles.textDialogTitle, children: [
            TextSpan(text: '收藏歌曲',style: TextStyle(color: titleColor)),
            TextSpan(text: ' - ${songData['baseInfo']['name']}', style: TextStyles.textDialogName),
          ]),
        ),
        // insetPadding: EdgeInsets.all(10),
        content: Container(
          height: 300,
          width: screenW,
          child: ListView.builder(
              itemCount: mySheet.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    leading: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(5),
                            image: index > 1
                                ? DecorationImage(
                                    image: mySheet[index]['song'].length == 0
                                        ? xImage()
                                        : xImage(urlOrPath: mySheet[index]['song'].values.toList()[0]['baseInfo']['picUrl']),
                                    fit: BoxFit.cover)
                                : null),
                        child: mySheet[index]['icon']),
                    title: Text(mySheet[index]['name']),
                    subtitle: index > 0 ? Text('共${mySheet[index]['song'].length}首') : null,
                    onTap: () async {
                      if (index == 0) {
                        bool isSuccess = await Funs.showCustomDialog(
                          context: context,
                          builder: (context) {
                            TextEditingController _unameController = TextEditingController();
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
//                                                  Map sheetInfo=MySongSheet.create(_unameController.text);
//                                                  MySongSheet.addSong(sheetInfo['id'], songData);
                                    Provider.of<SongSheetListModel>(context, listen: false).createAndAdd(_unameController.text, songData);
                                    Navigator.of(context).pop(true);
                                    Navigator.of(context).pop(true);
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else if (index == 1) {
                        bool res = MyFavoriteSong.addSong(songData);
                        if (res == true) {
                          MusicCardModel().collectSongNotice(songData);
                          if (songData['isLocal'] == true) LocalSong.favoriteSong(songData['baseInfo']['id']);
                          Navigator.of(context).pop(true);
                          Navigator.of(context).pop(true);
                        }
                      } else {
                        bool res = Provider.of<SongSheetListModel>(context, listen: false).addSong(mySheet[index], songData);
                        if (res == true) {
                          Navigator.of(context).pop(true);
                          Navigator.of(context).pop(true);
                        }
                      }
                    });
              }),
        ),
      );
    },
  );
}

Future<void> downloadSong(context, songData, type) async {
  Color titleColor = Funs.isDarkMode(context)?Colours.dark_text:Colors.black87;
  bool isSuccess = await Funs.showCustomDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: RichText(
          text: TextSpan( style: TextStyles.textDialogTitle,children: [
            TextSpan(text: '确定要下载歌曲',style: TextStyle(color: titleColor) ),
            TextSpan(text: ' - ${songData['baseInfo']['name']}', style: TextStyles.textDialogName),
          ]),
        ),
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
              await downloadSongFun(songData, type: type);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              return;
            },
          ),
        ],
      );
    },
  );
//  if(isSuccess==true) {
//    bool res=Provider.of<SongSheetModel>(context,listen: false).deleteSong(songData);
//    if(res==true){
//      Utils.showToast('删除成功');
//      Navigator.of(context).pop();
//    }
//
//  }
}

Future<void> deleteSong(context, songData, type) async {
  bool isDelete = false;
  Color titleColor = Funs.isDarkMode(context)?Colours.dark_text:Colors.black87;
  bool isSuccess = await Funs.showCustomDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: RichText(
          text: TextSpan(style: TextStyles.textDialogTitle, children: [
            TextSpan(text: '确定要删除歌曲',style: TextStyle(color: titleColor)),
            TextSpan(text: ' - ${songData['baseInfo']['name']}', style: TextStyles.textDialogName),
          ]),
        ),
        content: songData['isDownload'] != true
            ? null
            : Builder(
                builder: (BuildContext context) {
                  return MediaQuery.removePadding(
                      removeLeft: true,
                      context: context,
                      child: CheckboxListTile(
                        value: isDelete,
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text('同时删除本地文件'),
                        onChanged: (value) {
                          (context as Element).markNeedsBuild();
                          isDelete = !isDelete;
                        },
                      ));
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
            child: Text("删除"),
            onPressed: () {
              bool res;
              if (type == 'localSheet')
                res = Provider.of<LocalSongModel>(context, listen: false).deleteSong(songData);
              else
                res = Provider.of<SongSheetModel>(context, listen: false).deleteSong(songData);
              if (res == true) {
                if (isDelete == true) {
                  String path = songData['playInfo']['path'];
                  if (File(path).existsSync()) File(path).deleteSync();
                }
                Utils.showToast('删除成功');
//                Provider.of<SongSheetListModel>(context, listen: false)
//                    .refresh();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
              //Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
//  if(isSuccess==true) {
//    bool res=Provider.of<SongSheetModel>(context,listen: false).deleteSong(songData);
//    if(res==true){
//      Utils.showToast('删除成功');
//      Navigator.of(context).pop();
//    }
//
//  }
}
