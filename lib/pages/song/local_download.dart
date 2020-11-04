
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:music_x/provider/local_song.dart';
import 'package:music_x/provider/player.dart';
import 'package:music_x/provider/download_task.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/custom_search.dart';
import 'package:music_x/widgets/extend_list_title.dart';
import 'package:music_x/widgets/flexible_app_bar.dart';
import 'package:music_x/widgets/song_more_info.dart';
import 'package:music_x/widgets/tabs.dart';
import 'package:provider/provider.dart';
import 'package:music_x/widgets/sheet_search.dart';

class LocalDownloadPage extends StatefulWidget {
  @override
  _LocalDownloadPageState createState() => _LocalDownloadPageState();
}

class _LocalDownloadPageState extends State<LocalDownloadPage>
    with SingleTickerProviderStateMixin {
  String url =
      "http://p1.music.126.net/6t714sCD46VGEahrR9JKsQ==/109951164623302688.jpg?param=300y300";
  String defaultSSImage = 'assets/img/sheet.jpg';
  double screenH;
  TabController _tabController;
  bool showAction = true;
  var _tab1 = PageStorageKey('_tab1');
  var _tab2 = PageStorageKey('_tab2');

  bool isFirstDownload = true;

  @override
  void initState() {
    _tabController = new TabController(
        initialIndex: 0,
        vsync: this, //固定写法
        length: 2 //,// 指定tab长度
        );
    _tabController.addListener(() {
      if (_tabController.index == _tabController.animation.value) {
        var index = _tabController.index;
//        if (index == 1) {
//          setState(() {
//            showAction = false;
//          });
//        } else {
//          setState(() {
//            showAction = true;
//          });
//        }
      }
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      if (mounted) {
        context.read<DownLoadModel>().init();
        context.read<LocalSongModel>().init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenH = MediaQuery.of(context).size.height;
    return Scaffold(
      body: tabSliver(),
    );
  }

  Widget tabSliver() {
//    LinkedHashMap localSongMap = LocalSong.getData();
//    List localSong = localSongMap.values.toList().reversed.toList();
    return NestedScrollView(
        headerSliverBuilder: (context, _) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                pinned: true,
                expandedHeight: screenH * 0.35,
                flexibleSpace: FlexibleDetailBar(
                  background: FlexShadowBackground(
                    child: Image(
                        fit: BoxFit.cover, image: AssetImage(defaultSSImage)),
                  ),
                  content: Text(''),
                  builder: (context, t) => AppBar(
                    leading: BackButton(),
                    automaticallyImplyLeading: false,
                    title: Text(t > 0.5 ? '本地歌曲' : ''),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    titleSpacing: 16,
                    actions: <Widget>[
                      if (showAction)
                        IconButton(
                            icon: Icon(Icons.search),
                            tooltip: "歌单内搜索",
                            onPressed: () {
                              List songList=Provider.of<LocalSongModel>(context,listen: false).localSong;
                              Map curSong= Provider.of<PlayerModel>(context,listen: false).curSong;
                              String curSongID = curSong != null
                                  ? curSong['baseInfo']['id']
                                  : null;
                              myShowSearch(context: context, delegate: SearchBarDelegate(songList: songList,curSongID: curSongID));
                            }),
                      if (showAction) popupMenuButton(),
                    ],
                  ),
                ),
                bottom: RoundedTabBar(
                  tabController: _tabController,
                  tabs: <Widget>[
                    Tab(text: "本地歌曲"),
//                    Tab(text: "扫描"),
                    Tab(text: "下载中"),
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
              localSong,
              downloadTask
//              Center(
//                child: RaisedButton(
//                  child: Text('列出任务'),
//                  onPressed: () async {
//                    //  final tasks = await FlutterDownloader.loadTasks();
//                    //DownloadTaskStatus;
//                    String query =
//                        "SELECT * FROM task WHERE status in (0,1,2,4,6)";
//                    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
//                        query: query);
//                    tasks.forEach((element) {
//                      print(
//                          '${element.filename}-${element.status}-${element.taskId}');
//                    });
//                  },
//                ),
//              ),

            ]),
          ),
        ));
  }
  Widget get localSong{
    return  Consumer2<PlayerModel, LocalSongModel>(
        builder: (context, _player, _local, child) {
          print('本地歌曲列表更新');
          List localSong = _local.localSong;
          String curSongID = _player.curSong != null
              ? _player.curSong['baseInfo']['id']
              : null;
          return localSong.length == 0
              ? Center(
              child: RaisedButton(
                child: Text('扫描音乐'),
                onPressed: () {
                  Provider.of<LocalSongModel>(context, listen: false)
                      .scanMusic();
                },
              ))
              : ListView.builder(
              key: _tab1,
              itemCount: localSong.length,
              itemExtent: 55.0,
              itemBuilder: (context, index) {
                return xListTitle(
                    leading: Container(
                      width: 30,
                      height: 20,
                      child: Center(
                        child: curSongID ==
                            localSong[index]['baseInfo']['id']
                            ? Icon(Icons.volume_up,
                            color: Theme.of(context).primaryColor)
                            : Text('${index + 1}',style: TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.fade,),
                      ),
                    ),
                    title: localSong[index]['baseInfo']['name'],
                    subtitleIcon: localSong[index]['isDownload'] ==
                        true
                        ? Icon(
                      Icons.cloud_done,
                      size: 15,
                      color: Theme.of(context).primaryColor,
                    )
                        : Icon(Icons.phone_android,
                        size: 15,
                        color: Theme.of(context).primaryColor),
                    subtitle: localSong[index]['baseInfo']['author'],
                    trailing: IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () => showMusicMoreInfo(
                          context, localSong[index],type: 'localSheet'),
                    ),
                    onTap: () {
                      if (_player.curSong != null &&
                          curSongID ==
                              localSong[index]['baseInfo']['id']) {
                        NavigatorUtil.goPlaySong(context);
                      } else{
                        List newPlayList=List.from(localSong);
                        PlayerModel().playSong(localSong[index],
                            songIndex: index,
                            newPlayList: newPlayList, isLocal: true);
                      }
                    });
              });
        });
  }
  Widget get downloadTask{
    return  Scaffold(
      body: Consumer<DownLoadModel>(
        builder: (context, _task, child) {
          Color progressC = Funs.isDarkMode(context)
              ? Colors.white10
              : Colors.grey.withOpacity(0.3);
          List taskList = _task.dTaskList;
          Map dPMap = _task.dPMap;
          return ListView.builder(
              key: _tab2,
              itemCount: taskList.length,
              itemBuilder: (context, index) {
                return xListTitle(
                  leading: Container(
                    width: 30,
                    child: getLeading(taskList[index].status),
                  ),
                  title: taskList[index].filename.split('.').first,
                  subtitleIcon: taskList[index].status ==
                      DownloadTaskStatus.running
                      ? Expanded(
                      flex: 1,
                      child: SizedBox(
                          height: 3,
                          child: LinearProgressIndicator(
                            backgroundColor: progressC,
                            value: dPMap[taskList[index].taskId] ??
                                (taskList[index].progress) / 100,
                          )))
                      : null,
                  subtitle: taskStatus(taskList[index], dPMap),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteTask(taskList[index]),
                  ),
                  onTap: () => pauseResumeTask(taskList[index]),
                );
//                        ListTile(
//                        title: Text(taskList[index].filename.split('.').first),
//                        subtitle: Text(taskStatus(taskList[index].status)),
//                      );
              });
        },
      ),
      floatingActionButton: SpeedDial(
        // both default to 16
        marginRight: 1,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.05,
        onOpen: () => print('onOpen'),
        onClose: () => print('onClose'),
        //tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.pause),
              backgroundColor: Colors.grey,
              label: '全部暂停',
              labelBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
              onTap: () =>pauseResumeAllTask('pause')
          ),
          SpeedDialChild(
              child: Icon(Icons.cloud_download),
              backgroundColor: Colors.blue,
              label: '全部开始',
              labelBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
              onTap: () => pauseResumeAllTask('resume')
          ),
          SpeedDialChild(
            child: Icon(Icons.delete_forever),
            backgroundColor: Colors.red,
            label: '全部删除',
            labelBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            onTap: () => deleteAllTask(),
          ),
        ],
      ),
    );
  }

  Widget getLeading(DownloadTaskStatus status) {
    if (status == DownloadTaskStatus.running)
      return Icon(
        Icons.cloud_download,
        color: Theme.of(context).primaryColor,
        size: 20,
      );
    else if (status == DownloadTaskStatus.failed)
      return Icon(Icons.error_outline, size: 20);
    else if (status == DownloadTaskStatus.paused)
      return Icon(Icons.pause_circle_outline, size: 20);
    else if (status == DownloadTaskStatus.enqueued)
      return Icon(Icons.cloud, size: 20);
    else
      return Icon(Icons.device_unknown, size: 20);
  }

  String taskStatus(DownloadTask task, Map dPMap) {
    DownloadTaskStatus status = task.status;
    String key = task.taskId;
    int progress =
        dPMap[key] != null ? (dPMap[key] * 100).toInt() : task.progress;
    if (status == DownloadTaskStatus.running)
      return '$progress%';
    else if (status == DownloadTaskStatus.failed)
      return '下载失败 点击重试';
    else if (status == DownloadTaskStatus.paused)
      return '已暂停 点击恢复';
    else if (status == DownloadTaskStatus.enqueued)
      return '等待下载';
    else if (status == DownloadTaskStatus.canceled)
      return '已取消 点击恢复';
    else
      return '未知状态';
  }

  Widget popupMenuButton() {
    return PopupMenuButton<String>(itemBuilder: (context) {
      return <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'scan',
          child: Wrap(
            spacing: 5,
            children: <Widget>[
              Icon(
                Icons.youtube_searched_for,
                color: Theme.of(context).iconTheme.color,
              ),
              Text('扫描音乐')
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'sort',
          child: Wrap(
            spacing: 5,
            children: <Widget>[
              Icon(
                Icons.sort,
                color: Theme.of(context).iconTheme.color,
              ),
              Text('歌曲排序')
            ],
          ),
        ),
      ];
    }, onSelected: (String action) {
      if (action == 'scan') {
        Provider.of<LocalSongModel>(context, listen: false).scanMusic();
      }
      else if(action=='sort'){
        showSortAction(Provider.of<LocalSongModel>(context, listen: false));
      }
    });
  }

  Future<void> pauseResumeTask(DownloadTask task) async {
    print('${task.filename}-${task.status}');
    if (task.status == DownloadTaskStatus.running) {
      await FlutterDownloader.pause(taskId: task.taskId);
      Provider.of<DownLoadModel>(context, listen: false).init();
    } else if (task.status == DownloadTaskStatus.paused) {
      final taskId = await FlutterDownloader.resume(taskId: task.taskId);
      if(taskId!=null)MyDownloadTask.changeTask(task.taskId, taskId);
      Provider.of<DownLoadModel>(context, listen: false).init();
    } else if(task.status==DownloadTaskStatus.enqueued){
      await FlutterDownloader.cancel(taskId: task.taskId);
      Provider.of<DownLoadModel>(context, listen: false).init();
    } else if (task.status == DownloadTaskStatus.failed || task.status == DownloadTaskStatus.canceled) {
      final taskId = await FlutterDownloader.retry(taskId: task.taskId);
      if(taskId!=null)MyDownloadTask.changeTask(task.taskId, taskId);
      Provider.of<DownLoadModel>(context, listen: false).init();
    }
  }
  void pauseResumeAllTask(String action)async{
    var cancel = Utils.showLoading();
    List<DownloadTask> taskList = Provider.of<DownLoadModel>(context,listen: false).dTaskList;
    await Future.forEach(taskList, (DownloadTask task) async{
      print('${task.filename}-${task.status}');
      if ( action == 'pause' ){
//        if(task.status == DownloadTaskStatus.running)
//          await FlutterDownloader.pause(taskId: task.taskId);
//          print('取消任务');
//         if(task.status == DownloadTaskStatus.enqueued)
//          await FlutterDownloader.cancel(taskId: task.taskId);

         await   FlutterDownloader.cancelAll();
      }

      else  if ( action == 'resume' ) {
        if(task.status == DownloadTaskStatus.paused){
          final taskId = await FlutterDownloader.resume(taskId: task.taskId);
          if(taskId!=null)
            MyDownloadTask.changeTask(task.taskId, taskId);
        }else if(task.status == DownloadTaskStatus.failed || task.status == DownloadTaskStatus.canceled){
          final taskId = await FlutterDownloader.retry(taskId: task.taskId);
          if(taskId!=null)
            MyDownloadTask.changeTask(task.taskId, taskId);
        }

      }
    });
    Provider.of<DownLoadModel>(context, listen: false).init();
//    if(action == 'pause') {
//      List<DownloadTask> taskList = Provider.of<DownLoadModel>(context,listen: false).dTaskList;
//      await Future.forEach(taskList, (DownloadTask task) async {
//        print('${task.filename}-${task.status}');
//        if (task.status == DownloadTaskStatus.running){
//          print('设置暂停');
//          await FlutterDownloader.pause(taskId: task.taskId);
//        }
//
//        //  await   FlutterDownloader.cancelAll();
//
//      });
//      Provider.of<DownLoadModel>(context, listen: false).init();
//
//    }
    cancel();
  }


  Future<void> deleteTask(DownloadTask task) async {
    bool isSuccess = await Funs.showCustomDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: RichText(
            text: TextSpan(style: TextStyles.textDialogTitle, children: [
              TextSpan(text: '确定要删除任务'),
              TextSpan(
                  text: ' - ${task.filename.split('.').first}',
                  style: TextStyles.textDialogName),
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
              child: Text("删除"),
              onPressed: () async {
                String taskId = task.taskId;
                await FlutterDownloader.remove(
                    taskId: taskId, shouldDeleteContent: true);
                MyDownloadTask.delete(taskId);

                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    if (isSuccess == true) {
      Utils.showToast('删除成功');
      Provider.of<DownLoadModel>(context, listen: false).init();
    }
  }
  void deleteAllTask()async{

    List<DownloadTask> taskList = Provider.of<DownLoadModel>(context,listen: false).dTaskList;
    Funs.showCustomDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: RichText(
            text: TextSpan(style: TextStyles.textDialogTitle, children: [
              TextSpan(text: '确定要删除'),
              TextSpan(
                  text: '  ${ taskList.length} ',
                  style: TextStyles.textDialogName),
              TextSpan(text: '个任务？'),
            ]),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () {
                FlutterDownloader.cancelAll();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("删除"),
              onPressed: () async {
                var cancel = Utils.showLoading();
                await Future.forEach(taskList, (DownloadTask task) async{
                  String taskId = task.taskId;
                  await FlutterDownloader.remove(
                      taskId: taskId, shouldDeleteContent: true);
                  MyDownloadTask.delete(taskId);
                });
                cancel();
                Navigator.of(context).pop(true);
                Provider.of<DownLoadModel>(context, listen: false).init();
              },
            ),
          ],
        );
      },
    );

  }
  showSortAction(_model){
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
                    Text('按添加时间倒序',style: TextStyle(color: Colors.black.withOpacity(0.6)),),
                    if(_model.sortType=='timeZ_A') SizedBox(width: 10,),
                    if(_model.sortType=='timeZ_A') Icon(Icons.done,color: Theme.of(context).primaryColor,)
                  ],),
                onPressed: () {
                  if(_model.sortType!='timeZ_A') {
                    _model.sortSongList('timeZ_A');
                    Navigator.of(context).pop();
                  }
                },
                isDefaultAction: _model.sortType=='timeZ_A'?true:false,
              ),
              CupertinoActionSheetAction(
                isDefaultAction: _model.sortType=='timeA_Z'?true:false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('按添加时间顺序',style: TextStyle(color: Colors.black.withOpacity(0.6)),),
                    if(_model.sortType=='timeA_Z') SizedBox(width: 10,),
                    if(_model.sortType=='timeA_Z') Icon(Icons.done,color: Theme.of(context).primaryColor,)
                  ],),
                onPressed: () {
                  if(_model.sortType!='timeA_Z') {
                    _model.sortSongList('timeA_Z');
                    Navigator.of(context).pop();
                  }
                },
              ),
              CupertinoActionSheetAction(
                isDefaultAction: _model.sortType=='nameA_Z'?true:false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('按歌曲名A-Z排序',style: TextStyle(color: Colors.black.withOpacity(0.6)),),
                    if(_model.sortType=='nameA_Z') SizedBox(width: 10,),
                    if(_model.sortType=='nameA_Z') Icon(Icons.done,color: Theme.of(context).primaryColor,)
                  ],),
                onPressed: () {
                  if(_model.sortType!='nameA_Z') {
                    _model.sortSongList('nameA_Z');
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
