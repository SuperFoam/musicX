import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget xListTitle({Widget leading,@required String title,Widget subtitleIcon,String subtitle ,Widget trailing,GestureTapCallback onTap}){
  return ListTile(
    title:Row(
      children: <Widget>[
        if(leading!=null) leading,
        if(leading!=null) SizedBox(width: 5,),
        Expanded(flex: 1,child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title,style:TextStyle(fontSize: 14),maxLines: 1,overflow:TextOverflow.ellipsis,),
            Row(
              children: <Widget>[
                if(subtitleIcon!=null) subtitleIcon,
                if(subtitleIcon!=null) SizedBox(width: 5,),
                if(subtitle!=null) Expanded(flex: 1,child: Text(subtitle,style:TextStyle(color: Colors.grey,fontSize: 13),maxLines: 1,overflow:TextOverflow.ellipsis,),),
              ],
            )
          ],
        ),)

      ],
    ) ,
      trailing:trailing,
    onTap: onTap,
  );
}
class xListTitle2 extends StatelessWidget{
  xListTitle2({ this.leading,@required this.title, this.subtitleIcon, this.subtitle ,this.trailing});
  Widget leading;
  String title;
  Icon subtitleIcon;
  String subtitle;
  Widget trailing;

  @override
  Widget build(BuildContext context) {
    return  ListTile(
        title:  Row(
          children: <Widget>[
            if(leading!=null) leading,
            if(leading!=null) SizedBox(width: 5,),
            Expanded(flex: 1,child:   Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,maxLines: 1,overflow:TextOverflow.ellipsis,),
                Row(
                  children: <Widget>[
                    if(subtitleIcon!=null) subtitleIcon,
                    if(subtitleIcon!=null) SizedBox(width: 5,),
                    Text(subtitle,maxLines: 1,overflow:TextOverflow.ellipsis,),
                  ],
                )
              ],
            ),)

          ],
        ) ,

        trailing: trailing
    );
  }
}
