import 'package:flutter/material.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/widgets/custom_paint.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
import 'package:provider/provider.dart';
import 'package:music_x/provider/user.dart';

class PersonPage extends StatefulWidget {
  @override
  _PersonPageState createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> with AutomaticKeepAliveClientMixin {
  int count = 0;
  Color color;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('PersonPage初始化');
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('PersonPage rebuild');
    color =Theme.of(context).scaffoldBackgroundColor;
    String userId = Provider.of<UserProvider>(
          context,
        ).userId ??
        '未知';
    return Scaffold(
    //  backgroundColor: Color(0xffededed),
      backgroundColor: Theme.of(context).splashColor,
//      appBar: AppBar(
//        title: Text('我的'),
//      ),
      body: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView(
          children: <Widget>[
            head(userId),
            SizedBox(
              height: 10,
            ),
            order,
            SizedBox(
              height: 10,
            ),
            property,
            SizedBox(
              height: 10,
            ),
            toolService,
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget head(String userId) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: Column(
        children: <Widget>[
          Container(
            height: 100 + 55 / 2,
            child: Stack(
              children: <Widget>[
                CustomPaint(
                  painter: PersonPaint(Colors.redAccent, MediaQuery.of(context).padding.top),
                  child: Container(
                      width: double.infinity,
                      height: 100,
                      alignment: Alignment(0, -0.2),
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 0, right: 0),
                      child:
                          //Text('卧夜思雨-$userId',style: TextStyle(fontSize: 18, shadows: [BoxShadow(color: Colors.black12, offset: Offset(-5, -5), blurRadius: 5)],),),
                          RichText(
                        text: TextSpan(
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                              shadows: [BoxShadow(color: Colors.black12, offset: Offset(-5, -5), blurRadius: 5)],
                            ),
                            children: [
                              TextSpan(text: '卧夜思雨'),
                              TextSpan(text: '-$userId', style: TextStyle(fontSize: 15)),
                            ]),
                      )

//                      Column(
//                        children: <Widget>[
//
//                          Row(
//                            children: <Widget>[
//                              Spacer(),
//                              Icon(
//                                Icons.settings,
//                                size: 20,
//                              ),
//                              //SizedBox(width: 30,),
//                            ],
//                          ),
//                          Text('卧夜思雨',style: TextStyle( shadows: [BoxShadow(color: Colors.black12, offset: Offset(-5, -5), blurRadius: 5)],),),
//                        ],
//                      )
                      ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 55,
                    height: 55,
                    child: xImgRoundRadius(radius: 55 / 2),
                  ),
                )
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.security,
                            size: 15,
                          ),
                          Text(
                            '普拉斯会员',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        'v7',
                        style: TextStyle(
                          shadows: [BoxShadow(color: Colors.black12, offset: Offset(-1, -1), blurRadius: 2)],
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.headset,
                            size: 15,
                          ),
                          Text('累计听歌',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ))
                        ],
                      ),
                      Text(
                        '996首',
                        style: TextStyle(
                          shadows: [BoxShadow(color: Colors.black12, offset: Offset(-1, -1), blurRadius: 2)],
                        ),
                      )
                    ],
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Widget get order {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '我的订单',
                style: TextStyles.textDialogTitle,
              ),
              Spacer(),
              Row(
                children: <Widget>[
                  Text(
                    '查看全部',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  )
                ],
              )
            ],
          ),
          Divider(
            thickness: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[Icon(Icons.payment), Text('待支付')],
              ),
              Column(
                children: <Widget>[
                  Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Icon(Icons.access_time),
                      Positioned(
                        right: -3,
                        top: -3,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text(
                            '99',
                            style: TextStyle(fontSize: 6, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                  Text('待发货')
                ],
              ),
              Column(
                children: <Widget>[Icon(Icons.local_car_wash), Text('待收货')],
              ),
              Column(
                children: <Widget>[Icon(Icons.build), Text('售后')],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget get property {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '我的资产',
                style: TextStyles.textDialogTitle,
              ),
              Spacer()
            ],
          ),
          Divider(
            thickness: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    '32',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('欢乐豆')
                ],
              ),
              Column(
                children: <Widget>[
                  Text(
                    '0',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('优惠券')
                ],
              ),
              Column(
                children: <Widget>[
                  Text(
                    '0.00',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('黑条')
                ],
              ),
              Column(
                children: <Widget>[Icon(Icons.account_balance_wallet), Text('钱包')],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget get toolService {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '工具与服务',
                style: TextStyles.textDialogTitle,
              ),
              Spacer(),
              Row(
                children: <Widget>[
                  Text(
                    '查看全部',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  )
                ],
              )
            ],
          ),
          Divider(
            thickness: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[Icon(Icons.star), Text('商品收藏')],
              ),
              Column(
                children: <Widget>[Icon(Icons.local_mall), Text('店铺关注')],
              ),
              Column(
                children: <Widget>[Icon(Icons.visibility), Text('历史浏览')],
              ),
              Column(
                children: <Widget>[Icon(Icons.receipt), Text('领券中心')],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[Icon(Icons.chat), Text('客户服务')],
              ),
              Column(
                children: <Widget>[Icon(Icons.autorenew), Text('以旧换新')],
              ),
              Column(
                children: <Widget>[Icon(Icons.monetization_on), Text('充值缴费')],
              ),
              GestureDetector(
                onTap: () => NavigatorUtil.goAppSettingPage(context),
                child: Column(
                  children: <Widget>[Icon(Icons.settings), Text('设置中心')],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
