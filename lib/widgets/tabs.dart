import 'package:flutter/material.dart';

class PrimaryTabIndicator extends UnderlineTabIndicator {
  PrimaryTabIndicator({Color color: Colors.white})
      : super(
            insets: const EdgeInsets.only(bottom: 4),
            borderSide: BorderSide(color: color, width: 2.0));
}

///网易云音乐风格的TabBar
class RoundedTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> tabs;
  final TabController tabController;

  const RoundedTabBar({Key key, @required this.tabs,@required this.tabController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: TabBar(
          controller:tabController ,
            indicator:
                PrimaryTabIndicator(color: Theme.of(context).primaryColor),
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Theme.of(context).primaryColor,
            tabs: tabs),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}

class RoundedTabBarDefault extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> tabs;

  const RoundedTabBarDefault({Key key, @required this.tabs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: TabBar(
            indicator:
            PrimaryTabIndicator(color: Theme.of(context).primaryColor),
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Theme.of(context).primaryColor,
            tabs: tabs),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}
