import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:provider/provider.dart';

class GroupNoticePage extends StatefulWidget {
  final String groupId;

  GroupNoticePage(this.groupId);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GroupNoticePageState();
  }
}

class _GroupNoticePageState extends State<GroupNoticePage> {
  bool noticeUpdate = false;
  String notice = '';
  bool showDone = false;
  bool noticeChange = false;
  GroupIdentity userIdentity;
  TextEditingController _noticeController;

  FocusNode _noticeFocus;

  @override
  void initState() {
    // TODO: implement initState
    loadGroupInfo();
    super.initState();
  }

  @override
  void dispose() {
    _noticeController?.dispose();
    _noticeFocus?.dispose();
    super.dispose();
  }

  void loadGroupInfo() async {
    if(Provider.of<UserProvider>(context,listen: false).isGuest)return;
    if (this.widget.groupId == null) return;
    String userId = Provider.of<UserProvider>(context, listen: false).userId;
//    EMClient.getInstance().groupManager().fetchGroupAnnouncement(this.widget.groupId,onSuccess:(String announcement){
//      print('notice000 is $notice,${notice == ''}');
//    });
    EMGroup group = await EMClient.getInstance().groupManager().getGroup(this.widget.groupId);
    String owner = group.getOwner();
    List admin = group.getAdminList();
    notice = group.getAnnouncement();
    print('notice is $notice,${notice == ''}');
    if (owner == userId)
      userIdentity = GroupIdentity.OWNER;
    else if (admin.contains(userId))
      userIdentity = GroupIdentity.ADMIN;
    else
      userIdentity = GroupIdentity.MEMBER;
    if (userIdentity != GroupIdentity.MEMBER) {
      _noticeController = TextEditingController();
      _noticeFocus = FocusNode();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(noticeUpdate);
        return Future.value(true);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('群公告'),
            actions: <Widget>[
              if ((userIdentity == GroupIdentity.OWNER || userIdentity == GroupIdentity.ADMIN) && !showDone)
                FlatButton(
                    child: Text('编辑'),
                    textColor: Colors.white,
                    onPressed: () {
                      showDone = true;
                      _noticeController.text = notice;
                      setState(() {});
                    }),
              if (showDone == true)
                FlatButton(
                    child: Text('完成'),
                    textColor: Colors.white,
                    onPressed: noticeChange == true
                        ? () {
                            updateToNotice();
                          }
                        : null),
            ],
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              print('点击了');
              if (showDone != true) return;
              if (_noticeFocus.hasFocus)
                _noticeFocus.unfocus();
              else
                FocusScope.of(context).requestFocus(_noticeFocus);
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: SingleChildScrollView(
                child: showDone
                    ? TextField(
                        controller: _noticeController,
                        focusNode: _noticeFocus,
                        decoration: InputDecoration(border: InputBorder.none),
                        onChanged: (value) {
                          if (value.isNotEmpty && value != notice)
                            noticeChange = true;
                          else
                            noticeChange = false;

                          setState(() {});
                        },
                      )
                    : Text(notice),
              ),
            ),
          )),
    );
  }

  void updateToNotice() {
    if (_noticeFocus.hasFocus) _noticeFocus.unfocus();
    Funs.showCustomDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              '确定要发布公告吗',
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
                  EMClient.getInstance().groupManager().updateGroupAnnouncement(this.widget.groupId, _noticeController.text, onSuccess: () {
                   noticeUpdate=true;
                   notice = _noticeController.text;
                   showDone=false;
                    Navigator.of(context).pop();
                    Utils.showToast('发布成功');
                  }, onError: (int errorCode, String desc) {
                    Navigator.of(context).pop();
                    Utils.showToast('发布失败-$desc');
                  });
                },
              ),
            ],
          );
        });
  }
}
