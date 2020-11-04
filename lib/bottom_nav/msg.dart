import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/model/msg/conversation.dart';
import 'package:music_x/pages/msg/address_book.dart';
import 'package:music_x/pages/msg/conversation_page.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/custom_show_menu.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:music_x/route/routes.dart';

class MsgPage extends StatefulWidget {
  @override
  _MsgPageState createState() => _MsgPageState();
}

class _MsgPageState extends State<MsgPage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final AddressBookPageController addressBookController = AddressBookPageController();
  final ConversationPageController conversationController = ConversationPageController();
  int count = 0;
  TabController _tabController;
  List tabTitle = ['会话', '朋友'];
  List msgList = [];
  List<Map> popupMenu = [
    {"key": "发起群聊", "value": Icons.chat},
    {"key": "添加朋友", "value": Icons.person_add},
    {"key": "扫一扫", "value": Icons.filter_center_focus},
  ];
  List<PopupMenuEntry<String>> popupItemList = [];
  String num10000 = '10000联系人';
  String numNormal = '正常联系人';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('MsgPage初始化');
    _tabController = TabController(vsync: this, length: tabTitle.length);
    popupMenu.add({"key": num10000, "value": Icons.person});
    popupMenu.forEach((element) {
      PopupMenuEntry<String> t = PopupMenuItem(
        value: element['key'],
        child: Row(
          children: <Widget>[
            Icon(
              element['value'],
            ),
            SizedBox(
              width: 3,
            ),
            Text(
              element['key'],
            ),
          ],
        ),
      );
      popupItemList.add(t);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('MsgPage rebuild');
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // backgroundColor: Colors.transparent,
        title: Text('消息'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              showPopup();
            },
          )
        ],
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(40.0),
            child: Container(
                height: 40,
                color: Funs.isDarkMode(context)?Colours.dark_tabBar_color:Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Theme.of(context).primaryColor.withOpacity(0.99),
                  labelColor: Theme.of(context).primaryColor,
                  tabs: List.generate(
                      tabTitle.length,
                      (index) => Tab(
                            text: tabTitle[index],
                          )),
                ))),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[ConversationPage(conversationController), AddressBookTabBar(addressBookController)],
      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: (){
//          setState(() {
//
//          });
//        },child: Icon(Icons.add),
//      ),
    );
  }

  void showPopup() async {
    double statusH = MediaQuery.of(context).padding.top;
    double top = kToolbarHeight + statusH;
    double left = MediaQuery.of(context).size.width;
    String result = await customShowMenu(position: RelativeRect.fromLTRB(left, top, 0, 0), elevation: 8.0, items: popupItemList, context: context, useRootNavigator: false);
    if (result == '发起群聊') {
      print('click 发起群聊');
      bool isCreate=await NavigatorUtil.goCreateGroupPage(context);
      if(isCreate==true)
        conversationController.loadConversion();
    } else if (result == numNormal) {
      toggleFriendListType(numNormal, num10000);
    } else if (result == num10000) {
      toggleFriendListType(num10000, numNormal);
    }
  }

  void toggleFriendListType(String target, String nextTarget) {
    PopupMenuEntry<String> t = PopupMenuItem(
      value: nextTarget,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.person,
          ),
          SizedBox(
            width: 3,
          ),
          Text(nextTarget),
        ],
      ),
    );
    popupItemList.last = t;
    setState(() {});
    if (addressBookController.switchPersonList != null) addressBookController?.switchPersonList(target);
  }
}
