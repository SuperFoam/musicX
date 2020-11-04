import 'dart:math';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class myCanvas extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    final _paint = Paint()..color=Colors.blue..isAntiAlias = true..strokeWidth = 2.0;
    Offset x = Offset(10,0);
    Offset y = Offset(10,10);
    canvas.drawLine(x, y, _paint);

    canvas.drawPoints(
      ///PointMode的枚举类型有三个，points（点），lines（线，隔点连接），polygon（线，相邻连接）
        PointMode.polygon,
        [
          Offset(20.0, 130.0),
          Offset(100.0, 210.0),
          Offset(100.0, 310.0),
          Offset(200.0, 310.0),
          Offset(200.0, 210.0),
          Offset(280.0, 130.0),
          Offset(20.0, 130.0),
        ],
        _paint..color = Colors.redAccent);
    canvas.drawCircle(
        Offset(100.0, 350.0),
        30.0,
        _paint
          ..color = Colors.greenAccent
          ..style = PaintingStyle.stroke //绘画风格改为stroke
    );

    Rect rect = Rect.fromCircle(center: Offset(100.0, 150.0), radius: 20.0); // 边长
    //根据上面的矩形,构建一个圆角矩形
    RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(0.0)); //边角
    canvas.drawRRect(rrect, _paint);

    Path path = new Path()..moveTo(100.0, 100.0);

    path.lineTo(200.0, 200.0);
    path.lineTo(100.0, 300.0);
    path.lineTo(150.0, 350.0);
    path.lineTo(150.0, 500.0);
    canvas.drawPath(path, _paint);

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


class ChatBubbleTriangle extends CustomPainter { //单纯绘制三角形
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Color(0xFF486993);

    var path = Path();
    path.lineTo(-15, 0);
    path.lineTo(0, -15);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
class TrianglePainter extends CustomPainter{ /// 绘制三角形

  Color color; //填充颜色
  Paint _paint;//画笔
  Path _path;  //绘制路径
  double angle;//角度

  TrianglePainter(this.color){
    _paint = Paint()
      ..strokeWidth = 1.0 //线宽
      ..color = color
      ..isAntiAlias = true;
    _path = Path();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final baseX = size.width * 0.5;
    final baseY = size.height * 0.5;
    //起点
    _path.moveTo(baseX - 0.86 * baseX, 0.5 * baseY);
    _path.lineTo(baseY, 1.5 * baseY);
    _path.lineTo(baseX + 0.86 *baseX, 0.5*baseY);
    canvas.drawPath(_path,_paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }

}

enum _TailDirection { right, left,bottom }

class ChatBubblePainter extends CustomPainter {
  ChatBubblePainter(this.color, this.direction);

  final Color color;
  final String direction;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    Path paintBubbleTail( direction) {
      double pointX,pointY,x1,y1,x2,y2,x3,y3;
      if (direction =='right') {
        pointX = size.width - 5;
        pointY = size.height;
        x1 = size.width + 10;
        y1 = size.height;
        x2 =  size.width + 3;
        y2 = size.height;
        x3 = size.width;
        y3 = size.height - 10;

      }else if (direction =='rightTop') {
        pointX = size.width - 5;
        pointY = 0.0;
        x1 = size.width + 10;
        y1 = 0.0;
        x2 =  size.width + 3;
        y2 = 0.0;
        x3 = size.width;
        y3 = 10;

      }
      else if(direction == 'bottom'){
        pointX = size.width;
        pointY = size.height-5;
        x1= size.width ;
        y1 = size.height+10 ;
        x2 = size.width ;
        y2 = size.height+5;
        x3 =  size.width-10;
        y3 = size.height;
      } else if (direction == 'left') {
        pointX =  5;
        pointY = size.height;
        x1 =  -10;
        y1 = size.height;
        x2 =  - 3;
        y2 = size.height;
        x3 = 0;
        y3 = size.height - 10;
      }else if (direction == 'leftTop') {
        pointX =  5;
        pointY = 0.0;
        x1 =  -10;
        y1 =0.0;
        x2 =  - 3;
        y2 = 0.0;
        x3 = 0;
        y3 = 10;
      }else if (direction == 'bottom3/4'){
        var t = size.width*0.65;
        pointX = t;
        pointY = size.height;
        x1= t -1;
        y1 = size.height+10 ;
        x2 = t ;
        y2 = size.height+5;
        x3 =  t-10;
        y3 = size.height;
      }
      return Path()
        ..moveTo(pointX, pointY)
        ..lineTo(x1, y1)
        ..quadraticBezierTo(x2, y2, x3, y3);

    }

    final RRect bubbleBody = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(5.0));
    final Path bubbleTail =paintBubbleTail(direction);
    canvas.drawRRect(bubbleBody, paint);
    canvas.drawPath(bubbleTail, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class CouponPaint extends CustomPainter{ // 优惠券

  Color color; //填充颜色
  Paint _paint;//画笔
  Path _path;  //绘制路径
  double angle;//角度
  int count = 6;

  CouponPaint(this.color){
    _paint = Paint()
      ..strokeWidth = 1.0 //线宽
      ..color = color
      ..style=PaintingStyle.stroke
      ..isAntiAlias = true;
    _path = Path();
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset p1 = Offset(0,0);
    Offset p2 = Offset(size.width,0);
    Offset p3 = Offset(0,size.height);
    Offset p4 = Offset(size.width,size.height);
    _path.moveTo(0, 0);
    _path.lineTo(size.width, 0);
    double h=size.height/count;
    for(int i=1;i<=count;i++){
      if(i.isOdd)  _path.lineTo(size.width-5, h*i);
      else _path.lineTo(size.width, h*i);
    }
   // _path.lineTo(size.width, size.height);
    _path.lineTo(0, size.height);
    for(int i=count;i>=1;i--){
      if(i.isEven) _path.lineTo(5, h*(i-1));
      else _path.lineTo(0, h*(i-1));
    }
    canvas.drawPath(_path, _paint);


  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }

}

class CouponPaintLeft extends CustomPainter{

  Color color; //填充颜色
  Paint _paint;//画笔
  Path _path;  //绘制路径
  double angle;//角度
  int count = 8;

  CouponPaintLeft(this.color){
    _paint = Paint()
      ..strokeWidth = 1.0 //线宽
      ..color = color
  //..style = PaintingStyle.stroke
     // ..strokeJoin=StrokeJoin.round
      ..isAntiAlias = true;
    _path = Path();
  //  _path.fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const PI = math.pi;
    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    final Gradient gradient = new LinearGradient(
      colors: <Color>[
        Colors.blueGrey,
        Colors.grey,
      ],
    );
    _paint.shader=gradient.createShader(rect);
    _path.moveTo(0, 0);
    _path.lineTo(size.width, 0);
    double h=size.height/count;

    _path.lineTo(size.width, size.height);
    _path.lineTo(0, size.height);

    double r=h/2;

//    for(int i=0;i<count;i++){
//      double y = r*(2*i+1);
//      Rect rect2 = Rect.fromCircle(center: Offset(0, y), radius: r);
//      canvas.drawArc(rect2, 3*PI/2, PI , false, _paint);
//
//    }

    for(int i=count-1;i>=0;i--){
      double y = r*(2*i+1);
     // Rect rect2 = Rect.fromCircle(center: Offset(0, y), radius: r);
     // _path.arcTo(rect2,  -3*PI/2,  -PI, false); // 圆
      _path.quadraticBezierTo(r, y, 0, y-r); // 椭圆

    }
    canvas.drawPath(_path, _paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }

}

class PersonPaint extends CustomPainter{ // 个人中心

  Color color; //填充颜色
  Paint _paint;//画笔
  Path _path;  //绘制路径
  double angle;//角度
  int count = 8;
  double top;

  PersonPaint(this.color,this.top){
    _paint = Paint()
      ..strokeWidth = 1.0 //线宽
      ..color = color
   // ..style = PaintingStyle.stroke
     ..strokeJoin=StrokeJoin.round
      ..isAntiAlias = true;
    _path = Path();
    //  _path.fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const PI = math.pi;
    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    final Gradient gradient = new LinearGradient(
      begin: Alignment.center,
      end: Alignment(1, 0.5), // 10% of the width, so there are ten blinds.
     // tileMode: TileMode.mirror, // repeats the gradient over the canvas
      colors: <Color>[
        Colors.blueGrey,
        Colors.grey,

      ],
      //stops: [0.1, 1],
    );
    _paint.shader=gradient.createShader(rect);
    _path.moveTo(0, 0);
    _path.lineTo(size.width, 0);

    double r2= 15.0;

//    double h1=size.height/2-r2; //椭圆
//    _path.lineTo(size.width, h1);
//    _path.quadraticBezierTo(size.width-r2-r2/2, h1+r2, size.width, h1+2*r2);
//    _path.lineTo(size.width, size.height);

    double h1=size.height/2+top/2;
    _path.lineTo(size.width, h1);
    _path.cubicTo(size.width-r2*3/4, h1-r2,    size.width-r2-r2/2, h1-r2+r2/4,     size.width-r2, h1);
    _path.cubicTo( size.width-r2-r2/2, h1+r2-r2/4, size.width-r2*3/4, h1+r2, size.width, h1);
    _path.lineTo(size.width, size.height);

    double r3=30; //中间半圆
    _path.lineTo(size.width/2+r3, size.height);
    Rect rect2 = Rect.fromCircle(center: Offset(size.width/2, size.height), radius: r3);
    _path.arcTo(rect2, 0.0, -PI , false,);


//    _path.lineTo(0, size.height); //椭圆
//    double h2=size.height/2+r2;
//    _path.lineTo(0, h2);
//    _path.quadraticBezierTo(r2+r2/2, h2-r2, 0, h2-2*r2);
//    _path.lineTo(0, 0);

    _path.lineTo(0, size.height); //爱心
    double h3 = size.height/2+top/2;
    _path.lineTo(0, h3);
    _path.cubicTo(r2*3/4, h3+r2, r2+r2/2, h3+r2-r2/4, r2, h3);
    _path.cubicTo(r2+r2/2, h3-r2+r2/4, r2*3/4, h3-r2, 0, h3);
    _path.lineTo(0, 0);
    canvas.drawPath(_path, _paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}
class VoiceWavePaint extends CustomPainter{ // 录音波浪
  Paint _paint;//画笔
  Path _path;  //绘制路径
  double waveH = 12;
  int semiCircle=5;

  VoiceWavePaint(this.waveH){
    _paint = Paint()
      ..strokeWidth = 1.0 //线宽
      ..color = Colors.blue
     ..style = PaintingStyle.fill
      ..strokeJoin=StrokeJoin.round
      ..isAntiAlias = true;
    _path = Path();
  }
  @override
  void paint(Canvas canvas, Size size){
    double side = size.width;
    double radius = side / (semiCircle*2);
    waveH = min(waveH,20-waveH%20);
    //print('waveH is $waveH');
   bool waveHisEven = waveH.toInt().isEven;
    double tH;
    int t;
    int t2;
    for (int i = 0; i <semiCircle; i ++) {
       t = 2*i+1;
       t2 = 2*(i+1);
        if(waveHisEven)
           tH=i.isEven?-waveH:waveH;
        else
           tH=i.isEven?waveH:-waveH;
      _path.quadraticBezierTo(radius*t, tH, radius*t2, 0);

    }
    _path.lineTo(size.width, 0);
    _path.lineTo(size.width, size.height);
    _path.lineTo(0, size.height);
    _path.lineTo(0, 0);
    canvas.drawPath(_path, _paint);



  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}


