import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_app/splash/after_splash.dart';
import 'package:flutter_chat_app/home.dart';
import 'package:flutter_chat_app/splash/splash.dart';
import 'package:flutter_villains/villain.dart';
void main() => runApp(Main());

class Main extends StatelessWidget {
  final _themeData = ThemeData(
      fontFamily: 'AppFont',
      primarySwatch: Colors.green
  );

  final _routes = <String , WidgetBuilder>{
    '/aftersplash' : (BuildContext context) => AfterSplash(),
    '/home' : (BuildContext context) => HomePage()
  };

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.green,
        statusBarIconBrightness: Brightness.light
    ));

    return MaterialApp(
      title: 'Game of Chats',
      theme: _themeData,
      home: Splash(),
      debugShowCheckedModeBanner: false,
      routes: _routes,
      navigatorObservers: [new VillainTransitionObserver()],
    );
  }
}
