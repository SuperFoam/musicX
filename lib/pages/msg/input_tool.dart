import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/provider/face.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/custom_im.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/media.dart';
import 'package:music_x/utils/my_special_text_span_builder.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/custom_paint.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:music_x/utils/emoji_text.dart' as EMOJI;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ChildPageController{
  bool Function() closeBottom;
}

class ChatBottomInputTool extends StatefulWidget{
  final ChildPageController childController;
  final BottomInputBarDelegate delegate;

  ChatBottomInputTool(this.delegate,{@required this.childController});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChatBottomInputToolState(childController);
  }
}
class _ChatBottomInputToolState extends State<ChatBottomInputTool> with WidgetsBindingObserver,TickerProviderStateMixin{
 // ChildPageController _childController;
  BottomInputBarDelegate delegate;
  TextEditingController _textFiled;
  FocusNode _focusNode;
  bool showSend = false;
  bool showFace = false;
  bool showMoreTool = false;
  bool showSpeak = false;
  double faceH = 0;
  double moreToolH = 0;
  double curKeyboardH = 0;
  double storeKeyboardH = 250;
  bool readOnly = false;
  bool isExistFace = false;
  bool showFaceA = true;
  bool showToolA = true;
  ScrollController _gridController;
  bool isPicking = false;
  StreamSubscription _recorderSubscription;

//  FlutterSoundRecorder _recorderModule=FlutterSoundRecorder() ;
  FlutterSoundRecorder _recorderModule;
  OverlayEntry overlayEntry;
  Offset touchStart;
  Offset touchEnd;
  Offset touchMaxEnd;
  double voidedB = 0.0;
  String recordFilePath;
  int voiceTime = 0;
  int maxRecordTime = 60;
  String voiceTip = '手指上滑 取消发送';
  String textShow = '按住 说话';
  IconData voiceIcon = Icons.record_voice_over;
  bool isCancelSend = false;
  bool haveRecordPermission;

  _ChatBottomInputToolState( ChildPageController _childController){
   // _childController=_childController;
    _childController.closeBottom=closeBottom;
  }

//  @override
//  void didUpdateWidget(ChatBottomInputTool oldWidget) {
//    _childController.closeBottom=closeBottom;
//    super.didUpdateWidget(oldWidget);
//  }

  @override
  void initState() {
    super.initState();
     delegate = widget.delegate;
    _textFiled = TextEditingController();
    _focusNode = FocusNode();
    _textFiled.addListener(() {
      onInputChange();
    });
    initKeyboardH();
    _gridController = ScrollController();
    _gridController.addListener(() {
      onGridScroll();
    });
    initRecord();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {

    _textFiled.dispose();
    _focusNode.dispose();
    _gridController.dispose();
    _recorderModule?.closeAudioSession();
    _recorderSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    overlayEntry?.remove();
    //EMClient.getInstance().chatManager().removeMessageListener(this);
    super.dispose();
  }
  void initRecord() async {
    _recorderModule = await FlutterSoundRecorder().openAudioSession();
    //_recorderModule.openAudioSession();
    _recorderModule.setSubscriptionDuration(Duration(milliseconds: 250));
    _recorderSubscription = _recorderModule.onProgress.listen((e) {
      print('录音时长 ${e.duration.inMilliseconds}');
      print('分贝 is ${e.decibels}');
      voiceTime = e.duration.inMilliseconds;
      if (voiceTime >= maxRecordTime * 1000) {
       // hideVoiceView();
        return;
      }
      voidedB = e.decibels;
      overlayEntry?.markNeedsBuild();
    });

  }
  @override
  void didChangeMetrics() {
    if (isPicking) {
      print('正在选图片');
      return;
    }
    final renderObject = context.findRenderObject();
    final renderBox = renderObject as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final widgetRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
    final keyboardTopPixels = window.physicalSize.height - window.viewInsets.bottom;
    final keyboardTopPoints = keyboardTopPixels / window.devicePixelRatio;
    double keyH = widgetRect.bottom - keyboardTopPoints;
    print('得到键盘高度$keyH');
    curKeyboardH = keyH >= 0 ? keyH : -keyH;
    if (_focusNode.hasFocus && showMoreTool == true) showMoreTool = false;
    //if (_focusNode.hasFocus && showFace == true) showFace = false;
    if (isExistFace == true) {
      showFace = false;
      isExistFace = false;
    }
    if (readOnly == true) readOnly = false;
    if (keyH > 0) {
      faceH = 0;
      moreToolH = 0;
      showFaceA = true;
      showToolA = true;
    }
    delegate.scrollBottom();
    setState(() {});

    if (keyH > 0.0 && keyH != storeKeyboardH) {
      storeKeyboardH = keyH;
      KeyboardHeight.change(keyH);
      print('键盘高度写入本地');
    }
    super.didChangeMetrics();
  }
  void onInputChange() {
    if (_textFiled.text.trim().length > 0) {
      if (showSend == false)
        setState(() {
          showSend = true;
        });
    } else {
      if (showSend == true)
        setState(() {
          showSend = false;
        });
    }
  }
  Future<void> initKeyboardH() async {
    double h = KeyboardHeight.getData();
    if (h != null) storeKeyboardH = h;
    print('工具栏高度为$h');
  }
  void onGridScroll() {
    // print('offset is ${_gridController.offset},postion is ${_gridController.position.pixels},${_gridController.position.viewportDimension}');
    Provider.of<FaceListProvider>(context, listen: false).updateFace();
    //context.read<FaceListProvider>().updateFace();
  }
  bool closeBottom() {
    bool update = false;
    faceH = 0;
    moreToolH = 0.0;
    showFaceA = true;
    showToolA = true;
    if (showMoreTool) {
      update = true;
      // showMoreTool = false;
    }
    if (showFace) {
      update = true;
      // showFace = false;
    }
    if (_focusNode.hasFocus && curKeyboardH > 0) {
      _focusNode.unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      return true;
    }
    if (update) {
      setState(() {});
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        showFace = false;
        showMoreTool = false;
      });
      return true;
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {

    final double screenH = MediaQuery.of(context).size.height;
    final double dialogH = 150.0;
    final double dialogW = 150.0;
    final double maxEnd = screenH * 0.5 + dialogH;
    print('curKeyboardH is $curKeyboardH');
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          // constraints: BoxConstraints( minHeight:20,maxHeight: 120.0),

          width: double.infinity,
          decoration: BoxDecoration(
              color: Theme.of(context).splashColor,
              border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.withOpacity(0.2),width: 0.5))
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              InkWell(
                onTap: () {
                  showSpeak = !showSpeak;
                  bool update = closeBottom();
                  if (!update) setState(() {});
//                          if (showFace) showFace = false;
//                          if (showMoreTool) showMoreTool = false;
//                          if (_focusNode.hasFocus && curKeyboardH > 0) {
//                            print('有焦点，有高度');
//                            //_focusNode.unfocus();
//                            SystemChannels.textInput.invokeMethod('TextInput.hide');
//                            return;
//                          } else{
//                            faceH=0;
//                            setState(() {});
//                          }

                  if (showSpeak == false) _focusNode.requestFocus();
                },
                child: Container(
                  width: 40,
                  margin: EdgeInsets.only(bottom: 5),
                  child: Icon(showSpeak ? Icons.keyboard : Icons.mic_none),
                ),
              ),
              Expanded(
                flex: 1,
                child: showSpeak
                    ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
//                  onTap: (){
//                    sendVoiceMessage();
//                  },

                  onPanStart: (DragStartDetails details) {
                    showVoiceView(details, dialogW, dialogH, maxEnd);
                  },
                  onPanUpdate: (DragUpdateDetails e) {
                    updateVoiceView(e, maxEnd);
                  },
                  onPanEnd: (DragEndDetails e) {
                    hideVoiceView();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      //  color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(textShow),
                  ),
                )
                    : Container(
                    constraints: BoxConstraints(minHeight: 30, maxHeight: 100),
                    child: Builder(
                      builder: (BuildContext context) {
                        return ExtendedTextField(
                          specialTextSpanBuilder: MySpecialTextSpanBuilder(
                            showAtBackground: false,
                          ),
                          controller: _textFiled,
                          focusNode: _focusNode,
                          readOnly: readOnly,
                          showCursor: true,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          //style: TextStyle(textBaseline: TextBaseline.alphabetic),
                          maxLength: 20,

                          onSubmitted: (String _) {},
                          onTap: () {
                            print('输入框点击了,$readOnly');
                            if (readOnly == true) {
                              readOnly = false;
                              if (showFace == true) showFace = false;
                              (context as Element).markNeedsBuild();
//                                    setState(() {
//
//                                    });
                            }
                            isExistFace = showFace;
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            counterText: "",

                            //border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8.0),
                            //contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                           // fillColor: Colors.white,
                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                            focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green, //边框颜色为绿色
                                  width: 5, //宽度为5
                                )),
                            filled: true,
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x00FF0000)), borderRadius: BorderRadius.all(Radius.circular(10))),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x00000000)), borderRadius: BorderRadius.all(Radius.circular(10))),
                          ),
                        );
                        TextField(
                          controller: _textFiled,
                          focusNode: _focusNode,
                          readOnly: readOnly,
                          showCursor: true,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          //style: TextStyle(textBaseline: TextBaseline.alphabetic),
                          maxLength: 20,

                          onSubmitted: (String _) {},
                          onTap: () {
                            print('输入框点击了,$readOnly');
                            if (readOnly == true) {
                              readOnly = false;
                              if (showFace == true) showFace = false;
                              (context as Element).markNeedsBuild();
//                                    setState(() {
//
//                                    });
                            }
                            isExistFace = showFace;
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            counterText: "",

                            //border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8.0),
                            //contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                            fillColor: Colors.white,
                            focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green, //边框颜色为绿色
                                  width: 5, //宽度为5
                                )),
                            filled: true,
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x00FF0000)), borderRadius: BorderRadius.all(Radius.circular(10))),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x00000000)), borderRadius: BorderRadius.all(Radius.circular(10))),
                          ),
                        );
                      },
                    )),
              ),
              GestureDetector(
                child: Container(
                  width: 35,
                  margin: EdgeInsets.only(bottom: 5),
                  child: Icon(showFace ? Icons.face : Icons.tag_faces),
                ),
                onTap: () {
                  delegate.scrollBottom();
                  if (showSpeak) showSpeak = false;
                  if (showMoreTool == true) showMoreTool = false;
                  showFace = !showFace;
                  //  print('是否展示表情$showFace,showMoreTool是$showMoreTool');
                  if (showFace) {
                    faceH = storeKeyboardH;
                    showToolA = false;
                    showFaceA = true;
                    if (_focusNode.hasFocus) {
                      if (curKeyboardH > 0) {
                        // print('有键盘高度，不更新');
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        return;
                      }
                    } else {
                      //print('没有有键盘高度，更新');

                      readOnly = true;
                      setState(() {});
                      Future.delayed(Duration(milliseconds: 100)).then((value) => _focusNode.requestFocus());
                      return;
                    }
                    setState(() {});
                  } else {
                    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
                  }
                },
              ),
              showSend
                  ? InkWell(
                onTap: () {
                  //sendCustomText();
                  sendText(_textFiled.text);
                },
                child: Container(
                  key: ValueKey(showSend),
                  width: 40,
                  margin: EdgeInsets.only(bottom: 5, right: 5),
                  //padding: EdgeInsets.symmetric(horizontal: 1, ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2)),
                  child: Text(
                    '发送',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
                  : InkWell(
                onTap: () {
                  delegate.scrollBottom();
                  if (showSpeak) showSpeak = false;
                  if (showFace == true) showFace = false;
                  showMoreTool = !showMoreTool;
                  //print('是否展示更多工具$showMoreTool,face状态$showFace');
                  if (showMoreTool) {
                    moreToolH = storeKeyboardH;
                    showFaceA = false;
                    showToolA = true;
                    if (_focusNode.hasFocus) {
                      _focusNode.unfocus();
                      // SystemChannels.textInput.invokeMethod('TextInput.hide');
                      if (curKeyboardH > 0) {
                        // print('有键盘高度，不更新');
                        return;
                      }
                    }
                    //  print('没有有键盘高度，更新');

                    if (readOnly == true) readOnly = false;
                    setState(() {});
                  } else {
                    _focusNode.requestFocus();
                  }
                },
                child: Container(
                  key: ValueKey(showSend),
                  width: 35,
                  margin: EdgeInsets.only(bottom: 5),
                  child: Icon(Icons.add_circle_outline),
                ),
              )
            ],
          ),
        ),

        Container(
          width: double.infinity,
          height: curKeyboardH,
         // color: Color(0xffededed),
          color: Theme.of(context).splashColor,
        ),

        Visibility(
          visible: showFace && !showMoreTool,
          maintainAnimation: showFaceA && curKeyboardH == 0,
          maintainState: showFaceA && curKeyboardH == 0,
          //  maintainSize: showFaceA && curKeyboardH==0,
          child: AnimatedSize(
            vsync: this,
            duration: Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: Container(
              width: double.infinity,
              height: faceH,
              color: Theme.of(context).splashColor,
              child: buildEmojiGird(),
            ),
          ),
        ),

        Visibility(
            visible: showMoreTool && !showFace,
            maintainAnimation: showToolA && curKeyboardH == 0,
            maintainState: showToolA && curKeyboardH == 0,
            //   maintainSize: showToolA && curKeyboardH==0,
//                  replacement: Container(
//                    width: double.infinity,
//                    height: curKeyboardH,
//                    color: Color(0xffededed),
//                  ),
            //maintainState: curKeyboardH == 0 ,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: buildMoreTool(),
            )),

//                if(curKeyboardH>0 || showMoreTool )
//                  Stack(
//                    children: <Widget>[
//                      Container(
//                    width: double.infinity,
//                    height: moreToolH,
//                    color: Color(0xffededed),
//                  ),
//                      if(showMoreTool )
//                      buildMoreTool,
//                    ],
//                  )
      ],
    );
  }
  Widget buildMoreTool() {
    // double itemW=MediaQuery.of(context).size.width/8;
    double columnSpace = moreToolH / 10;
    List row1 = [
      {"key": "相册", "icon": Icons.photo},
      {"key": "拍摄", "icon": Icons.camera_alt},
      {"key": "视频通话", "icon": Icons.phone_forwarded},
      {"key": "位置", "icon": Icons.location_on},
    ];
    List row2 = [
      {"key": "红包", "icon": Icons.card_giftcard},
      {"key": "转账", "icon": Icons.compare_arrows},
      {"key": "语音输入", "icon": Icons.mic},
      {"key": "我的收藏", "icon": Icons.color_lens},
    ];
    return Container(
        height: moreToolH,
        width: double.infinity,
        //color: Color(0xffededed),
        color: Theme.of(context).splashColor,
        child: Column(children: <Widget>[
          SizedBox(
            height: columnSpace,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
                row1.length,
                    (index) => GestureDetector(
                  onTap: () {
                    if (row1[index]['key'] == '拍摄')
                      takePhoto();
                    else if (row1[index]['key'] == '相册')
                      pickPhoto();
                    else if (row1[index]['key'] == '位置') sendLocationMsg();
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                           // color: Colors.white,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: Icon(row1[index]['icon']),
                      ),
                      Text(row1[index]['key'], style: TextStyle(fontSize: 12)),
                    ],
                  ),
                )),
          ),
          SizedBox(
            height: columnSpace,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
                row2.length,
                    (index) => Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(15),
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                          //color: Colors.white,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Icon(row2[index]['icon']),
                    ),
                    Text(row2[index]['key'], style: TextStyle(fontSize: 12)),
                  ],
                )),
          )
        ]));
  }

  Widget buildEmojiGird() {
    double screenW = MediaQuery.of(context).size.width;
    double mainAxisSpacing = 10.0;
    double crossAxisSpacing = 15.0;
    double itemW = 50.0;
    int crossAxisCount = screenW ~/ itemW;
    int faceCount = EMOJI.EmojiUtil.instance.emojiMap.length;
    int yu = faceCount % crossAxisCount;
    int sumFaceCount = faceCount;
//    if(yu!=0){
//      int addCount = crossAxisCount-yu+crossAxisCount;
//      sumFaceCount+=addCount;
//    }
    if (yu == 0) {
      int addCount = crossAxisCount;
      sumFaceCount += addCount;
    }

    var width = (screenW - ((crossAxisCount - 1) * crossAxisSpacing) - 10) / crossAxisCount;
    // print('width is $width');
    int rows = faceH ~/ (width + mainAxisSpacing);
    //  print('rows is $rows,${rows.runtimeType}');

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Stack(
          children: <Widget>[
            Selector<FaceListProvider, FaceListProvider>(
                shouldRebuild: (pre, next) => false,
                selector: (context, _face) => _face,
                builder: (context, _face, child) {
                  return GridView.builder(
                    controller: _gridController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        // maxCrossAxisExtent: 50,
                        childAspectRatio: 1,
                        crossAxisSpacing: crossAxisSpacing,
                        mainAxisSpacing: mainAxisSpacing),
                    itemBuilder: (BuildContext context, int index) {
                      return Selector<FaceListProvider, int>(
                          selector: (BuildContext context, int) => index,
                          shouldRebuild: (oldVal, newVal) {
                            //  print('$index是否重建，$oldVal,$newVal,,${index>=rows*crossAxisCount-1 && (index+1)%crossAxisCount==0}');
                            return (index >= rows * crossAxisCount - 1 && (index + 1) % crossAxisCount == 0);
                          },
                          builder: (context, data, child) {
                            //print("build item $index");
                            if (index >= faceCount) return Container(height: 35);
                            if (index >= rows * crossAxisCount - 1 && (index + 1) % crossAxisCount == 0) {
                              int curRow = (index + 1) ~/ crossAxisCount + 1;
                              double x = faceH % (width + mainAxisSpacing) / (width + mainAxisSpacing);
                              // print('x is $x');
                              double x2 = 0;
                              if ((sumFaceCount / crossAxisCount).ceil() == curRow) x2 = 1.0;
                              // double t = _gridController.offset/((curRow-rows-x/(curRow-rows)-x2)*(width+mainAxisSpacing/1));
                              double t = _gridController.offset / ((curRow - rows - x - x2) * (width + mainAxisSpacing / 1));
                              if (t > 1.0) t = 1.0;

                              // if(_gridController.offset<(curRow-rows-1.3*x-x2)*(width+mainAxisSpacing/1))t=0.0;
                              if (_gridController.offset < (curRow - rows - x - x2) * (width + mainAxisSpacing / 1)) t = 0.0;
                              //print('index is $index,curRow is $curRow,透明度 $t,offset is ${_gridController.offset}');
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (t < 0.9) return;
                                  insertText('[emoji$index]');
                                },
                                child: Opacity(
                                  opacity: t,
                                  child:
                                  // Text('$index-$t')
                                  Image.asset(EMOJI.EmojiUtil.instance.emojiMap['[emoji$index]']),
                                ),
                              );
                            }

                            return GestureDetector(
                              child: Container(
                                width: itemW + mainAxisSpacing / 2,
                                height: itemW,
                                child: Image.asset(EMOJI.EmojiUtil.instance.emojiMap['[emoji$index]']),
                              ),
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                insertText('[emoji$index]');
                              },
                            );
                          });
                    },
                    itemCount: sumFaceCount,
                    //  padding:  EdgeInsets.symmetric(horizontal: 5)
                  );
                }),
            Positioned(
                right: 0,
                bottom: 10,
                child: InkWell(
                  onTap: () {
                    manualDelete();
                  },
                  child: Container(
                    width: width,
                    height: width,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                    child: Icon(Icons.arrow_back),
                  ),
                ))
          ],
        ));
  }

  void insertText(String text) {
    final TextEditingValue value = _textFiled.value;
    final int start = value.selection.baseOffset;
    int end = value.selection.extentOffset;
    if (value.selection.isValid) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }

      _textFiled.value = value.copyWith(text: newText, selection: value.selection.copyWith(baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      _textFiled.value = TextEditingValue(text: text, selection: TextSelection.fromPosition(TextPosition(offset: text.length)));
    }
  }

  void manualDelete() {
    //delete by code
    final TextEditingValue _value = _textFiled.value;
    final TextSelection selection = _value.selection;
    if (!selection.isValid) {
      return;
    }

    TextEditingValue value;
    final String actualText = _value.text;
    if (selection.isCollapsed && selection.start == 0) {
      return;
    }
    final int start = selection.isCollapsed ? selection.start - 1 : selection.start;
    final int end = selection.end;

    value = TextEditingValue(
      text: actualText.replaceRange(start, end, ''),
      selection: TextSelection.collapsed(offset: start),
    );

    final TextSpan oldTextSpan = MySpecialTextSpanBuilder().build(_value.text);

    value = handleSpecialTextSpanDelete(value, _value, oldTextSpan, null);

    _textFiled.value = value;
  }

  void sendText(String text) {
    EMMessage message = EMMessage.createTxtSendMessage(content:text, userName:delegate.userIdOrGroupId);
    message.chatType = fromChatType(delegate.chatType);
    EMTextMessageBody body = EMTextMessageBody(text);
    message.body = body;
    print('-----------LocalID---------->' + message.msgId);
    message.setAttribute({"test1": "1111", "test2": "2222"});
    if(Provider.of<UserProvider>(context,listen: false).isGuest){
      _textFiled.text = '';
      delegate.insertNewMessage(message);
      return;
    }
    EMClient.getInstance().chatManager().sendMessage(message, onSuccess: () {
      print('-----------ServerID---------->' + message.msgId);
      print('-----------MessageStatus---------->' + message.status.toString());
    }, onError: (int code, String desc) {
      print('发送失败$code,$desc');
    });
    _textFiled.text = '';
    print('message is ${message.toDataMap()}');

    // _onConversationInit();
    delegate.insertNewMessage(message);
//    messageList.insert(0, message);
//    setState(() {});
  }


  void takePhoto() async {
    String imgPath = await MediaUtil.instance.takePhoto();
    if (imgPath == null) {
      return;
    }
    print('onTapItemCamera' + imgPath);
    EMMessage imageMessage = EMMessage.createImageSendMessage(filePath:imgPath, sendOriginalImage:true, userName:delegate.userIdOrGroupId);
    imageMessage.chatType = fromChatType(delegate.chatType);
    if(Provider.of<UserProvider>(context,listen: false).isGuest){
      delegate.insertNewMessage(imageMessage);
      return;
    }
    EMClient.getInstance().chatManager().sendMessage(imageMessage, onSuccess: () {
      print('-----------success---------->');
    }, onError: (int code, String desc) {
      print('发送失败$code,$desc');
    });
    delegate.insertNewMessage(imageMessage);
  }

  void pickPhoto() async {
    isPicking = true;
    List<AssetEntity> assets = await MediaUtil.instance.pickImage(context);
    Future.delayed(Duration(milliseconds: 100)).then((value) => isPicking = false);
    if (assets == null || assets.length == 0) return;

    if(Provider.of<UserProvider>(context,listen: false).isGuest){
      for (AssetEntity asset in assets) {
        File file = await asset.originFile;
        EMMessage imageMessage = CustomEMMessage.createImageSendMessage(file, true, delegate.userIdOrGroupId);
        imageMessage.chatType = fromChatType(delegate.chatType);
        delegate.insertNewMessage(imageMessage);
      }
      return;
    }
    for (AssetEntity asset in assets) {
      File file = await asset.originFile;
      EMMessage imageMessage = CustomEMMessage.createImageSendMessage(file, true, delegate.userIdOrGroupId);
      imageMessage.chatType = fromChatType(delegate.chatType);
      EMClient.getInstance().chatManager().sendMessage(imageMessage, onSuccess: () {
        print('-----------success---------->');
      }, onError: (int code, String desc) {
        print('发送失败$code,$desc');
      });
      delegate.insertNewMessage(imageMessage);
    }
  }

//  @override
//  void onProgress(int progress, String status) {
//    // TODO: implement onProgress
//    print('-----------onProgress---------->' + ': ' + progress.toString());
//  }

  void sendLocationMsg() async {
    bool res = await applySomePermission(Permission.location);
    if (!res) return;
    // Navigator.push(context, MaterialPageRoute(builder: (_)=>LocationMapPage()));
    Map map = await NavigatorUtil.goLocationMapPage(context);
    if (map == null) return;
    EMMessage locationMessage = EMMessage.createFileSendMessage(filePath:map['path'],userName: delegate.userIdOrGroupId);
    locationMessage.chatType = fromChatType(delegate.chatType);
    map['msgType'] = 'location';
    locationMessage.setAttribute(map);
    if(Provider.of<UserProvider>(context,listen: false).isGuest){
      delegate.insertNewMessage(locationMessage);
      return;
    }
    EMClient.getInstance().chatManager().sendMessage(locationMessage, onSuccess: () {
      print('-----------success---------->');
    }, onError: (int code, String desc) {
      print('发送失败$code,$desc');
    });
    delegate.insertNewMessage(locationMessage);
//    EMMessage customMessage = EMMessage.createSendMessage(EMMessageType.FILE);
//    EMCustomLocationMessageBody customBody =  EMCustomLocationMessageBody(
//        File(map['path']),map['title'],map['address'],map['latitude'],map['longitude']);
//    customMessage.body = customBody;
//    customMessage.to = chatRoomInfo['title'];
//    customMessage.chatType = fromChatType(0);
//    EMClient.getInstance().chatManager().sendMessage(customMessage, onSuccess: () {
//      print('---发送成功--------ServerID---------->' + customMessage.msgId);
//      print('-----------MessageStatus---------->' + customMessage.status.toString());
//    }, onError: (int code, String desc) {
//      print('发送失败$code,$desc');
//    });
//    messageList.insert(0, customMessage);
//    setState(() {
//    });
  }

  void startVoiceRecord() async {
   // print('录音状态 is ${_recorderModule.isRecording}');

    String dir;
    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectory()).path + '/record/';
      Directory music = Directory(dir);
      if (!music.existsSync()) {
        music.createSync(recursive: true);
      }
    } else {
      dir = (await getApplicationDocumentsDirectory()).path;
    }
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.aac';
    recordFilePath = dir + fileName;
    await _recorderModule.startRecorder(toFile: recordFilePath, bitRate: 32000);
    print('startRecorder');
//    _recorderModule.setSubscriptionDuration(Duration(milliseconds: 100));
//    _recorderSubscription = _recorderModule.onProgress.listen((e) {
////      print('录音时长 ${e.duration.inMilliseconds}');
////      print('分贝 is ${e.decibels}');
//    });
  }

  showVoiceView(DragStartDetails details, dialogW, dialogH, maxEnd) async{
    // print('details is ${details.localPosition},${details.globalPosition}');
    if(haveRecordPermission!=true){
      if(await Permission.microphone.status.isGranted==false)  haveRecordPermission=false;
      bool res = await applySomePermission(Permission.microphone);
      if (!res) {
        haveRecordPermission=false;
        return;
      }
      if(res==true && haveRecordPermission==false){
        haveRecordPermission=true;
        return;
      }
    }

    setState(() {
      textShow = "松开 发送";
    });
    touchStart = touchEnd = Offset(details.globalPosition.dx, details.globalPosition.dy - details.localPosition.dy - 2.0);
    showVoiceDialogView(context, dialogW: dialogW, dialogH: dialogH, maxEndY: maxEnd);
    startVoiceRecord();
  }

  updateVoiceView(DragUpdateDetails e, maxEnd) {
    //print('voidedB is $voidedB,on move is ${e.localPosition},${e.globalPosition}');
    touchEnd = e.globalPosition;
    if (overlayEntry != null) {
      if (e.globalPosition.dy > touchStart.dy)
        touchEnd = touchStart;
      else if (e.globalPosition.dy < maxEnd) touchEnd = Offset(e.globalPosition.dx, maxEnd);
      if (touchEnd.dy <= maxEnd) {
        voiceTip = '松开手指 取消发送';
        voiceIcon = Icons.mic_off;
        isCancelSend = true;
        if (textShow != '松开 取消')
          setState(() {
            textShow = '松开 取消';
          });
      } else {
        voiceTip = '手指上滑 取消发送';
        voiceIcon = Icons.record_voice_over;
        isCancelSend = false;
        if (textShow != '松开 发送')
          setState(() {
            textShow = '松开 发送';
          });
      }

      overlayEntry.markNeedsBuild();
    }
  }

  hideVoiceView() async {
    if (_recorderModule.isRecording) {
      if (voiceTime < 1000) {
        voiceTip = '录音时间太短';
        voiceIcon = Icons.info_outline;
        overlayEntry.markNeedsBuild();
        await Future.delayed(Duration(milliseconds: 300));
        await _recorderModule.stopRecorder();
      } else
        await _recorderModule.stopRecorder();
      overlayEntry.remove();
      overlayEntry = null;
      textShow = "按住 说话";
      voiceTip = '手指上滑 取消发送';
      voiceIcon = Icons.record_voice_over;
      print('stopRecorder');
      if (isCancelSend == true || voiceTime < 1000) {
        isCancelSend = false;
        File(recordFilePath).exists().then((value) => File(recordFilePath).delete());
        setState(() {});
        return;
      }
      isCancelSend = false;
      print('recordFilePath is $recordFilePath');
      EMMessage voiceMessage = EMMessage.createVoiceSendMessage(filePath:recordFilePath, timeLength:voiceTime, userName:delegate.userIdOrGroupId);
      voiceMessage.chatType = fromChatType(delegate.chatType);
      if(Provider.of<UserProvider>(context,listen: false).isGuest){
        delegate.insertNewMessage(voiceMessage);
        return;
      }
      EMClient.getInstance().chatManager().sendMessage(voiceMessage, onSuccess: () {
        print('-----------success---------->');
      }, onError: (int code, String desc) {
        print('发送失败$code,$desc');
      });
    delegate.insertNewMessage(voiceMessage);
    }
  }

  showVoiceDialogView(BuildContext context, {double dialogW, double dialogH, @required double maxEndY}) {
    if (overlayEntry == null) {
      final double h = MediaQuery.of(context).size.height;
      final double w = MediaQuery.of(context).size.width;
      final Offset maxEnd = Offset(w * 0.5, maxEndY);
      overlayEntry = new OverlayEntry(builder: (content) {
        return Stack(
          children: <Widget>[
            if (touchStart != touchEnd)
              Positioned(
                top: maxEnd.dy,
                left: w * 0.5,
                child: Container(
                  //color: Colors.red,
                  height: touchStart.dy - maxEnd.dy,
                  width: 10,
                  child: RotatedBox(
                      quarterTurns: 3,
                      child: Material(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 10.0,
                            trackShape: CustomTrackShape(),
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4),
                          ),
                          child: Slider(
                            value: touchStart.dy - touchEnd.dy,
                            min: 0,
                            max: touchStart.dy - maxEnd.dy,
                            onChanged: (double value) {},
                          ),
                        ),
                      )
//                      LinearProgressIndicator(
//                        value: 1 - (touchEnd.dy - maxEnd.dy) / (touchStart.dy - maxEnd.dy),
//                      ),
                  ),
                ),
              ),
            Positioned(
              top: h * 0.5,
              left: w * 0.5 - dialogH / 2,
              child: Material(
                type: MaterialType.transparency,
                elevation: 10,
                child: Center(
                  child: Opacity(
                    opacity: 0.9,
                    child: Container(
                        width: dialogW,
                        height: dialogH,
                        decoration: BoxDecoration(
                          color: Color(0xff77797A),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: <Widget>[
                            if (voiceTime > 1000)
                              CustomPaint(
                                painter: VoiceWavePaint(voidedB),
                                size: Size(dialogW, dialogH / maxRecordTime * voiceTime / 1000),
                              ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  voiceIcon,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  voiceTip,
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                ),
              ),
            )
          ],
        );
      });
      Overlay.of(context).insert(overlayEntry);
    } else {
      overlayEntry.markNeedsBuild();
    }
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

abstract class BottomInputBarDelegate {
  String  userIdOrGroupId;
  int chatType=0;

  void insertNewMessage(EMMessage msg);
  void scrollBottom();
}
