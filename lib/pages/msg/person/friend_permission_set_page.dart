import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_x/model/msg/person_info.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/local_storage.dart';

class FriendPermissionSetPage extends StatefulWidget {
  final String userId;

  FriendPermissionSetPage({@required this.userId});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FriendPermissionSetState();
  }
}
class _FriendPermissionSetState extends State<FriendPermissionSetPage>{
  PersonInfoModel personInfo;
  double paddingNum = 15.0;
  EdgeInsetsGeometry padding;
  EdgeInsetsGeometry paddingTitle;
  double itemH = 50;
  double titleH = 40;
  Color color;

  @override
  void initState() {
    padding = EdgeInsets.symmetric(horizontal: paddingNum);
    paddingTitle = EdgeInsets.fromLTRB(paddingNum, paddingNum, paddingNum, 5);
    String userId = FluroConvertUtils.fluroCnParamsDecode(this.widget.userId);
    Map<String, dynamic> info = PersonInfoStorage.get(userId);
   // print('info is $info');
    personInfo = PersonInfoModel.fromJson(info);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      color =Theme.of(context).scaffoldBackgroundColor;
    return WillPopScope(
      onWillPop: (){
        Navigator.of(context).pop(personInfo.friendPermission);
        return new Future.value(true);
      },
      child: Scaffold(
       // backgroundColor: Color(0xffededed),
        backgroundColor: Theme.of(context).splashColor,
        appBar: AppBar(
          title: Text('朋友权限',style: TextStyle(color: Colors.black54),),
          titleSpacing: 0.0,
          iconTheme: IconThemeData(color: Colors.black54),
          //backgroundColor: Colors.white,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1.0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Container(
            padding: paddingTitle,
            height: titleH,
            child: Text('设置朋友权限',style: TextStyle(fontSize: 13,color: Colors.grey),),
          ),
          Container(
            padding: padding,
            color: color,
            child: Column(
              children: <Widget>[
                Container(
                  height: itemH,
                  child:InkWell(
                    onTap: (){
                      if(personInfo.friendPermission!=FriendPermission.ALL){
                        personInfo.friendPermission=FriendPermission.ALL;
                        PersonInfoStorage.put(personInfo.userId,'friendPermission',personInfo.getFriendPermission(FriendPermission.ALL));
                        setState(() {

                        });
                      }
                    },
                    child:  Row(children: <Widget>[
                      Text('聊天、朋友圈、访客记录等'),
                      Spacer(),
                      if(personInfo.friendPermission==FriendPermission.ALL)
                        Icon(Icons.done,color: Colors.green,)
                    ],),
                  )
                ),
                Divider(
                  thickness: 1,
                  height: 1,
                ),
                Container(
                  height: itemH,
                  child: InkWell(
                    onTap: (){
                      if(personInfo.friendPermission!=FriendPermission.CHAT){
                        personInfo.friendPermission=FriendPermission.CHAT;
                        PersonInfoStorage.put(personInfo.userId,'friendPermission',personInfo.getFriendPermission(FriendPermission.CHAT));
                        setState(() {

                        });
                      }
                    },
                    child: Row(children: <Widget>[
                      Text('仅聊天'),
                      Spacer(),
                      if(personInfo.friendPermission==FriendPermission.CHAT)
                        Icon(Icons.done,color: Colors.green,)
                    ],),
                  )
                ),
              ],
            ),
          ),
            Container(
              padding: paddingTitle,
              height: titleH,
              child: Text('朋友圈和视频动态',style: TextStyle(fontSize: 13,color: Colors.grey),),
            ),
            Container(
              padding: padding,
              color: color,
              child: Column(
                children: <Widget>[
                  Container(
                    height: itemH,
                    child: Row(children: <Widget>[
                      Text('你看不到我'),
                      Spacer(),
                      CupertinoSwitch(
                        value: personInfo.hideMyPosts?true:false,
                        onChanged: (value){
                          personInfo.hideMyPosts=value;
                          PersonInfoStorage.put(personInfo.userId,'hideMyPosts',value);
                          setState(() {

                          });
                        },
                      ),
                    ],),
                  ),
                  Divider(
                    thickness: 1,
                    height: 1,
                  ),
                  Container(
                    height: itemH,
                    child: Row(children: <Widget>[
                      Text('我看不到你'),
                      Spacer(),
                      CupertinoSwitch(
                        value: personInfo.hideHisPosts?true:false,
                        onChanged: (value){
                          personInfo.hideHisPosts=value;
                          PersonInfoStorage.put(personInfo.userId,'hideHisPosts',value);
                          setState(() {

                          });
                        },
                      ),
                    ],),
                  ),
                ],
              ),
            ),
        ],),
      ),
    );
  }
}
