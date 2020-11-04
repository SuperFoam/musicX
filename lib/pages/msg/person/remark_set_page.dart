import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_x/model/msg/person_info.dart';
import 'package:music_x/route/routes.dart';
import 'package:music_x/utils/local_storage.dart';
import 'package:music_x/utils/utils_function.dart';

class PersonInfoRemarkSetPage extends StatefulWidget {
  final String userId;

  PersonInfoRemarkSetPage({@required this.userId});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PersonInfoRemarkSetPageState();
  }
}
class _PersonInfoRemarkSetPageState extends State<PersonInfoRemarkSetPage> {
  PersonInfoModel personInfo;
  double paddingNum = 15.0;
  EdgeInsetsGeometry padding;
  double itemH = 60;
  double titleH = 30;
  Color color;
  bool isShowSave = false;
  String oldRemark;
  TextEditingController _remarkC = new TextEditingController();

  @override
  void initState() {
    padding = EdgeInsets.symmetric(horizontal: paddingNum);
    String userId = FluroConvertUtils.fluroCnParamsDecode(this.widget.userId);
    Map<String, dynamic> info = PersonInfoStorage.get(userId);
   // print('info is $info');
    personInfo = PersonInfoModel.fromJson(info);
    if(personInfo.remark!=null){
      _remarkC.text=personInfo.remark;
      oldRemark=personInfo.remark;
    }

    _remarkC.addListener(() {
      onInputChange();
    });
    super.initState();
  }

@override
  void dispose() {
    // TODO: implement dispose
  _remarkC.dispose();
    super.dispose();
  }
  void onInputChange(){
    String input = _remarkC.text.trim();
    bool isUpdate = false;
    if(input.length==0 ){
      if(isShowSave==true){
        isShowSave=false;
        isUpdate = true;
      }
    }else{
      if(input!=oldRemark && isShowSave==false){
        isShowSave=true;
        isUpdate = true;
      }
      else if(input==oldRemark && isShowSave==true){
        isShowSave=false;
        isUpdate = true;
      }
    }
    if(isUpdate==true)
      setState(() {

      });
  }

  @override
  Widget build(BuildContext context) {
    color=Theme.of(context).scaffoldBackgroundColor;
   return WillPopScope(
     onWillPop: (){
       Navigator.of(context).pop(_remarkC.text.trim());
       return new Future.value(true);
     },
     child:  Scaffold(
      // backgroundColor: Color(0xffededed),
       backgroundColor: Theme.of(context).splashColor,
       appBar: AppBar(
         title: Text('设置备注',style: TextStyle(color: Colors.black54),),
          titleSpacing: 0.0,
         iconTheme: IconThemeData(color: Colors.black54),
        // backgroundColor: Colors.white,
         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
         elevation: 1.0,
         actions: <Widget>[
           Container(
             width: 80,
             padding: EdgeInsets.all(10),
             child: RaisedButton(
               textColor:Colors.white,

               padding: EdgeInsets.all(1),
               onPressed: isShowSave?(){
                 PersonInfoStorage.put(personInfo.userId,'remark',_remarkC.text.trim());
                 Utils.showToast('保存成功');
                 FocusScope.of(context).unfocus();

               }:null,
               child: Text('保存'),
             ),
           )
         ],
       ),
       body:SingleChildScrollView(child:  Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: <Widget>[

           SizedBox(
             height: titleH,
           ),
           Container(
             padding: padding,
             color: color,
             height: itemH,
             child: input(title: '备注名',placeholder: '行走江湖 怎能没有一个小号',controller: _remarkC),
           ),
           SizedBox(
             height: titleH,
           ),

           Container(
             padding: padding,
             color: color,
             height: itemH,
             child: input(title: '标签',placeholder: '渣男渣女 贴个标签 谨防假冒'),
           ),
           SizedBox(
             height: titleH,
           ),
           Container(
             padding: padding,
             color: color,
             height: itemH,
             child: input(title: '生日',placeholder: '灵魂拷问 我生日哪天'),
           ),
           SizedBox(
             height: titleH,
           ),
           Container(
             padding: EdgeInsets.all(paddingNum),
             color: color,
             width: double.infinity,
             alignment: Alignment.center,
             child: FDottedLine(
               color: Colors.grey,
               strokeWidth: 1.0,
               dottedLength: 8.0,
               space: 3.0,
               corner: FDottedLineCorner.all(6.0),
               child: Container(
                 // color: Colors.blue[100],
                 // width: 130,
                 height: 100,
                 alignment: Alignment.center,
                 child: Text("添加日程成为时间管理大师",style: TextStyle(color: Colors.grey),),
               ),
             ),
           )


         ],),),
     ),
   );
  }
  Widget  input({String title,String placeholder,TextEditingController controller}){
    return TextField(
      controller: controller,
      maxLength: 20,
      decoration: InputDecoration(
        counterText: '',
        labelText: title,
          hintText:placeholder,
        hintStyle: TextStyle(fontSize: 16),
         border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 0)
      ),
    );
  }
}
