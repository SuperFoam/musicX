//import 'package:flutter/material.dart';
//import 'package:music_x/utils/utils_function.dart';
//
//class RoundImgWidget extends StatelessWidget {
//  final String img;
//  final double width;
//  final BoxFit fit;
//
//  RoundImgWidget(this.img, this.width, {this.fit});
//
//  @override
//  Widget build(BuildContext context) {
//    return ClipRRect(
//      borderRadius: BorderRadius.circular(width / 2),
//      child: img.startsWith('http')
//          ? Utils.showNetImage(img,
//              width:width,
//              height: width,
//              fit: fit)
//          : Image.asset(img, fit: fit,),
//    );
//  }
//}
