import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class SlideBarLetterListener {

  factory SlideBarLetterListener.create() => LetterNotifier();

  ValueListenable<String> get slideLetter;
}
class LetterNotifier implements SlideBarLetterListener {
  @override
  final ValueNotifier<String> slideLetter = ValueNotifier(null);
}

const List<String> slideBarData = const [
  '↑',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '#'
];

class SliderBarPage extends StatefulWidget{
  final LetterNotifier letterNotifier;
  SliderBarPage({@required this.letterNotifier });
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
   return _SliderBarPageState();
  }
}

class _SliderBarPageState extends State<SliderBarPage>{
  double slideBarW=25.0;
  double slideBarH=15.0;
  double slideBarDy;
  double dialogTop;
  GlobalKey slideBarKey = GlobalKey();
  OverlayEntry overlayEntry;
  String overlayLetter;

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return buildSlideBar;
  }
  Widget get buildSlideBar{
    List<Widget> children = List.generate(slideBarData.length, (index) {
      return Container(
        width: slideBarW,
        height: slideBarH,
        alignment: Alignment.center,
        child: Text(slideBarData[index],style: TextStyle(fontSize: 11),),
      );
    });
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
//      onTap: (){
//        print('点击slide');
//      },

      onVerticalDragDown: (DragDownDetails details) {
        RenderBox renderBox=slideBarKey.currentContext.findRenderObject();
        Offset offset =  renderBox.localToGlobal(Offset.zero);
        slideBarDy = offset.dy;
        int index = (details.globalPosition.dy-slideBarDy)~/slideBarH;
        overlayLetter = slideBarData[index];
        dialogTop = details.globalPosition.dy;
        showLetterDialog();
        widget.letterNotifier.slideLetter.value=overlayLetter;


      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
       // print('onVerticalDragUpdate');
        bool isJump;
        int index = (details.globalPosition.dy-slideBarDy)~/slideBarH;
        if (index<0 || index >=slideBarData.length)return;
        overlayLetter = slideBarData[index];
        dialogTop = details.globalPosition.dy;
        showLetterDialog();
        widget.letterNotifier.slideLetter.value=overlayLetter;

      },
      onVerticalDragEnd: (DragEndDetails details) {
       // print('onVerticalDragEnd');
        overlayEntry?.remove();
        overlayEntry=null;

      },
      onVerticalDragCancel: () {

        overlayEntry?.remove();
        overlayEntry=null;
      },
      child: Column(
          key: slideBarKey,
          mainAxisSize: MainAxisSize.min,
           //mainAxisAlignment: MainAxisAlignment.center,
          children: children),
    );
  }
  void showLetterDialog(){
    if(overlayEntry==null){
      overlayEntry = new OverlayEntry(builder: (content) {
        return Stack(children: <Widget>[
          Positioned(
              right: slideBarW+5.0,
              top: dialogTop-slideBarH,
              child: Material(
                type: MaterialType.transparency,
                elevation: 10,
                child:  Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  alignment: Alignment.center,
                  child: Text(overlayLetter,style: TextStyle(color: Colors.white),),
                ),

              )
          )
        ],);
      });
      Overlay.of(context).insert(overlayEntry);

    }else{
      overlayEntry.markNeedsBuild();
    }
  }
}
