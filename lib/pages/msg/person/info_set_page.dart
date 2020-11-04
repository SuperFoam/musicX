import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_x/model/msg/person_info.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';

class PersonInfoSetPage extends StatefulWidget {
  final String userId;

  PersonInfoSetPage({@required this.userId});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PersonInfoSetPageState();
  }
}

class _PersonInfoSetPageState extends State<PersonInfoSetPage> {
  PersonInfoModel personInfo;
  double paddingNum = 15.0;
  EdgeInsetsGeometry padding;
  double itemH = 50;
  Color color;

  @override
  void initState() {
    padding = EdgeInsets.symmetric(horizontal: paddingNum);
    String userId = FluroConvertUtils.fluroCnParamsDecode(this.widget.userId);
    Map<String, dynamic> info = PersonInfoStorage.get(userId);
    print('info is $info');
    personInfo = PersonInfoModel.fromJson(info);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    color=Theme.of(context).scaffoldBackgroundColor;
    return WillPopScope(
      onWillPop: (){
        Navigator.of(context).pop(personInfo.remark);
        return new Future.value(true);
      },
      child: Scaffold(
       // backgroundColor: Color(0xffededed),
        backgroundColor: Theme.of(context).splashColor,
        appBar: AppBar(
          title: Text('资料设置'),
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: padding,
              color: color,
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
                      child: buildItem('设置备注', remark: personInfo.remark),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    height: 1,
                  ),
                  Container(
                      height: itemH,
                      child: InkWell(
                        onTap: ()async{
                          FriendPermission res = await NavigatorUtil.goFriendPermissionSetPage(context, personInfo.userId);
                          print('返回 $res');
                          if(res!=null && res!=personInfo.friendPermission){
                            Map<String, dynamic> info = PersonInfoStorage.get(personInfo.userId);
                            personInfo = PersonInfoModel.fromJson(info);
                            setState(() {

                            });
                          }
                        },
                        child: buildItem('朋友权限', remark: personInfo.getFriendPermissionString()),
                      )
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: padding,
              color: color,
              child: Column(
                children: <Widget>[
                  Container(
                    height: itemH,
                    child: buildItem(
                      '把他推荐给朋友',
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    height: 1,
                  ),
                  Container(
                    height: itemH,
                    child: buildItem(
                      '添加到桌面',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: padding,
              color: color,
              height: itemH,
              child: buildItemSwitch(
                '设为星标朋友',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: padding,
              color: color,
              child: Column(
                children: <Widget>[
                  Container(
                    height: itemH,
                    child: buildItemSwitch(
                      '加入黑名单',
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    height: 1,
                  ),
                  Container(
                    height: itemH,
                    child: buildItem(
                      '投诉',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: ()=>deletePerson(),
              child: Container(
                  padding: padding,
                  color: color,
                  height: itemH,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    '删除',
                    style: TextStyle(color: Colors.red),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget buildItem(String title, {String remark}) {
    return Row(
      children: <Widget>[
        Text(title),
        SizedBox(
          width: 10,
        ),
        if (remark == null)
          Spacer(),
//        if(remark!=null)
//          SizedBox(width: 10,),
        if (remark != null)
          //Expanded(child: Container(child: Text(remark,overflow: TextOverflow.ellipsis,),),),
          Expanded(
              child: Text(
            remark,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )),
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

  Widget buildItemSwitch(
    String title,
  ) {
    return Row(
      children: <Widget>[
        Text(title),
        Spacer(),
        if (title == '设为星标朋友')
          CupertinoSwitch(
            value: personInfo.isStar,
            onChanged: (value) {
              print(title);
              personInfo.isStar = value;
              PersonInfoStorage.put(personInfo.userId,'isStar',value);
              setState(() {});
            },
          ),
        if (title == '加入黑名单')
          CupertinoSwitch(
            value: personInfo.isBlacklist,
            onChanged: (value) async {
              if (value == false) {
                personInfo.isBlacklist = false;
                PersonInfoStorage.put(personInfo.userId,'isBlacklist',false);
                setState(() {});
                return;
              }
              bool res = await Funs.showCustomDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        '加入黑名单',
                        style: TextStyles.textDialogTitle,
                      ),
                      content: Text('加入黑名单 从此不往来'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("取消"),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text("确认"),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  });
              if(res==true){
                personInfo.isBlacklist=true;
                PersonInfoStorage.put(personInfo.userId,'isBlacklist',true);
                setState(() {

                });
              }

            },
          )
      ],
    );
  }
  void deletePerson()async{
    bool res = await Funs.showCustomDialog(context: context,builder: (context){
      return AlertDialog(
        title: RichText(text: TextSpan(
            style: TextStyles.textDialogTitle,
            children: [
              TextSpan(text: '删除联系人'),
              TextSpan(text: ' - ${personInfo.remark??personInfo.nickname}',style: TextStyles.textDialogName),
            ]
        ),),
        content: Text('删除联系人，不再梦相枕'),
        actions: <Widget>[
          FlatButton(
            child: Text("取消"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text("确认"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    });
    if(res==true)Utils.showToast('哈哈哈');
  }
}
