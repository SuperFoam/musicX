import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:provider/provider.dart';

class GroupListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GroupListPageState();
  }
}

class _GroupListPageState extends State<GroupListPage> {
  List<EMGroup> groupList = List();

  @override
  void initState() {
    loadGroup();
    super.initState();
  }

  void loadGroup() {
    if(Provider.of<UserProvider>(context,listen: false).isGuest)return;
    EMClient.getInstance().groupManager().getJoinedGroupsFromServer(onSuccess: (List<EMGroup> groups) {
      if (groups.length == 0) {
        Utils.showToast('当前无群组');
        return;
      }
      groupList = groups;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('群聊${groupList.length}个'),
      ),
      body: ListView.builder(
          itemCount: groupList.length,
          itemBuilder: (context, int index) {
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                child: xImgRoundRadius(),
              ),
              title: Text(groupList[index].getGroupName()),
              trailing: Icon(Icons.arrow_forward_ios,size: 15,),
              onTap: (){
                NavigatorUtil.goChatRoomPage(context, {"conversationId": groupList[index].getGroupId(),
                  "conversationType": EMConversationType.GroupChat.index});
              },
            );
          }),
    );
  }
}
