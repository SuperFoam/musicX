import 'package:flutter/cupertino.dart';
import 'package:music_x/utils/cached_image.dart';
import 'package:music_x/utils/global_data.dart';

xImage({String urlOrPath}) {
  if (urlOrPath == null) {
    return AssetImage(Constant.defaultSongImage);
  }
  if (urlOrPath.startsWith('http'))
    return  CachedImage('$urlOrPath?param=200y200');
  else
    return AssetImage(urlOrPath);
}

Widget xImgRoundRadius({String urlOrPath, double radius,bool smallSize=true,BoxFit fit=BoxFit.cover,String size='200y200'}) {
  if (radius == null) radius = 5.0;
  if (urlOrPath == null) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(Constant.defaultSongImage,fit: BoxFit.cover,));
  }
  if (urlOrPath.startsWith('http'))
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: FadeInImage(placeholder: AssetImage(Constant.defaultSongImage), image: CachedImage('$urlOrPath${smallSize==true?'?param=$size':''}'),
            fit: fit));
  else
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(urlOrPath,fit: BoxFit.cover));


}
