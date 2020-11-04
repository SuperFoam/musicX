import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingPageState();
  }
}

class _SettingPageState extends State<SettingPage> {
  Color color;

  @override
  Widget build(BuildContext context) {
    color =Theme.of(context).scaffoldBackgroundColor;
    String userId=  Provider.of<UserProvider>(context,).userId??'未知';
    return
      Scaffold(
         // backgroundColor: Color(0xffededed),
          backgroundColor: Theme.of(context).splashColor,
          appBar: AppBar(
            title: Text('设置'),
          ),
          body: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.0))
                ),
                child: Column(children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 50,
                        height: 50,
                        child: xImgRoundRadius(radius: 50 / 2),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('卧夜思雨'),
                          Text(
                            userId,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          )
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      )
                    ],
                  ),
                  Divider(thickness: 1,),
                  Row(children: <Widget>[
                    Text('地址管理'),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    )
                  ],),
                ],),
              ),
              Container(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(children: <Widget>[
                      Text('账号与安全'),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      )
                    ],),
                    Divider(thickness: 1,),
                    Row(children: <Widget>[
                      Text('音效与通知'),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      )
                    ],),
                    Divider(thickness: 1,),
                    Row(children: <Widget>[
                      Text('隐私'),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      )
                    ],),
                    Divider(thickness: 1,),
                    Row(children: <Widget>[
                      Text('通用'),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      )
                    ],),
                  ],
                ),
              ),
              Container(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(children: <Widget>[
                      Text('帮助与反馈'),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      )
                    ],),
                    Divider(thickness: 1,),
                    Row(children: <Widget>[
                      Text('关于应用'),
                      Spacer(),
                      Text('V1.0 ',style: TextStyle(fontSize: 12,color: Colors.grey),),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      )
                    ],),

                  ],
                ),
              ),
              Container(
                height: 10,
              ),
              InkWell(
                onTap: (){
                  Funs.showCustomDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          '确认退出吗',
                          style: TextStyles.textDialogTitle,
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("取消"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text("确定"),
                            onPressed: () async {

                              Provider.of<UserProvider>(context,listen: false).logout();
                              NavigatorUtil.goLogin(context);

                            },
                          ),
                        ],
                      );
                    },
                  );

                },
                child:  Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child:     Text('退出登录'),
                ),
              )
            ],
          ));

  }
}
