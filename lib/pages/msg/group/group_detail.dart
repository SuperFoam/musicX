

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:provider/provider.dart';

class GroupDetailPage extends StatefulWidget{
  final String groupId;

  GroupDetailPage(this.groupId);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GroupDetailPageState();
  }
}

class _GroupDetailPageState extends State<GroupDetailPage>{
  EMGroup group;
  double headW = 50.0;
  double paddingNum = 15.0;
  double itemH = 45.0;
  double arrowIconSize = 13.0;
  EdgeInsetsGeometry padding;
  List admin =List();
  List black = List();
  List mute = List();
  int maxCount;

    @override
  void initState() {
      padding = EdgeInsets.symmetric(horizontal: paddingNum);
      loadGroupInfo();
    super.initState();
  }

  void loadGroupInfo() async {
    if(Provider.of<UserProvider>(context,listen: false).isGuest)return;
    String id = this.widget.groupId;
    group = await EMClient.getInstance().groupManager().getGroup(id);
    admin=group.getAdminList();
    black = group.getBlackList();
    mute = group.getMuteList();
    maxCount = group.getMaxUserCount();
    setState(() {

    });
//    EMClient.getInstance().groupManager().getGroupFromServer(id,onSuccess: (EMGroup group){
//          print(group.getGroupName());
//    print(group.getMembers());
    //  });

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).splashColor,
      appBar: AppBar(
        title: Text('群组详情'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          ListTile(
           contentPadding: padding,
            leading: Container(
              height: headW,
              width: headW,
              child: xImgRoundRadius(),
            ),
            title: Text(group?.getGroupName() ?? '', overflow: TextOverflow.ellipsis),
            subtitle: Text(group?.getGroupId() ?? '', overflow: TextOverflow.ellipsis),
          ),
          Padding(padding: padding,child: Text(group?.getDescription() ?? '',style: TextStyles.text12Grey,),),
           SizedBox(height: 5,),
           Utils.spaceGery(context: context),
            buildShowTitle('群成员上限',subtitle: maxCount?.toString()??null),
            Utils.spaceGery(context: context),
            InkWell(
              onTap: (){
                if(group==null)return;
                String owner = group.getOwner();
                if(owner== Provider.of<UserProvider>(context, listen: false).userId)
                  return;
                NavigatorUtil.goPersonInfoPage(context, group.getOwner());
              },
              child: buildShowTitle('群主',subtitle: group?.getOwner()),
            ),
            Utils.divider(context: context,indent: paddingNum),
            buildShowTitle('群管理员',subtitle: '${admin.length}人'),
            if(admin.length!=0)Padding(
              padding: padding,
              child: buildShowMember(admin),
            ),
            if(admin.length!=0)SizedBox(height: 8,),
            Utils.divider(context: context,indent: paddingNum),
            buildShowTitle('群黑名单',subtitle: '${black.length}人'),
            if(black.length!=0)Padding(
              padding: padding,
              child: buildShowMember(black),
            ),
            if(black.length!=0)SizedBox(height: 8,),
            Utils.divider(context: context,indent: paddingNum),
            buildShowTitle('群禁言名单',subtitle: '${mute.length}人'),
            if(mute.length!=0) Padding(
              padding: padding,
              child: buildShowMember(mute),
            ),
            if(mute.length!=0)SizedBox(height: 8,),

        ],),
      ),
    );
  }
  Widget buildShowTitle(String title, {String subtitle,IconData icon}) {
    return Container(
      height: itemH,
      padding: padding,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: <Widget>[
          Text(title),
          Spacer(),
          if (subtitle != null) Text(subtitle,style: TextStyles.text14Grey,),
          if(icon!=null)Icon(icon,size: 20,),
          SizedBox(
            width: 5,
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: arrowIconSize,
          )
        ],
      ),
    );
  }
  Widget  buildShowMember(List member) {
    double crossAxisSpacing = 8.0;
    List<Widget> children=List.generate(member.length, (index) {
      return Column(
        children: <Widget>[
          Container(
            width: headW,
            height: headW,

            child: xImgRoundRadius(),
          ),
          Text(
            member[index],
            style: TextStyles.text11Grey,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      );
    });
    return GridView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: headW, mainAxisSpacing: 5, crossAxisSpacing: crossAxisSpacing, childAspectRatio: 0.75),
        children: children);


  }
}
