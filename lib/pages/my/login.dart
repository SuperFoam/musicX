import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:music_x/provider/user.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:provider/provider.dart';

DateTime lastPopTime;

Future<bool> _doubleExit() async {
  if (lastPopTime == null || DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
    lastPopTime = DateTime.now();
    Utils.showToast('再按一次退出');

    return new Future.value(false);
  } else {
    lastPopTime = DateTime.now();
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return new Future.value(true);
    // 退出app
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _controllerName;
  TextEditingController _controllerPwd;
  GlobalKey _formKey = new GlobalKey<FormState>();
  GlobalKey _toolTipKey = GlobalKey();
  List userTest = Constant.IMUser;
  String userTestPwd = Constant.IMPwd;

  @override
  void initState() {
    _controllerName = new TextEditingController(text: userTest.first);
    _controllerPwd = new TextEditingController(text: userTestPwd);
    super.initState();
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerPwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _doubleExit,
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('登录-${Constant.isProduction}'),
          ),
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: FlutterLogo(size: 50.0),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Form(
                            key: _formKey, //设置globalKey，用于后面获取FormState
                            autovalidate: true,
                            child: Column(
                              children: <Widget>[
                                Stack(
                                  alignment: Alignment.centerRight,
                                  children: <Widget>[
                                    TextFormField(
                                        controller: _controllerName,
                                        maxLength: 20,
                                        decoration: InputDecoration(
                                          labelText: "用户名",
                                          hintText: "用户名",
                                          prefixIcon: Icon(Icons.person),
                                          counterText: '',
//                               suffixIcon: IconButton(
//                                 icon: Icon(Icons.arrow_drop_down),
//                                 onPressed: (){
//                                   FocusScope.of(context).unfocus();
//                                   print('下拉');
//                                 },
//                               ),

                                          // border: InputBorder.none,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            // borderSide: BorderSide(color: Colors.orangeAccent,), //这个不生效
                                          ),

//                            enabledBorder: OutlineInputBorder( //未选中时候的颜色
//                              borderRadius: BorderRadius.circular(5.0),
//                              borderSide: BorderSide(color: Colors.red,),
//                            ),
//                            focusedBorder: OutlineInputBorder( //选中时外边框颜色
//                              borderRadius: BorderRadius.circular(5.0),
//                              borderSide: BorderSide(color: Colors.blue),
//                            ),
                                        ),

                                        // 校验用户名
                                        validator: (v) {
                                          return v.trim().length > 0 ? null : "用户名不能为空";
                                        }),
                                    GestureDetector(
                                      onTapDown: (TapDownDetails detail) {
                                        print('点击展示更多');
                                        FocusScope.of(context).unfocus();
                                        print('下拉');
                                        onShowMenu(detail);
                                      },
                                      child: IconButton(icon: Icon(Icons.arrow_drop_down), onPressed: null),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                    controller: _controllerPwd,
                                    maxLength: 20,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        labelText: "密码",
                                        hintText: "登录密码",
                                        prefixIcon: Icon(Icons.lock),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        )),
                                    obscureText: true,
                                    //校验密码
                                    validator: (v) {
                                      return v.trim().length > 0 ? null : "密码不能为空";
                                    }),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                          child: Text('登录'),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if ((_formKey.currentState as FormState).validate()) {
                              initIM();
                            }
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        OutlineButton(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                          highlightedBorderColor: Colors.blueGrey,
                          child: Text('跳过登录'),
                          onPressed: () {
                            guestLogin();
                          },
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            final dynamic tooltip = _toolTipKey.currentState;
                            tooltip.ensureTooltipVisible();
                            Future.delayed(Duration(seconds: 3)).then((value) => tooltip.deactivate());
                          },
                          child: Tooltip(
                            key: _toolTipKey,
                            message: '跳过登录，消息功能将不可使用',
                            child: Icon(Icons.info_outline),
                            showDuration: Duration(seconds: 2),
                          ),
                        )
                      ],
                    ),
                  ))
            ],
          )),
    );
  }

  void onShowMenu(TapDownDetails details) async {
    String curUser = _controllerName.text;
    List<PopupMenuEntry<String>> popupItem = List.generate(
        userTest.length,
        (index) => PopupMenuItem(
              value: userTest[index],
              child: Text(userTest[index]),
              enabled: curUser != userTest[index],
            ));
    String res = await showCustomPopupMenu(tapDownDetail: details, popupItem: popupItem, context: context, bottomHeight: Constant.bottomNavHeight);
    print('res is $res');
    if (res == null) return;
    _controllerName.text = res;
    _controllerPwd.text = userTestPwd;
  }

  void initIM() {
    var cancel = Utils.showLoading();
    EMOptions options = new EMOptions(appKey: Constant.IMAppKey);
    EMClient.getInstance().init(options);
    EMClient.getInstance().setDebugMode(false);
    EMClient.getInstance().login(_controllerName.text, _controllerPwd.text, onSuccess: (username) {
      cancel();
      EMClient.getInstance().groupManager().loadAllGroups();
      EMClient.getInstance().chatManager().loadAllConversations();
      String token = _controllerName.text + '_test_token';
      String userId = _controllerName.text;
      UserType userType = UserType.COMMON;
      Map userInfo = getUserInfo(); // 实际项目是拿token向后台请求用户信息
      if (userInfo == null) {
        Provider.of<UserProvider>(context, listen: false).saveUser(userToken: token, userId: userId, userType: userType);
      } else {
        Provider.of<UserProvider>(context, listen: false).saveUser(userToken: token, userId: userId,
            userType: userType, userNickname: userInfo['userNickname']);
      }
      Utils.showToast('$username登录成功');
      NavigatorUtil.goHome(context);
    }, onError: (code, desc) {
      cancel();
      Utils.showToast('登录失败');
      print('登录错误 -$code-- $desc');
    });
  }

  Map getUserInfo() {
    Map userInfo = SpUtil.getObject(Constant.userInfo + _controllerName.text);
    return userInfo;
  }
  void guestLogin(){
    String token = 'guest_test_token';
    String userId = 'guest';
    UserType userType = UserType.GUEST;
    Provider.of<UserProvider>(context, listen: false).saveUser(userToken: token, userId: userId, userType: userType);
    NavigatorUtil.goHome(context);

  }
}
