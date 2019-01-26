import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_app/auth/login_intro.dart';
import 'package:flutter_chat_app/auth/signup.dart';
import 'package:page_transition/page_transition.dart';

class AfterSplash extends StatefulWidget {
  @override
  _AfterSplashState createState() => _AfterSplashState();
}

class _AfterSplashState extends State<AfterSplash> {
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(top: 30.0),
                child: Hero(
                  tag: 'tag_1',
                  child: Text(
                    "Game of Chats",
                    style: Theme.of(context).
                    textTheme.
                    display1.
                    apply(
                      color: Colors.green,
                      fontWeightDelta: 100 ,
                      fontFamily: 'AppFont2',
                    ),
                  ),
                ),
              ),
            ),
            Text.rich(TextSpan(
                style: Theme.of(context).textTheme.display1.apply(color: Colors.black , fontWeightDelta: 50),
                children: [
                  TextSpan(text: 'Come ! \n'),
                  TextSpan(text: 'Lets make westeros\n'),
                  TextSpan(text: 'better than ever')
                ]
            )),
            Container(
              width: _width,
              padding: EdgeInsets.symmetric(horizontal: 30.0 , vertical: 10.0),
              child: RaisedButton(
                padding: EdgeInsets.all(15.0),
                color: Colors.green,
                onPressed: (){
                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SignUp() , duration: Duration(seconds: 1)));
                } ,
                shape: StadiumBorder(),
                child: Text(
                  'Aye , I\'m in',
                  style: Theme.of(context).textTheme.title.apply(color: Colors.white , fontWeightDelta: 100),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 30.0 , vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    Text('I\'ve already in that! ' , style: Theme.of(context).textTheme.subhead,),
                    InkWell(
                      splashColor: Colors.blue,
                      child: Text('Log in' , style: Theme.of(context).textTheme.subhead.apply(color: Colors.blue),),
                      onTap: (){
                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: LoginPage() , duration: Duration(seconds: 1)));
                      },
                    )
                  ],
                )
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Do you really want to exit the app?'),
          actions: <Widget>[
            FlatButton(
                onPressed: (){
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text('No')),
            FlatButton(
                onPressed: (){
                  SystemNavigator.pop();
                },
                child: Text('Yes')),
          ],
        )
    );
  }
}

