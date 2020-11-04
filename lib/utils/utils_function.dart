import 'dart:collection';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/widgets/custom_show_menu.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math_64.dart' as vector_t;
import 'package:bot_toast/bot_toast.dart';

//import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flustars/flustars.dart';
import 'package:collection/collection.dart';
import 'global_data.dart';
import 'local_storage.dart';

class Funs {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static bool isDarkMode2(BuildContext context) {
    final Brightness brightnessValue = MediaQuery.of(context).platformBrightness;
    return brightnessValue == Brightness.dark;
  }

  static Offset globalToLocal(RenderObject object, Offset point, {RenderObject ancestor}) {
    final Matrix4 transform = object.getTransformTo(ancestor);
    final double det = transform.invert();
    if (det == 0.0) return Offset.zero;
    final vector_t.Vector3 n = vector_t.Vector3(0.0, 0.0, 1.0);
    final vector_t.Vector3 i = transform.perspectiveTransform(vector_t.Vector3(0.0, 0.0, 0.0));
    final vector_t.Vector3 d = transform.perspectiveTransform(vector_t.Vector3(0.0, 0.0, 1.0)) - i;
    final vector_t.Vector3 s = transform.perspectiveTransform(vector_t.Vector3(point.dx, point.dy, 0.0));
    final vector_t.Vector3 p = s - d * (n.dot(s) / n.dot(d));
    return Offset(p.x, p.y);
  }

  static Future<T> showCustomDialog<T>({
    @required BuildContext context,
    bool barrierDismissible = true,
    WidgetBuilder builder,
  }) {
    final ThemeData theme = Theme.of(context, shadowThemeOnly: true);
    return showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        final Widget pageChild = Builder(builder: builder);
        return SafeArea(
          child: Builder(builder: (BuildContext context) {
            return theme != null ? Theme(data: theme, child: pageChild) : pageChild;
          }),
        );
      },
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.6),
      // 自定义遮罩颜色
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: _buildMaterialDialogTransitions,
    );
  }

  static Widget _buildMaterialDialogTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // 使用缩放动画
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }
}

class Utils {
  static Widget spaceGery({@required BuildContext context,double height=8.0}){
    return Container(
      height: height,
      color: Theme.of(context).splashColor,
    );
  }
  static Widget  divider({@required BuildContext context,double dividerH=1.0,double thickness=0.5,double indent=0}) {
    return Row(children: [
      Container(
        width: indent,
        height: dividerH,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      Expanded(child:  Divider(
        //indent: paddingNum  + paddingNum + headW + paddingNum+ (showCheckBox?checkBoxW:0),
        thickness: dividerH,
        height: dividerH,
        // color: Colours.wx_bg,
      ),)
    ],);
  }
//  static Widget  divider({double indent=0}) {
//    return Divider(
//      indent:indent,
//      thickness: 0.5,
//      height: 1,
//      color: Colours.wx_bg,
//    );
//  }
  static void showToast(String msg) {
    BotToast.showText(text: msg, align: Alignment.center, contentColor: Colors.black);
  }

  static showLoading() {
    CancelFunc cancel = BotToast.showCustomLoading(
        // crossPage:true,
        duration: Duration(seconds: 10),
        toastBuilder: (cancelFunc) {
          return CupertinoActivityIndicator(
            radius: 10,
          );
        }); //BotToast.showLoading();
    return cancel;
  }

//  static Widget showNetImage(String url,
//      {double width, double height, BoxFit fit}) {
//    return Image(
//      image: ExtendedNetworkImageProvider(url, cache: true),
//      width: width,
//      height: height,
//      fit: fit,
//    );
//  }

//  /// 格式化歌词
//  static List<Lyric> formatLyric(String lyricStr) {
//    RegExp reg = RegExp(r"^\[\d{2}");
//
//    List<Lyric> result =
//    lyricStr.split("\n").where((r) => reg.hasMatch(r)).map((s) {
//      String time = s.substring(0, s.indexOf(']'));
//      String lyric = s.substring(s.indexOf(']') + 1);
//      time = s.substring(1, time.length - 1);
//      int hourSeparatorIndex = time.indexOf(":");
//      int minuteSeparatorIndex = time.indexOf(".");
//      return Lyric(
//        lyric,
//        startTime: Duration(
//          minutes: int.parse(
//            time.substring(0, hourSeparatorIndex),
//          ),
//          seconds: int.parse(
//              time.substring(hourSeparatorIndex + 1, minuteSeparatorIndex)),
//          milliseconds: int.parse(time.substring(minuteSeparatorIndex + 1)),
//        ),
//      );
//    }).toList();
//
//    for (int i = 0; i < result.length - 1; i++) {
//      result[i].endTime = result[i + 1].startTime;
//    }
//    result[result.length - 1].endTime = Duration(hours: 1);
//    return result;
//  }
//
//  /// 查找歌词
//  static int findLyricIndex(double curDuration, List<Lyric> lyrics) {
//    for (int i = 0; i < lyrics.length; i++) {
//      if (curDuration >= lyrics[i].startTime.inMilliseconds &&
//          curDuration <= lyrics[i].endTime.inMilliseconds) {
//        return i;
//      }
//    }
//    return 0;
//  }
}

Future<bool> applyStoragePermanent() async {
  var status = await Permission.storage.status;
  if (status.isPermanentlyDenied) {
    Utils.showToast('权限被永久拒绝');
    openAppSettings();
    return Future.value(false);
  }
  if (!status.isGranted) {
    if (!await Permission.storage.request().isGranted) {
      Utils.showToast('权限申请失败');
      return Future.value(false);
    }
  }
  return Future.value(true);
}

Future<bool> applySomePermission(Permission permission) async {
  var status = await permission.status;
  if (status.isPermanentlyDenied) {
    Utils.showToast('权限被永久拒绝');
    openAppSettings();
    return Future.value(false);
  }
  if (!status.isGranted) {
    if (!await permission.request().isGranted) {
      Utils.showToast('权限申请失败');
      return Future.value(false);
    }
  }
  return Future.value(true);
}

Future<bool> downloadSongFun(Map songData, {String type}) async {
  bool res = await applyStoragePermanent();
  if (res == false) Future.value(false);
  String dirloc;
  if (Platform.isAndroid) {
    dirloc = Constant.downloadSongPath;
    Directory music = Directory(dirloc);
    if (!music.existsSync()) {
      music.createSync(recursive: true);
    }
  } else {
    dirloc = (await getApplicationDocumentsDirectory()).path;
  }
  String url = songData['playInfo']['url'];
  if (!url.startsWith('http')) {
    Utils.showToast('歌曲没有下载地址');
    return false;
  }
  String fileName = '${songData['baseInfo']['author']} - ${songData['baseInfo']['name']}.mp3';
  String savePath = '$dirloc$fileName';
  File file = File(savePath);
  if (file.existsSync() == true) {
    Utils.showToast('歌曲已经下载到本地');
    return Future.value(false);
  }

  final taskId = await FlutterDownloader.enqueue(
    url: url,
    savedDir: dirloc,
    fileName: fileName,
    showNotification: false,
    // show download progress in status bar (for Android)
    openFileFromNotification: false,
  );
  if (type == 'card')
    MyDownloadTask.add(taskId, songData['baseInfo']['id'], savePath, t: songData);
  else
    MyDownloadTask.add(taskId, songData['baseInfo']['id'], savePath);
  Utils.showToast('已加入下载任务队列');
  return Future.value(true);
}

Future<void> downloadSongAllFun(List songList, {String type}) async {
  bool res = await applyStoragePermanent();
  if (res == false) Future.value(false);
  String dirloc;
  if (Platform.isAndroid) {
    dirloc = Constant.downloadSongPath;
    Directory music = Directory(dirloc);
    if (!music.existsSync()) {
      music.createSync(recursive: true);
    }
  } else {
    dirloc = (await getApplicationDocumentsDirectory()).path;
  }
  var cancel = Utils.showLoading();
  songList.forEach((songData) async {
    String url = songData['playInfo']['url'];
    if (url.startsWith('http')) {
      String fileName = '${songData['baseInfo']['author']} - ${songData['baseInfo']['name']}.mp3';
      String savePath = '$dirloc$fileName';
      File file = File(savePath);
      if (file.existsSync() == false) {
        final taskId = await FlutterDownloader.enqueue(
          url: url,
          savedDir: dirloc,
          fileName: fileName,
          showNotification: false,
          // show download progress in status bar (for Android)
          openFileFromNotification: false,
        );
        MyDownloadTask.add(taskId, songData['baseInfo']['id'], savePath,t: songData);
//        if (type == 'card')
//          MyDownloadTask.add(taskId, songData['baseInfo']['id'], savePath, t: songData);
//        else
//            MyDownloadTask.add(taskId, songData['baseInfo']['id'], savePath);
      }
    }
  });
  cancel();
  Utils.showToast('已加入下载任务队列');
}

String getFormattedTime(int milliseconds) {
  // 评论时间
  var dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  var now = DateTime.now();

  var diff = Duration(milliseconds: now.millisecondsSinceEpoch - dateTime.millisecondsSinceEpoch);
  if (diff.inMinutes < 1) {
    return "刚刚";
  }
  if (diff.inMinutes <= 60) {
    return "${diff.inMinutes}分钟前";
  }
  if (diff.inHours <= 24) {
    return "${diff.inHours}小时前";
  }
  if (diff.inDays <= 5) {
    return "${diff.inDays}天前";
  }
  return DateFormat("y年M月d日").format(dateTime);
}

///format milliseconds to time stamp like "06:23", which
///means 6 minute 23 seconds
String getTimeStamp(int milliseconds) {
  int seconds = (milliseconds / 1000).truncate();
  int minutes = (seconds / 60).truncate();

  String minutesStr = (minutes % 60).toString().padLeft(2, '0');
  String secondsStr = (seconds % 60).toString().padLeft(2, '0');

  return "$minutesStr:$secondsStr";
}

///format number to local number.
///example 10001 -> 1万
///        100 -> 100
///        11000-> 1.1万
String getFormattedNumber(int number) {
  if (number < 10000) {
    return number.toString();
  }
  number = number ~/ 10000;
  return "$number万";
}

String formatTimeWX(
  int ms, {
  int locMs,
  String formatToday = 'HH:mm',
  String format = 'yyyy-MM-dd',
  String languageCode = 'zh',
  bool short = false,
}) {
  int _locTimeMs = locMs ?? DateTime.now().millisecondsSinceEpoch;
  int elapsed = _locTimeMs - ms;
  if (elapsed < 0) {
    return DateUtil.formatDateMs(ms, format: formatToday);
  }

  if (DateUtil.isToday(ms, locMs: _locTimeMs)) {
    return DateUtil.formatDateMs(ms, format: formatToday);
  }

  if (DateUtil.isYesterdayByMs(ms, _locTimeMs)) {
    String t = languageCode == 'zh' ? '昨天' : 'Yesterday';
    return short ? t : t + ' ' + DateUtil.formatDateMs(ms, format: 'HH:mm');
  }

  if (DateUtil.isWeek(ms, locMs: _locTimeMs)) {
    String week = DateUtil.getWeekdayByMs(ms, languageCode: languageCode, short: short);
    return short ? week : week + ' ' + DateUtil.formatDateMs(ms, format: 'HH:mm');
  }
  String format;
  if (short)
    format = DateUtil.yearIsEqualByMs(ms, _locTimeMs) ? 'MM-dd' : 'yyyy-MM-dd';
  else
    format = DateUtil.yearIsEqualByMs(ms, _locTimeMs) ? 'MM-dd HH:mm' : 'yyyy-MM-dd HH:mm';

  return DateUtil.formatDateMs(ms, format: format);
}

// popup menu
Future<String> showCustomPopupMenu({TapDownDetails tapDownDetail, LongPressStartDetails longPressDetail, @required List<PopupMenuEntry<String>> popupItem, @required BuildContext context, double bottomHeight = 0.0}) async {
  double left;
  double top;
  if(tapDownDetail!=null)
    {
      left= tapDownDetail.globalPosition.dx;
      top = tapDownDetail.globalPosition.dy;
    }
  else if(longPressDetail != null ){
    left= longPressDetail.globalPosition.dx;
    top = longPressDetail.globalPosition.dy;
  }else
    return null;
  double tt = MediaQuery.of(context).size.height;
  //print('$left,$top');
  if (top + kMinInteractiveDimension * popupItem.length + bottomHeight > tt) top = top - kMinInteractiveDimension * popupItem.length;
  String result = await customShowMenu(position: RelativeRect.fromLTRB(left, top, left, 0), elevation: 8.0, items: popupItem, context: context, useRootNavigator: false);
  return result;
}


