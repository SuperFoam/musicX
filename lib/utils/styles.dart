import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'global_data.dart';

class TextStyles {
  static const TextStyle textComment = const TextStyle(
    fontSize: 11.0,
    //color: Colors.black.withOpacity(0.5),
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    //height: 1.5,
    //wordSpacing: 2.0,
    shadows: <Shadow>[
      Shadow(
        //offset: Offset(0.0, 1.0),
        blurRadius: 0.5,
       // color: Color.fromARGB(255, 0, 0, 0),
      ),

    ],
  );
  static const TextStyle text14Grey =  const TextStyle(
    fontSize: 14,
    color: Colors.grey
  );
  static const TextStyle text11Grey =  const TextStyle(
      fontSize: 11,
      color: Colors.grey,
  );
  static const TextStyle text12Grey =  const TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
  static const TextStyle textSizeSM = const TextStyle(
      fontSize: Dimens.font_sp10,
  );
  static const TextStyle textSizeMD = const TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle textSize12 = const TextStyle(
    fontSize: Dimens.font_sp12,
  );
  static const TextStyle textSize16 = const TextStyle(
    fontSize: Dimens.font_sp16,
  );
  static const TextStyle textBold14 = const TextStyle(
    fontSize: Dimens.font_sp14,
    fontWeight: FontWeight.bold
  );
  static const TextStyle textBold16 = const TextStyle(
    fontSize: Dimens.font_sp16,
    fontWeight: FontWeight.bold
  );
  static const TextStyle textBold18 = const TextStyle(
    fontSize: Dimens.font_sp18,
    fontWeight: FontWeight.bold
  );
  static const TextStyle textBold24 = const TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold
  );
  static const TextStyle textBold26 = const TextStyle(
    fontSize: 26.0,
    fontWeight: FontWeight.bold
  );

  static const TextStyle textDialogTitle = const TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
   // color: Colors.black87
  );
  static const TextStyle textDialogName = const TextStyle(
      fontSize: 13.0,
      color: Colors.black54
  );
  static const TextStyle couponText = const TextStyle(
      fontSize: 12.0,
      color: Colours.coupon_text
  );

//  static const TextStyle textGray14 = const TextStyle(
//    fontSize: Dimens.font_sp14,
//    color: Colours.text_gray,
//  );
//  static const TextStyle textDarkGray14 = const TextStyle(
//    fontSize: Dimens.font_sp14,
//    color: Colours.dark_text_gray,
//  );

  static const TextStyle textWhite14 = const TextStyle(
    fontSize: Dimens.font_sp14,
    color: Colors.white,
  );
  static const TextStyle appbarCard = const TextStyle(
    fontSize: 15,
    color: Colors.white70,
    fontWeight: FontWeight.w100
  );

  static const TextStyle text = const TextStyle(
    fontSize: Dimens.font_sp14,
    color: Colours.light_text,
    textBaseline: TextBaseline.alphabetic
  );
  static const TextStyle primaryText = const TextStyle(
      fontSize: 20,
      color: Colours.light_text,
      fontWeight: FontWeight.w700,
      textBaseline: TextBaseline.alphabetic
  );

  static const TextStyle textDark = const TextStyle(
    fontSize: Dimens.font_sp14,
    color: Colours.dark_text,
    textBaseline: TextBaseline.alphabetic
  );

  static const TextStyle headline6Dark = const  TextStyle(
      fontSize: 21.0, fontWeight: FontWeight.w500,  color: Colours.dark_text,textBaseline: TextBaseline.ideographic
  );
  static const TextStyle headline6 = const  TextStyle(
      fontSize: 21.0, fontWeight: FontWeight.w500,  color: Colours.light_page_color,textBaseline: TextBaseline.ideographic
  );
  static const TextStyle subtitle1Dark = const  TextStyle(
       // fontSize: 19.0,
       color: Colours.dark_title_text,

  );
  static const TextStyle subtitle1 = const  TextStyle(
    // fontSize: 19.0,
    color: Colours.light_text,

  );
//
//  static const TextStyle textGray12 = const TextStyle(
//    fontSize: Dimens.font_sp12,
//    color: Colours.text_gray,
//    fontWeight: FontWeight.normal
//  );
//  static const TextStyle textDarkGray12 = const TextStyle(
//    fontSize: Dimens.font_sp12,
//    color: Colours.dark_text_gray,
//    fontWeight: FontWeight.normal
//  );
//
//  static const TextStyle textHint14 = const TextStyle(
//    fontSize: Dimens.font_sp14,
//    color: Colours.dark_unselected_item_color
//  );
}
