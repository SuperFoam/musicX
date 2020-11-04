import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:music_x/utils/cached_image.dart';
import 'package:music_x/utils/global_data.dart';
import 'package:music_x/widgets/local_or_network_image.dart';
class MusicListHeader extends StatelessWidget implements PreferredSizeWidget {
  MusicListHeader(this.count, {this.tail});

  final int count;

  final Widget tail;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        child: InkWell(
          onTap: () {
//            final list = MusicTileConfiguration.of(context);
//            if (context.player.queue.queueId == list.token && context.player.playbackState.isPlaying) {
//              //open playing page
//              Navigator.pushNamed(context, pagePlaying);
//            } else {
//              context.player.playWithQueue(PlayQueue(queue: list.queue, queueId: list.token, queueTitle: list.token));
//            }
          },
          child: SizedBox.fromSize(
            size: preferredSize,
            child: Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 16)),
                Icon(
                  Icons.play_circle_outline,
                  color: Theme.of(context).iconTheme.color,
                ),
                Padding(padding: EdgeInsets.only(left: 4)),
                Text(
                  "播放全部",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                Padding(padding: EdgeInsets.only(left: 2)),
                Text(
                  "(共$count首)",
                  style: Theme.of(context).textTheme.caption,
                ),
                Spacer(),
                tail,
              ]..removeWhere((v) => v == null),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class PlayListHeaderBackground extends StatelessWidget {
  final String imageUrl;
  final String type ;

  const PlayListHeaderBackground({Key key, @required this.imageUrl,this.type="network"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        FadeInImage(placeholder: AssetImage(Constant.defaultSongImage),image: xImage(urlOrPath: imageUrl),fit: BoxFit.cover, width: 120, height: 1),
        //Image(image: type=='network'?xImage(urlOrPath: imageUrl):AssetImage(imageUrl), fit: BoxFit.cover, width: 120, height: 1),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        Container(color: Colors.black.withOpacity(0.3))
      ],
    );
  }
}


class BlurBackground extends StatelessWidget {
  final String imageUrl;
  const BlurBackground({Key key, @required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image(
          image: xImage(urlOrPath: imageUrl),
          fit: BoxFit.cover,
          height: 15,
          width: 15,
          gaplessPlayback: true,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 14, sigmaX: 24),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.black26,
                    Colors.black45,
                    Colors.black87,
                  ],
                )),
          ),
        ),
      ],
    );
  }
}
