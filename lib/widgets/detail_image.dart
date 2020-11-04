
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/route/routes.dart';



class ChatDetailImagePage extends StatefulWidget {
//  final bool isLocal;
//  final String imgPath;
//  final String msgTimeStamp;
  final String msg;
  final String userId;

  ChatDetailImagePage(this.userId, this.msg);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChatDetailImageState();
  }
}

class _ChatDetailImageState extends State<ChatDetailImagePage> {
  static String host = "/storage/emulated/0/Android/data/com.example.music_x/files/Pictures/";
//  List imgList = [
//    host + '677385e4-8c06-4645-8112-fb542f7498af1795630868.jpg',
//    host + '2a252540-46e1-447a-b598-5de7eba09ba166161537.jpg',
//  ];
  List<Map> imageList = [];
  int msgMaxCount = 10;
  Map message;
  String userId;
  int initPage=0;
  //PageController _pageController = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userId = FluroConvertUtils.fluroCnParamsDecode(this.widget.userId);
    message = FluroConvertUtils.string2map(this.widget.msg);
    print('message is $message');
    // msg['body']['type'] = msg['type'];
    bool isLocal = false;
    String path;
    path = message['body']['localUrl'];
    if (path.isNotEmpty && File(path).existsSync())
      isLocal = true;
    else
      path = message['body']['remoteUrl'];
    //message=EMMessage.from(msg);
    Map t = {'isLocal': isLocal, 'path': path,"msgId":message['msgId']};
    imageList.add(t);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadMoreImage();
    });

  }

  void loadMoreImage() async {
    EMConversation conversation = await EMClient.getInstance().chatManager().getConversation(userId, fromEMConversationType(0), true);

    if (conversation != null) {
      List<EMMessage> msgListUp = await conversation.searchMsgFromDBByType(EMMessageType.IMAGE, int.parse(message['localTime']), msgMaxCount, '', EMSearchDirection.Up);
      List<EMMessage> msgListDown = await conversation.searchMsgFromDBByType(EMMessageType.IMAGE, int.parse(message['localTime']), msgMaxCount, '', EMSearchDirection.Down);
//      print(msgListUp);
//      print(msgListDown);
      List<Map> _listImg = [];
      void handleMsg(EMMessage msg){
        bool isLocal = false;
        String path;
        path = msg.body.toDataMap()['localUrl'];
        if (path.isNotEmpty && File(path).existsSync())
          isLocal = true;
        else
          path = msg.body.toDataMap()['remoteUrl'];
        //message=EMMessage.from(msg);
        Map t = {'isLocal': isLocal, 'path': path,"msgId":message['msgId']};
        _listImg.add(t);
        if(msg.msgId==message['msgId'])initPage=_listImg.length-1;
      }
      if (msgListUp != null && msgListUp.length > 0) {
        for(EMMessage msg in msgListUp){
          handleMsg(msg);
        }
      }
      if (msgListDown != null && msgListDown.length > 0) {
        for(EMMessage msg in msgListDown){
          handleMsg(msg);
        }
      }
      if(_listImg.length>1){
        imageList.clear();
        imageList=_listImg;

        setState(() {
           // _pageController.jumpToPage(initPage);
        });
      }

    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    // _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

//    return GestureDetector(
//      behavior: HitTestBehavior.opaque,
//      onTap: () => Navigator.pop(context),
//      child: Center(
//          child:  Hero(
//            tag: "detailImage${imageList[0]['msgId']}",
//            child: ExtendedImage.file(File(imageList[0]['path']),),
//          )
//
//      ),
//    );

    return Material(
        color: Colors.transparent,
        child:
        ExtendedImageGesturePageView.builder(
          key: UniqueKey(), // 要使用UniqueKey，不然initialPage无效
          itemCount: imageList.length,
          controller:
         // _pageController,
          PageController(
            initialPage: initPage,
          ),
          itemBuilder: (context, int index) {
            return ExtendedImageSlidePage(
              slideAxis: SlideAxis.vertical,
              slideType: SlideType.onlyImage,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: Center(
                  child: imageList[index]['msgId']==message['msgId']?
                  Hero(
                      tag: "detailImage${imageList[index]['msgId']}",
                      child: buildDetailImg(index)
                  ):buildDetailImg(index),
                ),
              ),
            );
          },
        )
    );
  }
  Widget buildDetailImg(int index){
    return imageList[index]['isLocal'] == true
        ? ExtendedImage.file(
      File(imageList[index]['path']),
      enableSlideOutPage: true,
      mode: ExtendedImageMode.gesture,
      initGestureConfigHandler: (state) => GestureConfig(inPageView: true, maxScale:3.0,initialScale: 1.0, cacheGesture: false),
    )
        : ExtendedImage.network(
      imageList[index]['path'],
      enableSlideOutPage: true,
      mode: ExtendedImageMode.gesture,
      initGestureConfigHandler: (state) => GestureConfig(inPageView: true, initialScale: 1.0, cacheGesture: false),
    );
  }
}
