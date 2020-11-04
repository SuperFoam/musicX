import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_x/model/msg/person_info.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/widgets/local_or_network_image.dart';

class ChatInfoPage extends StatefulWidget {
  final String userId;

  ChatInfoPage({@required this.userId});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChatInfoPageState();
  }
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  PersonInfoModel personInfo;
  double paddingNum = 15.0;
  EdgeInsetsGeometry padding;
  double itemH = 45.0;
  double headW = 50.0;
  double spaceH = 10.0;
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
   return Scaffold(
     //backgroundColor: Color(0xffededed),
     backgroundColor: Theme.of(context).splashColor,
     appBar: AppBar(
       title: Text('聊天信息'),
     ),
     body: SingleChildScrollView(
       child: Column(children: <Widget>[
         head,
        space,
         buildItem('查找聊天记录'),
         space,
         buildItemSwitch('消息免打扰',),
         divider,
         buildItemSwitch('置顶聊天',),
         divider,
         buildItemSwitch('上线提醒',),
         space,
         buildItem('设置聊天背景'),
         space,
         buildItem('清空聊天记录'),
         space,
         buildItem('投诉'),
       ],),
     ),
   );
  }
  Widget get  head {
    return Container(
      color: color,
      padding: EdgeInsets.all(paddingNum),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
        Container(
          width: headW,
          child: Column(
            children: <Widget>[
              Container(
                width: headW,
                height: headW,
                child: xImgRoundRadius(),
              ),
              Text(personInfo.userId,style: TextStyles.text11Grey,maxLines: 1,overflow: TextOverflow.ellipsis,)
            ],
          ),
        ),
        SizedBox(width: 20,),
        Container(width: headW,height: headW,child:
        FDottedLine(
          color: Colors.grey,
          strokeWidth: 1.0,
          dottedLength: 8.0,
          space: 3.0,
          corner: FDottedLineCorner.all(6.0),
          child: Container(
            // color: Colors.blue[100],
            // width: 130,
            height: 100,
            alignment: Alignment.center,
            child: Icon(Icons.add),
          ),
        ),)
      ],),
    );
  }

  Widget buildItem(String title) {
    return Container(
      height: itemH,
      padding: padding,
      color: color,
      child: Row(
        children: <Widget>[
          Text(title),
          Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            size: 15,
          ),
        ],
      ),
    );
  }
  Widget buildItemSwitch(
      String title,
      ) {
    return Container(
      padding: padding,
      color: color,
      height: itemH,
      child: Row(
        children: <Widget>[
          Text(title),
          Spacer(),
          if (title == '消息免打扰')
            CupertinoSwitch(
              value: personInfo.muteNotice,
              onChanged: (value) {
                print(title);
                personInfo.muteNotice = value;
                PersonInfoStorage.put(personInfo.userId,'muteNotice',value);
                setState(() {});
              },
            ),
          if (title == '置顶聊天')
            CupertinoSwitch(
              value: personInfo.topChat,
              onChanged: (value)  {
                personInfo.topChat = value;
                PersonInfoStorage.put(personInfo.userId,'topChat',value);
                setState(() {});

              },
            ),
          if (title == '上线提醒')
            CupertinoSwitch(
              value: personInfo.chatAlert,
              onChanged: (value)  {
                personInfo.chatAlert = value;
                PersonInfoStorage.put(personInfo.userId,'chatAlert',value);
                setState(() {});

              },
            ),
        ],
      ),
    );
  }
  Widget get divider{
    return      Container(
      color: color,
      child:  Divider(indent: paddingNum,thickness: 1,height: 1),
    );
  }
  Widget get space{
    return  SizedBox(height: spaceH,);
  }
}
