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

class GroupInfoPage extends StatefulWidget {
  final String groupId;

  GroupInfoPage(this.groupId);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GroupInfoPageState();
  }
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  EMGroup group;
  double headW = 50.0;
  double paddingNum = 15.0;
  double itemH = 45.0;
  double arrowIconSize = 13.0;
  EdgeInsetsGeometry padding;
  int pageSize = 10;
  int cursor = 0;
  List<String> member = List();
  String owner;
  String userId;
  String notice='';

  @override
  void initState() {
    padding = EdgeInsets.symmetric(horizontal: paddingNum);
    loadGroupInfo();
    userId = Provider.of<UserProvider>(context, listen: false).userId;
    super.initState();
  }

  void loadGroupInfo() async {
    if(Provider.of<UserProvider>(context,listen: false).isGuest)return;
    String id = this.widget.groupId;
    group = await EMClient.getInstance().groupManager().getGroup(id);
    owner = group.getOwner();
        EMClient.getInstance().groupManager().fetchGroupAnnouncement(this.widget.groupId,onSuccess:(String announcement){
          notice=announcement;
          setState(() {

          });
      print('notice000 is $notice,${notice == ''}');
    });
//    EMClient.getInstance().groupManager().getGroupFromServer(id,onSuccess: (EMGroup group){
//          print(group.getGroupName());
//    print(group.getMembers());
    //  });
    String cursor = "";
    EMClient.getInstance().groupManager().fetchGroupMembers(id, cursor, pageSize, onSuccess: (EMCursorResult result) {
      print(result.getData());
      member = result.getData();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('群组信息'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              //  isThreeLine: false,
              leading: Container(
                height: headW,
                width: headW,
                child: xImgRoundRadius(),
              ),
              title: Text(group?.getGroupName() ?? '', overflow: TextOverflow.ellipsis),
              subtitle: Text(group?.getDescription() ?? '', overflow: TextOverflow.ellipsis),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: arrowIconSize,
              ),
              onTap: () {
                NavigatorUtil.goGroupDetailPage(context, this.widget.groupId);
              },
            ),
            Utils.spaceGery(context: context),
            InkWell(
              onTap: () {
                NavigatorUtil.goGroupMemberPage(context, this.widget.groupId).then((value) {
                  if (value == true) loadGroupInfo();
                });
              },
              child: buildShowTitle('群成员', subtitle: '${member.length}人'),
            ),
            if (member.length > 0)
              Padding(
                padding: padding,
                child: buildShowMember,
              ),
            if (member.length > 0)
              SizedBox(
                height: 8,
              ),
           Utils.divider(context: context,indent: paddingNum),
            InkWell(
              onTap: ()async{
                bool groupMemberChange =await NavigatorUtil.goCreateGroupPage(context,action: 'add_group_member-${this.widget.groupId}');
                if(groupMemberChange==true)
                  loadGroupInfo();

                },
              child: buildShowTitle('邀请加入', icon: Icons.add),
            ),
            if (owner != null && owner == userId)
              Utils.divider(context: context,indent: paddingNum),
            if (owner != null && owner == userId) buildShowTitle('挥泪移除', icon: Icons.remove),
            Utils.spaceGery(context: context),
            InkWell(
              onTap: ()async{
                bool noticeChange =await NavigatorUtil.goGroupNoticePage(context,this.widget.groupId);
                if(noticeChange==true)
                  loadGroupInfo();

              },
              child: buildShowNotice(),
            ),
           Utils.divider(context: context,indent: paddingNum),
            buildShowTitle('群二维码', icon: Icons.qr_code),
           Utils.divider(context: context,indent: paddingNum),
            buildShowTitle('群文件', icon: Icons.insert_drive_file),
            if (owner != null && owner == userId)
              Utils.divider(context: context,indent: paddingNum),
            if (owner != null && owner == userId) buildShowTitle('群管理', icon: Icons.build),
            Utils.spaceGery(context: context),
            buildShowTitle('查找聊天记录', icon: Icons.search),
            Utils.spaceGery(context: context),
            buildItemSwitch('消息免打扰'),
           Utils.divider(context: context,indent: paddingNum),
            buildItemSwitch('置顶聊天'),
           Utils.divider(context: context,indent: paddingNum),
            buildItemSwitch('显示群成员昵称'),
            Utils.spaceGery(context: context),
            buildShowTitle('清空聊天记录', icon: Icons.delete_forever),
            Utils.spaceGery(context: context),
            InkWell(
              onTap: (){
                quitGroup();
              },
              child: Container(
                  padding: padding,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: itemH,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    '删除退出',
                    style: TextStyle(color: Colors.red),
                  )),
            ),
            Utils.spaceGery(context: context),
          ],
        ),
      ),
    );
  }

  Widget buildItemSwitch(String title, {bool status = false}) {
    return Container(
        height: itemH,
        padding: padding,
        child: Row(
          children: <Widget>[
            Text(title),
            Spacer(),
            CupertinoSwitch(
              value: status,
              onChanged: (value) {},
            ),
          ],
        ));
  }

  Widget buildShowNotice() {
    return Padding(
        padding: padding,
        child: Container(
          margin: EdgeInsets.only(bottom: notice != ''?5:0),
          constraints: BoxConstraints(minHeight: itemH),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('群公告'),
                    if(notice != '')Text(
                      notice,
                      style: TextStyles.text12Grey,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 5,
              ),
              //Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: arrowIconSize,
              )
            ],
          ),
        ));
  }

  Widget buildShowTitle(String title, {String subtitle, IconData icon}) {
    return Container(
      height: itemH,
      padding: padding,
      child: Row(
        children: <Widget>[
          Text(title),
          Spacer(),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyles.text14Grey,
            ),
          if (icon != null)
            Icon(
              icon,
              size: 20,
            ),
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

  Widget get buildShowMember {
    double crossAxisSpacing = 8.0;
    List<Widget> children = List.generate(member.length, (index) {
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
    //   int crossAxisCount = (MediaQuery.of(context).size.width-paddingNum*2) ~/ (headW + crossAxisSpacing);
//    List memberT;
//    int showUserCount;
//    String userId = Provider.of<UserProvider>(context, listen: false).userId;
//    if (owner == userId)
//      showUserCount = crossAxisCount - 2;
//    else
//      showUserCount = crossAxisCount - 1;
//    print('showUserCount is $showUserCount');
//    if (member.length <= showUserCount)
//      memberT = member;
//    else
//      memberT = member.sublist(0, showUserCount);
//    List<Widget> children=List.generate(memberT.length, (index) {
//      return Container(
//        margin: EdgeInsets.only(right: crossAxisSpacing),
//        child: Column(
//        children: <Widget>[
//          Container(
//            width: headW,
//            height: headW,
//
//            child: xImgRoundRadius(),
//          ),
//          Text(
//            memberT[index],
//            style: TextStyles.text11Grey,
//            maxLines: 1,
//            overflow: TextOverflow.ellipsis,
//          )
//        ],
//      ),);
//    });
//    Widget add =    Container(
//      width: headW,
//      height: headW,
//      margin: EdgeInsets.only(right: crossAxisSpacing),
//      decoration: BoxDecoration(
//        // border: Border.all(color: Colors.grey,width: 0.5)
//          color: Colors.grey.withOpacity(0.35),
//          shape: BoxShape.circle
//      ),
//      child: IconButton(
//        icon: Icon(Icons.add),
//        onPressed: (){},
//      ),
//    );
//    children.add(add);
//    if(owner == userId){
//      Widget remove =    Container(
//        width: headW,
//        height: headW,
//        decoration: BoxDecoration(
//          // border: Border.all(color: Colors.grey,width: 0.5)
//            color: Colors.grey.withOpacity(0.35),
//            shape: BoxShape.circle
//        ),
//        child: IconButton(
//          icon: Icon(Icons.remove),
//          onPressed: (){},
//        ),
//      );
//      children.add(remove);
//    }
//    return Row(
//      crossAxisAlignment: CrossAxisAlignment.start,
//        children: children);
  }
  void quitGroup(){
    if(owner==null )return;
    String title;
    if(owner==userId)
      title='确定要解散群组吗';
    else
      title='确定要退出群组吗';
    void quitSuccess(){
      Utils.showToast('操作成功');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop(true);

    }
    void quitFail(int code,String desc){
      Utils.showToast('操作失败-$desc');
      Navigator.of(context).pop();
    }
    Funs.showCustomDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
            title,
              style: TextStyles.textDialogTitle,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('确定'),
                onPressed: () {
                  if(owner==userId){
                    EMClient.getInstance().groupManager().destroyGroup(this.widget.groupId,onSuccess: quitSuccess,onError: quitFail);
                  }
                  else
                    EMClient.getInstance().groupManager().leaveGroup(this.widget.groupId,onSuccess:quitSuccess,onError: quitFail );

                },
              ),
            ],
          );
        });


  }
}
