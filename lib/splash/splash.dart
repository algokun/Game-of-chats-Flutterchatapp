import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_chat_app/splash/after_splash.dart';
import 'package:flutter_chat_app/home.dart';
import 'package:flutter_chat_app/auth/update_info.dart';
import 'package:page_transition/page_transition.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final _assetName = "assets/bg.png";

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user){
      if(user == null){
        Timer(Duration(seconds: 4) , gotoLogin);
      }
      else{
       if(user.displayName.isEmpty){
         Timer(Duration(seconds: 4) , gotoProfile);
       }
       else{
         Timer(Duration(seconds: 4) , gotoHome);
       }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.5;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Hero(
              tag: 'tag_1',
              child: Text(
                "Game of Chats",
                style: Theme.of(context).
                textTheme.
                display2.
                apply(
                  color: Colors.green,
                  fontWeightDelta: 100 ,
                  fontFamily: 'AppFont2',
                ),
              ),
            ),
          ),
          Text(
            "Valar Dohaeris",
            style: Theme.of(context).
            textTheme.
            title.
            apply(
              color: Colors.green ,
              fontWeightDelta: 100 ,
              fontFamily: 'AppFont2',
            ),
          ),
          Image.asset(
            _assetName,
            color: Colors.green,
          )
        ],
      ),
    );
  }

  void gotoLogin(){
    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: AfterSplash() , duration: Duration(seconds: 2)));
  }
  void gotoHome(){
    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomePage() , duration: Duration(seconds: 2)));
  }
  void gotoProfile(){
    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: Profile() , duration: Duration(seconds: 2)));
  }
}

