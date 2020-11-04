import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class EmojiText extends SpecialText {
  EmojiText(TextStyle textStyle, {this.start})
      : super(EmojiText.flag, ']', textStyle);
  static const String flag = '[emoji';
  final int start;
  @override
  InlineSpan finishText() {
    final String key = toString();

    ///https://github.com/flutter/flutter/issues/42086
    /// widget span is not working on web
    if (EmojiUtil.instance.emojiMap.containsKey(key) && !kIsWeb) {
      //fontsize id define image height
      //size = 30.0/26.0 * fontSize
      const double size = 20.0;

      ///fontSize 26 and text height =30.0
      //final double fontSize = 26.0;
      return ImageSpan(
          AssetImage(
            EmojiUtil.instance.emojiMap[key],
          ),
          actualText: key,
          imageWidth: size,
          imageHeight: size,
          start: start,
          fit: BoxFit.fill,
          margin: const EdgeInsets.only(left: 2.0, top: 2.0, right: 2.0));
    }

    return TextSpan(text: toString(), style: textStyle);
  }
}

class EmojiUtil {
  final Map<String, String> _emojiMap = new Map<String, String>();

  Map<String, String> get emojiMap => _emojiMap;

  final String _emojiFilePath = "assets/img/face/douyin";

  static EmojiUtil _instance;
  static EmojiUtil get instance {
    if (_instance == null) _instance = new EmojiUtil._();
    return _instance;
  }

  EmojiUtil._() {
    for (int i = 0; i < 141; i++) {
      _emojiMap["[emoji$i]"] = "$_emojiFilePath/$i.png";
    }
  }
}
