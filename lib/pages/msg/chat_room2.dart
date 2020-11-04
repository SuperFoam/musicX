import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/utils_function.dart';
import 'dart:ui';

class ChatRoomPage2 extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    return _ChatRoomPageState();
  }
}

class _ChatRoomPageState extends State<ChatRoomPage2> with WidgetsBindingObserver {
  Map chatRoomInfo;
  ScrollController _msgListController;
  TextEditingController _textFiled;
  FocusNode _focusNode;
  bool showSend = false;
  bool showFace = false;
  bool showMoreTool = false;
  double moreToolH = 250;
  double keyboardH = 0;
  bool readOnly = false;
  bool isExistFace=false;

  @override
  void initState() {
    super.initState();
    chatRoomInfo =chatRoomInfo ={"title":"test"};
    _msgListController = ScrollController();
    _textFiled = TextEditingController();
    _focusNode = FocusNode();//FirstDisabledFocusNode();
    _textFiled.addListener(() {
      onInputChange();
    });
    _focusNode.addListener(() {
      onFocusChange();
    });
    initKeyboardH();
    WidgetsBinding.instance.addObserver(this);
  }


  @override
  void didChangeMetrics() {
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
    keyboardH =keyH>=0? keyH:-keyH;
    if (_focusNode.hasFocus && showMoreTool == true) showMoreTool = false;
    // if (_focusNode.hasFocus && showFace == true) showFace = false;
    if(isExistFace==true) {
      print('存在表情显示');
      showFace=false;
      isExistFace=false;

    }
    if(readOnly==true)readOnly=false;
    setState(() {});

    if (keyH > 0.0 && keyH != moreToolH) {
      moreToolH = keyH;
      KeyboardHeight.change(keyH);
      print('键盘高度写入本地');
    }
    super.didChangeMetrics();
  }

  Future<void> initKeyboardH() async {
    double h = KeyboardHeight.getData();
    if (h != null) moreToolH = h;
    print('工具栏高度为$h');
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

  void onFocusChange() {
    print('焦点改变了');
    if (_focusNode.hasFocus) {
      //SystemChannels.textInput.invokeMethod('TextInput.hide');
//    if( showMoreTool==true){
//      showMoreTool=false;
//      setState(() {
//        print('关闭更多工具');
//      });
//    }

      // _msgListController.animateTo(_msgListController.position.maxScrollExtent, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _msgListController.dispose();
    _textFiled.dispose();
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print('chat list rebuild');
    return Scaffold(
       //resizeToAvoidBottomPadding: false,
      // backgroundColor:  Color(0xffededed).withOpacity(0.95),
      appBar: AppBar(
        title: Text(
          chatRoomInfo['title'] ?? '未知',
        ),
      ),
      body: Container(
        //padding: EdgeInsets.only(bottom: pp),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: ListView.builder(
                  key: UniqueKey(),
                  controller: _msgListController,
                  itemCount: 20,
                  reverse: true,
                  itemBuilder: (context, int index) {
                    return ListTile(
                      leading: Text('test$index'),
                    );
                  }),
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  // constraints: BoxConstraints( minHeight:20,maxHeight: 120.0),

                  width: double.infinity,
                  decoration: BoxDecoration(color: Color(0xffededed), border: Border.symmetric(vertical: BorderSide(color: Colors.grey.withOpacity(0.2)))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        width: 40,
                        margin: EdgeInsets.only(bottom: 5),
                        child: Icon(Icons.mic_none),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          constraints: BoxConstraints(minHeight: 30, maxHeight: 100),
                          child: Builder(
                            builder: (BuildContext context){
                              return TextField(
                                showCursor: true,
                                readOnly: readOnly,
                                //autofocus: auto,
                                controller: _textFiled,
                                focusNode: _focusNode,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                //style: TextStyle(textBaseline: TextBaseline.alphabetic),
                                maxLength: 20,

                                onSubmitted: (String _) {},
                                onTap: (){
                                  print('输入框点击了,$readOnly');
                                  if(readOnly==true){
                                    readOnly=false;
                                    if(showFace==true)showFace=false;
                                    (context as Element).markNeedsBuild();
//                                    setState(() {
//
//                                    });
                                  }
                                  isExistFace=showFace;

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
                          ),
                        ),
                      ),
                      GestureDetector(
                        child:  Container(
                          width: 35,
                          margin: EdgeInsets.only(bottom: 5),
                          child: Icon(showFace?Icons.face:Icons.tag_faces),
                        ),
                        onTap: (){
                          if(showMoreTool==true)showMoreTool=false;
                          showFace=!showFace;
                          print('是否展示表情$showFace');
                          if(showFace){
                            if(_focusNode.hasFocus){

                              if(keyboardH>0){
                                SystemChannels.textInput.invokeMethod('TextInput.hide');
                                return;
                              }

                            }else{
                              readOnly=true;
                              setState(() {

                              });
                              Future.delayed(Duration(milliseconds: 100)).then((value) => _focusNode.requestFocus());
                              return;
                            }
                            setState(() {

                            });

                          }else
                            //_focusNode.requestFocus();
                            SystemChannels.textInput.invokeMethod<void>('TextInput.show');

                        },
                      ),
                      showSend
                          ? Container(
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
                      )
                          : InkWell(
                        onTap: () {
                          if(showFace==true)showFace=false;

                          showMoreTool = !showMoreTool;
                          print('是否展示更多工具$showMoreTool');
                          if (showMoreTool) {
                            if (_focusNode.hasFocus) {
                              _focusNode.unfocus();
                              if (keyboardH > 0) {
                                print('键盘高度大于0，直接返回');
                                return;
                              }
                            }
                            if(readOnly==true)readOnly=false;
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
//                if(showFace && !showMoreTool)
//                  Container(
//                    width: double.infinity,
//                    height: moreToolH,
//                    child: Text('qq'),
//                  ),

                Visibility(
                  visible: showFace && !showMoreTool,
                  child:   Container(
                    width: double.infinity,
                    height: moreToolH,
                    child:RaisedButton(
                      onPressed: (){
                        _textFiled.text=_textFiled.text+'q';
                        _textFiled.selection=TextSelection(baseOffset:  _textFiled.text.length,extentOffset:  _textFiled.text.length);
                      },
                      child: Text('输入'),
                    ),
                  ),
                ),

                Visibility(
                  visible: showMoreTool && !showFace,
                  child: buildMoreTool,
                ),


//                if(keyboardH>0 || showMoreTool )
//                  Stack(
//                    children: <Widget>[
//                      Container(
//                        width: 200,
//                        height: moreToolH,
//                        color: Colors.red,
//                      ),
//                      if(showMoreTool )
//                        Container(
//                        height: moreToolH,
//                        width: double.infinity,
//                        color: Colors.blue,
//                        child: Text('qq'),
//                      )
//                    ],
//                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget get buildMoreTool{
    //double itemW=MediaQuery.of(context).size.width/8;
    double columnSpace = moreToolH/10;
    List row1=[
      {"key":"相册","icon":Icons.photo},
      {"key":"拍摄","icon":Icons.camera_alt},
      {"key":"视频通话","icon":Icons.phone_forwarded},
      {"key":"位置","icon":Icons.location_on},
    ];
    List row2=[
      {"key":"红包","icon":Icons.card_giftcard},
      {"key":"转账","icon":Icons.compare_arrows},
      {"key":"语音输入","icon":Icons.mic},
      {"key":"我的收藏","icon":Icons.color_lens},
    ];
    return Container(
      height: moreToolH,
      width: double.infinity,
      color: Color(0xffededed),
      child: Column(
          children: <Widget>[
            SizedBox(
              height: columnSpace,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(row1.length, (index) =>  Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                    child: Icon(row1[index]['icon']),
                  ),
                  Text(row1[index]['key'],style: TextStyle(fontSize: 12)),
                ],
              ) ),
            ),
            SizedBox(
              height: columnSpace,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:  List.generate(row2.length, (index) =>  Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                    child: Icon(row2[index]['icon']),
                  ),
                  Text(row2[index]['key'],style: TextStyle(fontSize: 12)),
                ],
              ) ),
            )
          ]

      ),
    );
  }
}
class FirstDisabledFocusNode extends FocusNode {


  @override
  bool consumeKeyboardToken() {
    return false;
  }
}
class NoKeyboardEditableText extends EditableText{

}
