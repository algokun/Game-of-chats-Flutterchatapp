import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/home.dart';
import 'package:flutter_chat_app/auth/login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.green,
      body: Column(
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
                    color: Colors.white,
                    fontWeightDelta: 100 ,
                    fontFamily: 'AppFont2',
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: _width / 2,
            height: _height / 4,
            child: Card(
              elevation: 4.0,
              child: InkWell(
                onTap: () => _signIn(),
                splashColor: Colors.green,
                child: GridTile(
                  footer: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(color: Colors.lightGreen),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Sign in with Google" , style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
                    ),
                  ),
                  child: Icon(FontAwesomeIcons.google , size: 50.0, color: Colors.lightGreen,),
                ),
              ),
            ),
          ),
          Container(
            width: _width / 2,
            height: _height / 4,
            child: Card(
              elevation: 4.0,
              child: InkWell(
                onTap: (){
                  Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: Login() , duration: Duration(seconds: 2)));
                },
                splashColor: Colors.green,
                child: GridTile(
                  footer: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(color: Colors.redAccent),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Sign in with Phone" , style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
                    ),
                  ),
                  child: Icon(Icons.call , size: 50.0, color: Colors.redAccent,),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<FirebaseUser> _signIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
        idToken: gSA.idToken, accessToken: gSA.accessToken).then((fbUser){
      Firestore.instance.collection("users").document(fbUser.uid).setData({
        'name' : fbUser.displayName,
        'img' : fbUser.photoUrl,
        'uid' : fbUser.uid,
        'privacy' : false
      }).then((value){
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomePage(photoUrl: fbUser.photoUrl, displayName: fbUser.displayName,) , duration: Duration(seconds: 2)));
      });
    });
    return user;
  }
}
