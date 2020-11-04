import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/model/msg/person_info.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/widgets/local_or_network_image.dart';

class PersonInfoPage extends StatefulWidget {
  final String userId;

  PersonInfoPage({@required this.userId});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PersonInfoPageState();
  }
}

class _PersonInfoPageState extends State<PersonInfoPage> {
  String userId;
  PersonInfoModel personInfo;
  double paddingNum = 15.0;
  EdgeInsetsGeometry padding;

  double itemH = 50;

  @override
  void initState() {
    padding = EdgeInsets.symmetric(horizontal: paddingNum);
    userId = FluroConvertUtils.fluroCnParamsDecode(this.widget.userId);
    print(userId);
    Map<String, dynamic> info = PersonInfoStorage.get(userId);
    print('info is $info');
    personInfo = PersonInfoModel.fromJson(info);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // backgroundColor: Color(0xffededed),
      backgroundColor: Theme.of(context).splashColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black54),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () async{
              String res = await NavigatorUtil.goPersonInfoSetPage(context, userId);
              if(res!=null && res!=personInfo.remark){
                Map<String, dynamic> info = PersonInfoStorage.get(personInfo.userId);
                personInfo = PersonInfoModel.fromJson(info);
                setState(() {

                });
              }
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            color:Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.fromLTRB(paddingNum, 0, paddingNum, 30),
            child: head,
          ),
          Divider(
            thickness: 1,
            height: 1,
          ),
          Container(
              padding: padding,
              //color: Colors.white,
              color:Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: <Widget>[
                  Container(
                    height: itemH,
                    child: InkWell(
                      onTap: ()async{
                        String res = await NavigatorUtil.goPersonInfoRemarkSetPage(context, personInfo.userId);
                        // print('返回 $res');
                        if(res!=null && res!=personInfo.remark){
                          Map<String, dynamic> info = PersonInfoStorage.get(personInfo.userId);
                          personInfo = PersonInfoModel.fromJson(info);
                          setState(() {

                          });
                        }
                      },
                      child: buildItem('设置备注'),
                    )
                  ),
                  Divider(
                    thickness: 1,
                    height: 1,
                  ),
                  Container(
                    height: itemH,
                    child:InkWell(
                      onTap: (){
                         NavigatorUtil.goFriendPermissionSetPage(context, personInfo.userId);

                      },
                      child:  buildItem('朋友权限'),
                    )
                  ),
                ],
              )),
          SizedBox(
            height: 10,
          ),
          Container(
              padding: padding,
              //color: Colors.white,
              color:Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    child: buildMoments,
                  ),
                  Divider(
                    thickness: 1,
                    height: 1,
                  ),
                  Container(
                    height: 40,
                    child: buildItem('更多信息'),
                  ),
                ],
              )),
          SizedBox(
            height: 10,
          ),
          Container(
            //color: Colors.white,
            color:Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap:(){
                    NavigatorUtil.goChatRoomPage(context, {"conversationId": personInfo.userId??'未知id',"conversationType":EMConversationType.Chat.index});
          },
                  child: Container(
                    height: itemH,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.chat_bubble_outline),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '发消息',
                          style: TextStyle(color: Colors.blue),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  height: 1,
                ),
                Container(
                  height: itemH,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.video_call),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '音视频通话',
                        style: TextStyle(color: Colors.blue),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget get buildMoments {
    return Row(
      children: <Widget>[
        Text('朋友圈'),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(personInfo.moments.length, (index) {
              return Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.only(right: index == personInfo.moments.length - 1 ? 0 : 10),
                decoration: BoxDecoration(image: DecorationImage(image: xImage(urlOrPath: personInfo.moments[index]))),
              );
            }),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 15,
        ),
      ],
    );
  }

  Widget get head {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 60,
          height: 60,
          child: xImgRoundRadius(),
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (personInfo.remark != null)
                  Text(
                    personInfo.remark,
                    style: TextStyles.textSizeMD,
                  ),
                buildSex,
              ],
            ),
            Text(
              '昵称：${personInfo.nickname}',
              style: TextStyles.text14Grey,
            ),
            Text(
              '用户id：$userId',
              style: TextStyles.text14Grey,
            ),
            Text(
              '地区：${personInfo.location}',
              style: TextStyles.text14Grey,
            ),
          ],
        )
      ],
    );
  }

  Widget get buildSex {
    Icon icon;
    if (personInfo.sex == PersonSex.MAN)
      icon = Icon(
        Icons.person,
        color: Colors.blue,
      );
    else if (personInfo.sex == PersonSex.WOMAN)
      icon = Icon(
        Icons.person,
        color: Colors.deepOrangeAccent,
      );
    else if (personInfo.sex == PersonSex.UNKNOWN)
      icon = Icon(
        Icons.wc,
      );
    else
      icon = null;
    return icon;
  }

  Widget buildItem(String title) {
    return Row(
      children: <Widget>[
        Text(title),
        Spacer(),
        Icon(
          Icons.arrow_forward_ios,
          size: 15,
        ),
      ],
    );
  }
}
