import 'dart:async';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/utils/music.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/custom_paint.dart';
import 'package:music_x/widgets/local_or_network_image.dart';

class GoodsDetailPage extends StatefulWidget {
  final String songInfo;

  GoodsDetailPage({@required this.songInfo});

  @override
  _GoodsDetailPageState createState() => _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> {
  Map _songGoods;
  double appBarAlpha = 0;
  String shopImg = Constant.defaultLoadImage;
  int fans = 0;
  String albumDesc = '暂无信息';
  int goodsSelectIndex = 0;
  int goodsSelectCount = 1;
  Color color;
  Color backgroundColor;

  @override
  void initState() {
    _songGoods = FluroConvertUtils.string2map(widget.songInfo);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (mounted) {
        Map data = await AlbumInfo(_songGoods['baseInfo']['albumId'].toString()).getAlbumInfo();
        if (data == null) return;
        setState(() {
          shopImg = data['authorPic'];
          albumDesc = data['description'];
          fans = data['fans'];
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print(_songGoods);
    print('goods detail rebuild');
    color =Theme.of(context).scaffoldBackgroundColor;
    backgroundColor=Theme.of(context).splashColor;
    return Scaffold(
      // backgroundColor: Colors.grey.withOpacity(0.2), // Color(0xffededed),
      backgroundColor: Theme.of(context).splashColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(appBarAlpha),
        leading: UnconstrainedBox(
            child: InkWell(
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5 - appBarAlpha >= 0 ? 0.5 - appBarAlpha : 0), shape: BoxShape.circle),
            child: Icon(Icons.arrow_back),
          ),
          onTap: () => Navigator.of(context).pop(),
        )),
        title: Text(
          _songGoods['baseInfo']['name'],
          style: TextStyle(
            color: Colors.white.withOpacity(appBarAlpha),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan.withOpacity(appBarAlpha), Colors.blue.withOpacity(appBarAlpha), Colors.blueAccent.withOpacity(appBarAlpha)],
            ),
          ),
        ),
        actions: <Widget>[
          UnconstrainedBox(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5 - appBarAlpha >= 0 ? 0.5 - appBarAlpha : 0), shape: BoxShape.circle),
              child: Icon(Icons.share),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),

      body: NotificationListener(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollUpdateNotification) {
              if (scrollNotification.metrics.axis == Axis.vertical) _onScroll(scrollNotification.metrics.pixels);
            }
            return false;
          },
          child: MediaQuery.removePadding(
              removeTop: false,
              context: context,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: <Widget>[
                        Hero(
                          tag: _songGoods['tag'],
                          child: Container(
                            height: 250,
                            child: xImgRoundRadius(
                              urlOrPath: _songGoods['baseInfo']['picUrl'],
                              radius: 0,
                            ),
                          ),
                        ),
                        goodsPrice,
//                        Padding(
//                          padding: EdgeInsets.only(left: 12, bottom: 5),
//                          child: Row(
//                            children: <Widget>[
//                              Baseline(
//                                baseline: 10.0,
//                                baselineType: TextBaseline.alphabetic,
//                                child: Text('￥${_songGoods['newPrice'].toString()}.00 ',
//                                    style: TextStyle(fontSize: 14, color: Color(0xffFE2E2E), fontWeight: FontWeight.bold)),
//                              ),
//                              Baseline(
//                                baseline: 7.0,
//                                baselineType: TextBaseline.alphabetic,
//                                child: Container(
//                                  padding: EdgeInsets.symmetric(horizontal: 3),
//                                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(5)),
//                                  child: Text(
//                                    '粉丝价',
//                                    style: TextStyle(fontSize: 11),
//                                  ),
//                                ),
//                              ),
//                            ],
//                          ),
//                        ),
                        goodsName,

                        goodsTime,
                        Utils.divider(context: context),
                        goodsService,
                        Utils.spaceGery(context: context),
                        goodsYouHui,
                        Utils.spaceGery(context: context),
                        goodsSelect,
                        Utils.spaceGery(context: context),
                        goodsComment,
                        Utils.spaceGery(context: context),
                        goodsShop,
                        Utils.spaceGery(context: context),
                        goodsDetail,

//                        ListView.builder(
//                          shrinkWrap: true,
//                          physics: NeverScrollableScrollPhysics(),
//                          itemBuilder: (context, index) => ListTile(
//                            title: Text(index.toString()),
//                          ),
//                          itemCount: 20,
//                        ),
                      ],
                    ),
                  ),
                  bottomNav,
                ],
              ))),
    );
  }

  Widget get bottomNav {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 55,
          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1, color: backgroundColor))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Icon(Icons.business), Text('店铺')],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Icon(Icons.chat), Text('客服')],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Icon(Icons.star_border), Text('收藏')],
              ),
              Container(
                  height: 40,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.red.withOpacity(0.7), Colors.red]),
                      // 渐变色
                      borderRadius: BorderRadius.circular(20)),
                  child: RaisedButton(
                    padding: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.transparent,
                    // 设为透明色
                    elevation: 0,
                    // 正常时阴影隐藏
                    highlightElevation: 0,
                    // 点击时阴影隐藏
                    onPressed: () {
                      showGoodsSelect(context, 'addCart');
                    },
                    child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        child: Text(
                          '加购物车',
                          style: TextStyle(
                            color: color,
                          ),
                        )),
                  )),
              Container(
                  height: 40,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.red,
                        Colors.red.withOpacity(0.7),
                      ]),
                      // 渐变色
                      borderRadius: BorderRadius.circular(20)),
                  child: RaisedButton(
                    padding: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.transparent,
                    // 设为透明色
                    elevation: 0,
                    // 正常时阴影隐藏
                    highlightElevation: 0,
                    // 点击时阴影隐藏
                    onPressed: () {
                      showGoodsSelect(context, 'buy');
                    },
                    child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        child: Text(
                          '立即购买',
                          style: TextStyle(
                            color: color,
                          ),
                        )),
                  )),
            ],
          ),
        ));
  }

  _onScroll(offset) {
    //print(offset);
    if (offset > 200) return;
    double alpha = offset / 200;
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    setState(() {
      appBarAlpha = alpha;
    });
  }

  Widget get goodsPrice {
    return Container(
      padding: EdgeInsets.all(10),
      color: color,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Baseline(
                  baseline: 10.0,
                  baselineType: TextBaseline.alphabetic,
                  child: RichText(
                    text: TextSpan(text: '￥', style: TextStyle(fontSize: 14, color: Colors.red), children: <TextSpan>[
                      TextSpan(text: _songGoods['oldPrice'].toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextSpan(text: '.00', style: TextStyle(fontSize: 14)),
                    ]),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Baseline(
                  baseline: 10.0,
                  baselineType: TextBaseline.alphabetic,
                  child: Text(
                    '￥996',
                    style: TextStyle(fontSize: 13, color: Colors.grey, decoration: TextDecoration.lineThrough),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Baseline(
                  baseline: 10.0,
                  baselineType: TextBaseline.alphabetic,
                  child: Text('￥${_songGoods['newPrice'].toString()}.00 ',
                      style: TextStyle(fontSize: 14, color: Color(0xffFE2E2E), fontWeight: FontWeight.bold)),
                ),
                Baseline(
                  baseline: 7.0,
                  baselineType: TextBaseline.alphabetic,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      '粉丝价',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget get goodsName {
    return Container(
      color: color,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text.rich(
        TextSpan(children: [
          WidgetSpan(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3),
              margin: EdgeInsets.only(right: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.red),
              child: Text(
                _songGoods['type'],
                style: TextStyle(color: color, fontSize: 11),
              ),
            ),
          ),
          TextSpan(
              text: _songGoods['baseInfo']['name'],
              //style: TextStyle(color: Color(0xff151516), fontWeight: FontWeight.w700, fontSize: 15,)
            style: TextStyles.textDialogTitle,
          ),
          if (_songGoods['subType'] != null)
            WidgetSpan(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 1),
              margin: EdgeInsets.only(left: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: Colors.blueGrey),
              child: Text(_songGoods['subType'],
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    shadows: [BoxShadow(color: Colors.black12, offset: Offset(-1, -1), blurRadius: 2)],
                  )),
            )),
        ]),
      ),
    );
  }

  Widget get goodsTime {
    return Container(
      color: color,
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3),
              margin: EdgeInsets.only(right: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.red),
              child: Text(
                '上线',
                style: TextStyle(color: color, fontSize: 11),
              ),
            ),
            Text(
              getFormattedTime(_songGoods['publishTime']),
              style: TextStyle(
                shadows: [BoxShadow(color: Colors.grey, offset: Offset(-1, -1), blurRadius: 2)],
              ),
            )
          ],
        ));
  }

  Widget get goodsService {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: color,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: DefaultTextStyle(
            style: TextStyle(fontSize: 13, color: Colors.black54),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('不好听不退款 '),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        ' . ',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Text('免费试听'),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        ' . ',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Text('包抑郁'),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
              ],
            )),
      ),
      onTap: () {
        showGoodsServiceInfo(context);
      },
    );
  }

  Widget get goodsYouHui {
    return Container(
        width: 100,
        decoration: BoxDecoration(
         //color: Color(0xffededed),
          color:backgroundColor
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => showGoodsCoupon(context,color),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                            width: 30,
                            child: Text(
                              '优惠',
                              style: TextStyles.textDialogTitle,
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Funs.isDarkMode(context)?Colours.dark_appBar_color:Colours.coupon_bg,
                          ),
                          child: Text(
                            '领券',
                            style: TextStyles.couponText,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CustomPaint(
                          painter: CouponPaint(Colours.coupon_border),
                          child: Container(
                            height: 18,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: Text(
                                '满200加99',
                                style: TextStyles.couponText,
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 40,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Funs.isDarkMode(context)?Colours.dark_appBar_color:Colours.coupon_bg,
                          ),
                          child: Text(
                            '折扣',
                            style: TextStyles.couponText,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Text(
                            '满2件，总价打11折；满99件，总价打骨折',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 40,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Funs.isDarkMode(context)?Colours.dark_appBar_color:Colours.coupon_bg,
                          ),
                          child: Text(
                            '加一元',
                            style: TextStyles.couponText,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Text(
                            '加一元钱，即可什么也得不到',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
              Divider(
                indent: 40,
                thickness: 1,
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: <Widget>[
                  Container(
                      width: 30,
                      child: Text(
                        '活动',
                        style: TextStyles.textDialogTitle,
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(border: Border.all(color: Colours.coupon_border), borderRadius: BorderRadius.circular(3)),
                    child: Text(
                      '入会无礼',
                      style: TextStyles.couponText,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(border: Border.all(color: Colours.coupon_border), borderRadius: BorderRadius.circular(3)),
                    child: Text(
                      '粉丝不见面会',
                      style: TextStyles.couponText,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                  )
                ],
              )
            ],
          ),
        ));
  }

  Widget get goodsSelect {
    return GestureDetector(
      onTap: () => showGoodsSelect(context, 'select'),
      child: Container(
          width: 100,
          decoration: BoxDecoration(
            //color: Color(0xffededed),
              color:backgroundColor
          ),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                        width: 30,
                        child: Text(
                          '选择',
                          style: TextStyles.textDialogTitle,
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    _songGoods['quality'].length > 0
                        ? Text(
                            '${_songGoods['quality'][goodsSelectIndex]['name']} ${_songGoods['quality'][goodsSelectIndex]['size']}M，$goodsSelectCount件')
                        : Text('暂无选择'),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Divider(
                  indent: 40,
                  thickness: 1,
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: <Widget>[
                    Container(
                        width: 30,
                        child: Text(
                          '发货',
                          style: TextStyles.textDialogTitle,
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      (_songGoods['company'] == "" ? '网易云音乐' : _songGoods['company'] ?? '网易云音乐') + '-' + _songGoods['albumName'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }

  Widget get goodsComment {
    return Container(
        width: 100,
        decoration: BoxDecoration(
          //color: Color(0xffededed),
            color:backgroundColor
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  print('qq');
                  NavigatorUtil.goSongCommentPage(context, _songGoods);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 30,
                          child: Baseline(
                            baseline: 20,
                            baselineType: TextBaseline.alphabetic,
                            child: Text(
                              '评价',
                              style: TextStyles.textDialogTitle,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Baseline(
                          baseline: 20,
                          baselineType: TextBaseline.alphabetic,
                          child: Text(
                            '${_songGoods['commentInfo']['total']}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(10)),
                          child: Text('终于找到'),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(10)),
                          child: Text('抖腿上天'),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(10)),
                          child: Text('考研加油'),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(10)),
                          child: Text('亲自耕地'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 30,
                          child: xImgRoundRadius(urlOrPath: _songGoods['commentInfo']['avatarUrl'], radius: 30 / 2),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(_songGoods['commentInfo']['name']),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.star,
                                  color: Colors.redAccent,
                                  size: 14,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.redAccent,
                                  size: 14,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.redAccent,
                                  size: 14,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.redAccent,
                                  size: 14,
                                ),
                                Icon(
                                  Icons.star_half,
                                  color: Colors.redAccent,
                                  size: 14,
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    Text(
                      _songGoods['commentInfo']['content'],
                      style: TextStyles.textComment,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: <Widget>[
                  Container(
                      width: 30,
                      child: Text(
                        '问答',
                        style: TextStyles.textDialogTitle,
                      )),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.live_help,
                    size: 16,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('听完能打篮球吗'),
                  ),
                  //Spacer(),
                  Text(
                    '2个回答',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.live_help,
                    size: 16,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('听完能唱跳吗'),
                  ),
                  //Spacer(),
                  Text(
                    '5个回答',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  Widget get goodsShop {
    return GestureDetector(
      onTap: (){
        NavigatorUtil.goSongArtistPage(context,_songGoods['baseInfo']['authorId'].toString());
      },
      child: Container(
          width: 100,
          decoration: BoxDecoration(
           // color: Color(0xffededed),
              color:backgroundColor
          ),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(width: 40, height: 40, child: xImgRoundRadius(urlOrPath: shopImg)),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('${_songGoods['baseInfo']['author']}官方旗舰店',
                               // style: TextStyle(color: Color(0xff151516), fontWeight: FontWeight.w700, fontSize: 15,)
                              style: TextStyles.textDialogTitle,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 3),
                              margin: EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.red),
                              child: Text(
                                '官方',
                                style: TextStyle(color: color, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          getFormattedNumber(fans).toString() + '人关注',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      ],
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }

  Widget get goodsDetail {
    return Container(
        width: 100,
        decoration: BoxDecoration(
         // color: Color(0xffededed),
            color:backgroundColor
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 30,
                    child: Text(
                      '详情',
                     // style: TextStyles.textDialogTitle,,
                      style: TextStyles.textDialogTitle,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(albumDesc),
            ],
          ),
        ));
  }

  Future showGoodsSelect(context2, String type) {
    double h = MediaQuery.of(context2).size.height * 0.65;
    int _selectIndex = goodsSelectIndex;
    TextEditingController _controllerText = TextEditingController(text: goodsSelectCount.toString());
    FocusNode _focusNode = FocusNode();
    Timer _timer1, _timer2;
    int maxCount = 99;
    bool isReduce = goodsSelectCount == 1 ? false : true;
    bool isAdd = goodsSelectCount == maxCount ? false : true;
    List goodsService = ['一年免费换新 ￥19', '两年半免费换新 ￥29'];
    int goodsServiceSelect;
    Future<void> future = showModalBottomSheet(
        context: context2,
        elevation: 10,
        isScrollControlled: true,
        enableDrag: false,
        // isDismissible: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (BuildContext context) {
          return Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (_focusNode.hasFocus) _focusNode.unfocus();
                },
                child: Container(
//                duration: Duration(milliseconds: 350),
//                curve: Curves.easeInOut,
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: MediaQuery.of(context).viewInsets.bottom),

                  // height: h,
                  constraints: BoxConstraints(minHeight: h, maxHeight: MediaQuery.of(context2).size.height - MediaQuery.of(context2).padding.top),
                  color: Colors.transparent,
                  child: SingleChildScrollView(
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            height: 50,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text('商品选择'),
                                  ),
                                ),
                                Icon(Icons.close),
                                SizedBox(
                                  width: 10,
                                )
                              ],
                            ),
                          ),
                          onTap: () {
//                          setState(() {
//                            goodsSelectCount=int.parse(_controllerText.text);
//                          });
                            Navigator.of(context).pop();
                          },
                        ),
                        Divider(thickness: 1),
                        Text('品质', style: TextStyles.textDialogTitle,),
                        Builder(
                          builder: (BuildContext context) {
                            _focusNode.addListener(() {
                              if (_focusNode.hasFocus == false) {
                                if (_controllerText.text == '99') {
                                  isAdd = false;
                                  isReduce = true;
                                  (context as Element).markNeedsBuild();
                                } else if (int.parse(_controllerText.text) <= 1) {
                                  _controllerText.text = '1';
                                  isAdd = true;
                                  isReduce = false;
                                  (context as Element).markNeedsBuild();
                                }
                              }
                            });
                            return Wrap(
                              spacing: 15,
                              children: List.generate(_songGoods['quality'].length, (index) {
                                return ChoiceChip(
                                  label: Text('${_songGoods['quality'][index]['name']} ${_songGoods['quality'][index]['size']}M'),
                                  selected: _selectIndex == index,
                                  selectedColor: Funs.isDarkMode(context)?Colours.dark_appBar_color:Colours.app_main.withOpacity(0.1),
                                  onSelected: (v) {
                                    (context as Element).markNeedsBuild();
                                    _selectIndex = index;
                                    setState(() {
                                      goodsSelectIndex = index;
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('数量', style: TextStyles.textDialogTitle,),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.error_outline,
                              size: 14,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              '每人最多购买99件',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Spacer(),
                            Builder(
                              builder: (context) {
                                return Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Icon(
                                        Icons.remove,
                                        color: isReduce == true ? Colors.black87 : Colors.grey,
                                      ),
                                      onTap: () {
                                        if (_focusNode.hasFocus) _focusNode.unfocus();
                                        if (_controllerText.text == '1') return;
                                        if (_controllerText.text == "") {
                                          _controllerText.text = '1';
                                          isReduce = false;
                                          (context as Element).markNeedsBuild();
                                          return;
                                        }
                                        if (isReduce == false || isAdd == false) {
                                          isReduce = true;
                                          isAdd = true;
                                          (context as Element).markNeedsBuild();
                                        }
                                        _controllerText.text = (int.parse(_controllerText.text) - 1).toString();
                                        if (_controllerText.text == '1') {
                                          isReduce = false;
                                          (context as Element).markNeedsBuild();
                                        }
                                      },
                                      onLongPressStart: (details) {
                                        if (_controllerText.text == '1') return;
                                        if (_controllerText.text == "") {
                                          _controllerText.text = '1';
                                        }
                                        if (isAdd == false || isReduce == false) {
                                          isAdd = true;
                                          isReduce = true;
                                          (context as Element).markNeedsBuild();
                                        }
                                        int count = 0;
                                        _timer1 = Timer.periodic(Duration(milliseconds: 200), (timer) {
                                          count += 1;
                                          int text = int.parse(_controllerText.text);
                                          if (text <= 1) {
                                            timer.cancel();
                                            timer = null;
                                            isReduce = false;
                                            (context as Element).markNeedsBuild();
                                          } else
                                            _controllerText.text = (text - 1).toString();
                                          if (count >= 10) {
                                            timer.cancel();
                                            timer = null;
                                            _timer2 = Timer.periodic(Duration(milliseconds: 100), (timer) {
                                              int text = int.parse(_controllerText.text);
                                              if (text <= 1) {
                                                timer.cancel();
                                                timer = null;
                                                isReduce = false;
                                                (context as Element).markNeedsBuild();
                                              } else
                                                _controllerText.text = (text - 1).toString();
                                            });
                                          }
                                        });
                                      },
                                      onLongPressEnd: (detail) {
                                        if (_timer1 != null) {
                                          _timer1.cancel();
                                          _timer1 = null;
                                        }
                                        if (_timer2 != null) {
                                          _timer2.cancel();
                                          _timer2 = null;
                                        }
                                      },
                                    ),
                                    Container(
                                      width: 50,
                                      height: 30,
                                      child: TextField(
                                        controller: _controllerText,
                                        focusNode: _focusNode,
                                        autofocus: false,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        maxLength: 2,
                                        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                        decoration: InputDecoration(
                                          counterText: "",
                                          //contentPadding:EdgeInsets.all(0),
                                          fillColor: Color(0x30cccccc),
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0x00FF0000)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0x00000000)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      child: Icon(
                                        Icons.add,
                                        color: isAdd == true ? Colors.black87 : Colors.grey,
                                      ),
                                      onTap: () {
                                        if (_focusNode.hasFocus) _focusNode.unfocus();
                                        if (_controllerText.text == maxCount.toString()) return;
                                        if (_controllerText.text == "") {
                                          _controllerText.text = '1';
                                          isReduce = false;
                                          (context as Element).markNeedsBuild();
                                          return;
                                        }
                                        if (isAdd == false || isReduce == false) {
                                          isAdd = true;
                                          isReduce = true;
                                          (context as Element).markNeedsBuild();
                                        }
                                        _controllerText.text = (int.parse(_controllerText.text) + 1).toString();
                                        if (_controllerText.text == maxCount.toString()) {
                                          isAdd = false;
                                          (context as Element).markNeedsBuild();
                                        }
                                      },
                                      onLongPressStart: (details) {
                                        if (_controllerText.text == maxCount.toString()) return;
                                        if (_controllerText.text == "") {
                                          _controllerText.text = '1';
                                        }
                                        if (isAdd == false || isReduce == false) {
                                          isAdd = true;
                                          isReduce = true;
                                          (context as Element).markNeedsBuild();
                                        }
                                        int count = 0;
                                        _timer1 = Timer.periodic(Duration(milliseconds: 200), (timer) {
                                          count += 1;
                                          int text = int.parse(_controllerText.text);
                                          if (text >= maxCount) {
                                            timer.cancel();
                                            timer = null;
                                            isAdd = false;
                                            (context as Element).markNeedsBuild();
                                          } else
                                            _controllerText.text = (text + 1).toString();
                                          if (count >= 10) {
                                            timer.cancel();
                                            timer = null;
                                            _timer2 = Timer.periodic(Duration(milliseconds: 100), (timer) {
                                              int text = int.parse(_controllerText.text);
                                              if (text >= maxCount) {
                                                timer.cancel();
                                                timer = null;
                                                isAdd = false;
                                                (context as Element).markNeedsBuild();
                                              } else
                                                _controllerText.text = (text + 1).toString();
                                            });
                                          }
                                        });
                                      },
                                      onLongPressEnd: (detail) {
                                        if (_timer1 != null) {
                                          _timer1.cancel();
                                          _timer1 = null;
                                        }
                                        if (_timer2 != null) {
                                          _timer2.cancel();
                                          _timer2 = null;
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('售后', style: TextStyles.textDialogTitle,),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.remove_shopping_cart,
                              size: 14,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              '只换不买',
                              style: TextStyle(fontSize: 12),
                            ),
                            Spacer(),
                            GestureDetector(
                              child: Text(
                                '服务介绍',
                                style: TextStyle(color: Colours.coupon_text, fontSize: 12),
                              ),
                              onTap: () {
                                Funs.showCustomDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Text("购买服务后，在有效期限内，可免费换领歌手新发布的歌曲1首"),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text("我知道了"),
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Icon(Icons.help_outline, size: 14, color: Colours.coupon_text)
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Builder(
                          builder: (context) {
                            return Wrap(
                                spacing: 15,
                                children: List.generate(
                                    goodsService.length,
                                    (index) => ChoiceChip(
                                          label: Text(goodsService[index]),
                                          selected: goodsServiceSelect == index,
                                          onSelected: (v) {
                                            if (goodsServiceSelect == index)
                                              goodsServiceSelect = null;
                                            else
                                              goodsServiceSelect = index;
                                            (context as Element).markNeedsBuild();
                                          },
                                        )));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (type == 'select')
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.red.withOpacity(0.7), Colors.red]),
                                // 渐变色
                                borderRadius: BorderRadius.circular(20)),
                            child: RaisedButton(
                              padding: EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              color: Colors.transparent,
                              // 设为透明色
                              elevation: 0,
                              // 正常时阴影隐藏
                              highlightElevation: 0,
                              // 点击时阴影隐藏
                              onPressed: () {
                                //showGoodsSelect(context,'addCart');
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  child: Text(
                                    '加购物车',
                                    style: TextStyle(
                                      color: color,
                                    ),
                                  )),
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Colors.red,
                                  Colors.red.withOpacity(0.7),
                                ]),
                                // 渐变色
                                borderRadius: BorderRadius.circular(20)),
                            child: RaisedButton(
                              padding: EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              color: Colors.transparent,
                              // 设为透明色
                              elevation: 0,
                              // 正常时阴影隐藏
                              highlightElevation: 0,
                              // 点击时阴影隐藏
                              onPressed: () {},
                              child: Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  child: Text(
                                    '立即购买',
                                    style: TextStyle(
                                      color: color,
                                    ),
                                  )),
                            )),
                      )
                    ],
                  ),
                )
              else if (type == 'buy')
                Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.red.withOpacity(0.7), Colors.red]),
                            // 渐变色
                            borderRadius: BorderRadius.circular(20)),
                        child: RaisedButton(
                          padding: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.transparent,
                          // 设为透明色
                          elevation: 0,
                          // 正常时阴影隐藏
                          highlightElevation: 0,
                          // 点击时阴影隐藏
                          onPressed: () {},
                          child: Container(
                              alignment: Alignment.center,
                              height: 40,
                              child: Text(
                                '立即购买',
                                style: TextStyle(
                                  color: color,
                                ),
                              )),
                        )))
              else if (type == 'addCart')
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.red.withOpacity(0.7), Colors.red]),
                          // 渐变色
                          borderRadius: BorderRadius.circular(20)),
                      child: RaisedButton(
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.transparent,
                        // 设为透明色
                        elevation: 0,
                        // 正常时阴影隐藏
                        highlightElevation: 0,
                        // 点击时阴影隐藏
                        onPressed: () {},
                        child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            child: Text(
                              '加入购物车',
                              style: TextStyle(
                                color: color,
                              ),
                            )),
                      )),
                )
            ],
          );
        });
    future.then((void value) {
      int now = int.parse(_controllerText.text);
      if (now != goodsSelectCount)
        setState(() {
          goodsSelectCount = int.parse(_controllerText.text);
        });
    });

    return future;
  }
}

Future showGoodsServiceInfo(context) {
  return showModalBottomSheet(
      context: context,
      elevation: 10,
      isScrollControlled: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Column(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 50,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text('服务说明'),
                      ),
                    ),
                    Icon(Icons.close),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
            Divider(thickness: 1),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 20,
                              child: Icon(
                                Icons.flag,
                                color: Colors.green,
                                size: 18,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('不好听不退款'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '购买歌曲后,如果听到一半发现歌曲不好听、干呕、头晕,甚至想喝一大碗酸梅汤,我们是不退款哦！',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 20,
                              child: Icon(
                                Icons.flag,
                                color: Colors.green,
                                size: 18,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('免费试听'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '歌曲提供前30s免费在线试听,好听再下单哦！',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 20,
                              child: Icon(
                                Icons.flag,
                                color: Colors.green,
                                size: 18,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('包抑郁'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '购买歌曲后,假如您听完没有抑郁,我们对此深表遗憾,并不全额退款哦！',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      });
}

Future showGoodsCoupon(BuildContext context,Color color) {
  double h = MediaQuery.of(context).size.height * 0.65;
  return showModalBottomSheet(
      context: context,
      elevation: 10,
      isScrollControlled: true,
      enableDrag: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          height: h,
          child: Column(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text('优惠'),
                        ),
                      ),
                      Icon(Icons.close),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
              Divider(thickness: 1),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ListView(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                width: 20,
                                child: Icon(
                                  Icons.flag,
                                  color: Colors.green,
                                  size: 18,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text('领券'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '成功领取优惠券后，商品结算时会自动调整你想要的价格，可以叠加使用哦~',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                width: 20,
                                child: Icon(
                                  Icons.flag,
                                  color: Colors.green,
                                  size: 18,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text('折扣'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '购买商品满2件，总价打11折；满99件，总价打骨折，数量有限，先到先得哦~',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                width: 20,
                                child: Icon(
                                  Icons.flag,
                                  color: Colors.green,
                                  size: 18,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text('加一元'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '加一元钱，即可什么也的不到哦~',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      Text(
                        '可领取优惠券',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: <Widget>[
                          UnconstrainedBox(
                            child: CustomPaint(
                                painter: CouponPaintLeft(Colours.coupon_border),
                                child: Container(
                                    height: 80,
                                    width: 120,
                                    //color: color,
                                    padding: EdgeInsets.symmetric(horizontal: 10),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [Colors.cyan, Colors.blue, Colors.blueAccent],
//                               ),
//                             ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        RichText(
                                          text: TextSpan(
                                            text: '￥',
                                            style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
                                            children: [
                                              TextSpan(text: '99', style: TextStyle(fontSize: 30)),
                                            ],
                                          ),
                                        ),
                                        Text('满200元可加', style: TextStyle(fontSize: 13, color: color))
                                      ],
                                    ))),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 80,
                              padding: EdgeInsets.all(5.0),
                              alignment: Alignment.topRight,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xffededed)),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      child: Image.asset('assets/img/get_coupon.png'),
                                    ),
                                  ),
                                  Text.rich(TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child:   Container(
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.blueGrey),
                                          margin: EdgeInsets.only(right: 5),
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Text('店铺券', style: TextStyle(fontSize: 12, color: color)),
                                        ),
                                      ),
                                      TextSpan(
                                        text:'仅可购买当前店铺下部分商品',
                                      ),
                                    ]
                                  )),
                                 Positioned(
                                   bottom: 0,
                                   left: 0,
                                   right: 0,
                                   child:  Row(children: <Widget>[
                                     Flexible(child: FittedBox(
                                       fit: BoxFit.fitWidth,
                                       child:  Text('${DateUtil.formatDate(DateTime.now(),format: "yyyy.M.d")}-${DateUtil.formatDate(DateTime.now(),format: "yyyy.M.d")}'),
                                     ),
                                     ),
                                     SizedBox(width: 20,),
                                     Container(
                                       padding: EdgeInsets.symmetric(horizontal: 7),
                                       decoration: BoxDecoration(
                                           borderRadius: BorderRadius.circular(5),
                                           gradient:LinearGradient(
                                               colors: [
                                                 Colors.blueGrey,
                                                 Colors.grey,
                                               ]
                                           )
                                       ),
                                       child:  Text('点击领取'),
                                     )
                                   ],),
                                 )

                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      });
}
