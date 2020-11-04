import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_back_gesture/cupertino_back_gesture.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:music_x/provider/download_task.dart';
import 'package:music_x/provider/face.dart';
import 'package:music_x/provider/local_song.dart';
import 'package:music_x/provider/message_notice.dart';
import 'package:music_x/provider/music_card.dart';
import 'package:music_x/provider/provider.dart';
import 'package:music_x/provider/player.dart';
import 'package:music_x/provider/song_sheet_detail.dart';
import 'package:music_x/provider/song_sheet_list.dart';
import 'package:music_x/provider/user.dart';

import 'package:provider/provider.dart';
import 'package:fluro/fluro.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import './route/routes.dart';
import 'package:bot_toast/bot_toast.dart';





void main()  {
  debugPaintSizeEnabled = false;
  AudioPlayer.logEnabled = false;
  final textSize = 48;
  FluroRouter router = FluroRouter();
  Routes.configureRoutes(router);
  Application.router = router;
  runApp( MultiProvider(
    providers: [
      // Provider.value(value: textSize),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => MusicCardModel()),
      ChangeNotifierProvider(create: (_) => PlayerModel()..init()),
      ChangeNotifierProvider(create: (_)=> SongSheetModel(),),
      ChangeNotifierProvider(create: (_)=>SongSheetListModel()..init()),
      ChangeNotifierProvider(create: (_)=>DownLoadModel(),),
      ChangeNotifierProvider(create: (_)=>LocalSongModel(),),
      ChangeNotifierProvider(create: (_)=>FaceListProvider(),),
      ChangeNotifierProvider(create: (_)=>IMNoticeProvider()..updateMsgCount(),),
      ChangeNotifierProvider(create: (_)=>UserProvider(),),
      //StreamProvider(create: (_)=>ThemeStream().intStream(),initialData: null,)
    ],
    child: MainApp(),
  ));
//  runApp(OKToast(
//      radius: 7.0,
//      textPadding: EdgeInsets.all(10),
//      child:
//      MultiProvider(
//        providers: [
//          // Provider.value(value: textSize),
//          ChangeNotifierProvider(create: (_) => ThemeProvider()),
//          ChangeNotifierProvider(create: (_) => MusicCardModel()),
//          ChangeNotifierProvider(create: (_) => PlayerModel()..init()),
//          ChangeNotifierProvider(create: (_)=> SongSheetModel(),),
//          ChangeNotifierProvider(create: (_)=>SongSheetListModel()..init()),
//          ChangeNotifierProvider(create: (_)=>DownLoadModel(),),
//          ChangeNotifierProvider(create: (_)=>LocalSongModel(),),
//          //StreamProvider(create: (_)=>ThemeStream().intStream(),initialData: null,)
//        ],
//        child: MainApp(),
//      )
//  )
//  );

}
final botToastBuilder = BotToastInit();
class MainApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print('MainApp rebuild');
//    return BackGestureWidthTheme(
//      backGestureWidth: BackGestureWidth.fraction(1),
//      child: MaterialApp(
//          debugShowCheckedModeBanner: false,
////           theme: themeProvider.getTheme(isDarkMode: false),
//            themeMode: themeProvider.getThemeMode(),
//            darkTheme: themeProvider.getTheme(isDarkMode: true),
//          theme:  Provider.of<ThemeData>(context),
//          //themeMode: Provider.of<ThemeMode>(context),
//          //darkTheme:  ThemeStream().getTheme(isDarkMode: true),
//          initialRoute: '/',  //配置默认访问路径
//          onGenerateRoute:
//          Application.router.generator //onGenerateRoute,  //必须加上这一行，固定写法
//      ),
//    );
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return BackGestureWidthTheme(
        backGestureWidth: BackGestureWidth.fraction(1),
        child: MaterialApp(

            debugShowCheckedModeBanner: false,
            theme: themeProvider.getTheme(isDarkMode: false),
            themeMode: themeProvider.getThemeMode(),
            darkTheme: themeProvider.getTheme(isDarkMode: true),

//            theme: ThemeData.dark(),
//            themeMode: ThemeMode.dark,

            //theme:  Provider.of<ThemeData>(context),

            initialRoute: '/',
            //配置默认访问路径
            onGenerateRoute: Application.router.generator,
          //builder: BotToastInit(), //1.调用BotToastInit
          builder: (context, child) {
            child= ScrollConfiguration(
              child:  child,
              behavior: RefreshScrollBehavior(),
            );
//            child=Scaffold(
//              body: GestureDetector(
//                onTap: () {
//                  FocusScopeNode currentFocus = FocusScope.of(context);
//                  if (!currentFocus.hasPrimaryFocus &&
//                      currentFocus.focusedChild != null) {
//                    FocusManager.instance.primaryFocus.unfocus();
//                  }
//                },
//                child: child,
//              ),
//            );
            child = botToastBuilder(context,child);
            return child;
          },
          navigatorObservers: [BotToastNavigatorObserver()], //2.注册路由观察者
           // locale: const Locale("en", "US"),//设置这个可以使输入框文字垂直居中
            supportedLocales: [
              const Locale('zh','CH'),
              const Locale('en','US'),
            ],
             // supportedLocales: S.delegate.supportedLocales,
            localizationsDelegates: [
              //S.delegate,
              RefreshLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate
            ],
          localeResolutionCallback:
              (Locale locale, Iterable<Locale> supportedLocales) {
            //print("change language");
            return locale;
          },

            ),
      );
    });
  }
}
class RefreshScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    // When modifying this function, consider modifying the implementation in
    // _MaterialScrollBehavior as well.
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
        return child;
      case TargetPlatform.macOS:
      case TargetPlatform.android:
        return GlowingOverscrollIndicator(
          child: child,
          // this will disable top Bouncing OverScroll Indicator showing in Android
          showLeading: false, //顶部水波纹是否展示
          showTrailing: false, //底部水波纹是否展示
          axisDirection: axisDirection,
          notificationPredicate: (notification) {
            if (notification.depth == 0) {
              // 越界了拖动触发overScroll的话就没必要展示水波纹
              if (notification.metrics.outOfRange) {
                return false;
              }
              return true;
            }
            return false;
          },
          color: Theme.of(context).primaryColor,
        );
      case TargetPlatform.fuchsia:
    }
    return null;
  }
}
