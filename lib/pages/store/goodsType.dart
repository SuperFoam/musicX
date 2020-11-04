import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:reorderables/reorderables.dart';

class GoodsTypeManagePage extends StatefulWidget {
  @override
  _GoodsTypeManagePageState createState() => _GoodsTypeManagePageState();
}

class _GoodsTypeManagePageState extends State<GoodsTypeManagePage> with SingleTickerProviderStateMixin {
  List mySelect = List();
  List allGoodsType = List();
  List mySelectValue = List();
  bool showDelete = false;
  AnimationController _animationController;
  Animation _animationRot;
  Tween<double> tween;
  double start = 0.005;
  int deleteIndex;
  int maxCount = 9;

  @override
  void initState() {
    super.initState();
    allGoodsType = MyGoodsType.goodsTypeList;
    mySelect = MyGoodsType.getData();
    mySelect.forEach((element) {
      mySelectValue.add(element['name']);
    });
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    tween = Tween(begin: 0.0, end: -start);
    _animationRot = tween.chain(CurveTween(curve: Curves.linear)).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('管理'),
      ),
      body: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        shrinkWrap: true,
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '我的选择',
                style: TextStyles.textDialogTitle,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                '长按可拖动排序',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showDelete = !showDelete;
                  });
                  if (showDelete) {
                    tween.begin = start;
                    _animationController.repeat(reverse: true);
                  } else {
                    tween.begin = 0.0;
                    _animationController.reset();
                    MyGoodsType.change(mySelect);
                  }
                },
                child: Text(
                  showDelete == true ? '完成' : '编辑',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          ReorderableWrap(
              spacing: 8.0,
              runSpacing: 4.0,
              // padding: const EdgeInsets.all(8),
              children: List.generate(mySelect.length+1, (index) {
                return GestureDetector(
                    onTap: () async {
                      print('点击了');
                      if (!showDelete) return;
                      setState(() {
                        deleteIndex = index;
                      });
                      await Future.delayed(Duration(milliseconds: 350));
                      setState(() {
                        mySelectValue.remove(mySelect[index]['name']);
                        mySelect.removeAt(index);
                        deleteIndex = null;
                      });
                    },
                    child: RotationTransition(
                        turns: _animationRot,
                        child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            reverseDuration: const Duration(milliseconds: 350),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(child: child, scale: animation);
                            },
                            child: index==mySelect.length?Visibility(
                              visible: false,
                              child: SizedBox(),
                            ): deleteIndex == index
                                ? Visibility(
                                    visible: false,
                                    child: SizedBox(),
                                  )
                                : Container(
                                    // key: ValueKey(mySelect[index]['name']),
                                    width: 50,
                                    height: 50,
                                    // padding: EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                       FittedBox(fit: BoxFit.fitWidth,child:  Text(mySelect[index]['name']),),//mySelect[index]['name']
                                        if (showDelete)
                                          Positioned(
                                            top: 1,
                                            right: 1,
                                            child: Icon(
                                              Icons.clear,
                                              size: 12,
                                            ),
                                          )
                                      ],
                                    )))));
              }),
              onReorder: (int _old, int _new) {
                Map t = mySelect[_old];
                mySelect.removeAt(_old);
                mySelect.insert(_new, t);
                print('$_old,$_new');
                setState(() {

                });
                MyGoodsType.change(mySelect);
              },
              onNoReorder: (int index) {
                //this callback is optional
                debugPrint('${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
              },
              onReorderStarted: (int index) {
                //this callback is optional
                debugPrint('${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
              }),
          Divider(
            thickness: 1,
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text('可选添加'),
          )
        ]..addAll(List.generate(allGoodsType.length, (index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  allGoodsType[index]['type'],
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: List.generate(
                      allGoodsType[index]['value'].length,
                      (index2) => InkWell(
                            onTap: () {
                              if (mySelectValue.contains(allGoodsType[index]['value'][index2])) {
                                Utils.showToast('已经添加');
                                return;
                              }
                              if (mySelect.length >= maxCount) {
                                Utils.showToast('最多添加$maxCount个');
                                return;
                              }
                              Map t = {"type": allGoodsType[index]['type'], "name": allGoodsType[index]['value'][index2]};
                             setState(() {
                               mySelect.add(t);
                               mySelectValue.add(allGoodsType[index]['value'][index2]);
                             });
                              MyGoodsType.change(mySelect);

                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              padding: EdgeInsets.symmetric(horizontal: 1.5),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.grey.withOpacity(0.25)),
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(allGoodsType[index]['value'][index2]),
                                  ),
                                  //  if(!mySelectValue.contains(allGoodsType[index]['value'][index2]))
                                  Positioned(
                                      top: 1,
                                      right: 1,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 350),
                                        reverseDuration: const Duration(milliseconds: 350),
                                        transitionBuilder: (Widget child, Animation<double> animation) {
                                          return ScaleTransition(child: child, scale: animation);
                                        },
                                        child: mySelectValue.contains(allGoodsType[index]['value'][index2])==true?Visibility(
                                          visible: false,
                                          child: SizedBox(),
                                        ):Icon(
                                          Icons.add,
                                          size: 12,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          )),
                ),
                SizedBox(
                  height: 10,
                )
              ],
            );
          })),
      ),
    );
  }
}
