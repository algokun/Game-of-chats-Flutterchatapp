import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/home.dart';
import 'package:page_transition/page_transition.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isButtonEnabled = false;
  bool isOTPEnable = false;

  String phoneNo;
  String smsCode;
  String verificationId;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final _height  = MediaQuery.of(context).size.height ;
    final _width  = MediaQuery.of(context).size.width ;
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter your Mobile Number'),
      ),
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          SizedBox(height: 25.0,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25.0 , vertical: 10.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Container(
                  child: Image.asset("assets/flag.png"),
                  width: 30,
                ),
                prefixText: "+91",
                helperText: "You will receive an OTP on the mobile number you have entered",
                counterText: "",
              ),
              enabled: !isOTPEnable,
              autofocus: true,
              maxLength: 10,
              keyboardType: TextInputType.phone,
              onChanged: (value){
                setState(() {
                  this.phoneNo = value;
                });
                onChangedPhone(value);
              },
            ),
          ),
          Visibility(
            visible: isOTPEnable,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25.0 , vertical: 10.0),
              child: TextField(
                onChanged: (value) {
                  this.smsCode = value;
                },
                decoration: InputDecoration(
                    labelText: "OTP"
                ),
                maxLength: 6,
                keyboardType: TextInputType.phone,
              ),
            ),
          )
        ],
      ),
      bottomSheet: Material(
        color: Colors.green,
        child: Container(
          width: _width,
          height: _height / 12,
          child: RaisedButton(
            color: Colors.green,
            disabledColor: Colors.grey,
            child: Text(
              "Let me in!",
              style: Theme.of(context).textTheme.subhead.apply(color: Colors.white),
            ),
            onPressed: isButtonEnabled ? () => onButtonClick() : null,
          ),
        ),
      ),
    );
  }

  void createUser(){
    FirebaseAuth.instance.currentUser().then((user){
      if(user != null){
        if (user != null) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('/homepage');
        } else {
          if(smsCode.length == 6){
            FirebaseAuth
                .instance
                .signInWithPhoneNumber(verificationId: verificationId, smsCode: smsCode)
                .then((user) => print(user));
          }
        }
      }
    });
  }

  void onChangedPhone(String val){
    if(val.length == 10){
      setState(() {
        this.isButtonEnabled = true;
      });
    }
  }

  void onButtonClick(){
    if(isOTPEnable){
      createUser();
    }
    else{
      verifyPhone();
    }
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      setState(() {
        this.isOTPEnable = true;
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user) {
      onVerifyComplete();
    };

    final PhoneVerificationFailed verifyFailed = (AuthException exception) {
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text(exception.message))
      );
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91$phoneNo",
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: verifyFailed);
  }

  void onVerifyComplete(){
    BuildContext ctx = _scaffoldKey.currentContext;
    showDialog(
        context: ctx,
        builder: (ctx) => AlertDialog(
          title: Text('Success'),
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(width: 20.0,),
              Text('Signing in !!')
            ],
          ),
        )
    );
    Timer(
        Duration(seconds: 1),
            (){
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomePage() , duration: Duration(seconds: 2)));
        }
    );
  }
}
