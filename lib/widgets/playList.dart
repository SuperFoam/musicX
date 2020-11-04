
import 'package:flutter/material.dart';
import 'package:music_x/provider/player.dart';
import 'package:music_x/utils/custom_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PlayingListDialog extends StatefulWidget {
  static void show(BuildContext context) {
    myShowModalBottomSheet(
      duration: 300,
        context: context,
        //backgroundColor: Colors.transparent,
        elevation: 10,
        isScrollControlled: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return PlayingListDialog();
        });
  }

  @override
  PlayingListDialogState createState() {
    return new PlayingListDialogState();
  }
}

class PlayingListDialogState extends State<PlayingListDialog> {
  //ScrollController _controller;
  double itemHeight = 50.0;
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    //_controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      if (mounted) {
        initScroll();
      }
    });
  }
  Future<void> initScroll() async{
   // int index=context.read<PlayerModel>().curSongIndex;
   // double offset = itemHeight * (index) + (index);
   // _controller.jumpTo(offset);
   //itemScrollController.jumpTo(index: index);

//    String id=context.read<PlayerModel>().curSong['baseInfo']['id'];
//    List songList = context.read<PlayerModel>().playList;
//    for(int i=0;i<songList.length;i++){
//      if(songList[i]['baseInfo']['id']==id){
//        double offset = itemHeight * (i) + (i);
//        _controller.jumpTo(offset);
//        break;
//      }
//    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        height: 500.0,
        padding: EdgeInsets.all(5.0),
        //color: Color(0xfff1f1f1),
        child: Consumer<PlayerModel>(builder: (context, _player, child) {
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
                child:
                ScrollablePositionedList.separated(
                  physics: BouncingScrollPhysics(),
                  //controller: _controller2,
                  initialScrollIndex:Provider.of<PlayerModel>(context,listen: false).curSongIndex,
                  itemCount: _player.playList.length,
                  itemScrollController: itemScrollController,
                  //cacheExtent: _player.playList.length*60.0,
                  itemBuilder: (context, int index) {
                    return buildItem(_player.playList[index], _player,index);
                  },
                  separatorBuilder: (context, int index) {
                    return Divider(
                      height: 1,
                      thickness: 1,
                    );
                  },
                ),
              ),
              Divider(
                height: 1,
              ),
            ],
          );
        }));
  }

  Widget buildItem(Map item, _player,int index) {
    List<Widget> title = [];
    if (item == _player.curSong) {
      Color color = Theme.of(context).primaryColor;
      title.add(Icon(
        Icons.volume_up,
        color: color,
      ));
      title.add(SizedBox(width: 5));
      title.add(Expanded(
          flex: 5,
          child: Text(
            item['baseInfo']['name'],
            style: TextStyle(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )));
      title.add(Flexible(
          flex: 1,
          child: Text(
            '${item['baseInfo']['author']}',
            style: TextStyle(color: color, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.clip,
          )));
    } else {
      title.add(Expanded(
          flex: 5,
          child: Text(item['baseInfo']['name'],
              maxLines: 1, overflow: TextOverflow.ellipsis)));
      title.add(Flexible(
          flex: 1,
          child: Text(
            item['baseInfo']['author'],
            style: TextStyle(color: Colors.grey, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.clip,
          )));
    }
    return Container(
      height: itemHeight,
      child: ListTile(
        // leading: Icon(Icons.add),
        title: Row(
          children: title,
        ),
        trailing: IconButton(
          alignment: Alignment.centerRight,
          icon: Icon(Icons.delete_forever),
          onPressed: () {
            _player.deletePlayItem(item);
          },
        ),
        onTap: () => _player.switchSong(item,index),
      ),
    );
  }

  @override
  void dispose() {
    //print('销毁滚动监听');
    //_controller.dispose();
    super.dispose();

  }
}

