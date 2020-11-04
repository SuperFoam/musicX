import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:music_x/model/msg/address_book.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:music_x/widgets/slide_bar.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class GroupMemberPage extends StatefulWidget {
  final String groupId;

  GroupMemberPage(this.groupId);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GroupMemberPageState();
  }
}


class _GroupMemberPageState extends State<GroupMemberPage> {
  SlideBarLetterListener letterListener = SlideBarLetterListener.create();
  ItemScrollController itemScrollController = ItemScrollController();
  double headW = 35.0;
  double paddingNum = 15.0;
  double itemH = 50.0;
  double letterH = 20.0;
  double dividerH = 1.0;
  double checkBoxW = 20.0;
  EdgeInsetsGeometry padding;
  Map sortPersonData = Map();
  List<AddressBookModel> member = List();
//  List admin = List();
//  List black = List();
//  List mute = List();
  String owner;
  String userId;
  GroupIdentity userIdentity;
 // Color color;
  bool showSearch = false;
  bool showSearchIng = false;
  List<AddressBookModel> searchAddressList = List();
  List<AddressBookModel> selectPerson = List();
  bool showCheckBox=false;
  bool isRemoveMember=false;
  Map letterMemberCount=Map();
  int longPressIndex;

  List<PopupMenuItem<String>> popupItem = [
    PopupMenuItem(
      value: 'remove',
      child: Row(
        children: <Widget>[
          Icon(Icons.delete_outline),
          SizedBox(
            width: 3,
          ),
          Text("移出群聊"),
        ],
      ),
    ),
  ];
  PopupMenuItem<String> setAdmin =    PopupMenuItem(
    value: 'set_admin',
    child: Row(
      children: <Widget>[
        Icon(Icons.person_outline),
        SizedBox(
          width: 3,
        ),
        Text("设为管理员"),
      ],
    ),
  );
  PopupMenuItem<String> cancelAdmin =     PopupMenuItem(
    value: 'cancel_admin',
    child: Row(
      children: <Widget>[
        Icon(Icons.cancel),
        SizedBox(
          width: 3,
        ),
        Text("撤销管理员"),
      ],
    ),
  );
  PopupMenuItem<String> setMute =    PopupMenuItem(
    value: 'set_mute',
    child: Row(
      children: <Widget>[
        Icon(Icons.mic_off),
        SizedBox(
          width: 3,
        ),
        Text("禁止发言"),
      ],
    ),
  );
  PopupMenuItem<String> cancelMute =     PopupMenuItem(
    value: 'cancel_mute',
    child: Row(
      children: <Widget>[
        Icon(Icons.cancel),
        SizedBox(
          width: 3,
        ),
        Text("撤销禁言"),
      ],
    ),
  );
  PopupMenuItem<String> setBlack=    PopupMenuItem(
    value: 'set_black',
    child: Row(
      children: <Widget>[
        Icon(Icons.playlist_add),
        SizedBox(
          width: 3,
        ),
        Text("加入黑名单"),
      ],
    ),
  );
  PopupMenuItem<String> cancelBlack =     PopupMenuItem(
    value: 'cancel_black',
    child: Row(
      children: <Widget>[
        Icon(Icons.cancel),
        SizedBox(
          width: 3,
        ),
        Text("撤销黑名单"),
      ],
    ),
  );
  PopupMenuItem<String> addFriend=    PopupMenuItem(
    value: 'add_friend',
    child: Row(
      children: <Widget>[
        Icon(Icons.person_add),
        SizedBox(
          width: 3,
        ),
        Text("加为好友"),
      ],
    ),
  );

  @override
  void initState() {
    loadGroupInfo();
    padding = EdgeInsets.symmetric(horizontal: paddingNum);
    letterListener.slideLetter.addListener(onLetterChange);
    popupItem.addAll([setMute,setAdmin,setBlack,addFriend]);
    super.initState();
  }

  @override
  void dispose() {
    letterListener.slideLetter.removeListener(onLetterChange);
    super.dispose();
  }

  void handleOther({List data,List mute,String type}){
    List<AddressBookModel> adminModel = List();
    if(type=='black' && data.length>0){
      String letter = "黑名单";
      Map<String, dynamic> data = {
        "name": letter,
        "type": ContactTypeEnum.LETTER,
      };
      sortPersonData[letter] = member.length;
      AddressBookModel t = AddressBookModel.fromJson(data);
      member.add(t);
    }
    data.forEach((userId) {
      String pinyin = PinyinHelper.getShortPinyin(userId).toUpperCase();
      //String letter = pinyin.substring(0, 1);
      Map<String, dynamic> data = {
        "name": userId,
        "id": userId,
       // "type": ContactTypeEnum.ADMIN,
        'pinyin': pinyin,
       // 'isBlack':black.contains(userId),
        'isMute':mute.contains(userId),
      };
      if(type=='admin')
        data['type']=ContactTypeEnum.ADMIN;
      else if(type=='black'){
        data['type']=ContactTypeEnum.PERSON;
        data['isBlack']=true;
      }

      AddressBookModel t = AddressBookModel.fromJson(data);
      adminModel.add(t);
    });
    adminModel.sort((a, b) => a.pinyin.compareTo(b.pinyin));
    if (adminModel.isNotEmpty) adminModel.last.isLast = true;
    member.addAll(adminModel);
  }

  void loadGroupInfo() async {
    if(Provider.of<UserProvider>(context,listen: false).isGuest)return;
    member.clear();
    userId = Provider.of<UserProvider>(context,listen: false).userId;
    String id = this.widget.groupId;
    EMGroup group = await EMClient.getInstance().groupManager().getGroup(id);
    owner = group.getOwner();
    List memberT = group.getMembers();
    List admin = group.getAdminList();
    List black = group.getBlackList();
    List mute = group.getMuteList();
    print(admin);
    print(black);
    if(owner==userId)
      userIdentity=GroupIdentity.OWNER;
    else if(admin.contains(userId))
      userIdentity=GroupIdentity.ADMIN;
    else
      userIdentity=GroupIdentity.MEMBER;


    String letter = "群主及管理员";
    Map<String, dynamic> data = {
      "name": letter,
      "type": ContactTypeEnum.LETTER,
    };
    sortPersonData[letter] = member.length;
    AddressBookModel t = AddressBookModel.fromJson(data);
    member.add(t);
    Map<String, dynamic> ownerData = {
      "name": owner,
      "id": owner,
      "type": ContactTypeEnum.OWNER,
      'pinyin': PinyinHelper.getShortPinyin(owner).toUpperCase(),
    };
    AddressBookModel ownerModel = AddressBookModel.fromJson(ownerData);
    member.add(ownerModel);
    if(admin.length>0)handleOther(data: admin,type: 'admin',mute: mute);
    else
      member.last.isLast = true;
    handleOther(data: black,type: 'black',mute: mute);

    Map<String, List> sortData = Map();
    memberT.forEach((userId) {
      String pinyin = PinyinHelper.getShortPinyin(userId).toUpperCase();
      String letter = pinyin.substring(0, 1);
      Map<String, dynamic> data = {
        "name": userId,
        "id": userId,
        "type": ContactTypeEnum.PERSON,
        'pinyin': pinyin,
        'isBlack':black.contains(userId),
        'isMute':mute.contains(userId),
      };
      AddressBookModel t = AddressBookModel.fromJson(data);
      if (sortData[letter] == null) sortData[letter] = List<AddressBookModel>();
      sortData[letter].add(t);
    });
    List keys = sortData.keys.toList();
    keys.sort((a, b) => a.compareTo(b));
    keys.forEach((letter) {
      List<AddressBookModel> person = sortData[letter];
      // person.sort((a,b)=>a.pinyin.compareTo(b.pinyin));
      Map<String, dynamic> data = {
        "name": letter,
        "type": ContactTypeEnum.LETTER,
      };
      AddressBookModel t = AddressBookModel.fromJson(data);
      sortPersonData[letter] = member.length;
      member.add(t);

      person.last.isLast = true;
      member.addAll(person);
      letterMemberCount[letter]=person.length;
    });
    print(member);

    setState(() {});
  }

  void onLetterChange() {
    String letter = letterListener.slideLetter.value;
    print('字母变化了 $letter');
    if (letter == '↑') {
      itemScrollController.jumpTo(index: 0);
      return;
    }
    int index = sortPersonData[letter];
    if (index == null) return;
    itemScrollController.jumpTo(index: index);
  }

  @override
  Widget build(BuildContext context) {
    //color = Theme;
    return WillPopScope(
      onWillPop: (){
        Navigator.of(context).pop(isRemoveMember);
        return  Future.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
       backgroundColor: Theme.of(context).splashColor,
       // backgroundColor: Colours.wx_bg,
        appBar: AppBar(
          title: Text('群成员'),
          actions: <Widget>[
            if(userIdentity==GroupIdentity.OWNER || userIdentity == GroupIdentity.ADMIN)FlatButton(
                child: Text(!showCheckBox?'批量操作':'取消'),
                textColor: Colors.white,
                padding: EdgeInsets.all(0),
                onPressed: () {
                  showCheckBox=!showCheckBox;
                  setState(() {

                  });
                }
            ),
            if(showCheckBox && selectPerson.length>0)
              FlatButton(
                  child: Text('移出${selectPerson.length}'),
                  textColor: Colors.white,
                  onPressed: () {
                    removeMember();

                  }
              ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: paddingNum, vertical: 8),
                  height: itemH,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TextField(
                    onChanged: (value) {
                      if (value.length > 0) {
                        setState(() {
                          showSearch = true;
                          showSearchIng = true;
                        });
                        Future.delayed(Duration(milliseconds: 10)).then((e) => searchValue(value));
                      } else {
                        showSearch = false;
                        setState(() {});
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0.0),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                      fillColor: Color(0x30cccccc),
                      filled: true,
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x00FF0000)), borderRadius: BorderRadius.all(Radius.circular(100))),
                      hintText: '搜索',
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x00000000)), borderRadius: BorderRadius.all(Radius.circular(100))),
                    ),
                  ),
                ),
                Expanded(
                  child: showSearch == true ? buildSearchContact : buildShowContact,
                ),

              ],
            ),
            if (showSearch == false)
              Align(
                alignment: Alignment.centerRight,
                child: SliderBarPage(
                  letterNotifier: letterListener,
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget get buildShowContact {
    if (member.length == 0)
      return Center(
        child: CupertinoActivityIndicator(
          radius: 10,
        ),
      );
    return buildContactList(member);
  }

  Widget buildTag(String tag) {
    return Container(
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.35), borderRadius: BorderRadius.circular(5.0)),
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Text(
          tag,
          style: TextStyle(fontSize: 11),
        ));
  }

  Widget get buildSearchContact {
    print('showSearchIng is $showSearchIng');
    if (showSearchIng == true) {
      print('展示loading------------');
      return Center(
        child: CupertinoActivityIndicator(
          radius: 10,
        ),
      );
    }

    if (searchAddressList.length == 0)
      return Center(
        child: Text('未找到相关结果'),
      );
    return buildContactList(searchAddressList);
  }

  Widget buildContactList(List<AddressBookModel> dataList) {
    return ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        itemCount: dataList.length,
        itemBuilder: (context, int index) {
          return GestureDetector(
            onTap: () {
              //toggleSelect(dataList, index);
            },
            onLongPressStart: (LongPressStartDetails details){
              onLongPressConversation(details,index);
            },
            child: buildItem(dataList, index),
          );
        });
  }

  Widget buildItem(List<AddressBookModel> dataList, int index) {
    return Column(
      children: <Widget>[
        if (dataList[index].type == ContactTypeEnum.LETTER)
          Container(
            height: letterH,
            width: double.infinity,
            //color: Colours.wx_bg,
            color: Theme.of(context).splashColor,
            padding: EdgeInsets.only(left: paddingNum),
            alignment: Alignment.centerLeft,
            child: Text(
              dataList[index].name,
              style: TextStyle(fontSize: 12),
            ),
          ),
        if (dataList[index].type != ContactTypeEnum.LETTER)
          Container(
            height: itemH,
            padding: EdgeInsets.only(left: paddingNum),
            color: longPressIndex==index?Colors.grey.withOpacity(0.5):Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: <Widget>[
               if(showCheckBox ) SizedBox(
                  width: 20,
                  child: Checkbox(

                    value: selectPerson.contains(dataList[index]) ?? false,
                    onChanged: owner==dataList[index].id?null:(value) {
                     toggleSelect(dataList[index]);
                    },
                  ),
                ),
                SizedBox(
                  width: paddingNum,
                ),
                Container(width: headW, height: headW, child: xImgRoundRadius()),
                SizedBox(
                  width: paddingNum,
                ),
                Flexible(child: Text(dataList[index].name ?? '#未知',maxLines: 1,overflow: TextOverflow.ellipsis,),),
                if(member[index].id==userId)
                  buildTag('我'),
                if (member[index].type == ContactTypeEnum.OWNER)
                  buildTag('群主'),
                if (member[index].type == ContactTypeEnum.ADMIN)
                  buildTag('管理员'),
                if(member[index].isBlack==true)
                  buildTag('黑名单'),
                if(member[index].isMute==true)
                  buildTag('已禁言'),
                SizedBox(width: 15,),
              ],
            ),
          ),
        if (dataList[index].type != ContactTypeEnum.LETTER && dataList[index].isLast != true)
          Utils.divider(context: context,indent: paddingNum  + paddingNum + headW + paddingNum+ (showCheckBox?checkBoxW:0)),
//         Row(children: [
//           Container(
//             width:  paddingNum  + paddingNum + headW + paddingNum+ (showCheckBox?checkBoxW:0),
//             height: dividerH,
//             color: Theme.of(context).scaffoldBackgroundColor,
//           ),
//          Expanded(child:  Divider(
//            //indent: paddingNum  + paddingNum + headW + paddingNum+ (showCheckBox?checkBoxW:0),
//            thickness: dividerH,
//            height: dividerH,
//            // color: Colours.wx_bg,
//          ),)
//         ],)
      ],
    );
  }

  Future<void> searchValue(String value) async {
    searchAddressList.clear();
    searchAddressList = member.where((element) {
      int firstS = value.substring(0, 1).toLowerCase().codeUnits.first;
      if (firstS >= 97 && firstS <= 122) return PinyinHelper.getPinyinE(element.name, separator: '').contains(value.toLowerCase());
      return element.name.contains(value);
    }).toList();

    showSearchIng = false;
    setState(() {});
  }
  void toggleSelect(AddressBookModel value) {
    if (selectPerson.contains(value))
      selectPerson.remove(value);
    else
      selectPerson.add(value);
    setState(() {});
  }
  void removeMember(){
    Funs.showCustomDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text('确认移除${selectPerson.length}个成员吗',style: TextStyles.textDialogTitle,),
        actions: <Widget>[
          FlatButton(
            child: Text("取消"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text("确定"),
            onPressed: ()  {
              selectPerson.forEach((userModel) {
                EMClient.getInstance().groupManager().removeUserFromGroup(this.widget.groupId, userModel.id);

                if(userModel.type== ContactTypeEnum.PERSON ){
                  String letter = userModel.pinyin.substring(0,1).toUpperCase();
                  int count=letterMemberCount[letter];
                  count-=1;
                  letterMemberCount[letter]=count;
                  if(count==0)
                    member.removeWhere((element) => element.name==letter);
                }

                member.removeWhere((element) => element.id==userModel.id);
              });
              selectPerson.clear();
              Navigator.of(context).pop();
              Utils.showToast('移出成功');
              isRemoveMember=true;
              showCheckBox=false;

              setState(() {

              });

            },
          ),
        ],
      );
    });
  }
  void onLongPressConversation(LongPressStartDetails details, int index) async {
    if(member[index].type== ContactTypeEnum.OWNER)return;
    if(userIdentity ==null || userIdentity==GroupIdentity.MEMBER)return;
    setState(() {
      longPressIndex = index;
    });
    popupItem.forEach((element) {
      print(element.value);
    });
    if(member[index].isMute==true )
      popupItem[1]=cancelMute;
    else
      popupItem[1]=setMute;
    if(member[index].type==ContactTypeEnum.ADMIN)
      popupItem[2]=cancelAdmin;
    else
      popupItem[2]=setAdmin;
    if(member[index].isBlack==true)
      popupItem[3]=cancelBlack;
    else
      popupItem[3]=setBlack;


    String res = await showCustomPopupMenu(longPressDetail: details, popupItem: popupItem, context: context, );
    print('res is $res');
    longPressIndex = null;
    if (res == null) {
      setState(() {});
      return;
    }
    if(res=='remove'){
      selectPerson.clear();
      selectPerson.add(member[index]);
      removeMember();

    }
    else if(res=='set_admin'){
      if(userIdentity!=GroupIdentity.OWNER){
        setState(() {});
        Utils.showToast('无权操作');
        return;
      }
      EMClient.getInstance().groupManager().addGroupAdmin( this.widget.groupId,  member[index].id,
          onSuccess: (EMGroup group){
        Utils.showToast('设置管理员成功');
        loadGroupInfo();
      });//需异部处理
    }
    else if(res=='cancel_admin'){
      if(userIdentity!=GroupIdentity.OWNER){
        setState(() {});
        Utils.showToast('无权操作');
        return;
      }
      EMClient.getInstance().groupManager().removeGroupAdmin( this.widget.groupId,  member[index].id,
          onSuccess: (EMGroup group){
            Utils.showToast('撤销管理员成功');
            loadGroupInfo();
          });//需异部处理
    }
    else if(res=='set_mute'){
      if(userIdentity==GroupIdentity.ADMIN && member[index].type==ContactTypeEnum.ADMIN){
        setState(() {});
        Utils.showToast('无权操作');
        return;
      }
      String duration=(1000*60*5).toString();
      EMClient.getInstance().groupManager().muteGroupMembers(this.widget.groupId, [member[index].id], duration,
          onSuccess: (EMGroup group){
            Utils.showToast('禁言成功');
            loadGroupInfo();
          });//需异部处理
    }
    else if(res=='cancel_mute'){

      EMClient.getInstance().groupManager().unMuteGroupMembers(this.widget.groupId, [member[index].id],
          onSuccess: (EMGroup group){
            Utils.showToast('撤销禁言成功');
            loadGroupInfo();
          });//需异部处理
    }
    else if(res=='set_black'){
      if(userIdentity!=GroupIdentity.OWNER){
        setState(() {});
        Utils.showToast('无权操作');
        return;
      }
      EMClient.getInstance().groupManager().blockUser(this.widget.groupId, member[index].id,
          onSuccess: (){
        isRemoveMember=true;
            Utils.showToast('加入黑名单成功');
            loadGroupInfo();
          });//需异部处理
    }
    else if(res=='cancel_black'){
      if(userIdentity!=GroupIdentity.OWNER){
        Utils.showToast('无权操作');
        setState(() {});
        return;
      }
      EMClient.getInstance().groupManager().unblockUser(this.widget.groupId, member[index].id,
          onSuccess: (){
            isRemoveMember=true;
            Utils.showToast('撤销黑名单成功');
            loadGroupInfo();
          });//需异部处理
    }
    setState(() {});

  }
}
