import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/music.dart';
import 'package:music_x/utils/utils_function.dart';
import 'package:music_x/widgets/local_or_network_image.dart';

class GoodsSheetPage extends StatefulWidget {
  final String sheetName;

  GoodsSheetPage({@required this.sheetName});

  @override
  _GoodsSheetPageState createState() => _GoodsSheetPageState();
}

class _GoodsSheetPageState extends State<GoodsSheetPage> {
  String _sheetName;
  List sheetList=[];

  @override
  void initState() {
    _sheetName=FluroConvertUtils.fluroCnParamsDecode(widget.sheetName);
    print(_sheetName);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(mounted){
        initData();
      }
    });
  }
  void initData() async{
    var cancel =Utils.showLoading();
    List data =await GoodsSheetMusic(_sheetName).getGoodsSheet();
    cancel();
    if(data==null){
      Utils.showToast('数据获取失败');
      return;
    }
    setState(() {
      sheetList=data;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$_sheetName歌单'),),
      body: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: sheetList.length,
          cacheExtent: 60,
          itemBuilder: (context,int index){
        return ListTile(
          leading: Container(width: 50,height:50,child:xImgRoundRadius(urlOrPath: sheetList[index]['picUrl']) ,),
          title:  SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(sheetList[index]['title'],style: TextStyle(fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis,),
          ),
          subtitle: Row(children: <Widget>[
            Icon(Icons.queue_music,size: 14,),
            Text('${sheetList[index]['count']}首'),
            SizedBox(width: 10,),
            Icon(Icons.headset,size: 14,),
            Text(getFormattedNumber(sheetList[index]['playCount'])+'播放')
          ],),
          trailing: Icon(Icons.arrow_forward_ios,size: 18,),
          onTap: (){
            Map t={
              'title':sheetList[index]['title'],
              'subtitle':sheetList[index]['username'],
              'image':sheetList[index]['picUrl'],
              'id':sheetList[index]['id'].toString(),
              'isSheet':true,
            };
            NavigatorUtil.goNetworkSongSheetPage(context, t);
          },
        );
      }),
    );
  }
}
