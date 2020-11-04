import 'dart:collection';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:music_x/model/msg/address_book.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/utils/random_name.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:music_x/widgets/slide_bar.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CreateGroupPage extends StatefulWidget {
    final String action;
  CreateGroupPage({this.action='create_group'});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CreateGroupPageState();
  }
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  double itemH = 50.0;
  double paddingNum = 15.0;
  double letterH = 20.0;
  double headW = 35.0;
  double dividerH = 1.0;
  double checkBoxW = 20.0;
  EdgeInsetsGeometry padding;
  ItemScrollController itemScrollController = ItemScrollController();
  List<AddressBookModel> addressList = List();
  List<AddressBookModel> searchAddressList = List();
  SlideBarLetterListener letterListener = SlideBarLetterListener.create();
  Map sortPersonData = Map();
  int maxPersonCount = 10000;
  LinkedHashMap<int,AddressBookModel> selectPerson = LinkedHashMap();
  bool showSearch = false;
  bool showSearchIng = false;
  bool showLoading=true;
  String action;
  String addGroupMember='add_group_member';
  String groupId;
  List member=List();
  bool groupMemberChange = false;

  @override
  void initState() {
    padding = EdgeInsets.symmetric(horizontal: paddingNum);
    loadRealFriend();
    print('CreateGroupPage init');
    List actionT = this.widget.action.split('-');
    action=actionT.first;
    if(action==addGroupMember){
       groupId=actionT[1];
      loadGroupInfo();
    }
    letterListener.slideLetter.addListener(onLetterChange);
    super.initState();
    print('this.widget.action is $action');
  }

  @override
  void dispose() {
    letterListener.slideLetter.removeListener(onLetterChange);
    super.dispose();
  }
  void loadGroupInfo()async{
    if(Provider.of<UserProvider>(context,listen: false).isGuest)return;
    if(groupId==null)return;
    EMGroup group = await EMClient.getInstance().groupManager().getGroup(groupId);
    member.add(group.getOwner());
     member = group.getMembers()+group.getAdminList();

     print('member is $member');
     setState(() {

     });
  }
  void onLetterChange() {
    String letter = letterListener.slideLetter.value;
    print('字母变化了 $letter');
    jumpLetter(letter);
  }

  void jumpLetter(String letter) {
    if (letter == '↑') {
      itemScrollController.jumpTo(index: 0);
      return;
    }
    int index = sortPersonData[letter];
    if (index == null) return;
    itemScrollController.jumpTo(index: index);
  }


  void loadRealFriend(){
    if(Provider.of<UserProvider>(context,listen: false).isGuest){
      loadVirtualFriend();
      return;
    }
    EMClient.getInstance().contactManager().getAllContactsFromServer(
        onSuccess: (List<String> contacts){
          print('contacts is $contacts');
          addressList.clear();
          if(contacts.length==0){
            Utils.showToast('暂无好友');
            showLoading=false;
            setState(() {

            });
            return;
          }

          Map<String, List> sortData = Map();
          contacts.forEach((userId) {
            String pinyin = PinyinHelper.getShortPinyin(userId).toUpperCase();
            String letter = pinyin.substring(0, 1);
            Map<String, dynamic> data = {
              "name": userId,
              "id":userId,
              "type": ContactTypeEnum.PERSON,
              'pinyin': pinyin,
            };
            AddressBookModel t = AddressBookModel.fromJson(data);

            if (sortData[letter] == null) sortData[letter] = List<AddressBookModel>();
            sortData[letter].add(t);
          });
          List keys = sortData.keys.toList();
          keys.sort((a, b) => a.compareTo(b));
          keys.forEach((element) {
            List<AddressBookModel> person = sortData[element];
            // person.sort((a,b)=>a.pinyin.compareTo(b.pinyin));
            Map<String, dynamic> data = {
              "name": element,
              "type": ContactTypeEnum.LETTER,
            };
            AddressBookModel t = AddressBookModel.fromJson(data);
            sortPersonData[element] =  addressList.length;
            addressList.add(t);

            person.last.isLast = true;
            addressList.addAll(person);
            showLoading=false;
            setState(() {

            });
          });

        }

    );
  }

  void loadVirtualFriend() async {
    var res = await compute(handlePerson, maxPersonCount);
    sortPersonData = res[0];
    addressList = res[1];
    showLoading=false;
    setState(() {});
  }
  static handlePerson(int maxPersonCount) {
    List<AddressBookModel> addressList = List();
    Map sortPersonData = Map();

    Map<String, List> sortData = Map();
    for (int i = 0; i < maxPersonCount; i++) {
      String name = ChineseName.getRandomName();
      String pinyin = PinyinHelper.getShortPinyin(name).toUpperCase();
      String letter = pinyin.substring(0, 1);
      Map<String, dynamic> data = {
        "name": name,
        "type": ContactTypeEnum.PERSON,
        'pinyin': pinyin,
        "id":name,
      };
      AddressBookModel t = AddressBookModel.fromJson(data);

      if (sortData[letter] == null) sortData[letter] = List<AddressBookModel>();
      sortData[letter].add(t);
    }
    List keys = sortData.keys.toList();
    keys.sort((a, b) => a.compareTo(b));
    keys.forEach((element) {
      List<AddressBookModel> person = sortData[element];
      // person.sort((a,b)=>a.pinyin.compareTo(b.pinyin));
      Map<String, dynamic> data = {
        "name": element,
        "type": ContactTypeEnum.LETTER,
      };
      AddressBookModel t = AddressBookModel.fromJson(data);
      sortPersonData[element] = addressList.length;
      addressList.add(t);

      person.last.isLast = true;
      addressList.addAll(person);
    });
    print(sortPersonData);
    return [sortPersonData, addressList];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print('addressList length is ${addressList.length}');
    return WillPopScope(
        onWillPop: (){
          Navigator.of(context).pop(groupMemberChange);
          return  Future.value(true);
        },
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
         // backgroundColor: Colours.wx_bg,
          backgroundColor: Theme.of(context).splashColor,
          appBar: AppBar(
            title: Text('选择联系人'),
            titleSpacing: 0.0,
            actions: <Widget>[
              if(action=='create_group')
                FlatButton(
                  child: Text('创建'),
                  textColor: Colors.white,
                  onPressed: selectPerson.length > 0 ? () {
                    createGroup();
                  } : null,
                ),
              if(action=='add_group_member')
                FlatButton(
                  child: Text('邀请'),
                  textColor: Colors.white,
                  onPressed: selectPerson.length > 0 ? () {
                    addMemberToGroup();
                  } : null,
                )
            ],
          ),
          body: Stack(
            children: <Widget>[
              buildMain,
              if(showSearch==false)Align(
                alignment: Alignment.centerRight,
                child: SliderBarPage(
                  letterNotifier: letterListener,
                ),
              )
            ],
          )),
    );

  }

  Widget get buildMain {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: itemH,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TextField(
            decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: '搜索', border: InputBorder.none),
            onChanged: (value) {
             if(value.length>0){

               setState(() {
                 showSearch=true;
                 showSearchIng=true;
               });
               Future.delayed(Duration(milliseconds: 10)).then((e) => searchValue(value));

             }else{
               showSearch=false;
               setState(() {

               });
             }
            },
          ),
        ),
        Utils.divider(context: context),
        Container(
          height: itemH,
          padding: padding,
          color: Theme.of(context).scaffoldBackgroundColor,
          alignment: Alignment.centerLeft,
          child: selectPerson.length > 0
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: List.generate(selectPerson.length, (index) {
                    return InkWell(
                      onTap: () {
                        int key = selectPerson.keys.toList()[index];
                        selectPerson.remove(key);
                        setState(() {});
                      },
                      child: Row(
                        children: <Widget>[
                          Container(width: headW, height: headW, child: xImgRoundRadius()),
                          SizedBox(
                            width: paddingNum,
                          ),
                          if (selectPerson.length == 1)
                            Text(
                              '点击头像取消选取',
                              style: TextStyles.text14Grey,
                            ),
                        ],
                      ),
                    );
                  })),
                )
              : Text(
                  '选取的朋友在这里展示',
                  style: TextStyles.text14Grey,
                ),
        ),
        Expanded(
          child: showSearch==true?buildSearchContact:buildShowContact,
        )
      ],
    );
  }

  Widget get buildSearchContact {
   // print('showSearchIng is $showSearchIng');
    if (showSearchIng==true){
      print('展示loading------------');
      return Center(
        child: CupertinoActivityIndicator(
          radius: 10,
        ),
      );
    }

    if(searchAddressList.length==0)
      return Center(
        child: Text('未找到相关结果'),
      );
    return buildContactList(searchAddressList);
  }

  Widget get buildShowContact {
   // print('showLoading is $showLoading');
    if (showLoading==true)
      return Center(
        child: CupertinoActivityIndicator(
          radius: 10,
        ),
      );
    if(addressList.length==0)
      return Center(
        child: Text('检讨一下自己，为什么这里空无一人'),
      );
    return buildContactList(addressList);
//    return ScrollablePositionedList.builder(
//        itemScrollController: itemScrollController,
//        itemCount: addressList.length,
//        itemBuilder: (context, int index){
//          return InkWell(
//            onTap: (){
//              toggleSelect(index);
//
//            },
//            child: buildItem(index),
//          );
//        }
//    );
  }

  Widget buildContactList(List<AddressBookModel> dataList) {
    return ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        itemCount: dataList.length,
        itemBuilder: (context, int index) {
          return InkWell(
            onTap: () {
              toggleSelect(dataList, index);
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
            //color: Colors.white,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 20,
                  child: Checkbox(

                    value:member.contains(dataList[index].id)?true: selectPerson.containsKey(index) ?? false,
                    onChanged: member.contains(dataList[index].id)?null:(value) {
                      toggleSelect(dataList, index);
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
                Text(dataList[index].name ?? '#未知'),
              ],
            ),
          ),
        if (dataList[index].type != ContactTypeEnum.LETTER && dataList[index].isLast != true)
          Utils.divider(context: context,indent:paddingNum + checkBoxW + paddingNum + headW + paddingNum ),
      ],
    );
  }

  void toggleSelect(dataList, index) {
    if(member.contains(dataList[index].id))return;
    if(dataList[index].type!=ContactTypeEnum.PERSON )return;
    if (selectPerson.containsKey(index))
      selectPerson.remove(index);
    else
      selectPerson[index] = dataList[index];
    setState(() {});
  }
  Future<void> searchValue(String value) async{

    searchAddressList.clear();
    searchAddressList = addressList.where((element) {
      int firstS=value.substring(0,1).toLowerCase().codeUnits.first;
      if (firstS>=97 && firstS <=122)
        return PinyinHelper.getPinyinE(element.name,separator: '').contains(value.toLowerCase());
      return element.name.contains(value);
    }).toList();

    showSearchIng=false;
    setState(() {

    });
  }
  void createGroup(){
    if(Provider.of<UserProvider>(context,listen: false).isGuest)return;
    EMGroupOptions option = new EMGroupOptions();
    option.maxUsers = 200;
    option.style = EMGroupStyle.EMGroupStylePublicJoinNeedApproval;
    String groupName = "群聊-${DateUtil.getNowDateMs()}";
    String desc = "测试群聊-${DateUtil.getNowDateStr()}";
    List<String>  allMembers = selectPerson.values.map((e) {
      return e.id;
    }).toList();
    print(allMembers);
    String reason = "聊2块钱的";
    EMClient.getInstance().groupManager().createGroup(groupName, desc, allMembers, reason, option,onSuccess:(EMGroup group)async{
      Utils.showToast('创建成功');
      Map params = {
        "master": await EMClient.getInstance().getCurrentUser(),
        'slave':allMembers
      };
      EMMessage message = EMMessage.createCustomSendMessage(userName:group.getGroupId(),event: CustomIMType.JOIN_GROUP.index.toString(),params: params);
      message.chatType = ChatType.GroupChat;
      print('-----------LocalID---------->' + message.msgId);
      EMClient.getInstance().chatManager().sendMessage(message, onSuccess: () {
        print('-----------ServerID---------->' + message.msgId);
        print('-----------MessageStatus---------->' + message.status.toString());
      }, onError: (int code, String desc) {
        print('发送失败$code,$desc');
      });
      Navigator.of(context).pop(true);
    });
  }
  void addMemberToGroup(){
    List<String>  allMembers = selectPerson.values.map((e) {
      return e.id;
    }).toList();
    EMClient.getInstance().groupManager().addUsersToGroup(groupId, allMembers,onSuccess: (){
      groupMemberChange=true;

      Utils.showToast('邀请成功');
      Navigator.of(context).pop(true);
    },onError: (int errorCode, String desc){
      Utils.showToast('邀请失败-$desc');
    });//需异步处理
  }
}
