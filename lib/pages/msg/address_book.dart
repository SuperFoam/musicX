import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:music_x/model/msg/address_book.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/utils/random_name.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:music_x/widgets/slide_bar.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AddressBookPageController {
  void Function(String type) switchPersonList;
}

class AddressBookTabBar extends StatefulWidget {
  // final String friendListType;
  final AddressBookPageController childController;

  AddressBookTabBar(this.childController);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AddressBookTabBarState();
  }
}

class _AddressBookTabBarState extends State<AddressBookTabBar> with AutomaticKeepAliveClientMixin {
  String num10000 = '10000联系人';
  String numNormal = '正常联系人';
  double itemH = 50.0;
  double paddingNum = 15.0;
  double headW = 35.0;
  double letterH = 20.0;
  double dividerH = 1.0;

  EdgeInsetsGeometry padding;
  List headList;
  List<AddressBookModel> addressList = List();
  Map sortPersonData = Map();

//  ScrollController _listController = ScrollController();
  ItemScrollController itemScrollController = ItemScrollController();
  String overlayLetter;
  SlideBarLetterListener letterListener = SlideBarLetterListener.create();
  Color color;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

//  _AddressBookTabBarState(AddressBookPageController _childController){
//    _childController.switchPersonList=switchPersonList;
//
//  }

  @override
  void initState() {
    this.widget.childController.switchPersonList = switchPersonList;
    padding = EdgeInsets.symmetric(horizontal: paddingNum);
      loadRealFriend();
    //print(addressList);
    letterListener.slideLetter.addListener(onLetterChange);

    super.initState();
  }

  @override
  void dispose() {
    letterListener.slideLetter.removeListener(onLetterChange);
    super.dispose();
  }
  void loadRealFriend(){
    if(Provider.of<UserProvider>(context,listen: false).isGuest){
      loadUnrealFriend();
      return;
    }
     EMClient.getInstance().contactManager().getAllContactsFromServer(
      onSuccess: (List<String> contacts){
        print('contacts is $contacts');
        addressList.clear();
        initHead();
        if(contacts.length==0){
          Utils.showToast('暂无好友');
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
          setState(() {

          });
        });

      }

    );
  }

  void loadUnrealFriend()async{
    addressList.clear();
    setState(() {

    });
    await Future.delayed(Duration(milliseconds: 10));
    initHead();
    var res = await compute(handlePerson, addressList.length);
    sortPersonData = res[0];
    addressList.addAll(res[1]);
    setState(() {});
  }
  void switchPersonList(String type) {
    print('friendListType is $type');
    if(type == numNormal)
    loadRealFriend();
    else if (type==num10000)
      loadUnrealFriend();
  }

  void onLetterChange() {
    String letter = letterListener.slideLetter.value;
    print('字母变化了 $letter');
    jumpLetter(letter);
  }

  void initHead() {
    headList = [
      {
        "name": "新的朋友",
        "type": ContactTypeEnum.NEW_FRIEND,
        'color': Colors.orangeAccent,
        'icon': Icons.person_add,
      },
      {
        "name": "仅聊天的朋友",
        "type": ContactTypeEnum.ONLY_CHAT,
        'color': Colors.orangeAccent,
        'icon': Icons.chat,
      },
      {
        "name": "群聊",
        "type": ContactTypeEnum.GROUP_CHAT,
        'color': Colors.green,
        'icon': Icons.group,
      },
      {
        "name": "标签",
        "type": ContactTypeEnum.LABEL,
        'color': Colors.blueAccent,
        'icon': Icons.label,
      },
      {
        "name": "公众号",
        "type": ContactTypeEnum.OFFICIAL_ACCOUNT,
        'color': Colors.blueAccent,
        'icon': Icons.verified_user,
        'isLast': true,
      },
    ];
    headList.forEach((element) {
      AddressBookModel t = AddressBookModel.fromJson(element);
      addressList.add(t);
    });
  }



  static handlePerson(int baseLength) {
    List<AddressBookModel> addressList = List();
    Map sortPersonData = Map();
    int max = 10000;
    Map<String, List> sortData = Map();
    for (int i = 0; i < max; i++) {
      String name = ChineseName.getRandomName();
      String pinyin = PinyinHelper.getShortPinyin(name).toUpperCase();
      String letter = pinyin.substring(0, 1);
      Map<String, dynamic> data = {
        "name": name,
        "type": ContactTypeEnum.PERSON,
        'pinyin': pinyin,
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
      sortPersonData[element] = baseLength + addressList.length;
      addressList.add(t);

      person.last.isLast = true;
      addressList.addAll(person);
    });
    print(sortPersonData);
    return [sortPersonData, addressList];
  }

//  void initPerson() {
//    int max = 10000;
//    Map<String, List> sortData = Map();
//    for (int i = 0; i < max; i++) {
//      String name = ChineseName.getRandomName();
//      String pinyin = PinyinHelper.getShortPinyin(name).toUpperCase();
//      String letter = pinyin.substring(0, 1);
//      Map<String, dynamic> data = {
//        "name": name,
//        "type": ContactTypeEnum.PERSON,
//        'pinyin': pinyin,
//      };
//      AddressBookModel t = AddressBookModel.fromJson(data);
//
//      if (sortData[letter] == null) sortData[letter] = List<AddressBookModel>();
//      sortData[letter].add(t);
//    }
//    List keys = sortData.keys.toList();
//    keys.sort((a, b) => a.compareTo(b));
//    keys.forEach((element) {
//      List<AddressBookModel> person = sortData[element];
//      // person.sort((a,b)=>a.pinyin.compareTo(b.pinyin));
//      Map<String, dynamic> data = {
//        "name": element,
//        "type": ContactTypeEnum.LETTER,
//      };
//      AddressBookModel t = AddressBookModel.fromJson(data);
//      sortPersonData[element] = addressList.length;
//      addressList.add(t);
//
//      person.last.isLast = true;
//      addressList.addAll(person);
//    });
//    print(sortPersonData);
//  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    color =Theme.of(context).scaffoldBackgroundColor;
    return Stack(
      children: <Widget>[
        Material(
          color: Theme.of(context).splashColor,
          child: buildContact,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SliderBarPage(
            letterNotifier: letterListener,
          ),
        )
      ],
    );
  }

  Widget get buildContact {
    if (addressList.length ==0)
      return Center(
        child: CupertinoActivityIndicator(
          radius: 10,
        ),
      );
    return ScrollablePositionedList.builder(

        itemScrollController: itemScrollController,
        itemCount: addressList.length,
        itemBuilder: (context, int index) {
          return InkWell(
            onTap: () {
              onTapItem(addressList[index]);
            },
            child: Column(
              children: <Widget>[
                if (addressList[index].type == ContactTypeEnum.LETTER)
                  Container(
                    height: letterH,
                    width: double.infinity,
                    color: Theme.of(context).splashColor,
                    padding: EdgeInsets.only(left: paddingNum),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      addressList[index].name,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                if (addressList[index].type != ContactTypeEnum.LETTER)
                  Container(
                    height: itemH,
                    padding: EdgeInsets.only(left: paddingNum),
                    color: color,

                    child: Row(
                      children: <Widget>[
                        buildHead(addressList[index]),
                        SizedBox(
                          width: paddingNum,
                        ),
                        Container(

                          child:  Text(addressList[index].name),
                        ),

                      ],
                    ),
                  ),

                if (addressList[index].type != ContactTypeEnum.LETTER && addressList[index].isLast != true)
                  Utils.divider(context: context,indent: paddingNum + headW + paddingNum)
//                  Divider(
//                    indent: paddingNum + headW + paddingNum,
//                    thickness: dividerH,
//                    height: dividerH,
//                   // color: Colours.wx_bg,
//                  )
              ],
            ),
          );
        });
  }

  Widget buildHead(AddressBookModel obj) {
    if (obj.type != ContactTypeEnum.PERSON)
      return Container(
        width: headW,
        height: headW,
        color: obj.color,
        child: Icon(
          obj.icon,
          color: Colors.white,
        ),
      );
    else
      return Container(width: headW, height: headW, child: xImgRoundRadius());
  }

  void onTapItem(AddressBookModel obj) {
    if (obj.type == ContactTypeEnum.PERSON) NavigatorUtil.goPersonInfoPage(context, obj.name);
    else if(obj.type == ContactTypeEnum.GROUP_CHAT) NavigatorUtil.goGroupListPage(context);
    return;
    int index = Random().nextInt(sortPersonData.length);
    List keys = sortPersonData.keys.toList();
    String letter = keys[index];
    print(letter);
    itemScrollController.jumpTo(index: sortPersonData[letter]);
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
}
