import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flustars/flustars.dart';
import 'package:cupertino_back_gesture/cupertino_back_gesture.dart';
import 'package:music_x/utils/colors.dart';
import 'package:music_x/utils/styles.dart';
import 'package:music_x/utils/global_data.dart';
import 'dart:async';
class EventProvider {
  int value = 1;
  Stream<ThemeData> intStream({flag:1}) {
    if(flag==1){
      var l = ThemeData.light();
       return Stream.value(l);
    }else{
      var l = ThemeData.dark();
      return Stream.value(l);
    }
    Duration interval = Duration(seconds: 2);
    // ThemeData  themeData = _themeData == ThemeData.light()?ThemeData.dark():ThemeData.light()
    return Stream<ThemeData>.periodic(interval, (int _count) => _count %2 == 0?ThemeData.light():ThemeData.dark() );
    //return Stream<int>.periodic(interval, (int _count) => _count %2 == 0? 11: 22  );
    // return Stream<int>.periodic(interval, (int _count) => _count++);
  }

}

class ThemeStream{
  static const Map<ThemeMode, String> themes = {
    ThemeMode.dark: 'Dark', ThemeMode.light : 'Light', ThemeMode.system : 'System'
  };
  static ThemeStream _instance;
  ThemeStream._internal() {
    print("_internal");
  }
  static ThemeStream _getInstance() {
    if (_instance == null) {
      _instance = ThemeStream._internal();
    }
    return _instance;
  }

  factory ThemeStream() => _getInstance();
  static ThemeStream get instance => _getInstance();


  StreamController<ThemeData> sc = StreamController.broadcast();
  int _count = 0;

  int get count => _count;
  Stream<ThemeData> get stream => sc.stream;
  Stream<ThemeData> intStream() {
    print('intStream++');

    return sc.stream;
  }
  add (obj) {
    print('count++ $obj');
    var type = obj['type'];
      var t= getTheme(mainColor:obj['main'] ,appBarColor: obj['appbar'],bottomNavColor: obj['bottom']);

    sc.sink.add(t);
  }
  dispose() {
    sc.close();
  }
  bool syncTheme() {
    print('provider 同步主题');
    String theme = SpUtil.getString(Constant.appTheme);
    return theme.isNotEmpty && theme != themes[ThemeMode.system];


  }

  ThemeMode getThemeMode(){
    String theme = SpUtil.getString(Constant.appTheme);
    print('ThemeStream get theme $theme');
    switch(theme) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  getTheme({bool isDarkMode= false,Color mainColor,Color appBarColor,Color bottomNavColor}) {
    print('ThemeStream 获取主题数据,$mainColor,$appBarColor');
    return ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            // for Android - default page transition
            TargetPlatform.android: CupertinoPageTransitionsBuilderCustomBackGestureWidth(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilderCustomBackGestureWidth(),
          },
        ),
        errorColor: Colors.red,//isDarkMode ? Colours.dark_red : Colours.red,
        brightness: isDarkMode ? Brightness.dark : Brightness.light, //深色还是浅色
        //primaryColor: isDarkMode ? Colours.dark_app_main : Colours.app_main, //主色，决定导航栏颜色
        accentColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
        // Tab指示器颜色
        indicatorColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
        // 页面背景色
        // scaffoldBackgroundColor: isDarkMode ? Colours.dark_page_color : dark_page_color,
        scaffoldBackgroundColor:mainColor !=null?mainColor:(isDarkMode ? Colours.dark_page_color : Colours.light_page_color),
        // 主要用于Material背景色
      backgroundColor: mainColor !=null?mainColor:(isDarkMode ? Colours.dark_page_color : Colours.light_page_color),
        //canvasColor: isDarkMode ? Colours.dark_material_bg : Colors.white,
        // 文字选择色（输入框复制粘贴菜单）
        textSelectionColor: Colours.app_main.withAlpha(70),
        textSelectionHandleColor: Colours.app_main,
//        textTheme: TextTheme(
//          // TextField输入文字颜色
//
//        ),
        inputDecorationTheme: InputDecorationTheme(
         // hintStyle: isDarkMode ? TextStyles.textHint14 : TextStyles.textDarkGray14,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          color:appBarColor!=null?appBarColor:isDarkMode ? Colours.dark_appBar_color : Colors.blue,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          color:bottomNavColor!=null?bottomNavColor:isDarkMode ? Colours.dark_appBar_color :Colours.bottom_nav_color,
        ),
        iconTheme: IconThemeData(
            color: isDarkMode?Colours.dark_page_color:Colors.blue
        ),
        dividerTheme: DividerThemeData(
          color: isDarkMode ? Colours.dark_line : Colours.line,
//          space: 0.6, // 控件高度
//          thickness: 0.6 // 线高
        ),
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        primaryIconTheme: isDarkMode ? const IconThemeData(color: Colors.red) : const IconThemeData(color: Colors.orange),
        accentIconTheme: isDarkMode ? const IconThemeData(color: Colors.red) : const IconThemeData(color: Colors.orange),

    );
  }
}


class ThemeProvider extends ChangeNotifier{
//  static ThemeProvider _instance;
//  ThemeProvider._internal() {
//    print("_internal");
//  }
//  static ThemeProvider _getInstance() {
//    if (_instance == null) {
//      _instance = ThemeProvider._internal();
//    }
//    return _instance;
//  }
//
//  factory ThemeProvider() => _getInstance();
//  static ThemeProvider get instance => _getInstance();

  //Color mainColor = Colors.white;
  static const Map<ThemeMode, String> themes = {
    ThemeMode.dark: 'Dark', ThemeMode.light : 'Light', ThemeMode.system : 'System'
  };

  void syncTheme() {
   // print('provider 同步主题');
    String theme = SpUtil.getString(Constant.appTheme);
    if (theme.isNotEmpty && theme != themes[ThemeMode.system]) {
      notifyListeners();
    }
  }
  void setTheme(ThemeMode themeMode) {
    SpUtil.putString(Constant.appTheme, themes[themeMode]);
    notifyListeners();
  }
  ThemeMode getThemeMode(){
    String theme = SpUtil.getString(Constant.appTheme);
    //print('provider get theme $theme');
    switch(theme) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }


  getTheme({bool isDarkMode= false}) {
  //  print('provider 获取主题数据');

    return ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                // for Android - default page transition
                TargetPlatform.android: CupertinoPageTransitionsBuilderCustomBackGestureWidth(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilderCustomBackGestureWidth(),
              },
            ),
        errorColor:Colors.red ,//isDarkMode ? Colours.dark_red : Colours.red,
        brightness: isDarkMode ? Brightness.dark : Brightness.light, //深色还是浅色
        cardColor: Color(0xffF08080),

        primaryColor: isDarkMode ? Colors.grey : Colours.app_main, //主色，决定导航栏颜色
        accentColor: isDarkMode ? Colors.grey : Colours.app_main, // 文本、按钮等前景色
        // Tab指示器颜色
        indicatorColor: isDarkMode ? Colors.grey : Colours.app_main,
        // 页面背景色
       scaffoldBackgroundColor: isDarkMode ? Colours.dark_page_color : Colours.light_page_color, // Material默认颜色
        backgroundColor: isDarkMode ? Colours.dark_page_color : Colours.wx_bg.withOpacity(0.98), // Material应用或应用内页面的背景颜色
        // 主要用于Material背景色
        canvasColor: isDarkMode ? Colours.dark_canvas_color :Colours.light_canvas_color,
        bottomAppBarColor:  isDarkMode ? Colours.dark_appBar_color : Colours.bottom_nav_color,
        splashColor:  isDarkMode ? Colours.dark_appBar_color : Colours.wx_bg, // 点击按钮时的渐变背景色
        // 文字选择色（输入框复制粘贴菜单）
        textSelectionColor: Colours.app_main.withAlpha(70),
        textSelectionHandleColor: Colours.app_main,
        primaryTextTheme: TextTheme(
          headline6:  isDarkMode ?TextStyles.headline6Dark : TextStyles.headline6,
          bodyText2: isDarkMode ? TextStyles.textDark : TextStyles.text,
        ),
//        primaryIconTheme:IconThemeData(
//          color: isDarkMode?Colours.dark_icon_color:Colors.black45,
//        ) ,



                textTheme: TextTheme(
//            headline1: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            headline2: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            headline6: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            headline3: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            headline4: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            headline5: isDarkMode ? TextStyles.textDark : TextStyles.text,
            subtitle1: isDarkMode ? TextStyles.subtitle1Dark : TextStyles.subtitle1, // listTile title
//            subtitle2: isDarkMode ? TextStyles.textDark : TextStyles.text,
            bodyText1:isDarkMode ? TextStyles.textDark : TextStyles.text,
            bodyText2:isDarkMode ? TextStyles.textDark : TextStyles.text,

          ),
        inputDecorationTheme: InputDecorationTheme(
//          hintStyle: isDarkMode ? TextStyles.textHint14 : TextStyles.textDarkGray14,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0.5,
          color: isDarkMode ? Colours.dark_appBar_color : Colours.app_main,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
          textTheme: TextTheme(
            bodyText1:isDarkMode ? TextStyles.textDark : TextStyles.text,
            bodyText2:isDarkMode ? TextStyles.textDark : TextStyles.text,
            headline6: isDarkMode ?TextStyles.headline6Dark : TextStyles.headline6,
          ),
          iconTheme: IconThemeData(
            color: isDarkMode?Colors.white70:Colors.white,
          ),

//          textTheme: TextTheme(
//            headline1: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            headline2: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            headline6: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            headline3: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            headline4: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            headline5: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            subtitle1: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            subtitle2: isDarkMode ? TextStyles.textDark : TextStyles.text,
//            bodyText1:isDarkMode ? TextStyles.textDark : TextStyles.text,
//            bodyText2:isDarkMode ? TextStyles.textDark : TextStyles.text,
//
//          )
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          color: isDarkMode ? Colours.dark_appBar_color : Colours.bottom_nav_color,
        ),
        iconTheme: IconThemeData(
          color: isDarkMode?Colours.dark_icon_color:Colors.black45,
        ),
        dialogTheme:DialogTheme(
            backgroundColor: isDarkMode?Colours.dark_page_color:Colors.white,
        ),
        //dialogBackgroundColor:Colors.transparent,
        popupMenuTheme: PopupMenuThemeData(
            color: isDarkMode?Colours.dark_appBar_color:Colors.white,
        ),
//        accentIconTheme: IconThemeData( // 废弃
//            color: isDarkMode?Colours.dark_page_color:Colors.blue
//        ),
//        primaryIconTheme: IconThemeData(
//            color: isDarkMode?Colours.dark_page_color:Colors.blue
//        ),
        dividerTheme: DividerThemeData(
          color: isDarkMode ? Colours.dark_line : Colours.line,

//          space: 0.6, // 控件高度
//          thickness: 0.6 // 线高
        ),
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
     // primaryIconTheme: isDarkMode ? const IconThemeData(color: Colors.red) : const IconThemeData(color: Colors.orange),
     // accentIconTheme: isDarkMode ? const IconThemeData(color: Colors.red) : const IconThemeData(color: Colors.orange),
      sliderTheme: SliderThemeData(
          trackHeight:10.0,
          thumbShape:RoundSliderThumbShape(enabledThumbRadius: 3),

      ),
      buttonTheme: ButtonThemeData(
        buttonColor: isDarkMode ?Colours.dark_appBar_color:Colours.app_main
      ),
//      floatingActionButtonTheme: FloatingActionButtonThemeData(
//        backgroundColor: isDarkMode ? Colours.dark_page_color : Colors.red
//      ),


    );
  }
}




