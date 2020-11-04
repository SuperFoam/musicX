
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

import 'package:music_x/provider/song_sheet_detail.dart';
import 'package:music_x/provider/song_sheet_list.dart';
import 'package:music_x/utils/colors.dart';

import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/extend_list_title.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:music_x/utils/music.dart';

class SongManagePage extends StatefulWidget {
  final String sheetId;
  SongManagePage({this.sheetId});

  @override
  _SongManagePageState createState() => _SongManagePageState();
}

class ItemData {
  ItemData(this.song, this.key);

  final Map song;
  final Key key;
  bool isSelect = false;
}

class _SongManagePageState extends State<SongManagePage> {
  int select = 0;
  double selectW = 60;
  bool isSelectAll = false;
  String selectS = '全选';
  List songList = [];
  List<ItemData> itemList = [];

  @override
  void initState() {
    super.initState();
    if(widget.sheetId!=null){
      WidgetsBinding.instance.addPostFrameCallback((callback) {
        if (mounted) {
          var cancel =Utils.showLoading();
          WYMusic('song').getPlaylistSongTotal(widget.sheetId).then((value) {
            if(value==null) Utils.showToast('获取歌曲失败');
            else setState(() {
              songList=value;
              for (int i = 0; i < songList.length; i++) {
                itemList.add(ItemData(songList[i], ValueKey(i)));
              }
            });
            cancel();
          });
        }
      });
    }else{
      String sortType=Provider.of<SongSheetModel>(context, listen: false).sortType;
      if(sortType=='timeZ_A')
        songList = Provider.of<SongSheetModel>(context, listen: false).songList;
      else
        songList=Provider.of<SongSheetModel>(context, listen: false).originSongList.reversed.toList();
      for (int i = 0; i < songList.length; i++) {
        itemList.add(ItemData(songList[i], ValueKey(i)));
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    double itemW = MediaQuery.of(context).size.width / 4;
    double itemH = 50.0;
    return Scaffold(
      appBar: AppBar(
        title: Text('已选择$select首'),
        actions: <Widget>[
          InkWell(
            onTap: () {
              toggleSelect();
            },
            child: Container(
              width: selectW,
              //margin: EdgeInsets.only(right: 20),
              child: Center(
                child: Text(selectS),
              ),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
//          DragList<Map<String,dynamic>>(
//            items:List.from(songList) ,
//            itemExtent: 50.0,
//            itemBuilder: (context,item,handle){
//              return  Container(
//                height: 50.0,
//                child: Row(children: [
//                  Spacer(),
//                  Text(item.value['baseInfo']['name']),
//                  Spacer(),
//                  handle,
//                ]),
//              );
//            },
//            handleBuilder: (_) { //自定义拖动点组件
//              return Padding(
//                padding: EdgeInsets.symmetric(vertical: 8.0),
//                child: Icon(Icons.arrow_forward,color: Colors.red,),
//              );
//            },
//          ),
          Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(bottom: 0),
                child: ReorderableList(
                  onReorder: (Key item, Key newPosition) {
                    int draggingIndex = _indexOfKey(item);
                    int newPositionIndex = _indexOfKey(newPosition);
                    final draggedItem = itemList[draggingIndex];
                    setState(() {
                      itemList.removeAt(draggingIndex);
                      itemList.insert(newPositionIndex, draggedItem);
                    });
                    return true;
                  },
                  onReorderDone: (item) {
                    if(widget.sheetId==null)
                    onMoveDone();
                  },
                  child: ListView.builder(
                      itemCount: itemList.length,
                      itemExtent: 60,
                      itemBuilder: (context, index) {
                        return Item(
                          data: itemList[index],
                          isFirst: index == 0,
                          isLast: index == itemList.length - 1,
                          callback: (d, r) => setSelect(d, r),
                        );
                      }),
                ),
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                InkWell(
                    child: SizedBox(
                      height: itemH,
                      width: itemW,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[Icon(Icons.add_box), Text('收藏')],
                      ),
                    ),
                    onTap: () => batchCollection()),
                InkWell(
                    child: SizedBox(
                      height: itemH,
                      width: itemW,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[Icon(Icons.file_download), Text('下载')],
                      ),
                    ),
                    onTap: ()=>batchDownload()),
                if(widget.sheetId==null)
                InkWell(
                    child: SizedBox(
                      height: itemH,
                      width: itemW,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[Icon(Icons.delete), Text('删除')],
                      ),
                    ),
                    onTap: ()=>batchDelete()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _indexOfKey(Key key) {
    return itemList.indexWhere((ItemData d) {
      return d.key == key;
    });
  }
  void onMoveDone(){
//    itemList.forEach((element) {
//      print(element.song['baseInfo']['name']);
//    });

    List songList=itemList.map((e) => e.song).toList().reversed.toList();
    Provider.of<SongSheetModel>(context,listen: false).moveSongOrder(songList);
  }

  void setSelect(ItemData d, bool res) {
    if (res == true)
      select++;
    else
      select--;
    int index = itemList.indexWhere((element) => element == d);
    if (index != -1)
      setState(() {
        itemList[index].isSelect = res;
      });
  }

  void toggleSelect() {
    bool res = !isSelectAll;
    if (res == true)
      select = itemList.length;
    else
      select = 0;
    setState(() {
      itemList.forEach((element) {
        element.isSelect = res;
      });
      isSelectAll = res;
      selectW = isSelectAll == true ? 100 : 60;
      selectS = isSelectAll == true ? '取消全选' : '全选';
    });
  }
  List batchCheck(){
    if (select <= 0) {
      Utils.showToast('请勾选歌曲');
      return [];
    }
    List selectSong = [];
    itemList.forEach((element) {
      if (element.isSelect == true) selectSong.add(element.song);
    });
    return selectSong;
  }
  void batchCollection() {
    List selectSong=batchCheck();
    if(selectSong.length==0)return;
    collectSong(
      context,
      selectSong,
    );
  }
  void batchDownload() {
    List selectSong=batchCheck();
    if(selectSong.length==0)return;
    downloadAll(
      context,
      selectSong,
    );
  }

  void batchDelete(){
    List selectSong=batchCheck();
    if(selectSong.length==0)return;
    deleteSong(context,selectSong).then((value){
      if(value==true){
        setState(() {
          select=0;
          selectSong.forEach((song) {
            itemList.removeWhere((element) => element.song==song);
          });
        });

      }
    });

  }

}

void collectSong(context, List songList) {
  double screenW = MediaQuery.of(context).size.width;
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
        title: RichText(
          text: TextSpan(style: TextStyles.textDialogTitle, children: [
            TextSpan(text: '收藏歌曲',  style: TextStyle(color: titleColor) ),
            TextSpan(text: '  ${songList.length}首', style: TextStyles.textDialogName),
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
                            TextEditingController _nameController = TextEditingController();
                            FocusNode focusNode1 = new FocusNode();
                            return AlertDialog(
                              title: Text("创建歌单"),
                              content: TextField(
                                controller: _nameController,
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
                                    if (_nameController.text.length == 0) {
                                      Utils.showToast('请输入歌单名称');
                                      return;
                                    }
                                    Provider.of<SongSheetListModel>(context, listen: false).createAndBatchAdd(_nameController.text, songList);
                                    Navigator.of(context).pop(true);
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else if (index == 1) {
                         MyFavoriteSong.batchAddSong(songList);
                         Navigator.of(context).pop(true);
                      } else {
                        Provider.of<SongSheetListModel>(context, listen: false).batchAddSong(mySheet[index], songList);
                        Navigator.of(context).pop(true);
                      }
                    });
              }),
        ),
      );
    },
  );
}
Future<void> downloadAll(context,List songList) async {
  List songList2=[];
  songList.forEach((element) {
    if(element['isNetwork']==true){
      if(element['isDownload']!=true)
        songList2.add(element);
    }
  });
  if(songList2.length==0){
    Utils.showToast('没有可下载的歌曲');
    return;
  }
  Color titleColor = Funs.isDarkMode(context)?Colours.dark_text:Colors.black87;
  bool isSuccess = await Funs.showCustomDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: RichText(
          text: TextSpan(style: TextStyles.textDialogTitle, children: [
            TextSpan(text: '当前可下歌曲',  style: TextStyle(color: titleColor)),
            TextSpan(text: '  ${songList2.length}首', style: TextStyles.textDialogName),
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
              await downloadSongAllFun(songList2);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
Future<bool> deleteSong(context, List songList, ) async {
  bool isDelete = false;
  Color titleColor = Funs.isDarkMode(context)?Colours.dark_text:Colors.black87;
  bool res=await Funs.showCustomDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: RichText(
          text: TextSpan(style: TextStyles.textDialogTitle, children: [
            TextSpan(text: '确定要删除歌曲',  style: TextStyle(color: titleColor)),
            TextSpan(text: ' - ${songList.length}首', style: TextStyles.textDialogName),
          ]),
        ),
        content: Builder(
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
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text("删除"),
            onPressed: () {
              bool res;
                res = Provider.of<SongSheetModel>(context, listen: false).batchDeleteSong(songList);
              if (res == true) {
                if (isDelete == true) {
                  songList.forEach((songData) {
                    String path = songData['playInfo']['path'];
                    if (path !=null && File(path).existsSync()) File(path).deleteSync();
                  });
                }
                Utils.showToast('删除成功');
                Provider.of<SongSheetListModel>(context, listen: false)
                    .refresh();
              }
              Navigator.of(context).pop(res);
            },
          ),
        ],
      );
    },
  );
  return res;
}
class Item extends StatelessWidget {
  Item({
    this.data,
    this.isFirst,
    this.isLast,
    this.callback,
  });

  final ItemData data;
  final bool isFirst;
  final bool isLast;
  final callback;

  Widget _buildChild(BuildContext context, ReorderableItemState state) {
    BoxDecoration decoration;
    Widget subtitleIcon;
    if (data.song['isDownload'] == true)
      subtitleIcon = Icon(
        Icons.cloud_done,
        size: 15,
        color: Theme.of(context).primaryColor,
      );
    else if (data.song['isLocal'] == true)
      subtitleIcon = Icon(
        Icons.phone_android,
        size: 15,
        color: Theme.of(context).primaryColor,
      );

    if (state == ReorderableItemState.dragProxy || state == ReorderableItemState.dragProxyFinished) {
      // slightly transparent background white dragging (just like on iOS)
      decoration = BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: isFirst && !placeholder
                  ? Divider.createBorderSide(context) //
                  : BorderSide.none,
              bottom: isLast && placeholder
                  ? BorderSide.none //
                  : Divider.createBorderSide(context)),
          color: placeholder ? null : Colors.white);
    }

    // For iOS dragging mode, there will be drag handle on the right that triggers
    // reordering; For android mode it will be just an empty container
    Widget dragHandle = ReorderableListener(
      child: Container(
        padding: EdgeInsets.only(right: 18.0, left: 18.0),
        color: Color(0x08000000),
        child: Center(
          child: Icon(Icons.reorder, color: Color(0xFF888888)),
        ),
      ),
    );

    Widget content = Container(
      decoration: decoration,
      child: SafeArea(
          top: false,
          bottom: false,
          child: Opacity(
              // hide content for placeholder
              opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
              child: IntrinsicHeight(
                child: xListTitle(
                    leading: Checkbox(
                      value: data.isSelect,
                      onChanged: (value) {
                        callback(data, value);
                      },
                    ),
                    title: data.song['baseInfo']['name'],
                    subtitleIcon: subtitleIcon,
                    subtitle: data.song['baseInfo']['author'],
                    trailing: ReorderableListener(
                      child: Container(
                        height: double.infinity,
                        padding: EdgeInsets.only(right: 10.0, left: 10.0),
                        color: Colors.transparent,
                        child: Icon(Icons.reorder, color: Color(0xFF888888)),
                      ),
                    )),
              ))),
    );
//    Widget content = Container(
//      decoration: decoration,
//      child: SafeArea(
//          top: false,
//          bottom: false,
//          child: Opacity(
//            // hide content for placeholder
//            opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
//            child: IntrinsicHeight(
//              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.stretch,
//                children: <Widget>[
//                  Expanded(
//                      child: Padding(
//                        padding:
//                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
//                        child: Text(data.song['baseInfo']['name'],
//                            style: Theme.of(context).textTheme.subtitle1),
//                      )),
//                  // Triggers the reordering
//                  dragHandle,
//                ],
//              ),
//            ),
//          )),
//    );
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(
        key: data.key, //
        childBuilder: _buildChild);
  }
}
