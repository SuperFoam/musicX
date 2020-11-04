
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/provider/play_voice.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/custom_im.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/custom_paint.dart';
import 'package:provider/provider.dart';
import 'detail_image.dart';
import 'local_or_network_image.dart';
import 'package:music_x/utils/emoji_text.dart' as emoji;
import 'dart:io';
import 'package:music_x/utils/global_data.dart';

class ChatItem extends StatelessWidget {
  final EMMessage message;
  final bool isShowTime;
  final String userId;
  final double imageW=80.0;
  final double imageH = 120;
  final double tipPadding = 10.0;

  ChatItem(this.userId,this.message,this.isShowTime);

  @override
  Widget build(BuildContext context) {
    //print('构建item $message');

    return Padding(
     padding: EdgeInsets.symmetric(vertical: 5),

      child: Column(
        children: <Widget>[
          if(isShowTime)Text(formatTimeWX(int.parse(message.msgTime.isNotEmpty?message.msgTime:message.localTime))),
          Padding(
            padding: EdgeInsets.fromLTRB(message.direction == Direction.SEND ? 30 : 0, 0, message.direction == Direction.SEND ? 0 : 30, 0),

            child:  showMessage(context),
          ),

        ],
      ),
    );
  }
  Widget  showMessage(BuildContext context) {
    if(message.type==EMMessageType.CUSTOM ){
      EMCustomMessageBody custom = message.body;
      if(custom.event==CustomIMType.JOIN_GROUP.index.toString()) {
        String master = custom.params['master'];
        String otherUser;
        try {
          List otherUserList = jsonDecode(custom.params['slave']);
          otherUser = otherUserList.join('、');
        }catch(e){
          otherUser = custom.params['slave'];
        }
        String curUser =  Provider.of<UserProvider>(context, listen: false).userId;
        String tipInfo ;
        if(master==curUser)
          tipInfo='你邀请$otherUser加入了群聊';
        else
          tipInfo='$master邀请你加入群聊';
          return Padding(
            padding: EdgeInsets.only(top: tipPadding),
            child: Text(tipInfo,style: TextStyles.text11Grey,),
          );
      }

    }
      return showPersonMessage(context);
  }
  Widget  showPersonMessage(BuildContext context){
    return  Row(
      //mainAxisAlignment:index.isEven?MainAxisAlignment.end:MainAxisAlignment.start ,
      textDirection: message.direction == Direction.SEND ? TextDirection.rtl : TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            print('点击头像${message.from}');
            NavigatorUtil.goPersonInfoPage(context,message.from);
          },

          child: CircleAvatar(
            radius: 20,
            backgroundImage: xImage(),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              message.direction == Direction.RECEIVE ?
              Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  '昵称${message.from}',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ) : SizedBox(height: 10,),
              buildShowMessage(context),

            ],
          ),
        )
      ],
    );
  }
  Widget  buildShowMessage(BuildContext context){
    Widget widget = Text('未知消息类型');
    if(message.type==EMMessageType.TXT){
      widget=CustomPaint(
        painter: ChatBubblePainter(Theme.of(context).bottomAppBarColor, message.direction == Direction.SEND ? 'rightTop' : 'leftTop'),
        child: Container(
            padding: EdgeInsets.all(5),
            child:buildShowText( '${message.body.toDataMap()['message']}')
        ),
      );
    }else if (message.type==EMMessageType.IMAGE){
//      widget = InkWell(
//        onTap: ()=>NavigatorUtil.goDetailImageChat(context,this.userId,this.message.toDataMap()),
//        child:Container(
//          //width: imageW,
//            constraints: BoxConstraints(
//                maxWidth: imageW,
//                maxHeight: imageH
//            ),
//
//            child: Hero(
//                tag: "detailImage${message.msgId}",
//                child: buildShowImage()
//              //ExtendedImage.file(File(message.body.toDataMap()['localUrl']),cacheWidth: imageW.toInt(),),
//            )
//        ),
//      );
      widget = OpenContainer(
        closedBuilder: (context,VoidCallback open){
          return Container(
            //width: imageW,
            constraints: BoxConstraints(
                maxWidth: imageW,
                maxHeight: imageH
            ),
            child: buildShowImage(),
          );
        },
        openBuilder: (context,VoidCallback _){

          String _userId =FluroConvertUtils.fluroCnParamsEncode(userId);
          String t2 =  FluroConvertUtils.object2string(message.toDataMap());
          return ChatDetailImagePage(
              _userId,
              t2
          );
        },
      );
    }else if (message.type==EMMessageType.VOICE){
      widget = GestureDetector(
       onTap: (){
         Provider.of<VoicePlayerProvider>(context,listen: false).playVoice(message);
       },
        child: buildShowVoice(context),
      );

    } else if(message.type==EMMessageType.FILE && message.getAttribute('msgType')=='location'){
      widget = InkWell(
        onTap: ()=>NavigatorUtil.goLocationMapPage(context,location: message.ext()),
        child: buildShowLocation(context),
      );
    }
    else if(message.type==EMMessageType.CUSTOM){

    }

    return widget;
  }
  Widget buildShowVoice(BuildContext context){
    EMVoiceMessageBody msg = message.body;
   // print('语音消息 ${msg.toDataMap()}');
    return CustomPaint(
      painter: ChatBubblePainter(Theme.of(context).bottomAppBarColor, message.direction == Direction.SEND ? 'rightTop' : 'leftTop'),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          width: msg.getVoiceDuration()/1000*5,
          constraints: BoxConstraints(
            maxWidth: 200,
            minWidth: 60,
            minHeight: 35,
          ),
          child:  Consumer<VoicePlayerProvider>(
            builder: (context,_voicePlayer,child){
              IconData icon = Icons.mic_none;
              String msgId = '1';
              if(_voicePlayer.msgId==message.msgId){
                icon = Icons.mic;
                msgId= message.msgId;
              }
              return  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if(_voicePlayer.msgId==message.msgId)StreamBuilder<int>(
                    stream: _voicePlayer.curPositionController.stream,
                    builder: (context,AsyncSnapshot snapShot){
                      if(snapShot.hasData)
                      return LinearProgressIndicator(value: snapShot.data/_voicePlayer.voiceDuration,);
                      return Container(width: 0.0, height: 0.0);
                    },
                  ),
                  Row(
                    mainAxisAlignment: message.direction == Direction.SEND ? MainAxisAlignment.end : MainAxisAlignment.start,
                    textDirection: message.direction == Direction.SEND ? TextDirection.ltr : TextDirection.rtl,
                    children: <Widget>[
                      Text( "${msg.getVoiceDuration()~/1000}''"),
                      AnimatedSwitcher(
                       duration: const Duration(milliseconds: 500),
                       reverseDuration: const Duration(milliseconds: 200),
                       transitionBuilder:
                           (Widget child, Animation<double> animation) {
                         return ScaleTransition(child: child, scale: animation);
                       },
                       child:  Icon(icon,key:ValueKey(msgId),size: 20,color: Colors.black54,),
                     )

                    ],),
                ],
              );
            },

          )

      ),
    );

  }
  Widget buildShowLocation(BuildContext context){
    //print(message.toDataMap());
    EMFileMessageBody msg = message.body;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            //color: Colors.white,
              color:Theme.of(context).bottomAppBarColor,
          //  borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(1),
                child:  Text('  '+message.getAttribute('title'),overflow: TextOverflow.ellipsis,),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(1,0,1,5),
                child:  Text('  '+message.getAttribute('address'),style: TextStyle(fontSize: 11,color: Colors.grey),overflow: TextOverflow.ellipsis),
              ),

              Expanded(child: Container(width: 200,
                decoration: BoxDecoration(
                  //color: Colors.white,
                  color:Theme.of(context).bottomAppBarColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  showLocationImage(msg),),)

            ],)
      ),
    );

  }
  Widget showLocationImage(EMFileMessageBody msg){
    Widget widget;
    if(msg.localUrl!=null){
      String path = msg.localUrl;
      File file = File(path);
      if(file != null && file.existsSync()) {
        //print('显示本地图-----');
        widget = ExtendedImage.file(file,fit: BoxFit.cover);

      }else {
       // print('显展示远程图 -----$path');
        widget = ExtendedImage.network(msg.remoteUrl,fit: BoxFit.cover);

      }
    }else {
       //print('展示远程图');
      widget = ExtendedImage.network(msg.remoteUrl,fit: BoxFit.cover);
    }
    return widget;

  }
  Widget buildShowImage(){
    ///优先读缩略图，否则读本地路径图，否则读网络图
    EMImageMessageBody msg = message.body;

    Widget widget;
    if (msg.thumbnailUrl != null && msg.thumbnailUrl.length > 0) {
      //print('展示缩略图');
      widget = ExtendedImage.network(msg.thumbnailUrl);
    } else {
      if(msg.localUrl != null) {
        String path = msg.localUrl;
        File file = File(path);
        if(file != null && file.existsSync()) {
          widget = ExtendedImage.file(file,cacheWidth: imageW.toInt());
         // print('显示缩略图-----');
        }else {
          widget = ExtendedImage.network(msg.localUrl,);
        //  print('显示缩略图123 -----');
        }
      }else {
       // print('展示远程图');
        widget = ExtendedImage.network(msg.remoteUrl);
      }
    }
    return widget;
  }


  final RegExp reg = RegExp(r'\[emoji\d+\]');
  Widget buildShowText(String msg){
   // print('msg is $msg');
    var res = reg.allMatches(msg);
    if(res.length==0)
      return Text(msg);
    List<InlineSpan> widgets= [];
    int start = 0;
    for(var mach in res){
      String s = mach.group(0);
      int end = msg.indexOf(s,start);
      String text = msg.substring(start,end);
      if(text.isNotEmpty){
        var t=TextSpan(text: text);
        widgets.add(t);
      }
      var img =WidgetSpan(
        child:  Container(
          width: 20,
          height: 20,
          margin: EdgeInsets.only(right: 3),
          child:  Image.asset(emoji.EmojiUtil.instance.emojiMap[s]),
        )
      );
      widgets.add(img);
      start+=text.length+s.length;
    }
    if(start!=msg.length){
      String text = msg.substring(start);
      var t=TextSpan(text: text);
      widgets.add(t);
    }
    return Text.rich(TextSpan(children: widgets)
    );
  }

}

